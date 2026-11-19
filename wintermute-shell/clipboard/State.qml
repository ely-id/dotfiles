pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import ".."
import "Clipboard.js" as Clipboard

// O histórico da área de transferência (ficha 18, F6-T16). É a superfície que a peça lê (decisão 0011); demo/ClipboardService.qml tem
// os mesmos nomes. Cada item é { id, kind, title, text, source, time, pinned, pinnedTime, image: { url, width, height, format, bytes,
// path, hash }, color, linkTitle }, do mais novo para o mais antigo. `now` é o relógio da peça para o tempo relativo, em milissegundos.
//
// Como escuto: dois processos de vida longa, `wl-paste --type text --watch` e `wl-paste --type image/png --watch`, que chamam o
// clipboard/watch.py uma vez por mudança. O `watch.py` escreve uma linha de JSON por item e este arquivo a lê e entrega a `ingest`.
// Os processos só começam em `start()`, que o shell.qml chama; importar este singleton (a vitrine, a bancada, o launcher) não liga
// nada. A conta (classificar, guardar, cortar, fixar) é do Clipboard.js; aqui ficam os processos, o relógio e os comandos.
//
// O histórico vive só na sessão (P-17): nada é lido nem gravado entre uma sessão e outra. As imagens ficam em
// $XDG_RUNTIME_DIR/wintermute-shell/clipboard/, que é memória e some ao sair; o texto fica só em `items`. Como a lista some quando a
// shell reinicia e os arquivos não, `start()` limpa essa pasta (`watch.py sweep`) antes de ligar as escutas.
Singleton {
  id: root

  property var items: []
  readonly property real now: clock.now

  // ---- Tetos ----
  // 50 itens não fixados: é a resposta da P-17. Os fixados não contam e não saem.
  property int maxItems: 50
  // Os três números abaixo são a proposta da F6-T16 para o teto de memória, e não valor de desenho: a P-17 não fechou o teto das
  // imagens. Texto com mais de 1 MB não entra; PNG com mais de 16 MB não entra; a soma das imagens guardadas não passa de 64 MB,
  // e quando passa saem primeiro as imagens não fixadas mais antigas.
  property int maxTextBytes: 1024 * 1024
  property int maxImageBytes: 16 * 1024 * 1024
  property real maxImagesTotalBytes: 64 * 1024 * 1024

  // ---- Limites técnicos, não de desenho ----
  // Um aviso de origem (`expect`) vale para o próximo item que chegar em até este tempo, em ms.
  property int expectWindow: 1000
  // O `wl-paste` que sai antes disto, em ms, não conseguiu começar (sem o protocolo de controle de dados, sem o programa): um aviso
  // no log e nada de tentar de novo. O que sai depois disto é tentado de novo, no máximo `maxRestarts` vezes, `restartDelay` ms depois.
  property int startupGrace: 3000
  property int maxRestarts: 3
  property int restartDelay: 2000
  // A limpeza da pasta das imagens que não termina em até este tempo, em ms, é dada como falha e as escutas ligam sem ela.
  property int sweepTimeout: 3000
  // O argumento mais comprido que o sistema aceita no `wl-copy -- texto` é de 131072 bytes (MAX_ARG_STRLEN); acima de 100000 o texto
  // vai pela entrada padrão.
  property int argvLimit: 100000

  // Onde as imagens ficam (o `watch.py` grava aqui e só o que está aqui é apagado), e os dois scripts.
  property string imageDir: {
    const runtime = Quickshell.env("XDG_RUNTIME_DIR") || "";
    return runtime === "" ? "" : runtime + "/wintermute-shell/clipboard";
  }
  readonly property string watcher: decodeURIComponent(Qt.resolvedUrl("watch.py").toString().replace(/^file:\/\//, ""))
  readonly property string imageHelper: decodeURIComponent(Qt.resolvedUrl("../screenshot/clipboard.py").toString().replace(/^file:\/\//, ""))

  // ---- Ganchos que o teste troca ----
  // `sweepImages(pasta, pronto)` roda a limpeza do `watch.py sweep` e chama `pronto()` quando ela termina, bem ou mal.
  // `exec` roda um comando sem esperar (o wl-copy fica vivo servindo a área de transferência, o rm do arquivo de uma imagem);
  // `execInput` roda um comando e escreve `data` na entrada padrão dele; `focusedApp` diz quem está em foco; `clockMs` é o relógio.
  property var exec: argv => Quickshell.execDetached(argv)
  property var execInput: (argv, data) => {
    inputRunner.createObject(root, { command: argv, data: data }).running = true;
  }
  property var sweepImages: (directory, done) => {
    sweepRunner.createObject(root, { command: ["python3", root.watcher, "sweep", "--dir", directory], done: done }).running = true;
  }
  // { name, terminal } da janela em foco (o nome pela entrada .desktop, e `terminal` se ela é um TerminalEmulator), ou null sem janela.
  property var focusedApp: () => {
    const window = NiriMsg.focusedWindow();
    if (!window || window.appId === "")
      return null;
    const entry = DesktopEntries.heuristicLookup(window.appId);
    return {
      name: entry && entry.name ? String(entry.name) : window.appId,
      terminal: !!entry && Array.from(entry.categories || []).indexOf("TerminalEmulator") >= 0
    };
  }
  property var clockMs: () => Date.now()
  // O programa que escuta a área de transferência (wl-clipboard); o teste aponta para um que não existe, ou para um de mentira.
  property string pasteProgram: "wl-paste"

  property bool started: false
  property bool watching: false
  // Um aviso só por sessão, o do primeiro processo que não consegue escutar.
  property bool warned: false
  property int sequence: 0
  // O aviso de quem vai copiar: { name, until } valendo para o próximo item que chegar.
  property var pendingOrigin: null

  function warnOnce(message) {
    if (warned)
      return;
    warned = true;
    console.warn("clipboard: " + message);
  }

  // Liga a escuta. Quem chama é o shell.qml; sem o `wl-paste` (ou sem o protocolo de controle de dados, como no GNOME) o histórico
  // fica vazio e sai uma linha de aviso. Antes de ligar, limpo a pasta das imagens: o histórico em memória some quando a shell
  // reinicia, mas os arquivos ficam até o logout e nenhum item apontaria para eles. As escutas só ligam depois da limpeza, e ligam
  // do mesmo jeito se ela falha ou demora mais que `sweepTimeout`.
  function start() {
    if (started)
      return;
    started = true;
    warmEntries();
    if (imageDir === "") {
      beginWatching();
      return;
    }
    sweepGuard.restart();
    try {
      sweepImages(imageDir, beginWatching);
    } catch (error) {
      beginWatching();
    }
  }

  // Liga as duas escutas, uma vez só (a limpeza pode chamar mais de uma vez: o fim dela e o prazo).
  function beginWatching() {
    if (watching)
      return;
    watching = true;
    sweepGuard.stop();
    textWatch.begin();
    if (imageDir === "")
      warnOnce("sem XDG_RUNTIME_DIR não guardo imagens; só escuto texto");
    else
      imageWatch.begin();
    startCheck.restart();
  }

  // As entradas .desktop (o nome e a categoria da janela de origem) são lidas na primeira vez que alguém as pede e levam um ou dois segundos.
  // Peço já no começo, para o primeiro item da sessão (o que já estava na área de transferência) não cair no `appId` cru.
  function warmEntries() {
    return DesktopEntries.applications.values.length;
  }

  function watchExited(kind, startedAt, restarts, code) {
    const ranFor = clockMs() - startedAt;
    if (ranFor < startupGrace) {
      warnOnce("o wl-paste (" + kind + ") saiu logo, com código " + code + ". Sem o protocolo de controle de dados da área de "
          + "transferência (como no GNOME) ou sem o programa, o histórico fica vazio. Não tento de novo.");
      return false;
    }
    if (restarts >= maxRestarts) {
      warnOnce("o wl-paste (" + kind + ") parou de novo, com código " + code + ". Deixo de escutar.");
      return false;
    }
    return true;
  }

  Process {
    id: textWatch
    property double startedAt: 0
    property int restarts: 0
    // Verdadeiro quando o processo chegou a começar. Sem o programa o `exited` nem vem; quem avisa é o `startCheck`.
    property bool live: false
    onStarted: live = true
    command: [root.pasteProgram, "--type", "text", "--watch", "python3", root.watcher, "text", "--max-bytes", String(root.maxTextBytes)]
    stdout: SplitParser { onRead: line => root.handleLine(line) }
    stderr: StdioCollector {}
    onExited: code => {
      if (root.watchExited("text", textWatch.startedAt, textWatch.restarts, code)) {
        textWatch.restarts += 1;
        textRestart.start();
      }
    }
    function begin() {
      startedAt = root.clockMs();
      running = true;
    }
  }

  Process {
    id: imageWatch
    property double startedAt: 0
    property int restarts: 0
    property bool live: false
    onStarted: live = true
    command: [root.pasteProgram, "--type", "image/png", "--watch", "python3", root.watcher, "image", "--max-bytes", String(root.maxImageBytes),
        "--dir", root.imageDir]
    stdout: SplitParser { onRead: line => root.handleLine(line) }
    stderr: StdioCollector {}
    onExited: code => {
      if (root.watchExited("image", imageWatch.startedAt, imageWatch.restarts, code)) {
        imageWatch.restarts += 1;
        imageRestart.start();
      }
    }
    function begin() {
      startedAt = root.clockMs();
      running = true;
    }
  }

  // Um segundo depois de `start()`: o programa que não existe não chega a começar nem a sair, e então avisa daqui (uma vez só).
  Timer {
    id: startCheck
    interval: 1000
    onTriggered: {
      if (!textWatch.live && !textWatch.running)
        root.warnOnce("não consegui iniciar o " + root.pasteProgram + " (sem o programa, instale o wl-clipboard). O histórico fica vazio.");
    }
  }

  // O prazo da limpeza: se o `python3` não existe o processo nem chega a sair, e as escutas não podem ficar esperando para sempre.
  Timer {
    id: sweepGuard
    interval: root.sweepTimeout
    onTriggered: root.beginWatching()
  }

  Timer {
    id: textRestart
    interval: root.restartDelay
    onTriggered: textWatch.begin()
  }

  Timer {
    id: imageRestart
    interval: root.restartDelay
    onTriggered: imageWatch.begin()
  }

  // A limpeza da pasta das imagens (`watch.py sweep`): chama `done` quando o processo sai, com o código que for.
  Component {
    id: sweepRunner
    Process {
      id: sweeper
      property var done: null
      onExited: {
        if (sweeper.done)
          sweeper.done();
        sweeper.destroy();
      }
    }
  }

  // Um comando com o texto na entrada padrão (o `wl-copy` de um texto grande demais para o argumento).
  Component {
    id: inputRunner
    Process {
      id: runner
      property string data: ""
      stdinEnabled: true
      onStarted: {
        runner.write(runner.data);
        runner.stdinEnabled = false;
      }
      onExited: runner.destroy()
    }
  }

  // Uma linha do `watch.py`. Linha que não é JSON some em silêncio: nunca registro o que veio nela, que pode ser o que copiei.
  function handleLine(line) {
    let event = null;
    try {
      event = JSON.parse(line);
    } catch (error) {
      return;
    }
    ingest(event);
  }

  // O aviso de quem vai copiar: a shell chama `expect("Screenshot")` antes de copiar, e o próximo item que chegar em até
  // `expectWindow` ms leva esse nome como origem (e só ele). O seletor de cor avisa "Color picker", a captura e o editor de anotação
  // "Screenshot", e as outras cópias do launcher (emoji, cálculo) "Launcher".
  function expect(name) {
    pendingOrigin = { name: String(name), until: clockMs() + expectWindow };
  }

  // A origem do item que chegou: o aviso, se ainda vale; senão a janela em foco; sem janela, vazia ("Unknown" nos metadados). A
  // área de transferência do Wayland não diz quem copiou, então a janela em foco pode errar (o aplicativo copiou em segundo plano).
  function takeOrigin(time) {
    const expected = pendingOrigin;
    pendingOrigin = null;
    if (expected && time <= expected.until)
      return { name: expected.name, terminal: false };
    const app = focusedApp();
    return app ? { name: app.name || "", terminal: !!app.terminal } : { name: "", terminal: false };
  }

  function nextId() {
    sequence += 1;
    return "h" + sequence;
  }

  // Um item que o `watch.py` entregou: { type: "text", text } ou { type: "image", path, width, height, bytes, hash }. Entra no topo, ou,
  // se o conteúdo já estava, o que estava sobe com a hora nova e mantém o fixado e a origem. Devolve o item, ou null se não entrou.
  function ingest(event) {
    if (!event || typeof event !== "object")
      return null;
    const time = clockMs();
    let entry = null;
    if (event.type === "text") {
      const text = typeof event.text === "string" ? event.text : "";
      if (text.trim() === "" || Clipboard.utf8Length(text) > maxTextBytes)
        return null;
      const origin = takeOrigin(time);
      const kind = Clipboard.classify(text, origin.terminal);
      entry = {
        id: nextId(), kind: kind.kind, title: kind.title, text: text, source: origin.name, time: time,
        pinned: false, pinnedTime: 0, image: null, color: kind.color, linkTitle: ""
      };
    } else if (event.type === "image") {
      const hash = String(event.hash || "");
      const bytes = Number(event.bytes);
      const width = Number(event.width);
      const height = Number(event.height);
      // Só aceito o arquivo que o `watch.py` grava (`<hash>.png` na pasta do histórico): é o único que depois eu apago.
      if (!/^[0-9a-f]{8,128}$/.test(hash) || String(event.path) !== imageDir + "/" + hash + ".png"
          || !Clipboard.isOwnFile(imageDir, event.path))
        return null;
      if (!(bytes > 0) || bytes > maxImageBytes || !(width >= 1) || !(height >= 1))
        return null;
      const origin = takeOrigin(time);
      entry = {
        id: nextId(), kind: "image", title: Clipboard.imageTitle(origin.name === "Screenshot", time), text: "", source: origin.name,
        time: time, pinned: false, pinnedTime: 0, color: "", linkTitle: "",
        image: { url: "file://" + encodeURI(event.path), width: width, height: height, format: "PNG", bytes: bytes,
            path: String(event.path), hash: hash }
      };
    } else {
      return null;
    }
    const pushed = Clipboard.push(items, entry);
    clock.now = time;
    publish(pushed.items);
    return items.find(item => item.id === pushed.item.id) || null;
  }

  // Publica a lista nova já cortada nos tetos, e apaga o arquivo das imagens que saíram.
  function publish(list) {
    const trimmed = Clipboard.trim(list, maxItems, maxImagesTotalBytes);
    items = trimmed.items;
    trimmed.dropped.forEach(deleteFile);
  }

  // Só apaga o PNG que o `watch.py` gravou na pasta do histórico, e só pelo gancho `exec`.
  function deleteFile(item) {
    if (item && item.kind === "image" && item.image && Clipboard.isOwnFile(imageDir, item.image.path))
      exec(["rm", "-f", "--", item.image.path]);
  }

  function find(item) {
    return item ? (items || []).find(entry => entry.id === item.id) || null : null;
  }

  // Devolve o item à área de transferência (Enter na peça, e o launcher fecha). O texto vai pelo `wl-copy -- texto`, como o launcher faz;
  // acima de `argvLimit` bytes, ou com um byte nulo, pela entrada padrão. A imagem vai pelo clipboard.py da captura. A cópia gera
  // uma mudança na área de transferência, e o item que já existe sobe: não duplica.
  function copy(item) {
    const entry = find(item);
    if (!entry)
      return;
    if (entry.kind === "image") {
      if (entry.image && Clipboard.isOwnFile(imageDir, entry.image.path))
        exec(["python3", imageHelper, "copy-file", entry.image.path]);
      return;
    }
    if (Clipboard.utf8Length(entry.text) > argvLimit || entry.text.indexOf("\u0000") >= 0)
      execInput(["wl-copy"], entry.text);
    else
      exec(["wl-copy", "--", entry.text]);
  }

  // Fixa o item, ou solta se já estava fixo (Ctrl+P). Soltar pode passar dos 50 não fixados, e então sai o mais antigo.
  function togglePin(item) {
    if (!find(item))
      return;
    const time = clockMs();
    clock.now = time;
    publish(Clipboard.togglePin(items, item.id, time));
  }

  // Tira o item do histórico (Del), e o arquivo dele se for imagem. A área de transferência do sistema não muda.
  function remove(item) {
    const result = Clipboard.remove(items, item ? item.id : undefined);
    if (!result.removed)
      return;
    items = result.items;
    deleteFile(result.removed);
  }

  // "Clear history" (Ctrl+K): tira todos os não fixados, que eu escolhi guardar. A área de transferência do sistema não é esvaziada.
  function clear() {
    const result = Clipboard.clearUnpinned(items);
    if (result.removed.length === 0)
      return;
    items = result.items;
    result.removed.forEach(deleteFile);
  }

  // Um relógio que avança de minuto em minuto, para o "2 min" não ficar parado com a página aberta.
  QtObject {
    id: clock
    property real now: Date.now()
  }

  Timer {
    interval: 60 * 1000
    running: true
    repeat: true
    onTriggered: clock.now = Date.now()
  }
}
