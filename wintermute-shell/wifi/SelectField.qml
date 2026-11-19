import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Effects
import ".."

// Seletor Armitage (ficha 05): 276×44, raio 12, fundo control (hover pressed), borda border,
// texto 13 Medium e chevron-down 16 à direita.
Controls.Button {
  id: root
  implicitWidth: Theme.panelFieldWidth
  implicitHeight: Theme.panelFieldHeight
  hoverEnabled: true
  focusPolicy: Qt.StrongFocus
  leftPadding: 16
  rightPadding: 44
  Keys.onReturnPressed: clicked()
  Keys.onEnterPressed: clicked()
  HoverHandler { cursorShape: Qt.PointingHandCursor }

  background: Rectangle {
    radius: Theme.radiusRow
    color: root.hovered ? Theme.pressed : Theme.control
    border.width: root.activeFocus ? 1.5 : 1
    border.color: root.activeFocus ? Theme.accent : Theme.border
    antialiasing: true
  }
  contentItem: Text {
    text: root.text
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    color: Theme.text
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }
  Image {
    anchors.right: parent.right
    anchors.rightMargin: 14
    anchors.verticalCenter: parent.verticalCenter
    width: 16
    height: 16
    source: Qt.resolvedUrl("../icons/chevron-down.svg")
    sourceSize: Qt.size(32, 32)
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: Theme.muted
    }
  }
}
