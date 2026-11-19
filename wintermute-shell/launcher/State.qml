pragma Singleton

import QtQuick
import ".."
import "../settings" as Settings
import "Actions.js" as Actions
import "Calculator.js" as Calculator
import "Colors.js" as Colors
import "Emoji.js" as Emoji
import "Search.js" as Search
import "../screenshot" as Screenshot
import Quickshell
import Quickshell.Io

// Estado do launcher (ficha 14). É a superfície que a peça lê (decisão 0011); o serviço fictício de
// demo/LauncherService.qml tem os mesmos nomes. As fontes de resultado (F5-T02) são quatro: os aplicativos
// (DesktopEntries), os arquivos (FileSearch.qml, que roda o `fd`), as páginas dos Ajustes e os comandos de sessão.
// A biblioteca Search.js casa e ordena, decide entre "Best match" e os grupos e calcula a sugestão fantasma; aqui ficam
// as fontes, os recentes (launcher-recents.json), a confirmação do comando perigoso e `activate`, que despacha pelo
// alvo da linha (`row.target`). O cálculo (F5-T03) depende só do texto, então `calculation`, o modo e o rodapé saem dele.
// As ferramentas do estado vazio (F5-T04) são fixas. As duas linhas de ação do "sem resultado" (F5-T11, P-73) são "Search the
// web" (xdg-open no Google) e "Search files", que liga `deepFiles`: a mesma busca de arquivos na pasta pessoal inteira.
// O seletor de cor (F5-T08) abre uma página própria, `page === "color"`, com a cor mais recente do histórico; o seletor de emoji (F5-T09) é `page === "emoji"`, com o
// inventário lido na primeira abertura (EmojiInventory.qml) e os últimos copiados em emoji-recents.json; o histórico da área de transferência (F6-T05) é `page === "clipboard"`, com os dados em
// clipboard/State.qml; as ferramentas que ainda não existem só são registradas no log por `openTool`. O menu "Actions" (F5-T05, Ctrl+K) é outra página, `page === "actions"`: as ações do
// item que estava selecionado (a conta mora em Actions.js) e, para "Open on workspace…", uma segunda camada com os
// workspaces do monitor.
Singleton {
  id: root

  property bool opened: false
  property string outputName: ""
  property string query: ""
  // De onde o launcher foi aberto: { workspaceId, number } quando vem do "+" do organizador (o aplicativo escolhido
  // abre nesse workspace), null pelo atalho e pelo IPC. `number` é o que o organizador mostra, não o id do Niri.
  property var context: null
  readonly property string contextLabel: context ? "On workspace " + context.number : ""
  // O resto da palavra sugerida (para "ter", "minal"): o que falta do título da primeira linha quando o texto é
  // prefixo dele. Vazio quando não há sugestão, e no cálculo.
  readonly property string ghost: calculation ? "" : Search.ghost(query, sections)
  // Lista de { label, rows }; cada linha é { title, detail, kind, icon, iconSource, danger } e carrega o alvo dela em
  // `target` (Search.js). `icon` é o nome de um ícone de icons/; `iconSource` é um caminho ou um nome de ícone do tema.
  // Não é um binding puro: `applySections` decide quando publicar (ver "Sem piscar" abaixo).
  property var sections: []
  // Os apps recentes, mostrados na busca vazia sob "Recent": lista de linhas, no mesmo formato das de `sections`.
  // Sem recentes, a seção não aparece. São os `Search.RECENTS_SHOWN` primeiros ids do arquivo que ainda existem
  // como app instalado.
  readonly property var recents: Search.recentRows(recentIds, appIndex.byId, Search.RECENTS_SHOWN)
  // A resposta de arquivos que ainda falta para o texto atual: o `fd` rodando, ou um texto novo que ainda não chegou ao
  // `fd` (o atraso da busca). Derivado do texto, e não do estado interno do FileSearch, para valer no mesmo instante em
  // que o texto muda. O launcher nunca mostra "Nothing found" enquanto isto é verdade.
  // Na busca profunda a resposta que vale é a do modo profundo: `outputDeep` evita tomar a da busca normal por ela.
  readonly property bool searching: filesText.length >= (deepFiles ? files.deepMinChars : files.minChars)
      && (files.searching || files.outputText !== filesText || files.outputDeep !== deepFiles)
  // As ferramentas da busca vazia, na ordem do board: { key, label, icon }. A chave vai para `openTool`.
  readonly property var tools: [
    { key: "color", label: "Color picker", icon: "pipette" },
    { key: "emoji", label: "Emoji", icon: "smile" },
    { key: "screenshot", label: "Screenshot", icon: "scan" },
    { key: "clipboard", label: "Clipboard", icon: "clipboard" }
  ]
  // As linhas de ação do "sem resultado" (P-73): "Search the web" e, se o `fd` existe e a busca ainda não é a profunda,
  // "Search files". Na primeira vez que a profunda espera a resposta o bloco fica como estava, com as duas linhas
  // (`deepAnswered` ainda falso); depois só a da web.
  readonly property var fallbackRows: Search.fallbackRows(String(query).trim(), files.present() && !(deepFiles && deepAnswered))

  // O resultado sai no formato do locale do sistema (decisão 0012; P-70).
  readonly property string decimalSeparator: Qt.locale().decimalPoint
  // null quando o texto não é um cálculo; senão { expression, result, hex, rows } (launcher/Calculator.js).
  // Enquanto não for null, o modo cálculo ocupa o launcher inteiro.
  readonly property var calculation: Calculator.describe(query, decimalSeparator)

  // A página aberta no lugar da busca: "" (a busca), "color" (o resultado do seletor de cor), "emoji" (o seletor de emoji),
  // "clipboard" (o histórico da área de transferência) ou "actions" (o menu de ações do item selecionado). Abrir o launcher sempre começa na busca.
  property string page: ""

  // ---- Fontes de resultado (F5-T02) ----
  // As entradas de .desktop. O teste troca por entradas fictícias com os mesmos campos (id, name, genericName,
  // keywords, noDisplay, icon e o método execute()).
  property var appEntries: Array.from(DesktopEntries.applications.values)
  // { rows, byId }: as linhas dos apps que aparecem em menu e o mapa id → linha.
  readonly property var appIndex: Search.appRows(appEntries)
  readonly property var settingRows: Search.settingRows(Settings.State.pages)
  readonly property var commandRows: Search.commandRows()
  // A pasta pessoal, para escrever "~" no detalhe dos arquivos.
  property string homeDir: Quickshell.env("HOME") || ""
  // A saída do `fd` só vale no modo a que ela responde.
  readonly property var fileRows: files.outputDeep === deepFiles ? Search.fileRows(files.output, homeDir) : []
  // Onde a busca de arquivos procura e com que binário; o teste aponta para uma pasta temporária e um `fd` de mentira.
  property alias fileDirectories: files.directories
  property alias fileBinary: files.binary
  // Roda um comando solto (xdg-open, o script de sessão, o niri). O teste troca por uma função que só anota.
  property var exec: argv => Quickshell.execDetached(argv)

  // ---- Busca profunda (F5-T11, P-73): "Search files" no estado sem resultado ----
  // Ligada, o launcher continua aberto com o mesmo texto e a busca de arquivos roda na pasta pessoal inteira, com as ocultas,
  // sem `.git`, e só o grupo "Files" aparece (Search.deepSections). Sai ao apagar o texto, ao fechar e ao abrir.
  property bool deepFiles: false
  // O `fd` profundo já respondeu desde que o modo ligou. Até lá o "Nothing found" que estava na tela continua com as duas linhas.
  property bool deepAnswered: false
  // O "Nothing found" é o que está na tela e o modo profundo o segura enquanto o `fd` não responde, em vez de mostrar uma
  // lista vazia. Não é uma ligação: o Panel o lê no mesmo instante em que `searching` muda, e uma ligação poderia chegar
  // depois dele e deixar passar um quadro de lista vazia. Quem o escreve é `applySections` (e `searchFiles`, antes de ligar o modo).
  property bool holdNotice: false
  // Onde a busca profunda procura; o teste aponta para uma pasta temporária.
  property alias deepFileDirectories: files.deepDirectories

  // Os ids dos apps que abri pelo launcher, o mais novo primeiro, no máximo `Search.RECENTS_KEPT`.
  property var recentIds: []
  // A linha de comando perigosa que levou o primeiro Enter e espera o segundo ("command:reboot"), ou "".
  property string armedKey: ""

  // As seções do texto atual: os resultados que casam, em "Best match" ou nos grupos (Search.js). A linha armada
  // mostra a confirmação no detalhe.
  readonly property var candidateSections: decorate(deepFiles
      ? Search.deepSections(String(query).trim(), fileRows)
      : Search.buildSections(String(query).trim(), {
        apps: appIndex.rows,
        files: fileRows,
        settings: settingRows,
        commands: commandRows
      }, recentIds), armedKey)

  function decorate(built, armed) {
    if (armed === "")
      return built;
    return built.map(section => ({
      label: section.label,
      rows: section.rows.map(row => Search.rowKey(row) === armed
          ? Object.assign({}, row, { detail: "Press ↵ again to confirm" }) : row)
    }));
  }

  // Sem piscar: enquanto o `fd` não responde, as outras fontes já valem. Se elas têm resultado, publico na hora (as
  // linhas de arquivo da busca anterior que ainda casam com o texto novo continuam, porque `fileRows` guarda a última
  // resposta e a busca as filtra de novo). Se não têm nada, mantenho as seções como estavam até a resposta chegar: o
  // "Nothing found" nunca aparece com a busca de arquivos em andamento e some um instante depois.
  function applySections() {
    // Com o menu de ações aberto a lista fica como estava, para a seleção de antes valer quando eu voltar (uma resposta
    // tardia do `fd` não mexe nela); `closeActions` publica o que chegou nesse meio-tempo.
    if (page === "actions")
      return;
    const next = candidateSections;
    if (Search.countRows(next) === 0 && searching)
      return;
    sections = next;
    // O que ficou na tela é o "Nothing found" quando não há linha, há texto e não é cálculo. No modo profundo ele é segurado
    // enquanto a próxima resposta não chega (ver `holdNotice`).
    holdNotice = deepFiles && Search.countRows(next) === 0 && String(query).trim() !== "" && !calculation;
  }

  onCandidateSectionsChanged: applySections()
  onSearchingChanged: {
    // A primeira resposta do `fd` profundo: dali em diante o bloco sem resultado só oferece a busca na web.
    if (deepFiles && !searching)
      deepAnswered = true;
    applySections();
  }

  // A peça avisa qual linha ficou selecionada (nenhuma, com um chip em foco). Mudar a seleção desarma o comando
  // perigoso, a não ser que a selecionada seja a própria linha armada.
  function selectRow(row) {
    if (armedKey !== "" && Search.rowKey(row) !== armedKey)
      armedKey = "";
  }

  // O texto que vai para o `fd`: só na busca de texto (sem cálculo). O menu de ações mantém o texto, senão a resposta de
  // arquivos sumiria e a lista de antes não voltaria igual.
  readonly property string filesText: (page === "" || page === "actions") && !calculation ? String(query).trim() : ""

  FileSearch {
    id: files
    text: root.filesText
    deep: root.deepFiles
  }

  FileView {
    id: recentsFile
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state")
        + "/wintermute-shell/launcher-recents.json"
    blockLoading: true
    blockWrites: true
    atomicWrites: true
    printErrors: false
    onSaveFailed: error => console.warn("launcher: não gravei os recentes:", error)
  }

  // Relê o arquivo. Ausente, estragado ou fora do formato vale como lista vazia, sem erro na tela.
  function loadRecents() {
    recentsFile.reload();
    // O reload só vale no turno seguinte do laço de eventos; espero a leitura para não ler o que ficou em cache.
    recentsFile.waitForJob();
    let text = "";
    try {
      text = recentsFile.text();
    } catch (error) {
      text = "";
    }
    recentIds = Search.parseRecents(text, Search.RECENTS_KEPT);
  }

  function rememberApp(id) {
    recentIds = Search.pushRecent(recentIds, id, Search.RECENTS_KEPT);
    recentsFile.setText(Search.serializeRecents(recentIds));
  }

  // "Remove from recent": tira o app da lista e grava o arquivo.
  function forgetApp(id) {
    recentIds = Search.dropRecent(recentIds, id);
    recentsFile.setText(Search.serializeRecents(recentIds));
  }

  // O comando de cada ação de sessão. Lock, Sleep, Restart e Power off passam pelo settings/session.py, como a tela
  // inicial dos Ajustes (que usa a janela dos Ajustes para fechar, o que não serve aqui); "Log out" sai do Niri, e a
  // confirmação já foi a do launcher.
  function commandArgv(action) {
    if (action === "logout")
      return ["niri", "msg", "action", "quit", "--skip-confirmation"];
    return ["python3", Quickshell.shellDir + "/settings/session.py", action];
  }

  // O comando de sessão sai depois que o launcher some (o mesmo tempo que os Ajustes esperam), para a janela não
  // aparecer congelada na tela de bloqueio nem na volta da suspensão.
  property var pendingCommand: null

  Timer {
    id: commandDelay
    interval: Theme.settingsCloseDuration
    onTriggered: {
      const argv = root.pendingCommand;
      root.pendingCommand = null;
      if (argv)
        root.exec(argv);
    }
  }

  // O menu de ações é do launcher, mesmo quando o item é um cálculo: o modo do rodapé não muda.
  readonly property bool calculating: calculation !== null && page !== "actions"
  readonly property string mode: page === "color" ? "color" : page === "emoji" ? "emoji" : page === "clipboard" ? "clipboard" : calculating ? "calculator" : "launcher"
  readonly property string modeLabel: page === "color" ? "Color picker" : page === "emoji" ? "Emoji" : page === "clipboard" ? "Clipboard" : calculating ? "Calculator" : "Launcher"
  readonly property string modeIcon: page === "color" ? "pipette" : page === "emoji" ? "smile" : page === "clipboard" ? "clipboard" : calculating ? "calculator" : "sparkles"
  // Ícone do cabeçalho de busca.
  readonly property string searchIcon: calculation ? "calculator" : "search"
  // Ações do rodapé: { label, keys, primary }. No cálculo "Copy" e "Actions"; o "Paste" (Ctrl+↵) ficou de fora (P-71).
  readonly property var actions: page === "color" ? [
    { label: "Copy HEX", keys: ["↵"], primary: true },
    { label: "Pick another", keys: ["P"], primary: false }
  ] : page === "emoji" ? [
    { label: "Copy", keys: ["↵"], primary: true }
  ] : page === "actions" ? [
    { label: "Run", keys: ["↵"], primary: true },
    { label: "Back", keys: ["Esc"], primary: false }
  ] : calculation ? [
    { label: "Copy", keys: ["↵"], primary: true },
    { label: "Actions", keys: ["Ctrl", "K"], primary: false }
  ] : [
    { label: "Open", keys: ["↵"], primary: true },
    { label: "Actions", keys: ["Ctrl", "K"], primary: false }
  ]

  // `requestedContext` é opcional: sem ele o launcher abre sem etiqueta. Quem abre pelo "+" já deixou o workspace
  // em foco (NiriMsg.openLauncher), então o que eu escolher nasce nele.
  function open(requestedOutputName, requestedContext) {
    outputName = requestedOutputName || Settings.State.focusedOutputName();
    query = "";
    leaveDeep();
    armedKey = "";
    context = requestedContext || null;
    closePage();
    // Uma abertura nova não tem cor "pega agora".
    colorFreshStamp = "";
    loadColors();
    loadRecents();
    opened = true;
  }

  function close() {
    opened = false;
    context = null;
    armedKey = "";
    leaveDeep();
  }

  function toggle(requestedOutputName) {
    const targetOutput = requestedOutputName || Settings.State.focusedOutputName();
    if (opened && outputName === targetOutput)
      close();
    else
      open(targetOutput);
  }

  // Digitar desarma o comando perigoso que esperava a confirmação.
  function setQuery(text) {
    query = text;
    armedKey = "";
    // Apagar o texto todo sai da busca profunda.
    if (String(text).trim() === "")
      leaveDeep();
  }

  // Sai da busca profunda: a próxima busca é a normal.
  function leaveDeep() {
    deepFiles = false;
    deepAnswered = false;
    holdNotice = false;
  }

  // Tab: o texto passa a ser a palavra inteira.
  function acceptGhost() {
    if (ghost === "")
      return;
    setQuery(query + ghost);
  }

  // O comando que copia o texto. O texto vai depois de `--`, como argumento, nunca por shell.
  function copyCommand(text) {
    return ["wl-copy", "--", text];
  }

  // O wl-copy fica vivo em segundo plano servindo a área de transferência, por isso `execDetached` (o `exec` de cima,
  // que o teste troca por uma função que só anota).
  function copyText(text) {
    exec(copyCommand(text));
  }

  // ---- Seletor de cor (ficha 15, F5-T08) ----
  // O histórico: lista de { hex, pickedAt, app }, a mais nova primeiro, no máximo 12. Fica em
  // $XDG_STATE_HOME/wintermute-shell/colors.json e é relido toda vez que o launcher abre.
  property var colorHistory: []
  // A cor mostrada na página: uma das entradas do histórico, ou null fora da página.
  property var colorShown: null
  // O instante (`pickedAt`) da cor que entrou por `addColor` nesta abertura do launcher: a origem dela diz "Picked just now".
  property string colorFreshStamp: ""
  // O formato recém-copiado ("hex", "rgb", "hsl") durante `launcherCopiedDuration`, ou "".
  property string colorCopied: ""

  // { hex, rgb, hsl, name } da cor mostrada (launcher/Colors.js), ou null.
  readonly property var colorInfo: colorShown ? Colors.describe(colorShown.hex) : null
  readonly property string colorOrigin: {
    if (!colorShown)
      return "";
    const fresh = colorShown.pickedAt === colorFreshStamp;
    // Data e hora curtas no locale do sistema (decisão 0012); a cor "pega agora" não precisa delas.
    const when = fresh ? "" : new Date(colorShown.pickedAt).toLocaleString(Qt.locale(), Locale.ShortFormat);
    return Colors.originText(colorShown, fresh, when);
  }

  FileView {
    id: colorFile
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state")
        + "/wintermute-shell/colors.json"
    // O arquivo é pequeno: leio e gravo sem esperar, como o histórico de notificações.
    blockLoading: true
    blockWrites: true
    atomicWrites: true
    printErrors: false
    onSaveFailed: error => console.warn("launcher: não gravei o histórico de cores:", error)
  }

  Timer {
    id: copiedTimer
    interval: Theme.launcherCopiedDuration
    onTriggered: root.colorCopied = ""
  }

  // Relê o arquivo. Ausente, ilegível ou fora do formato vale como lista vazia, sem erro na tela.
  function loadColors() {
    colorFile.reload();
    let text = "";
    try {
      text = colorFile.text();
    } catch (error) {
      text = "";
    }
    colorHistory = Colors.parseHistory(text, Theme.launcherColorHistoryMax);
  }

  function saveColors() {
    colorFile.setText(Colors.serializeHistory(colorHistory));
  }

  // A cor que a lupa pegou (F5-T12 chama isto, depois de `open`): vai para a frente do histórico sem repetir, o
  // histórico é cortado em 12, a cor fica marcada como "pega agora" e a página a mostra. `app` é o aplicativo em foco
  // quando peguei, se eu souber. Devolve se a cor era um HEX válido.
  function addColor(hex, app) {
    const clean = Colors.normalizeHex(hex);
    if (clean === "")
      return false;
    const entry = { hex: clean, pickedAt: new Date().toISOString(), app: app ? String(app) : "" };
    colorHistory = Colors.pushHistory(colorHistory, entry, Theme.launcherColorHistoryMax);
    colorFreshStamp = entry.pickedAt;
    colorShown = colorHistory[0];
    colorCopied = "";
    page = "color";
    saveColors();
    return true;
  }

  // Clique numa amostra do histórico: ela vira a cor mostrada, e a ordem do histórico não muda.
  function showColor(index) {
    if (index >= 0 && index < colorHistory.length) {
      colorShown = colorHistory[index];
      colorCopied = "";
    }
  }

  // Copia um formato da cor mostrada ("hex", "rgb" ou "hsl") e deixa a linha em "Copied" por 1,5 s. Não fecha o launcher.
  function copyColor(format) {
    const info = colorInfo;
    if (!info || ["hex", "rgb", "hsl"].indexOf(format) < 0)
      return;
    copyText(info[format]);
    colorCopied = format;
    copiedTimer.restart();
  }

  // Pegar uma cor: o launcher some e a lupa aparece sobre a tela congelada (LoupeState.qml, ficha 15). Guardo de onde
  // vim para o Esc: a página de resultado, com a cor que eu via, ou a busca. Se o launcher nem estava aberto (um
  // teste, por exemplo), o `begin` só esconde o que não existe.
  function pickAnother() {
    LoupeState.begin({
      output: outputName,
      context: context,
      fromPage: page === "color",
      shown: colorShown,
      stamp: colorFreshStamp
    });
  }

  // Volta à página de resultado com a cor que a lupa interrompeu (Esc na lupa). Vem depois do `open`, que zera a marca
  // de "pega agora": devolvo a que a cor tinha, porque é a mesma tela de antes.
  function restoreColorPage(shown, stamp) {
    colorShown = shown;
    colorFreshStamp = stamp || "";
    colorCopied = "";
    page = "color";
  }

  // Voltar ao launcher: busca vazia, sem a cor mostrada. A marca de "pega agora" fica até o launcher fechar.
  function closePage() {
    copiedTimer.stop();
    colorCopied = "";
    colorShown = null;
    page = "";
    actionsItem = null;
    actionsLevel = "actions";
    actionsWorkspaces = [];
    emojiQuery = "";
    if (query !== "")
      setQuery("");
  }

  // Clique num chip, ou Enter com o chip em foco. O seletor de cor abre a página com a cor mais recente, ou vai direto
  // para a lupa quando não há nenhuma guardada; o de emoji abre a página com a busca vazia; o de histórico abre a página do histórico; o de captura de tela fecha o launcher e abre a janela de captura (ficha 17).
  // Para as outras ferramentas ainda não há o que abrir: registro no log e deixo o launcher aberto.
  function openTool(key) {
    if (key === "emoji") {
      openEmoji();
      return;
    }
    if (key === "color") {
      if (colorHistory.length > 0) {
        colorShown = colorHistory[0];
        colorCopied = "";
        page = "color";
      } else {
        pickAnother();
      }
      return;
    }
    if (key === "clipboard") {
      openClipboard();
      return;
    }
    if (key === "screenshot") {
      // A captura abre no monitor do launcher depois de ele sumir, para ele não sair no quadro (CaptureState espera).
      const from = outputName;
      close();
      Screenshot.CaptureState.open(from, true);
      return;
    }
    console.info("launcher: ferramenta pedida, ainda sem destino:", key);
  }

  // O chip "Clipboard": abre a página do histórico (ficha 18, clipboard/ClipboardPage.qml). O que ela mostra vem do clipboard/State.qml,
  // que por enquanto é vazio (F6-T16). A busca da página é dela, então aqui só troco a página.
  function openClipboard() {
    page = "clipboard";
  }

  // ---- Seletor de emoji (ficha 16, F5-T09) ----
  // O inventário (emoji/emoji.json, gerado por emoji/build.py) só é lido na primeira vez que a página abre.
  EmojiInventory {
    id: emojiInventory
  }

  // O inventário, ou null até a primeira abertura da página.
  readonly property var emojiData: emojiInventory.data
  // O texto da busca do emoji, que não é o da busca do launcher: voltar ao launcher o zera.
  property string emojiQuery: ""
  // Os últimos emojis copiados (o caractere), o mais novo primeiro, no máximo `Emoji.RECENTS_KEPT`.
  property var emojiRecents: []
  // As seções da grade, no formato de Emoji.buildSections: os recentes e as categorias, ou os resultados da busca.
  readonly property var emojiSections: page === "emoji" ? Emoji.buildSections(emojiData, emojiQuery, emojiRecents) : []

  FileView {
    id: emojiRecentsFile
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state")
        + "/wintermute-shell/emoji-recents.json"
    blockLoading: true
    blockWrites: true
    atomicWrites: true
    printErrors: false
    onSaveFailed: error => console.warn("launcher: não gravei os emojis recentes:", error)
  }

  // Relê o arquivo. Ausente, estragado ou fora do formato vale como lista vazia; emoji que não está no inventário é pulado.
  function loadEmojiRecents() {
    emojiRecentsFile.reload();
    emojiRecentsFile.waitForJob();
    let text = "";
    try {
      text = emojiRecentsFile.text();
    } catch (error) {
      text = "";
    }
    emojiRecents = Emoji.parseRecents(text, emojiData);
  }

  // O chip "Emoji": lê o inventário (só na primeira vez) e os recentes, e abre a página com a busca vazia e a primeira célula
  // selecionada. Se o inventário não presta, o aviso já saiu no log e o launcher fica onde estava.
  function openEmoji() {
    if (!emojiInventory.ensure())
      return;
    loadEmojiRecents();
    emojiQuery = "";
    page = "emoji";
  }

  function setEmojiQuery(text) {
    emojiQuery = text;
  }

  // Enter ou clique numa célula: copia o emoji (o `wl-copy`), põe nos recentes e fecha o launcher.
  function copyEmoji(ch) {
    copyText(ch);
    emojiRecents = Emoji.pushRecent(emojiRecents, ch);
    emojiRecentsFile.setText(Emoji.serializeRecents(emojiRecents));
    close();
  }

  // Enter ou clique numa linha, despachado pelo alvo dela. A linha de ação do cálculo traz o texto em `copy`: copio e
  // fecho. Um app executa a própria entrada e entra nos recentes; um arquivo abre com o xdg-open; um ajuste abre a
  // página no monitor do launcher; um comando roda (o perigoso só no segundo Enter). Tudo fecha o launcher, menos
  // o primeiro Enter do comando perigoso.
  function activate(row) {
    if (page === "actions" && row)
      activateAction(row);
    else
      activateTarget(row);
  }

  function activateTarget(row) {
    if (!row) {
      close();
      return;
    }
    if (row.copy !== undefined) {
      copyText(String(row.copy));
      close();
      return;
    }
    const target = row.target || {};
    if (target.type === "command") {
      runCommand(row);
      return;
    }
    if (target.type === "file-search") {
      searchFiles();
      return;
    }
    if (target.type === "app") {
      target.entry.execute();
      rememberApp(target.id);
    } else if (target.type === "file") {
      exec(["xdg-open", target.path]);
    } else if (target.type === "setting") {
      Settings.State.open(outputName, target.page);
    } else if (target.type === "web-search") {
      exec(["xdg-open", Search.webSearchUrl(target.text)]);
    }
    close();
  }

  // "Search files": o launcher fica aberto, com o mesmo texto, e a busca de arquivos passa a ser a profunda. `holdNotice` e
  // `deepAnswered` vão antes do modo, para o Panel, que lê `searching` no instante em que o modo liga, já achar o bloco
  // "Nothing found" segurado e com as duas linhas, e não uma lista vazia.
  function searchFiles() {
    if (deepFiles)
      return;
    deepAnswered = false;
    holdNotice = true;
    deepFiles = true;
  }

  // O primeiro Enter numa linha perigosa arma (o detalhe vira "Press ↵ again to confirm"); o segundo, na mesma
  // linha, roda e fecha. Os que não são perigosos rodam no primeiro.
  function runCommand(row) {
    const key = Search.rowKey(row);
    if (row.danger && armedKey !== key) {
      armedKey = key;
      return;
    }
    pendingCommand = commandArgv(row.target.action);
    commandDelay.restart();
    close();
  }

  // ---- Menu de ações (F5-T05, P-13) ----
  // O menu é uma subpágina do launcher, como a do seletor de cor, e não um menu por cima dele: o launcher muda de altura
  // com a lista, e um menu flutuante não teria onde caber. As ações de cada tipo de item são a conta de Actions.js.
  // Duas camadas: as ações do item e, em "Open on workspace…", os workspaces do monitor do launcher.
  // A linha que estava selecionada quando apertei Ctrl+K.
  property var actionsItem: null
  // "actions" (as ações do item) ou "workspaces" (a escolha do workspace do app).
  property string actionsLevel: "actions"
  // As linhas da segunda camada, tiradas do organizador quando ela abre.
  property var actionsWorkspaces: []
  // 0 fora do menu, 1 nas ações, 2 na escolha do workspace. O Panel guarda a seleção de cada camada por aqui.
  readonly property int actionsDepth: page !== "actions" ? 0 : actionsLevel === "workspaces" ? 2 : 1
  readonly property string actionsTitle: Actions.itemTitle(actionsItem, calculation)
  // Uma seção só, no formato de `sections`. A linha do comando perigoso armado mostra a confirmação no detalhe.
  readonly property var actionSections: page !== "actions" ? [] : decorate([{
    label: actionsLevel === "workspaces" ? "Open on workspace" : "Actions",
    rows: actionsLevel === "workspaces" ? actionsWorkspaces : Actions.rowsFor(actionsItem, recentIds, calculation)
  }], armedKey)

  // As linhas do organizador (NiriMsg.workspaceRows) como lista simples. O teste troca por dados fictícios.
  property var workspaceEntries: () => {
    const entries = [];
    const model = NiriMsg.workspaceRows;
    for (let i = 0; i < model.count; i++) {
      const row = model.get(i);
      entries.push({
        outputName: row.outputName,
        workspaceId: row.workspaceId,
        sidebarWorkspaceNumber: row.sidebarWorkspaceNumber,
        sidebarRowOrdinal: row.sidebarRowOrdinal
      });
    }
    return entries;
  }

  // Foca o workspace pelo id e chama `done(true)` quando o Niri aceitou, ou `done(false)`. É o mesmo foco que o "+" do
  // organizador faz, sem pedir o launcher de novo no fim. O teste troca por uma função que só anota.
  property var focusWorkspace: (workspaceId, done) => NiriMsg.focusWorkspaceId(workspaceId, done)
  // Há um pedido de foco no ar: um segundo Enter não manda outro.
  property bool focusPending: false

  // Ctrl+K numa linha da lista: abre as ações dela. Só vale na lista e com a linha tendo ação; devolve se abriu. O comando
  // perigoso armado desarma, porque a página recomeça do zero.
  function openActions(row) {
    if (page !== "" || Actions.rowsFor(row, recentIds, calculation).length === 0)
      return false;
    armedKey = "";
    actionsItem = row;
    actionsLevel = "actions";
    actionsWorkspaces = [];
    page = "actions";
    return true;
  }

  // Volta à lista, com o texto de antes. A seleção de antes é do Panel, que a guardou ao entrar.
  function closeActions() {
    if (page !== "actions")
      return;
    armedKey = "";
    page = "";
    actionsItem = null;
    actionsLevel = "actions";
    actionsWorkspaces = [];
    applySections();
  }

  // Esc, Backspace e o botão de voltar: um passo. Na escolha do workspace volta às ações do app; nas ações, à lista.
  function backActions() {
    if (page !== "actions")
      return;
    if (actionsLevel === "workspaces") {
      actionsLevel = "actions";
      actionsWorkspaces = [];
      return;
    }
    closeActions();
  }

  // Enter ou clique numa linha do menu. "Open" e "Run" valem o Enter na linha original (a linha carrega o alvo dela), e as
  // de copiar valem a linha do cálculo (a linha carrega o texto): `activateTarget` cuida das duas.
  function activateAction(row) {
    if (row.act === "workspaces") {
      actionsWorkspaces = Actions.workspaceRows(workspaceEntries(), outputName);
      actionsLevel = "workspaces";
    } else if (row.act === "remove-recent") {
      forgetApp(actionsItem.target.id);
      // O launcher continua aberto, na lista de antes.
      closeActions();
    } else if (row.act === "show-folder") {
      exec(["xdg-open", Actions.parentDirectory(actionsItem.target.path)]);
      close();
    } else if (row.act === "pick-workspace") {
      pickWorkspace(row.workspaceId);
    } else {
      activateTarget(row);
    }
  }

  // Foca o workspace e, dando certo, executa o app, grava nos recentes e fecha. Se o Niri recusar, o menu fica como está.
  // O pedido só vale enquanto eu continuo na camada dos workspaces em que o fiz: se voltei para as ações, voltei para a lista
  // ou fechei o launcher antes da resposta, o pedido perdeu o sentido e o app não é executado (o foco que o Niri já deu
  // fica, porque eu não desfaço). `actionsWorkspaces` é uma lista nova a cada vez que a camada abre, então compará-la
  // também recusa a resposta de um pedido antigo se eu saí e entrei de novo na camada.
  function pickWorkspace(workspaceId) {
    const item = actionsItem;
    if (!item || focusPending)
      return;
    const layer = actionsWorkspaces;
    focusPending = true;
    focusWorkspace(workspaceId, success => {
      focusPending = false;
      if (!success) {
        console.warn("launcher: não consegui focar o workspace", workspaceId);
        return;
      }
      if (opened && page === "actions" && actionsLevel === "workspaces" && actionsWorkspaces === layer
          && actionsItem === item)
        activateTarget(item);
    });
  }
}
