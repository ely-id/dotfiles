import QtQuick

// Serviço fictício do launcher para a vitrine e a bancada (decisão 0011). Tem a mesma superfície de
// launcher/State.qml: opened, outputName, query, ghost, sections, mode, modeLabel, modeIcon, actions e as
// funções open, close, toggle, setQuery, acceptGhost e activate. Os dados são inventados.
// `scenario` escolhe o estado: "empty-shell" (sem seções), "typing" ou "grouped".
QtObject {
  id: root

  property string scenario: "empty-shell"

  property bool opened: true
  property string outputName: ""
  property string query: scenario === "typing" ? "ter" : scenario === "grouped" ? "no" : ""
  property string ghost: scenario === "typing" ? "minal" : ""
  property var sections: scenario === "typing" ? typingSections
      : scenario === "grouped" ? groupedSections : []

  readonly property string mode: "launcher"
  readonly property string modeLabel: "Launcher"
  readonly property string modeIcon: "sparkles"
  readonly property var actions: [
    { label: "Open", keys: ["↵"], primary: true },
    { label: "Actions", keys: ["Ctrl", "K"], primary: false }
  ]

  // Para o teste de comportamento: a última linha ativada e quantas vezes.
  property var lastActivated: null
  property int activations: 0
  property int closes: 0

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
  function activate(row) {
    lastActivated = row;
    activations += 1;
    close();
  }
}
