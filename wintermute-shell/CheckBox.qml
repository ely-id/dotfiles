import QtQuick
import QtQuick.Effects

// Caixa de seleção Armitage (ficha 00):
// 20×20 raio 6; desmarcada control + borda borderStrong 1,5;
// marcada fundo accent + check 16 textOnAccent em (2,2).
Item {
  id: root

  property bool checked: false
  signal toggled(bool checked)

  implicitWidth: 20
  implicitHeight: 20

  Rectangle {
    anchors.fill: parent
    radius: 6
    color: root.checked ? Theme.accent
        : checkHover.hovered ? Theme.pressed : Theme.control
    border.width: root.checked ? 0 : 1.5
    border.color: Theme.borderStrong
    antialiasing: true
  }

  Image {
    x: 2
    y: 2
    width: 16
    height: 16
    visible: root.checked
    source: Qt.resolvedUrl("icons/check.svg")
    sourceSize: Qt.size(32, 32)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: Theme.textOnAccent
    }
  }

  HoverHandler {
    id: checkHover
    cursorShape: Qt.PointingHandCursor
  }
  TapHandler {
    onTapped: root.toggled(!root.checked)
  }
}
