import QtQuick
import ".."
import "../launcher/Actions.js" as Actions
import "../launcher/Calculator.js" as Calculator
import "../launcher/Colors.js" as Colors
import "../launcher/Emoji.js" as Emoji
import "../launcher/Search.js" as Search
import "../launcher" as Launcher

// Serviço fictício do launcher para a vitrine e a bancada (decisão 0011). Tem a mesma superfície de
// launcher/State.qml: opened, outputName, query, ghost, sections, recents, searching, tools, fallbackRows, deepFiles, holdNotice, decimalSeparator,
// calculation, mode, modeLabel, modeIcon, searchIcon, actions, context, contextLabel, page, colorHistory, colorShown,
// colorFreshStamp, colorCopied, colorInfo, colorOrigin, o menu de ações (actionsItem, actionsLevel, actionsWorkspaces,
// actionsDepth, actionsTitle, actionSections, armedKey) e as funções open, close, toggle, setQuery, acceptGhost,
// copyCommand, copyText, openTool, activate, selectRow, addColor, showColor, copyColor, pickAnother, closePage, openActions,
// backActions e closeActions, o menu de ações do histórico da área de transferência (F6-T16: clipboardService, clipboardDirect,
// actionsFrom e openClipboardActions) e o seletor de emoji (emojiData, emojiQuery, emojiRecents, emojiSections, setEmojiQuery e
// copyEmoji). Os dados são
// inventados: o histórico de cores é o do board, e nada aqui lê arquivo nem roda processo.
// `scenario` escolhe o estado:
//   "empty"        busca vazia com três recentes e as quatro ferramentas
//   "empty-tools"  busca vazia sem recentes (só as ferramentas)
//   "no-result"    busca "xyzzy" que não acha nada, com as duas linhas de ação
//   "no-result-bare" o mesmo sem nenhuma linha de ação (como a F5-T04 o desenhou: divisor em 196, 240 de altura; o serviço de verdade já não cai nele, porque "Search the web" sempre aparece)
//   "deep-files"   a busca profunda (F5-T11, "Search files"): a busca "notes" com uma seção só, "Files", de seis arquivos, alguns em
//                  pastas ocultas (`~/.config/...` fictícias), a primeira selecionada
//   "no-result-deep" a busca profunda que não achou nada: o "Nothing found" só com "Search the web" (divisor em 244, 288 de altura)
//   "typing", "grouped" ou "calc" (a busca é `expression`, o cálculo ocupa o launcher).
//   "confirm"      o "grouped" com a linha "Power off now" armada: o primeiro Enter num comando perigoso deixa o detalhe
//                  em "Press ↵ again to confirm" (a peça de verdade faz isso no State.qml; aqui o dado já vem assim).
//   "actions-app", "actions-file", "actions-command", "actions-command-armed", "actions-workspaces" e "actions-calc": o menu
//                  de ações (Ctrl+K, F5-T05) do app "Notes", do arquivo "meeting-notes.md", do comando "Power off now" (e
//                  com ele armado), da escolha do workspace do "Notes" (quatro workspaces fictícios) e do cálculo. A busca
//                  é a do "grouped" ("no"), e a do cálculo é `expression`.
//   "color"        a página de resultado do seletor de cor: #3FA9D9 "pega agora" no Firefox e o histórico do board.
//                  `copied` ("", "hex", "rgb" ou "hsl") deixa a linha em "Copied".
//   "clipboard"    a página do histórico da área de transferência (F6-T05): só o `page`, o modo e o ícone; o que ela mostra é do
//                  serviço fictício dela (demo/ClipboardService.qml) e a vitrine é demo/ClipboardSpecimen.qml.
//   "emoji", "emoji-empty", "emoji-search" e "emoji-none": o seletor de emoji (F5-T09). A grade com os onze recentes do board
//                  (👋 👍 🎮 🔥 ✨ 🙏 😂 💜 ☕ 🚀 ✅), a mesma sem recentes, a busca `emojiText` (padrão "gato", que mostra que o
//                  português funciona) e a busca "xyzzy", sem resultado. O inventário é o emoji.json de verdade, lido na primeira
//                  vez que o cenário precisa dele: não é dado da máquina.
// O cálculo usa a mesma biblioteca da peça de verdade. As linhas de ação seguem o texto que estiver na busca em
// qualquer cenário, menos no "no-result-bare", para o teste de comportamento poder digitar algo que não acha nada.
QtObject {
  id: root

  property string scenario: "empty"
  // Só no cenário "calc": o que digitei na busca.
  property string expression: "128*3.5+12"
  // Fixo no ponto, para o espécime não depender do locale da máquina; o de verdade lê Qt.locale().
  property string decimalSeparator: "."

  // O número do workspace de onde o launcher foi aberto pelo "+" (0: aberto pelo atalho, sem etiqueta).
  // No serviço de verdade `context` é { workspaceId, number }; aqui o id não importa.
  property int contextNumber: 0
  readonly property var context: contextNumber > 0 ? { workspaceId: -1, number: contextNumber } : null
  readonly property string contextLabel: context ? "On workspace " + context.number : ""

  // Só no cenário "color": a linha recém-copiada ("", "hex", "rgb" ou "hsl").
  property string copied: ""

  property bool opened: true
  property string outputName: ""
  // Só no cenário "emoji-search": o que digitei na busca do emoji.
  property string emojiText: "gato"

  property string query: scenario === "typing" ? "ter" : scenario === "grouped" || scenario === "confirm" ? "no"
      : scenario === "calc" || scenario === "actions-calc" ? expression
      : isActions ? "no"
      : scenario === "deep-files" ? "notes"
      : scenario === "no-result" || scenario === "no-result-bare" || scenario === "no-result-deep" ? "xyzzy" : ""
  property string ghost: scenario === "typing" ? "minal" : ""
  property var sections: scenario === "typing" ? typingSections
      : scenario === "grouped" ? groupedSections
      : scenario === "confirm" ? confirmSections
      : scenario === "deep-files" ? deepSections : []
  property var recents: scenario === "empty" ? recentRows : []
  // O serviço de verdade tem uma busca de arquivos assíncrona; aqui os dados já estão prontos.
  readonly property bool searching: false
  readonly property var tools: [
    { key: "color", label: "Color picker", icon: "pipette" },
    { key: "emoji", label: "Emoji", icon: "smile" },
    { key: "screenshot", label: "Screenshot", icon: "scan" },
    { key: "clipboard", label: "Clipboard", icon: "clipboard" }
  ]
  // As mesmas linhas do serviço de verdade (Search.fallbackRows): as duas, só a da web depois da busca profunda, ou nenhuma.
  readonly property var fallbackRows: scenario === "no-result-bare" ? [] : Search.fallbackRows(query.trim(), !deepFiles)
  // A busca profunda ligada (F5-T11), e o aviso segurado até a resposta: o fictício já tem a resposta, então nunca segura.
  readonly property bool deepFiles: scenario === "deep-files" || scenario === "no-result-deep"
  readonly property bool holdNotice: false

  // Os arquivos da busca profunda, como o `fd` os devolveria (caminhos absolutos separados por NUL, a pasta termina em "/"),
  // e as seções que o serviço de verdade tira deles (Search.deepSections). A pasta pessoal fictícia é a dos outros cenários.
  readonly property string deepOutput: [
    "/home/user/Documents/notes.md",
    "/home/user/.config/notes-app/notes.json",
    "/home/user/Downloads/release-notes.txt",
    "/home/user/.local/share/notes-app/notes.sqlite",
    "/home/user/Documents/work/meeting-notes.md",
    "/home/user/.local/share/notes/"
  ].join("\0") + "\0"
  readonly property var deepSections: Search.deepSections("notes", Search.fileRows(deepOutput, "/home/user"))

  readonly property var calculation: Calculator.describe(query, decimalSeparator)

  // A página aberta no lugar da busca: "", "color", "emoji", "clipboard" ou "actions".
  // O histórico da área de transferência para o menu Ctrl+K da página dele (F6-T16): o espécime liga o serviço fictício dele aqui. Aberta
  // direto (Super+V), a página fecha o launcher no Esc; `actionsFrom` é de onde o menu abriu ("" ou "clipboard").
  property var clipboardService: null
  property bool clipboardDirect: false
  property string actionsFrom: ""
  readonly property bool isActions: scenario.indexOf("actions-") === 0
  readonly property bool isEmoji: scenario.indexOf("emoji") === 0
  property string page: scenario === "color" ? "color" : isActions ? "actions" : isEmoji ? "emoji" : scenario === "clipboard" ? "clipboard" : ""

  readonly property bool calculating: calculation !== null && page !== "actions"
  readonly property string mode: page === "color" ? "color" : page === "emoji" ? "emoji" : page === "clipboard" ? "clipboard" : calculating ? "calculator" : "launcher"
  // O menu de ações aberto da página do histórico mantém o modo "Clipboard" no rodapé (F6-T16); os outros menus são do "Launcher".
  readonly property bool clipboardMenu: page === "actions" && actionsFrom === "clipboard"
  readonly property string modeLabel: page === "color" ? "Color picker" : page === "emoji" ? "Emoji" : page === "clipboard" || clipboardMenu ? "Clipboard" : calculating ? "Calculator" : "Launcher"
  readonly property string modeIcon: page === "color" ? "pipette" : page === "emoji" ? "smile" : page === "clipboard" || clipboardMenu ? "clipboard" : calculating ? "calculator" : "sparkles"
  readonly property string searchIcon: calculation ? "calculator" : "search"
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

  // Para o teste de comportamento: a última linha ativada e quantas vezes, e o que seria copiado (este
  // serviço não roda processo nenhum).
  property var lastActivated: null
  property int activations: 0
  property int closes: 0
  property string lastCopied: ""
  property int copies: 0
  // A última ferramenta pedida e quantas vezes (este serviço não abre nada).
  property string lastTool: ""
  property int toolOpens: 0

  // O histórico de cores do board (nó 13:17499): a mais nova primeiro. A data é inventada, e a primeira entrou agora.
  readonly property var boardColors: [
    { hex: "#3FA9D9", pickedAt: "2026-11-17T14:32:00.000Z", app: "Firefox" },
    { hex: "#F4A846", pickedAt: "2026-11-17T11:05:00.000Z", app: "Ghostty" },
    { hex: "#7F89E1", pickedAt: "2026-11-16T19:48:00.000Z", app: "" },
    { hex: "#88D59C", pickedAt: "2026-11-16T09:12:00.000Z", app: "Files" },
    { hex: "#F7B2B1", pickedAt: "2026-11-15T16:20:00.000Z", app: "" },
    { hex: "#E8E3D3", pickedAt: "2026-11-15T10:01:00.000Z", app: "Firefox" },
    { hex: "#2A2C31", pickedAt: "2026-11-14T22:30:00.000Z", app: "" },
    { hex: "#C2C4C7", pickedAt: "2026-11-14T08:44:00.000Z", app: "Ghostty" },
    { hex: "#12445C", pickedAt: "2026-11-13T17:09:00.000Z", app: "" },
    { hex: "#F68B43", pickedAt: "2026-11-13T12:56:00.000Z", app: "Firefox" },
    { hex: "#4D2F5C", pickedAt: "2026-11-12T20:15:00.000Z", app: "" },
    { hex: "#0D0E11", pickedAt: "2026-11-12T07:38:00.000Z", app: "Files" }
  ]
  property var colorHistory: scenario === "color" ? boardColors : []
  property var colorShown: scenario === "color" ? boardColors[0] : null
  property string colorFreshStamp: scenario === "color" ? boardColors[0].pickedAt : ""
  property string colorCopied: copied
  readonly property var colorInfo: colorShown ? Colors.describe(colorShown.hex) : null
  // O fictício não formata a data no locale da máquina (o espécime não pode depender dele): as cores do histórico
  // mostram a data em ISO, curta.
  readonly property string colorOrigin: colorShown
      ? Colors.originText(colorShown, colorShown.pickedAt === colorFreshStamp, colorShown.pickedAt.substring(0, 16).replace("T", " "))
      : ""
  // Para o teste de comportamento: quantas vezes a lupa foi pedida (o fictício não abre nada).
  property int pickRequests: 0

  // O QtObject não tem propriedade padrão para filhos, então o relógio entra como propriedade.
  readonly property Timer copiedTimer: Timer {
    interval: Theme.launcherCopiedDuration
    onTriggered: root.colorCopied = ""
  }

  readonly property var recentRows: [
    { title: "Ghostty", detail: "Terminal", kind: "App", icon: "terminal" },
    { title: "Firefox", detail: "Browser", kind: "App", icon: "globe" },
    { title: "Files", detail: "Nautilus", kind: "App", icon: "folder" }
  ]

  readonly property var typingSections: [
    {
      label: "Best match",
      rows: [
        { title: "Terminal", detail: "Ghostty", kind: "App", icon: "terminal" },
        { title: "Keyboard", detail: "Settings › System", kind: "Setting", icon: "settings" },
        { title: "terms-of-use.pdf", detail: "~/Documents", kind: "File", icon: "file-text" }
      ]
    }
  ]

  readonly property var groupedSections: [
    {
      label: "Apps",
      rows: [
        { title: "Notes", detail: "Text editor", kind: "App", icon: "file-text", target: { type: "app", id: "notes", entry: null } },
        { title: "Night mode", detail: "Night light", kind: "Command", icon: "moon", target: { type: "app", id: "night-mode", entry: null } }
      ]
    },
    {
      label: "Files",
      rows: [
        { title: "meeting-notes.md", detail: "~/Documents", kind: "File", icon: "file-text",
          target: { type: "file", path: "/home/user/Documents/meeting-notes.md", directory: false } },
        { title: "november.png", detail: "~/Pictures", kind: "File", icon: "image",
          target: { type: "file", path: "/home/user/Pictures/november.png", directory: false } }
      ]
    },
    {
      label: "Settings",
      rows: [
        { title: "Display · Scale", detail: "Settings › Display", kind: "Setting", icon: "monitor",
          target: { type: "setting", page: "display" } }
      ]
    },
    {
      label: "Commands",
      rows: [
        { title: "Power off now", detail: "Session", kind: "Command", icon: "power", danger: true,
          target: { type: "command", action: "shutdown" } }
      ]
    }
  ]

  // O "grouped" com o comando perigoso armado: o único detalhe que muda é o da última linha.
  readonly property var confirmSections: groupedSections.map(section => ({
    label: section.label,
    rows: section.rows.map(row => row.danger ? Object.assign({}, row, { detail: "Press ↵ again to confirm" }) : row)
  }))

  // ---- Seletor de emoji (F5-T09) ----
  // O mesmo leitor da peça de verdade, sobre o emoji.json do repositório.
  readonly property Launcher.EmojiInventory inventory: Launcher.EmojiInventory {}
  onScenarioChanged: {
    if (isEmoji)
      inventory.ensure();
  }
  Component.onCompleted: {
    if (isEmoji)
      inventory.ensure();
  }
  readonly property var emojiData: inventory.data
  // Os onze recentes do board (13:17572), o mais novo primeiro.
  readonly property var boardEmojis: ["👋", "👍", "🎮", "🔥", "✨", "🙏", "😂", "💜", "☕", "🚀", "✅"]
  property string emojiQuery: scenario === "emoji-search" ? emojiText : scenario === "emoji-none" ? "xyzzy" : ""
  property var emojiRecents: scenario === "emoji-empty" ? [] : boardEmojis
  readonly property var emojiSections: page === "emoji" ? Emoji.buildSections(emojiData, emojiQuery, emojiRecents) : []
  function setEmojiQuery(text) { emojiQuery = text; }
  // Copiar anota o texto e fecha, como a peça de verdade (que também grava os recentes em arquivo; aqui só em memória).
  function copyEmoji(ch) {
    copyText(ch);
    emojiRecents = Emoji.pushRecent(emojiRecents, ch);
    close();
  }
  function openEmoji() {
    inventory.ensure();
    emojiQuery = "";
    page = "emoji";
  }

  // ---- Menu de ações (F5-T05) ----
  // Os ids dos apps "recentes": o "Notes" está entre eles, então o menu dele oferece "Remove from recent".
  property var recentIds: ["notes"]
  property string armedKey: scenario === "actions-command-armed" ? "command:shutdown" : ""
  // O item de cada cenário: uma linha do "grouped" (ou a linha do cálculo).
  readonly property var actionsItemOfScenario: scenario === "actions-file" ? groupedSections[1].rows[0]
      : scenario === "actions-command" || scenario === "actions-command-armed" ? groupedSections[3].rows[0]
      : scenario === "actions-calc" && calculation ? calculation.rows[0]
      : isActions ? groupedSections[0].rows[0] : null
  property var actionsItem: actionsItemOfScenario
  property string actionsLevel: scenario === "actions-workspaces" ? "workspaces" : "actions"
  // Quatro workspaces fictícios do monitor; o último é a linha de criação, ainda sem número (vale a posição, 4).
  readonly property var workspaceEntries: [
    { outputName: outputName, workspaceId: 101, sidebarWorkspaceNumber: 1, sidebarRowOrdinal: 0 },
    { outputName: outputName, workspaceId: 102, sidebarWorkspaceNumber: 2, sidebarRowOrdinal: 1 },
    { outputName: outputName, workspaceId: 103, sidebarWorkspaceNumber: 3, sidebarRowOrdinal: 2 },
    { outputName: outputName, workspaceId: 104, sidebarWorkspaceNumber: 0, sidebarRowOrdinal: 3 }
  ]
  property var actionsWorkspaces: scenario === "actions-workspaces" ? Actions.workspaceRows(workspaceEntries, outputName) : []
  readonly property int actionsDepth: page !== "actions" ? 0 : actionsLevel === "workspaces" ? 2 : 1
  readonly property string actionsTitle: Actions.itemTitle(actionsItem, calculation)
  readonly property var actionSections: page !== "actions" ? [] : [{
    label: actionsLevel === "workspaces" ? "Open on workspace" : "Actions",
    rows: (actionsLevel === "workspaces" ? actionsWorkspaces : Actions.rowsFor(actionsItem, recentIds, calculation))
        .map(row => armedKey !== "" && Search.rowKey(row) === armedKey
            ? Object.assign({}, row, { detail: "Press ↵ again to confirm" }) : row)
  }]
  // Para o teste de comportamento: o último workspace escolhido e o que o menu faria sem rodar nada.
  property int lastWorkspaceId: -1
  property string lastActionsEffect: ""

  function openActions(row) {
    if (page !== "" || Actions.rowsFor(row, recentIds, calculation).length === 0)
      return false;
    armedKey = "";
    actionsItem = row;
    actionsFrom = "";
    actionsLevel = "actions";
    actionsWorkspaces = [];
    page = "actions";
    return true;
  }
  function openClipboardActions(item) {
    if (page !== "clipboard")
      return false;
    const unpinned = ((clipboardService ? clipboardService.items : null) || []).filter(entry => !entry.pinned).length;
    const row = { title: item ? String(item.title || "") : "Clipboard", clipboard: { item: item || null, unpinned: unpinned } };
    if (Actions.rowsFor(row, recentIds, calculation).length === 0)
      return false;
    armedKey = "";
    actionsItem = row;
    actionsFrom = "clipboard";
    actionsLevel = "actions";
    actionsWorkspaces = [];
    page = "actions";
    return true;
  }
  function closeActions() {
    if (page !== "actions")
      return;
    const back = actionsFrom;
    armedKey = "";
    actionsFrom = "";
    page = back;
    actionsItem = null;
    actionsLevel = "actions";
    actionsWorkspaces = [];
  }
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
  // O que cada ação faria, anotado em `lastActionsEffect`; só o que muda a página de fato acontece.
  function activateAction(row) {
    if (row.act === "workspaces") {
      actionsWorkspaces = Actions.workspaceRows(workspaceEntries, outputName);
      actionsLevel = "workspaces";
    } else if (row.act === "remove-recent") {
      lastActionsEffect = "forget " + actionsItem.target.id;
      recentIds = Search.dropRecent(recentIds, actionsItem.target.id);
      closeActions();
    } else if (row.act === "show-folder") {
      lastActionsEffect = "folder " + Actions.parentDirectory(actionsItem.target.path);
      close();
    } else if (row.act === "pick-workspace") {
      lastWorkspaceId = row.workspaceId;
      lastActionsEffect = "workspace " + row.workspaceId;
      close();
    } else if (row.act === "clipboard-copy") {
      clipboardService.copy(actionsItem.clipboard.item);
      close();
    } else if (row.act === "clipboard-pin") {
      clipboardService.togglePin(actionsItem.clipboard.item);
      closeActions();
    } else if (row.act === "clipboard-delete") {
      clipboardService.remove(actionsItem.clipboard.item);
      closeActions();
    } else if (row.act === "clipboard-clear") {
      if (armedKey !== Search.rowKey(row)) {
        armedKey = Search.rowKey(row);
        return;
      }
      clipboardService.clear();
      closeActions();
    } else if (row.copy !== undefined) {
      copyText(String(row.copy));
      close();
    } else if (row.target && row.target.type === "command" && row.danger && armedKey !== Search.rowKey(row)) {
      armedKey = Search.rowKey(row);
    } else {
      lastActionsEffect = "run " + row.target.type;
      close();
    }
  }

  // A peça avisa a linha selecionada; o fictício só guarda, para o teste de comportamento.
  property var lastSelectedRow: null
  function selectRow(row) { lastSelectedRow = row; }

  function open(requestedOutputName, requestedContext) { opened = true; }
  function close() { opened = false; closes += 1; }
  function toggle(requestedOutputName) { opened = !opened; }
  function setQuery(text) { query = text; ghost = ""; }
  function acceptGhost() {
    if (ghost !== "")
      setQuery(query + ghost);
  }
  function copyCommand(text) { return ["wl-copy", "--", text]; }
  function copyText(text) {
    lastCopied = text;
    copies += 1;
  }
  function openTool(key) {
    lastTool = key;
    toolOpens += 1;
    if (key === "emoji")
      openEmoji();
    if (key === "color") {
      if (colorHistory.length > 0) {
        colorShown = colorHistory[0];
        page = "color";
      } else {
        pickAnother();
      }
    }
  }
  function addColor(hex, app) {
    const clean = Colors.normalizeHex(hex);
    if (clean === "")
      return false;
    const entry = { hex: clean, pickedAt: "2026-11-17T15:00:00.000Z", app: app ? String(app) : "" };
    colorHistory = Colors.pushHistory(colorHistory, entry, Theme.launcherColorHistoryMax);
    colorFreshStamp = entry.pickedAt;
    colorShown = colorHistory[0];
    page = "color";
    return true;
  }
  function showColor(index) {
    if (index >= 0 && index < colorHistory.length)
      colorShown = colorHistory[index];
  }
  function copyColor(format) {
    const info = colorInfo;
    if (!info || ["hex", "rgb", "hsl"].indexOf(format) < 0)
      return;
    copyText(info[format]);
    colorCopied = format;
    root.copiedTimer.restart();
  }
  function pickAnother() { pickRequests += 1; }
  function closePage() {
    root.copiedTimer.stop();
    page = "";
    colorShown = null;
    emojiQuery = "";
    setQuery("");
  }
  function activate(row) {
    lastActivated = row;
    activations += 1;
    if (page === "actions" && row) {
      activateAction(row);
      return;
    }
    if (row && row.copy !== undefined)
      copyText(String(row.copy));
    close();
  }
}
