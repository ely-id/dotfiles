pragma ComponentBehavior: Bound
import QtQuick
import "." as Bluetooth
import ".." as Shell

// Lista de dispositivos pareados (ficha 06): 316×306 ligado, 316×156 desligado. Ícone bluetooth 20
// em (20,22), título Serif 20 em (48,16), chave em (242,18); rodapé como o do Wi-Fi.
Shell.DeviceList {
  id: root
  property var service: stackController ? stackController.service : Bluetooth.State
  title: "Bluetooth"
  titleIcon: Qt.resolvedUrl("../icons/bluetooth.svg")
  viewportHeight: service.enabled ? 306 : 156
  devices: service.enabled ? service.pairedDevices : []
  deviceKey: "path"
  emptyText: !service.available ? "No Bluetooth adapter found."
      : service.blocked ? "Bluetooth is blocked. Turn it on to unblock it."
      : !service.enabled ? "Bluetooth is off."
      : "No paired devices. Search for nearby devices to pair one."
  message: service.errorText
  headerControl: Component { Shell.Toggle {
    checked: root.service.enabled
    enabled: root.interactive && root.service.available
    busy: root.service.powerBusy
    onToggled: checked => root.service.setEnabled(checked)
  } }
  deviceDelegate: Component { DeviceRow {
    required property var modelData
    device: modelData; service: root.service
    interactive: root.interactive
    onClicked: root.service.activate(modelData)
    onInfoClicked: root.stackController.openDetails(modelData)
  } }
  footer: root.service.enabled ? footerComponent : null

  Component { id: footerComponent; Item {
    width: Shell.Theme.panelRowWidth
    height: 58

    Rectangle {
      x: 12; y: 8
      width: 276; height: 1
      color: Shell.Theme.border
    }
    Bluetooth.Row {
      y: 14
      width: Shell.Theme.panelRowWidth
      label: "Search for nearby devices"
      iconName: "bluetooth-searching"
      labelSize: Shell.Theme.fontLabel
      titleColor: Shell.Theme.muted
      interactive: root.interactive
      onClicked: root.stackController.openNearby()
    }
  } }
}
