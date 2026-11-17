pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "." as Battery
import ".." as Shell

// Pop-up da bateria (ficha 08): 280×232, raio 20. "Bateria" 13 muted em (20,16); à direita o estado
// (zap + "Carregando" em successText); percentual Serif 40 em (20,40); potência e tempo restante 13
// muted alinhados à direita; trilho 240×20 r6 em (20,100); "Perfil de energia" em (20,128); três
// botões 76×40 r8 em x 20 / 102 / 184, y 156, com o rótulo 11 embaixo em y 200.
// `service` é o estado da bateria; a vitrine troca por um fictício.
Shell.PanelBackground {
  id: root
  property var service: Battery.State
  readonly property bool charging: service.chargingNow

  radius: Shell.Theme.radiusPopup
  implicitWidth: 280
  implicitHeight: 232
  Accessible.role: Accessible.Pane
  Accessible.name: "Battery"

  function duration(seconds) {
    const minutes = Math.round(seconds / 60);
    const hours = Math.floor(minutes / 60);
    return hours > 0 ? hours + " h " + minutes % 60 + " min" : minutes + " min";
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
  }

  Label { x: 20; y: 16; text: "Battery"; color: Shell.Theme.muted }

  Image {
    x: status.x - 20
    y: 16
    width: 16
    height: 16
    visible: status.visible
    source: Qt.resolvedUrl("../icons/zap.svg")
    sourceSize: Qt.size(32, 32)
    layer.enabled: true
    layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.successText }
  }
  Label {
    id: status
    x: 260 - width
    y: 16
    visible: root.service.charging
    text: root.charging ? "Charging" : "Charged"
    color: Shell.Theme.successText
  }

  Text {
    x: 20; y: 40
    width: 120; height: 48
    verticalAlignment: Text.AlignVCenter
    text: root.service.level + "%"
    color: Shell.Theme.text
    font.family: Shell.Theme.titleFontFamily
    font.weight: Font.Normal
    font.pixelSize: Shell.Theme.fontBatteryPercent
    font.letterSpacing: 0
  }

  Label {
    x: 140; y: 46
    width: 120
    horizontalAlignment: Text.AlignRight
    visible: (root.charging || !root.service.charging) && root.service.changeRate !== 0
    text: Math.round(Math.abs(root.service.changeRate)) + " W"
    color: Shell.Theme.muted
  }
  Label {
    x: 100; y: 67
    width: 160
    horizontalAlignment: Text.AlignRight
    visible: root.charging || !root.service.charging
    color: Shell.Theme.muted
    text: root.charging
        ? (root.service.timeToFull > 0 ? root.duration(root.service.timeToFull) + " until full" : "")
        : (root.service.timeToEmpty > 0 ? root.duration(root.service.timeToEmpty) + " left" : "")
  }

  Rectangle {
    x: 20
    y: 100
    width: 240
    height: 20
    radius: 6
    color: Shell.Theme.track

    Rectangle {
      width: parent.width * root.service.percentage / 100
      height: parent.height
      radius: 6
      color: root.service.charging ? Shell.Theme.success
          : root.service.low ? Shell.Theme.danger : Shell.Theme.text
    }
  }

  Label { x: 20; y: 128; text: "Power profile"; color: Shell.Theme.muted }

  Repeater {
    model: root.service.profiles

    delegate: Item {
      id: profile
      required property var modelData
      required property int index
      readonly property bool selected: root.service.selectedProfile === modelData.key
      readonly property bool available: root.service.profileAvailable(modelData.key)

      x: 20 + index * 82
      y: 156
      width: 76
      height: 72
      activeFocusOnTab: true
      Accessible.role: Accessible.RadioButton
      Accessible.name: modelData.name
      Accessible.checkable: true
      Accessible.checked: selected
      Accessible.onPressAction: choose()
      Keys.onSpacePressed: choose()
      Keys.onReturnPressed: choose()
      Keys.onEnterPressed: choose()

      function choose() {
        if (available)
          root.service.setProfile(modelData.key);
      }

      Rectangle {
        width: 76
        height: 40
        radius: 8
        color: profile.selected ? Shell.Theme.accentSubtle
            : profileHover.hovered && profile.available ? Shell.Theme.pressed : Shell.Theme.control
        border.width: 1
        border.color: profile.selected ? Shell.Theme.accentRing : Shell.Theme.border
        antialiasing: true

        Behavior on color {
          ColorAnimation { duration: Shell.Theme.hoverDuration; easing.type: Easing.OutCubic }
        }

        Image {
          anchors.centerIn: parent
          width: 16
          height: 16
          opacity: profile.available ? 1 : 0.3
          source: Qt.resolvedUrl("../icons/" + profile.modelData.icon + ".svg")
          sourceSize: Qt.size(32, 32)
          fillMode: Image.PreserveAspectFit
          layer.enabled: true
          layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
        }
      }

      Text {
        y: 44
        width: 76
        height: 16
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: profile.modelData.name
        color: profile.selected ? Shell.Theme.text : Shell.Theme.muted
        opacity: profile.available ? 1 : 0.5
        font.family: Shell.Theme.fontFamily
        font.weight: profile.selected ? Font.DemiBold : Font.Medium
        font.pixelSize: Shell.Theme.fontCaption
        font.letterSpacing: 0
      }

      HoverHandler { id: profileHover; enabled: profile.available; cursorShape: Qt.PointingHandCursor }
      TapHandler { enabled: profile.available; onTapped: profile.choose() }
    }
  }

  component Label: Text {
    height: 16
    verticalAlignment: Text.AlignVCenter
    color: Shell.Theme.text
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontBody
    font.letterSpacing: 0
  }
}
