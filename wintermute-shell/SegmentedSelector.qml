pragma ComponentBehavior: Bound
import QtQuick

// Seletor segmentado Armitage (ficha 00):
// 168×40, raio 12, borda border.
// Marcador 80×32, raio 8, em x 4 ou 84, y 4, fundo accentSubtle.
// Opção ativa text, inativa muted, Geist 13 Medium.
Rectangle {
  id: root

  property var model: [
    { key: "0", label: firstLabel, width: 80 },
    { key: "1", label: secondLabel, width: 80 }
  ]
  property string firstLabel: "Touchpad"
  property string secondLabel: "Mouse"
  property string current: model.length > 0 ? model[0].key : "0"
  property int selectedIndex: {
    for (let i = 0; i < model.length; ++i) {
      if (model[i].key === current)
        return i;
    }
    return 0;
  }

  signal selected(string key)

  implicitWidth: 168
  implicitHeight: 40
  width: 168
  height: 40
  radius: 12
  color: "transparent"
  border.width: 1
  border.color: Theme.border
  antialiasing: true

  Rectangle {
    id: marker
    x: root.selectedIndex === 1 ? 84 : 4
    y: 4
    width: 80
    height: 32
    radius: 8
    color: Theme.accentSubtle
    antialiasing: true

    Behavior on x {
      NumberAnimation {
        duration: Theme.controlDuration
        easing.type: Easing.OutCubic
      }
    }
  }

  Repeater {
    model: root.model

    delegate: Item {
      id: option
      required property var modelData
      required property int index
      readonly property bool chosen: root.selectedIndex === index

      objectName: root.objectName + modelData.key
      x: index === 1 ? 84 : 4
      y: 4
      width: 80
      height: 32
      activeFocusOnTab: true

      Accessible.role: Accessible.RadioButton
      Accessible.name: modelData.label
      Accessible.checked: chosen
      Accessible.onPressAction: choose()
      Keys.onReturnPressed: choose()
      Keys.onSpacePressed: choose()

      function choose() {
        root.current = modelData.key;
        root.selected(modelData.key);
      }

      Text {
        anchors.centerIn: parent
        text: option.modelData.label
        color: option.chosen || hover.hovered ? Theme.text : Theme.muted
        font.family: Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Theme.fontBody
        font.letterSpacing: 0
      }

      HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
      }
      TapHandler {
        onTapped: option.choose()
      }
    }
  }
}
