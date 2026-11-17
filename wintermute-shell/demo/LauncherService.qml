import QtQuick
import "../launcher/Calculator.js" as Calculator

// Serviço fictício do launcher para a vitrine e a bancada (decisão 0011). Tem a mesma superfície de
// launcher/State.qml: opened, outputName, query, ghost, sections, decimalSeparator, calculation, mode,
// modeLabel, modeIcon, searchIcon, actions e as funções open, close, toggle, setQuery, acceptGhost, copyCommand,
// copyText e activate. Os dados são inventados.
// `scenario` escolhe o estado: "empty-shell" (sem seções), "typing", "grouped" ou "calc" (a busca é
// `expression`, o cálculo ocupa o launcher). O cálculo usa a mesma biblioteca da peça de verdade.
QtObject {
  id: root

  property string scenario: "empty-shell"
  // Só no cenário "calc": o que digitei na busca.
  property string expression: "128*3.5+12"
  // Fixo no ponto, para o espécime não depender do locale da máquina; o de verdade lê Qt.locale().
  property string decimalSeparator: "."

  property bool opened: true
  property string outputName: ""
  property string query: scenario === "typing" ? "ter" : scenario === "grouped" ? "no"
      : scenario === "calc" ? expression : ""
  property string ghost: scenario === "typing" ? "minal" : ""
  property var sections: scenario === "typing" ? typingSections
      : scenario === "grouped" ? groupedSections : []

  readonly property var calculation: Calculator.describe(query, decimalSeparator)

  readonly property string mode: calculation ? "calculator" : "launcher"
  readonly property string modeLabel: calculation ? "Calculator" : "Launcher"
  readonly property string modeIcon: calculation ? "calculator" : "sparkles"
  readonly property string searchIcon: calculation ? "calculator" : "search"
  readonly property var actions: calculation ? [
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

  function open(requestedOutputName) { opened = true; }
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
  function activate(row) {
    if (row && row.copy !== undefined)
      copyText(String(row.copy));
    lastActivated = row;
    activations += 1;
    close();
  }
}
