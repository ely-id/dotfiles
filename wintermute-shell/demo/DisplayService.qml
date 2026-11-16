import QtQuick

// Estado fictício da Tela para a vitrine da F4 (ficha 13): a tela embutida de 2560×1600 a 165 Hz em
// 125% e um monitor externo de 2560×1440 a 144 Hz, com as bases alinhadas. Mesma superfície de
// settings/display/State.qml. `geometry` pode ser trocada para mostrar outro arranjo em Organizar.
// Nada aqui chama o niri.
QtObject {
  id: root
  signal arrangementApplied

  property var monitors: [
    {
      name: "eDP-1", label: "Built-in", builtin: true, number: 1,
      logical: { x: 0, y: 160, width: 2048, height: 1280 },
      width: 2560, height: 1600, refresh: 165000, scale: 1.25,
      scales: [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2],
      resolutions: [
        { label: "2560 × 1600", value: "2560x1600" },
        { label: "1920 × 1200", value: "1920x1200" }
      ],
      rates: [{ label: "165 Hz", value: "165000" }, { label: "60 Hz", value: "60000" }],
      vrrSupported: true, vrrEnabled: true, orientation: "Normal"
    },
    {
      name: "DP-1", label: "Monitor", builtin: false, number: 2,
      logical: { x: 2048, y: 0, width: 2560, height: 1440 },
      width: 2560, height: 1440, refresh: 144000, scale: 1,
      scales: [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2],
      resolutions: [
        { label: "2560 × 1440", value: "2560x1440" },
        { label: "1920 × 1080", value: "1920x1080" }
      ],
      rates: [{ label: "144 Hz", value: "144000" }, { label: "60 Hz", value: "60000" }],
      vrrSupported: true, vrrEnabled: false, orientation: "Normal"
    }
  ]
  property var geometry: monitors.map(m => Object.assign({ name: m.name, identity: "Fictitious " + m.name }, m.logical))
  property string selectedName: "eDP-1"
  property string error: ""
  property bool loaded: true
  property bool busy: false
  readonly property var selected: monitors.find(m => m.name === selectedName) || null
  readonly property string summary: monitors.length + " monitors"

  function select(name) { selectedName = name; }
  function change(field, value) {
    monitors = monitors.map(m => {
      if (m.name !== selectedName) return m;
      const next = Object.assign({}, m);
      if (field === "vrr") next.vrrEnabled = value === "on";
      else if (field === "scale") next.scale = Number(value);
      else if (field === "refresh") next.refresh = Number(value);
      else if (field === "orientation") {
        const portrait = value === "90" || value === "270";
        const wasPortrait = m.orientation === "90" || m.orientation === "270";
        if (portrait !== wasPortrait)
          next.logical = Object.assign({}, m.logical, { width: m.logical.height, height: m.logical.width });
        next.orientation = value;
      }
      else if (field === "resolution") { const size = value.split("x"); next.width = Number(size[0]); next.height = Number(size[1]); }
      return next;
    });
  }
  function arrange(baseline, positions) { arrangementApplied(); }
}
