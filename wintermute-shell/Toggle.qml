import QtQuick

// Chave (toggle) Armitage (ficha 00):
// 54×28, raio 14. Botão 22×22 em y 3; desligada em x 3, ligada em x 29.
// Ligada: fundo accent (hover accentHover), botão textOnAccent.
// Desligada: fundo track + borda border (hover soma hover), botão muted.
// Movimento: 200 ms, curva [0.77, 0, 0.175, 1].
Rectangle {
  id: root

  property bool checked: false
  property bool busy: false
  property bool forceHovered: false
  readonly property bool hovered: forceHovered || (toggleMouse.containsMouse && root.enabled)
  property int animationDuration: Theme.toggleDuration
  property real trackAlpha: 0.12
  signal toggled(bool checked)
  property real position: checked ? 1 : 0

  implicitWidth: 54
  implicitHeight: 28
  radius: Theme.radiusToggle
  color: checked
      ? (hovered ? Theme.accentHover : Theme.accent)
      : Qt.rgba(1, 1, 1, trackAlpha + (hovered ? 0.06 : 0))
  border.width: checked ? 0 : 1
  border.color: Theme.border
  antialiasing: true

  Behavior on position {
    NumberAnimation {
      duration: root.animationDuration
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Theme.toggleCurve
    }
  }

  Behavior on color {
    ColorAnimation {
      duration: root.animationDuration
      easing.type: Easing.BezierSpline
      easing.bezierCurve: Theme.toggleCurve
    }
  }

  Item {
    x: Math.round(3 + 26 * root.position)
    y: 3
    width: 22
    height: 22

    Shadow {
      anchors.fill: parent
      cornerRadius: 11
      strength: 0.5
    }

    Rectangle {
      anchors.fill: parent
      radius: 11
      antialiasing: true
      color: root.checked ? Theme.textOnAccent : Theme.muted

      Behavior on color {
        ColorAnimation {
          duration: root.animationDuration
          easing.type: Easing.BezierSpline
          easing.bezierCurve: Theme.toggleCurve
        }
      }
    }
  }

  MouseArea {
    id: toggleMouse
    anchors.fill: parent
    enabled: root.enabled && !root.forceHovered
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: if (!root.busy) root.toggled(!root.checked)
  }
}
