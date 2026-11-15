pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "." as Bluetooth
import ".." as Shell
import "../battery" as Battery
Bluetooth.Row {
  id: root
  property var device: ({})
  property var service: Bluetooth.State
  readonly property bool busy: !!device.nativeBusy || service.isBusy(device.path || "")
  readonly property bool failed: service.failed(device.path || "")
  readonly property bool showBattery: !!device.connected && Number(device.battery) >= 0
  signal infoClicked
  label: String(device.name || device.address || "Bluetooth device")
  labelRight: showBattery ? (hovered ? 171 : 203) : hovered ? 232 : 264
  leading: Component { Image {
    width: 20; height: 20
    source: Qt.resolvedUrl("../icons/" + (root.device.icon || "bluetooth") + ".svg")
    sourceSize: Qt.size(40, 40)
  } }
  trailing: Component { Item {
    Rectangle {
      x: 264; y: 14; width: 1; height: 16
      visible: root.showBattery || root.hovered
      color: Shell.PanelStyle.outline
    }
    Rectangle {
      x: 203; y: 14; width: 1; height: 16
      visible: root.showBattery && root.hovered
      color: Shell.PanelStyle.outline
    }
    Battery.Indicator { x: 211; y: 14; visible: root.showBattery; percentage: root.device.battery || 0 }
    Text {
      x: 229; anchors.verticalCenter: parent.verticalCenter; width: 35
      visible: root.showBattery
      text: Math.round(root.device.battery || 0) + "%"
      font.family: Shell.Theme.fontFamily; font.weight: Font.Medium; font.pixelSize: 13
      color: Shell.Theme.colors.text
    }
    MouseArea {
      id: infoPointer
      x: root.showBattery ? 171 : 232; y: 6; width: 32; height: 32
      visible: root.hovered; enabled: root.interactive
      hoverEnabled: true; cursorShape: Qt.PointingHandCursor
      onClicked: root.infoClicked()
      Image {
        anchors.centerIn: parent; width: 16; height: 16
        opacity: infoPointer.containsMouse ? 1 : 0.6
        source: Qt.resolvedUrl("../icons/info.svg")
        sourceSize: Qt.size(32, 32)
      }
    }
    Rectangle {
      x: 272; y: 14; width: 16; height: 16; radius: 8
      visible: !root.busy && !root.failed
      color: root.device.connected ? Shell.Theme.colors.text : "transparent"
      border.width: root.device.connected ? 0 : 1
      border.color: Qt.rgba(1, 1, 1, 0.3)
      Image {
        anchors.centerIn: parent; width: 12; height: 12
        visible: !!root.device.connected
        source: Qt.resolvedUrl("../icons/check.svg")
        sourceSize: Qt.size(24, 24)
        layer.enabled: true
        layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.colors.panel }
      }
    }
    StatusAnimation {
      x: 272; y: 14; width: 16; height: 16
      visible: root.busy; running: root.busy
      firstFrame: Qt.resolvedUrl("../assets/bluetooth/connecting-1.svg")
      secondFrame: Qt.resolvedUrl("../assets/bluetooth/connecting-2.svg")
    }
    Image {
      x: 272; y: 14; width: 16; height: 16
      visible: root.failed && !root.busy
      source: Qt.resolvedUrl("../icons/circle-alert.svg")
      sourceSize: Qt.size(32, 32)
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.colors.dangerText }
    }
  } }
}
