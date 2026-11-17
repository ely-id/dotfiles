import QtQuick

// Estado de rede fictício para a vitrine da F3 (ficha 05). Tem a mesma superfície de
// wifi/State.qml, mas só com dados de exemplo (nenhum dado real da máquina).
QtObject {
  id: root
  property bool enabled: true
  property bool panelOpen: false
  property string phase: "idle"
  property string statusText: ""
  readonly property string incorrectPasswordText: "Incorrect password"
  readonly property var wiredNetworks: []
  readonly property var networks: [
    { ssid: "Wintermute-5G", signal: 92, bars: 3, locked: true, connected: true,
      enterprise: false, known: true, uuids: ["demo-1"] },
    { ssid: "Casa_Lima", signal: 70, bars: 3, locked: true, connected: false,
      enterprise: false, known: false, uuids: [] },
    { ssid: "Biblioteca", signal: 30, bars: 1, locked: false, connected: false,
      enterprise: false, known: false, uuids: [] },
    { ssid: "Café Lume", signal: 25, bars: 1, locked: true, connected: false,
      enterprise: false, known: false, uuids: [] }
  ]
  property string connectedSsid: "Wintermute-5G"
  property string linkSpeed: "866 Mb/s"
  property string ipv4: "192.168.0.42"
  property string band: "5 GHz · channel 36"
  property string gateway: "192.168.0.1"
  property string dns: "1.1.1.1"
  property string device: "wlan0"
  signal actionFinished(string kind, bool success, string message)

  function setWifiEnabled(on) { enabled = on; }
  function connectNetwork(ssid, password, hidden, securityMode, enterprise) {}
  function disconnect() {}
  function forget(selection) {}
  function refreshDetails() {}
}
