pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "." as Bluetooth
import ".." as Shell

// Linha de dispositivo (ficha 06): ListRow 300×44 r12 com ícone 20 em (12,12), nome, bateria 11
// (na linha conectada usa `text`, senão `muted`), botão de info 32×32 r8 em (224,6) e o rádio de
// conexão em (272,14). "Conectando" troca o rádio por dois pontos accent que piscam a cada 750 ms.
Bluetooth.Row {
  id: root
  property var device: ({})
  property var service: Bluetooth.State
  readonly property bool busy: !!device.nativeBusy || service.isBusy(device.path || "")
  readonly property bool failed: service.failed(device.path || "")
  readonly property bool showBattery: Number(device.battery) >= 0
  signal infoClicked
  label: String(device.name || device.address || "Dispositivo Bluetooth")
  selected: !!device.connected
  labelRight: showBattery ? 184 : 216
  leading: Component { Image {
    width: 20; height: 20
    source: Qt.resolvedUrl("../icons/" + (root.device.icon || "bluetooth") + ".svg")
    sourceSize: Qt.size(40, 40)
  } }
  trailing: Component { Item {
    Text {
      x: 216 - width
      anchors.verticalCenter: parent.verticalCenter
      width: 40
      horizontalAlignment: Text.AlignRight
      visible: root.showBattery
      text: Math.round(root.device.battery || 0) + "%"
      color: root.selected ? Shell.Theme.text : Shell.Theme.muted
      font.family: Shell.Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Shell.Theme.fontCaption
      font.letterSpacing: 0
    }
    Rectangle {
      x: 224; y: 6; width: 32; height: 32
      radius: 8
      color: infoPointer.containsMouse ? Shell.Theme.hover : "transparent"
      Image {
        anchors.centerIn: parent; width: 16; height: 16
        opacity: infoPointer.containsMouse ? 1 : 0.6
        source: Qt.resolvedUrl("../icons/info.svg")
        sourceSize: Qt.size(32, 32)
      }
      MouseArea {
        id: infoPointer
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.infoClicked()
      }
    }
    Shell.RadioButton {
      x: 272; y: 14
      visible: !root.busy && !root.failed
      checked: !!root.device.connected
      interactive: false
    }
    ConnectingDots {
      x: 272; y: 19
      visible: root.busy
      running: root.busy
    }
    Image {
      x: 272; y: 14; width: 16; height: 16
      visible: root.failed && !root.busy
      source: Qt.resolvedUrl("../icons/circle-alert.svg")
      sourceSize: Qt.size(32, 32)
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.dangerText }
    }
  } }
}
