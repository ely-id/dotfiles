import QtQuick
import QtQuick.Effects
import ".."

Item {
  id: root
  property int bars: 3
  // Cor opcional (por exemplo accentText nos detalhes); transparente usa `text`. O SVG é branco puro e a
  // cor vem sempre da colorização (P-64).
  property color tint: "transparent"
  implicitWidth: 20
  implicitHeight: 20

  Image {
    anchors.centerIn: parent
    width: 20
    height: 20
    source: root.bars >= 3
        ? Qt.resolvedUrl("../icons/wifi.svg")
        : root.bars === 2
          ? Qt.resolvedUrl("../icons/wifi-high.svg")
          : Qt.resolvedUrl("../icons/wifi-low.svg")
    sourceSize: Qt.size(40, 40)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: root.tint.a > 0 ? root.tint : Theme.text
    }
  }
}
