import QtQuick
import QtQuick.Effects
import "." as Audio
import ".."

// Linha de dispositivo de som (ficha 07): 300×40 r12, ícone 16 em (12,12), nome 13 Medium em x 40
// e rádio de seleção em (272,12). Hover `hover`.
Item {
  id: root

  property var device
  property var service: Audio.State
  property bool selected: false
  property bool interactive: true
  signal clicked

  implicitWidth: PanelStyle.rowWidth
  implicitHeight: Theme.audioRowHeight

  Rectangle {
    anchors.fill: parent
    radius: Theme.radiusRow
    color: pointer.containsMouse ? Theme.hover : "transparent"
    antialiasing: true

    Behavior on color {
      ColorAnimation {
        duration: Theme.controlDuration
        easing.type: Easing.OutCubic
      }
    }
  }

  Image {
    x: 12; y: 12
    width: 16; height: 16
    source: Qt.resolvedUrl("../icons/" + root.service.deviceIcon(root.device) + ".svg")
    sourceSize: Qt.size(32, 32)
    fillMode: Image.PreserveAspectFit
    smooth: true
    layer.enabled: true
    layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.text }
  }

  Text {
    x: 40
    width: 224
    anchors.verticalCenter: parent.verticalCenter
    text: root.service.displayName(root.device)
    color: Theme.text
    elide: Text.ElideRight
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }

  RadioButton {
    x: 272; y: 12
    checked: root.selected
    interactive: false
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    enabled: root.interactive
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
