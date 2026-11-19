pragma Singleton

import QtQuick
import ".."
import "." as Screenshot
import "Crop.js" as Crop
import "Windows.js" as Win
import QtCore
import Quickshell
import Quickshell.Io

// O estado da janela de captura de tela (ficha 17, F6-T01 e T02). As janelas (CaptureWindow.qml, uma por tela) leem
// `opened`, `mode`, `showCursor`, `delaySeconds` e `pointerOutput`; o IPC `screenshot` do shell.qml e o chip "Screenshot" do
// launcher chamam `open`, `close` e `toggle`. A prévia pós-captura tem outro estado (State.qml): a captura só lhe entrega o arquivo.
//
// A seleção de área (F6-T11) mora aqui, e não na peça, para as janelas de todos os monitores a verem: `selection` é um
// retângulo { x, y, width, height } em pixels lógicos do monitor `selectionOutput` (ou null), e `selecting` diz que ele
// ainda está sendo arrastado. Quem desenha e quem arrasta é a peça (Capture.qml); as contas são do Selection.js.
//
// Os modos Window e Screen (F6-T12) escolhem uma janela ou um monitor, e a escolha chama `captureWindow(id)` ou `captureScreen(nome)`. A
// lista das janelas é uma foto tirada quando a captura abre (`windowSnapshot`, por monitor), porque o quadro de fundo também está congelado:
// se as janelas mexerem depois, o destaque tem de continuar batendo com a imagem. As contas são do Windows.js.
//
// Capturar e copiar (F6-T13): a imagem sai do quadro congelado que a janela já mostra, recortado, e não da captura do Niri: o que
// eu vejo congelado é exatamente o que sai, nos três modos. Cada janela registra aqui o recortador do quadro dela (FrameCropper.qml,
// `registerFrame`), e `grab` faz a conta do recorte em pixels do quadro (Crop.js), grava um PNG num arquivo temporário, copia para a
// área de transferência (clipboard.py copy-file) e, quando a escolha é a de capturar, entrega o arquivo à prévia (State.qml). A janela
// só fecha depois de o PNG estar gravado, porque o recorte precisa do quadro vivo. Anotar (F6-T14) grava o recorte e abre o editor com ele, sem copiar
// e sem prévia (AnnotateState.qml); salvar continua sem destino.
//
// A regra de ouro da ficha: a captura sempre começa do zero. Nenhuma propriedade abaixo é lida de arquivo nem guardada
// entre uma abertura e outra: `reset()` devolve tudo ao padrão na abertura e de novo no fechamento, para a próxima vez
// não herdar o modo, o cursor, o atraso nem o monitor da anterior.
//
// O ciclo, como o da lupa do seletor de cor (launcher/LoupeState.qml):
//   ""         fechada
//   "waiting"  o launcher ou os Ajustes saíram e eu espero eles sumirem da tela antes de capturar, para não saírem no quadro
//   "open"     as janelas estão à vista, cada uma com o quadro congelado do seu monitor
Singleton {
  id: root

  property string phase: ""
  readonly property bool waiting: phase === "waiting"
  readonly property bool opened: phase === "open"

  // Os modos, na ordem em que o Espaço os percorre.
  readonly property var modes: ["area", "window", "screen"]
  property string mode: "area"
  // Mostrar o cursor na captura. Desligado ao abrir.
  property bool showCursor: false
  // O atraso antes de capturar, em segundos. Sempre 0 ao abrir; o seletor é a F6-T03.
  property int delaySeconds: 0
  // A área selecionada no modo Area (null: nenhuma), o monitor em que ela nasceu (ela fica presa a ele) e se o ponteiro
  // ainda a está arrastando (sem alças nem ações enquanto arrasta). Sempre vazia ao abrir, como o resto.
  property var selection: null
  property string selectionOutput: ""
  property bool selecting: false
  // A foto das janelas de cada monitor, tirada quando a captura abre: { nomeDoMonitor: [ { id, appId, title, entryName, isFloating,
  // layout } ] }, com as janelas do workspace ativo do monitor (NiriMsg.activeWorkspaceWindows) e o `entryName` (o Name da entrada
  // .desktop, ou ""). Vazia ao abrir e ao fechar, como o resto.
  property var windowSnapshot: ({})
  // O monitor em que o ponteiro está agora. Só a janela dele mostra a mira, a dica e a barra, e recebe o teclado.
  property string pointerOutput: ""
  // Os monitores cujo quadro já chegou.
  property var readyOutputs: []

  // Limite de falha, não valor de desenho: sem o protocolo de captura (como no GNOME) o quadro nunca chega, e depois
  // disto eu desisto e fecho. 2 s, o mesmo da lupa.
  readonly property int captureTimeout: 2000
  // Folga depois da animação de fechar do launcher e dos Ajustes: a janela deles só sai da tela depois do
  // `settingsCloseDuration` e o compositor leva alguns quadros para tirá-la. 100 ms, como na lupa.
  readonly property int settleMargin: 100

  property string pendingOutput: ""

  // Capturar e copiar (F6-T13). Os recortadores dos quadros, por monitor ({ nomeDoMonitor: FrameCropper }), que as janelas registram
  // enquanto o quadro existe; o pedido em andamento (`saving`) e um número que cada fechamento troca, para um pedido que ficou
  // para trás (fechei com Esc enquanto gravava) não copiar nem mostrar nada; o último arquivo gravado, para a próxima captura o
  // apagar (é o único estado que passa de uma abertura para a outra, e não é de interface), e o contador do nome.
  property var frames: ({})
  property bool saving: false
  property int grabToken: 0
  property string lastFile: ""
  property int fileCounter: 0

  // Os comandos e a entrega à prévia saem por funções que o teste troca. `exec` roda sem esperar (a cópia e a remoção do arquivo
  // antigo; o wl-copy fica vivo em segundo plano servindo a área de transferência), `makeDir` cria a pasta do arquivo e chama
  // `done(true)` ou `done(false)`, `deliver` mostra o arquivo na prévia da barra e `openEditor` o abre no editor de anotação.
  property var exec: argv => Quickshell.execDetached(argv)
  property var makeDir: (dir, done) => {
    makeDirComponent.createObject(root, { command: ["mkdir", "-p", "--", dir], done: done }).running = true;
  }
  property var deliver: (path, outputName) => Screenshot.State.receive(path, outputName)
  // Abre o editor de anotação com o PNG do recorte (F6-T14).
  property var openEditor: (path, outputName) => Screenshot.AnnotateState.openFile(path, outputName)

  readonly property string helper: decodeURIComponent(Qt.resolvedUrl("clipboard.py").toString().replace(/^file:\/\//, ""))

  Component {
    id: makeDirComponent
    Process {
      id: maker
      property var done
      stderr: StdioCollector { onStreamFinished: if (text.trim()) console.warn("screenshot: " + text.trim()) }
      onExited: code => {
        maker.done(code === 0);
        maker.destroy();
      }
    }
  }

  Timer {
    id: settleTimer
    interval: Theme.settingsCloseDuration + root.settleMargin
    onTriggered: root.show()
  }

  Timer {
    id: giveUpTimer
    interval: root.captureTimeout
    onTriggered: root.fail()
  }

  // Volta ao padrão de toda abertura (F6-T02): modo Area, cursor desligado, atraso 0 s, nenhum quadro recebido, nenhuma seleção,
  // nenhuma janela na foto.
  function reset() {
    windowSnapshot = ({});
    mode = "area";
    showCursor = false;
    delaySeconds = 0;
    readyOutputs = [];
    clearSelection();
  }

  // Abre a captura no monitor `outputName`. `afterClose` é verdadeiro quando o launcher ou os Ajustes estavam abertos e
  // acabaram de ser fechados: espero eles saírem da tela antes de capturar. Sem isso abro na hora.
  function open(outputName, afterClose) {
    if (phase !== "")
      return;
    reset();
    pendingOutput = outputName || "";
    pointerOutput = pendingOutput;
    if (afterClose) {
      phase = "waiting";
      settleTimer.restart();
    } else {
      show();
    }
  }

  function show() {
    if (phase === "open")
      return;
    pointerOutput = pendingOutput;
    // A foto das janelas sai junto com o pedido do quadro: a janela da captura só aparece (e só então o quadro é capturado) depois disto.
    takeWindowSnapshot();
    phase = "open";
    giveUpTimer.restart();
  }

  // Tira a foto das janelas de cada monitor, agora. O nome do aplicativo é o da entrada .desktop da janela, achada pelo appId como a
  // lupa do seletor de cor faz; o Windows.js escolhe entre ele, o título e o appId.
  function takeWindowSnapshot() {
    const snapshot = {};
    for (const screen of Quickshell.screens) {
      const windows = NiriMsg.activeWorkspaceWindows(screen.name).map(window => {
        const entry = window.appId !== "" ? DesktopEntries.heuristicLookup(window.appId) : null;
        return Object.assign({}, window, { entryName: entry && entry.name ? String(entry.name) : "" });
      });
      snapshot[screen.name] = windows;
      // Para o QA ao vivo: quantas janelas o Niri deu com posição e quantas ficaram de fora.
      const placed = Win.rects(windows).length;
      console.log("screenshot: " + windows.length + " janela(s) no workspace ativo de " + screen.name + ", " + placed + " com posição");
    }
    windowSnapshot = snapshot;
  }

  // Fecha a captura (Esc, o botão de fechar, o IPC, abrir o launcher ou os Ajustes) e zera tudo.
  function close() {
    settleTimer.stop();
    giveUpTimer.stop();
    saving = false;
    ++grabToken;
    phase = "";
    pendingOutput = "";
    pointerOutput = "";
    reset();
  }

  function toggle(outputName) {
    if (phase !== "")
      close();
    else
      open(outputName, false);
  }

  // Abrir o launcher ou os Ajustes enquanto a captura está aberta a fecha.
  function abort() {
    if (phase !== "")
      close();
  }

  // Sair do modo Area apaga a seleção: ela só existe nele.
  onModeChanged: {
    if (mode !== "area")
      clearSelection();
  }

  function setMode(newMode) {
    if (modes.indexOf(newMode) >= 0)
      mode = newMode;
  }

  // Espaço: Area, Window, Screen e de volta a Area.
  function nextMode() {
    mode = modes[(modes.indexOf(mode) + 1) % modes.length];
  }

  // A seleção passou a ser `rect` no monitor `outputName`; `dragging` diz que o ponteiro ainda a arrasta.
  function setSelection(outputName, rect, dragging) {
    selection = rect;
    selectionOutput = outputName;
    selecting = !!dragging;
  }

  function clearSelection() {
    selection = null;
    selectionOutput = "";
    selecting = false;
  }

  // As quatro ações da pílula de ações e as escolhas dos modos Window e Screen. Capturar (`capture`, `captureWindow`, `captureScreen`)
  // grava, copia, mostra na prévia e fecha; copiar (`copySelection`) grava, copia e fecha, sem a prévia. Anotar (`annotateSelection`, F6-T14) grava o
  // recorte, fecha a captura e abre o editor com ele, sem copiar e sem a prévia. Salvar é a F6-T03 (esperando a P-15 e a P-16): até lá só diz
  // no log que ainda não tem destino, e a janela continua aberta.
  function copySelection() { grabSelection("copy"); }
  function saveSelection() { pending("salvar a área"); }
  function annotateSelection() { grabSelection("annotate"); }
  function capture() { grabSelection("capture"); }

  function captureWindow(id) {
    const found = Crop.findWindow(windowSnapshot, id);
    if (!found) {
      console.warn("screenshot: a janela " + id + " não está na foto das janelas, ou não tem posição; nada foi capturado");
      return;
    }
    grab(found.output, found.rect, "capture");
  }

  function captureScreen(outputName) { grab(outputName, null, "capture"); }

  function pending(action) {
    console.log("screenshot: " + action + " ainda não tem destino (F6-T03); nada foi feito");
  }

  function grabSelection(kind) {
    if (!selection || selecting) {
      console.warn("screenshot: não há área selecionada; nada foi capturado");
      return;
    }
    grab(selectionOutput, selection, kind);
  }

  function registerFrame(outputName, cropper) {
    const next = Object.assign({}, frames);
    next[outputName] = cropper;
    frames = next;
  }

  function unregisterFrame(outputName, cropper) {
    if (frames[outputName] !== cropper)
      return;
    const next = Object.assign({}, frames);
    delete next[outputName];
    frames = next;
  }

  // A pasta dos arquivos temporários: wintermute-shell/ em $XDG_RUNTIME_DIR (a pasta da sessão, que some no logout e só eu leio);
  // sem ela, a pasta temporária do sistema.
  function captureDir() {
    let base = Quickshell.env("XDG_RUNTIME_DIR") || "";
    if (base === "")
      base = decodeURIComponent(StandardPaths.writableLocation(StandardPaths.TempLocation).toString().replace(/^file:\/\//, ""));
    return base.replace(/\/+$/, "") + "/wintermute-shell";
  }

  // Um nome que não se repete: a hora em milissegundos e um contador (duas capturas no mesmo milissegundo).
  function nextFile(dir) {
    return dir + "/capture-" + Date.now() + "-" + (++fileCounter) + ".png";
  }

  // Grava o PNG do recorte e entrega. `rect` é um retângulo em pixels lógicos do monitor `outputName`, ou null para o monitor inteiro.
  // `kind` diz o que fazer com o PNG: "capture" grava, copia, mostra na prévia e fecha; "copy" grava, copia e fecha; "annotate" grava, fecha e abre
  // o editor de anotação com o arquivo, sem copiar e sem a prévia (F6-T14). Se a gravação falhar, fica um aviso no log, a janela fecha e
  // nada vai para a área de transferência, para a prévia nem para o editor.
  function grab(outputName, rect, kind) {
    if (phase !== "open" || saving)
      return;
    const cropper = frames[outputName];
    if (!cropper || !cropper.ready) {
      console.warn("screenshot: não há quadro pronto em " + outputName + "; nada foi capturado. Fechando.");
      close();
      return;
    }
    const pixels = rect
        ? Crop.toPixels(rect, cropper.source.width, cropper.source.height, cropper.frameWidth, cropper.frameHeight)
        : Crop.screenPixels(cropper.frameWidth, cropper.frameHeight);
    if (!pixels) {
      console.warn("screenshot: o que escolhi está fora do monitor; nada foi capturado");
      return;
    }
    saving = true;
    const token = ++grabToken;
    const dir = captureDir();
    makeDir(dir, made => {
      if (token !== grabToken)
        return;
      if (!made) {
        finishGrab(token, false, "", outputName, kind);
        return;
      }
      const path = nextFile(dir);
      cropper.save(pixels, path, ok => finishGrab(token, ok, path, outputName, kind));
    });
  }

  function finishGrab(token, ok, path, outputName, kind) {
    if (token !== grabToken) {
      // Fechei a captura enquanto ela gravava: o arquivo ficou pronto e sem uso. Apago, para não sobrar na pasta.
      if (ok && path !== "")
        exec(["rm", "-f", "--", path]);
      return;
    }
    if (!ok) {
      console.warn("screenshot: não consegui gravar a imagem da captura; nada foi copiado nem mostrado. Fechando.");
      close();
      return;
    }
    if (kind === "annotate") {
      keepFile(path);
      // Fecho a captura antes de abrir o editor: os dois pedem teclado exclusivo, e o editor não pode nascer com a captura ainda aberta.
      close();
      openEditor(path, outputName);
      return;
    }
    deliverFile(path, outputName, kind === "capture");
    close();
  }

  // O arquivo `path` é o da captura de agora: cada captura nova apaga o arquivo da anterior, para não acumular. É o único estado que passa de
  // uma abertura para a outra, e não é de interface.
  function keepFile(path) {
    if (lastFile !== "" && lastFile !== path)
      exec(["rm", "-f", "--", lastFile]);
    lastFile = path;
  }

  // Entrega um PNG já gravado: guarda como o arquivo de agora, copia para a área de transferência e, com `withPreview`, mostra na prévia da barra.
  // O editor de anotação usa o mesmo caminho para entregar a imagem com as marcas.
  function deliverFile(path, outputName, withPreview) {
    keepFile(path);
    exec(["python3", helper, "copy-file", path]);
    if (withPreview)
      deliver(path, outputName);
  }

  function toggleCursor() {
    showCursor = !showCursor;
  }

  // Um monitor entregou o quadro. Com todos prontos, não há mais o que esperar.
  function markReady(outputName) {
    if (phase !== "open" || readyOutputs.indexOf(outputName) >= 0)
      return;
    readyOutputs = readyOutputs.concat([outputName]);
    if (Quickshell.screens.every(screen => readyOutputs.indexOf(screen.name) >= 0))
      giveUpTimer.stop();
  }

  // O quadro não chegou a tempo: desisto e fecho, com um aviso no log.
  function fail() {
    if (phase !== "open")
      return;
    const missing = Quickshell.screens.map(screen => screen.name).filter(name => readyOutputs.indexOf(name) < 0);
    console.warn("screenshot: a captura não recebeu o quadro da tela em " + captureTimeout + " ms (monitores sem quadro: "
        + missing.join(", ") + "); sem o protocolo de captura do compositor ela não funciona. Fechando.");
    close();
  }
}
