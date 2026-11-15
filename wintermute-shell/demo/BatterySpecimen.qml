import QtQuick
import ".."
import "../battery" as Battery

// O pop-up da bateria (battery/Card.qml) ou o alerta de bateria baixa (battery/AlertCard.qml) de
// verdade, com estado fictício. `kind`: "popup" ou "alert".
Item {
  id: root
  property string kind: "popup"
  property real percentage: 72
  property bool charging: true
  property string profile: "balanced"
  implicitWidth: kind === "alert" ? 176 : 280
  implicitHeight: kind === "alert" ? 40 : 232

  BatteryService {
    id: demoService
    percentage: root.percentage
    charging: root.charging
    chargingNow: root.charging
    changeRate: root.charging ? 18 : 0
    timeToFull: root.charging ? 4800 : 0
    timeToEmpty: root.charging ? 0 : 7500
    selectedProfile: root.profile
  }

  Shadow {
    anchors.fill: popup
    visible: root.kind === "popup"
    cornerRadius: popup.radius
    shadows: Theme.glassShadows
  }
  Battery.Card {
    id: popup
    visible: root.kind === "popup"
    service: demoService
  }
  Battery.AlertCard {
    visible: root.kind === "alert"
    service: demoService
  }
}
