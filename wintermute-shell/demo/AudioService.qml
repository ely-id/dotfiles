import QtQuick

// Estado de áudio fictício para a vitrine da F3 (ficha 07), com a mesma superfície de audio/State.qml.
QtObject {
  id: root
  property real outputVolume: 0.60
  property real inputVolume: 0.60
  property bool hasOutput: true
  property bool hasInput: true
  property bool outputMuted: false
  readonly property var outputDevices: [
    { id: 1, description: "Alto-falantes", icon: "speaker" },
    { id: 2, description: "Fones Lume", icon: "headphones" },
    { id: 3, description: "HDMI · Monitor", icon: "monitor" }
  ]
  readonly property var inputDevices: [
    { id: 11, description: "Microfone interno", icon: "mic" },
    { id: 12, description: "Fones Lume", icon: "headphones" },
    { id: 13, description: "Webcam", icon: "mic" }
  ]
  readonly property var sink: outputDevices[0]
  readonly property var source: inputDevices[0]

  function displayName(node) { return node ? node.description : ""; }
  function deviceIcon(node) { return node ? node.icon : "speaker"; }
  function setOutputVolume(value) { outputVolume = value; }
  function setInputVolume(value) { inputVolume = value; }
  function setOutputDevice(node) {}
  function setInputDevice(node) {}
  function refreshPorts() {}
}
