import QtQuick
import ".."

Item {
  id: root
  property int bars: 3
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
  }
}
