import QtQuick
import QtQuick.Effects
import ".." as Shell

// Indicador de bateria 16×16 com ícones Lucide (ficha 04, relógio recolhido).
Item {
  id: root
  property real percentage: 0
  property bool charging: false
  property color color: Shell.Theme.text
  implicitWidth: 16
  implicitHeight: 16

  readonly property string iconName: charging ? "battery-charging.svg"
      : percentage <= 20 ? "battery-low.svg"
      : percentage <= 75 ? "battery-medium.svg"
      : "battery-full.svg"

  Image {
    anchors.fill: parent
    source: Qt.resolvedUrl("../icons/" + root.iconName)
    sourceSize: Qt.size(32, 32)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: root.color
    }
  }
}
