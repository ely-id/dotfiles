import QtQuick

// Estado de Bluetooth fictício para a vitrine da F3 (ficha 06). Mesma superfície de
// bluetooth/State.qml, só com dados de exemplo (nenhum dispositivo real da máquina).
QtObject {
  id: root
  property bool available: true
  property bool enabled: true
  property bool blocked: false
  property bool discovering: false
  property bool panelOpen: false
  property bool powerBusy: false
  property string errorText: ""
  property var prompt: ({ kind: "" })
  readonly property var devices: [
    { path: "/demo/p1", address: "00:11:22:33:44:01", name: "Fones Lume", deviceName: "Fones Lume",
      icon: "headphones", type: "Fone de ouvido", connected: true, paired: true, bonded: true,
      trusted: true, blocked: false, battery: 82, model: "", nativeBusy: false },
    { path: "/demo/p2", address: "00:11:22:33:44:02", name: "Teclado K3", deviceName: "Teclado K3",
      icon: "keyboard", type: "Teclado", connected: false, paired: true, bonded: true,
      trusted: true, blocked: false, battery: 64, model: "", nativeBusy: false },
    { path: "/demo/p3", address: "00:11:22:33:44:03", name: "Mouse MX", deviceName: "Mouse MX",
      icon: "mouse", type: "Mouse", connected: false, paired: true, bonded: true,
      trusted: true, blocked: false, battery: -1, model: "", nativeBusy: true },
    { path: "/demo/p4", address: "00:11:22:33:44:04", name: "Controle", deviceName: "Controle",
      icon: "gamepad-2", type: "Controle", connected: false, paired: true, bonded: true,
      trusted: true, blocked: false, battery: -1, model: "", nativeBusy: false },
    { path: "/demo/n1", address: "00:11:22:33:44:11", name: "Caixa Orbe", deviceName: "Caixa Orbe",
      icon: "speaker", type: "Alto-falante", connected: false, paired: false, bonded: false,
      trusted: false, blocked: false, battery: -1, model: "", nativeBusy: false },
    { path: "/demo/n2", address: "00:11:22:33:44:12", name: "Buds Pro", deviceName: "Buds Pro",
      icon: "headphones", type: "Fone de ouvido", connected: false, paired: false, bonded: false,
      trusted: false, blocked: false, battery: -1, model: "", nativeBusy: false },
    { path: "/demo/n3", address: "00:11:22:33:44:13", name: "Celular Aurora", deviceName: "Celular Aurora",
      icon: "smartphone", type: "Celular", connected: false, paired: false, bonded: false,
      trusted: false, blocked: false, battery: -1, model: "", nativeBusy: false }
  ]
  readonly property var pairedDevices: devices.filter(d => d.paired)
  readonly property var nearbyDevices: devices.filter(d => !d.paired)
  signal panelCommand(string command, string outputName)
  signal actionFinished(string path, string action, bool success)

  function deviceFor(path) { return devices.find(d => d.path === path) || null; }
  function isBusy(path) { const device = deviceFor(path); return !!device && device.nativeBusy; }
  function failed(path) { return false; }
  function activate(device) {}
  function forget(device) {}
  function setEnabled(value) { enabled = value; }
  function answer(accept, value) {}
  function cancelPairing() { prompt = { kind: "" }; }
  function setDiscoveryConsumer(owner, active) {}
}
