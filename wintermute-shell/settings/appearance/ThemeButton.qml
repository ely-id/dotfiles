import QtQuick
import QtQuick.Effects
import "../.." as Shell

Item {
  id: root
  required property var theme
  property bool selected: false
  readonly property bool hovered: pointer.containsMouse || activeFocus
  signal clicked
  implicitWidth: 120; implicitHeight: 116
  activeFocusOnTab: true
  Accessible.role: Accessible.RadioButton
  Accessible.name: theme.label
  Accessible.checkable: true
  Accessible.checked: selected
  Accessible.onPressAction: clicked()
  Keys.onReturnPressed: clicked()
  Keys.onSpacePressed: clicked()

  Rectangle {
    id: disc
    x: 16; y: 0
    width: 88; height: 88; radius: 44
    color: root.selected ? Shell.Theme.accentSubtle
        : root.hovered ? Shell.Theme.hover : Shell.Theme.control
    border.width: root.selected ? 2 : 1
    border.color: root.selected ? Shell.Theme.accentRing : Shell.Theme.border
    Behavior on color { ColorAnimation { duration: Shell.Theme.hoverDuration; easing.type: Easing.OutCubic } }

    Rectangle {
      objectName: "themeSymbol"
      x: 24; y: 24
      width: 40; height: 40; radius: 20
      color: root.theme.accent
    }

    Rectangle {
      visible: root.selected
      x: 60; y: 60
      width: 24; height: 24; radius: 12
      color: Shell.Theme.accent
      Image {
        anchors.centerIn: parent
        width: 16; height: 16
        source: Qt.resolvedUrl("../../icons/check.svg")
        sourceSize: Qt.size(32, 32)
        layer.enabled: true
        layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.textOnAccent }
      }
    }
  }

  Text {
    y: 100
    width: parent.width
    horizontalAlignment: Text.AlignHCenter
    text: root.theme.label
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: 13
    color: root.selected || root.hovered ? Shell.Theme.text : Shell.Theme.muted
  }

  MouseArea {
    id: pointer; anchors.fill: parent; hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
