pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "." as Bluetooth
import ".." as Shell

// Dispositivos próximos (ficha 06, 236 com 3 dispositivos): título Serif 20 em (20,16), ícone de
// busca accentText em (276,22), legenda "Procurando…" 11 muted em (20,72) e linhas a partir de y 96.
// A altura cresce até 316 quando aparecem mais de 3 dispositivos, em vez de fixar em 236.
Shell.DeviceList {
  id: root
  property var service: stackController ? stackController.service : Bluetooth.State
  title: "Nearby devices"
  listBottomPadding: 8
  listTop: 96
  viewportHeight: Math.max(236, Math.min(316, 104 + 44 * devices.length))
  devices: service.enabled ? service.nearbyDevices : []
  deviceKey: "path"
  sectionLabel: service.enabled && service.discovering ? "Searching…" : ""
  emptyText: !service.enabled ? "Bluetooth is off."
      : service.discovering ? "Searching for devices…\nPut the device in pairing mode."
      : "No nearby devices found."
  message: service.errorText
  headerControl: Component { Item {
    Image {
      x: 34; y: 4; width: 20; height: 20
      visible: root.service.discovering
      source: Qt.resolvedUrl("../icons/bluetooth-searching.svg")
      sourceSize: Qt.size(40, 40)
      fillMode: Image.PreserveAspectFit
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.accentText }
    }
  } }
  deviceDelegate: Component { DeviceRow {
    required property var modelData
    device: modelData; service: root.service
    interactive: root.interactive
    onClicked: root.stackController.connectNearby(modelData)
    onInfoClicked: root.stackController.openDetails(modelData)
  } }
}
