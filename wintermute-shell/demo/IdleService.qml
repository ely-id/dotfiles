import QtQuick

// Tempos de inatividade fictícios para a vitrine da F4 (ficha 13), os mesmos do Figma: bloquear em
// 5 min, desligar a tela em 10 min e suspender em 30 min. Mesma superfície de settings/system/Idle.qml.
QtObject {
  id: root
  readonly property var choices: [0, 60, 120, 180, 300, 600, 900, 1200, 1500, 1800, 2700, 3600, 7200]
  readonly property var options: choices.map(seconds => ({ label: label(seconds), value: String(seconds) }))
  property var timeouts: ({
    pluggedIn: { lock: 300, display: 600, sleep: 1800 },
    battery: { lock: 300, display: 600, sleep: 1800 }
  })
  property bool askPasswordOnWake: true
  property string source: "battery"
  readonly property var current: timeouts[source]

  function label(seconds) {
    if (!seconds) return "Never";
    const hours = seconds >= 3600;
    const count = Math.round(seconds / (hours ? 3600 : 60));
    return hours ? count + (count === 1 ? " hour" : " hours") : count + " min";
  }
  function set(power, key, seconds) {
    timeouts = Object.assign({}, timeouts, { [power]: Object.assign({}, timeouts[power], { [key]: seconds }) });
  }
  function setAskPasswordOnWake(enabled) { askPasswordOnWake = enabled; }
}
