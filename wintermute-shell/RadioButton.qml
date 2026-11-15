import QtQuick

// Rádio Armitage (ficha 00):
// 16×16; desmarcado borda borderStrong 1,5;
// marcado fundo accent + miolo 6×6 textOnAccent em (5,5).
Item {
  id: root

  property bool checked: false
  property bool interactive: true
  signal toggled(bool checked)
  signal clicked

  implicitWidth: 16
  implicitHeight: 16

  Rectangle {
    anchors.fill: parent
    radius: 8
    color: root.checked ? Theme.accent : "transparent"
    border.width: root.checked ? 0 : 1.5
    border.color: Theme.borderStrong
    antialiasing: true

    Rectangle {
      x: 5
      y: 5
      width: 6
      height: 6
      radius: 3
      visible: root.checked
      color: Theme.textOnAccent
      antialiasing: true
    }
  }

  HoverHandler {
    id: radioHover
    enabled: root.interactive
    cursorShape: Qt.PointingHandCursor
  }
  TapHandler {
    enabled: root.interactive
    onTapped: {
      root.clicked();
      root.toggled(!root.checked);
    }
  }
}
