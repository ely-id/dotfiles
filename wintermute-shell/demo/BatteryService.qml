import QtQuick

// Estado de bateria fictício para a vitrine da F3 (ficha 08): 72%, carregando a 18 W, perfil Equilibrado.
QtObject {
  id: root
  property real percentage: 72
  property bool charging: true
  property bool chargingNow: true
  property real changeRate: 18
  property real timeToFull: 4800
  property real timeToEmpty: 0
  property string selectedProfile: "balanced"
  readonly property int level: Math.round(percentage)
  readonly property bool low: !charging && level <= 10
  readonly property var profiles: [
    { key: "power-saver", name: "Power saver", icon: "leaf" },
    { key: "balanced", name: "Balanced", icon: "gauge" },
    { key: "performance", name: "Performance", icon: "zap" }
  ]

  function profileAvailable(key) { return true; }
  function setProfile(key) { selectedProfile = key; }
}
