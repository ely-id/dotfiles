import QtQuick
import ".."
import "../launcher/Calculator.js" as Calculator
import "../launcher/Colors.js" as Colors

// Serviço fictício do launcher para a vitrine e a bancada (decisão 0011). Tem a mesma superfície de
// launcher/State.qml: opened, outputName, query, ghost, sections, recents, tools, fallbackRows, decimalSeparator,
// calculation, mode, modeLabel, modeIcon, searchIcon, actions, context, contextLabel, page, colorHistory, colorShown,
// colorFreshStamp, colorCopied, colorInfo, colorOrigin e as funções open, close, toggle, setQuery, acceptGhost,
// copyCommand, copyText, openTool, activate, addColor, showColor, copyColor, pickAnother e closePage. Os dados são
// inventados: o histórico de cores é o do board, e nada aqui lê arquivo nem roda processo.
// `scenario` escolhe o estado:
//   "empty"        busca vazia com três recentes e as quatro ferramentas
//   "empty-tools"  busca vazia sem recentes (só as ferramentas)
//   "no-result"    busca "xyzzy" que não acha nada, com as duas linhas de ação
//   "no-result-bare" o mesmo sem as linhas de ação (o que o serviço de verdade oferece por enquanto)
//   "typing", "grouped" ou "calc" (a busca é `expression`, o cálculo ocupa o launcher).
//   "color"        a página de resultado do seletor de cor: #3FA9D9 "pega agora" no Firefox e o histórico do board.
//                  `copied` ("", "hex", "rgb" ou "hsl") deixa a linha em "Copied".
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
  property string query: scenario === "typing" ? "ter" : scenario === "grouped" ? "no"
      : scenario === "calc" ? expression
      : scenario === "no-result" || scenario === "no-result-bare" ? "xyzzy" : ""
  property string ghost: scenario === "typing" ? "minal" : ""
  property var sections: scenario === "typing" ? typingSections
      : scenario === "grouped" ? groupedSections : []
  property var recents: scenario === "empty" ? recentRows : []
  readonly property var tools: [
    { key: "color", label: "Color picker", icon: "pipette" },
    { key: "emoji", label: "Emoji", icon: "smile" },
    { key: "screenshot", label: "Screenshot", icon: "scan" },
    { key: "clipboard", label: "Clipboard", icon: "clipboard" }
  ]
  readonly property var fallbackRows: scenario === "no-result-bare" ? [] : [
    { title: "Search the web", detail: "“" + query.trim() + "”", kind: "Action", icon: "globe" },
    { title: "Search files", detail: "“" + query.trim() + "”", kind: "Action", icon: "folder" }
  ]

  readonly property var calculation: Calculator.describe(query, decimalSeparator)

  // A página aberta no lugar da busca: "" ou "color".
  property string page: scenario === "color" ? "color" : ""

  readonly property string mode: page === "color" ? "color" : calculation ? "calculator" : "launcher"
  readonly property string modeLabel: page === "color" ? "Color picker" : calculation ? "Calculator" : "Launcher"
  readonly property string modeIcon: page === "color" ? "pipette" : calculation ? "calculator" : "sparkles"
  readonly property string searchIcon: calculation ? "calculator" : "search"
  readonly property var actions: page === "color" ? [
    { label: "Copy HEX", keys: ["↵"], primary: true },
    { label: "Pick another", keys: ["P"], primary: false }
  ] : calculation ? [
    { label: "Copy", keys: ["↵"], primary: true }
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
        { title: "Notes", detail: "Text editor", kind: "App", icon: "file-text" },
        { title: "Night mode", detail: "Night light", kind: "Command", icon: "moon" }
      ]
    },
    {
      label: "Files",
      rows: [
        { title: "meeting-notes.md", detail: "~/Documents", kind: "File", icon: "file-text" },
        { title: "november.png", detail: "~/Pictures", kind: "File", icon: "image" }
      ]
    },
    {
      label: "Settings",
      rows: [
        { title: "Display · Scale", detail: "Settings › Display", kind: "Setting", icon: "monitor" }
      ]
    },
    {
      label: "Commands",
      rows: [
        { title: "Power off now", detail: "Session", kind: "Command", icon: "power", danger: true }
      ]
    }
  ]

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
    setQuery("");
  }
  function activate(row) {
    if (row && row.copy !== undefined)
      copyText(String(row.copy));
    lastActivated = row;
    activations += 1;
    close();
  }
}
