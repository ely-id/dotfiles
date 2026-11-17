pragma ComponentBehavior: Bound
import QtQuick
import "." as Wifi
import ".."

// Lista de redes (ficha 05, 316×306): título Serif 20 em (20,16), chave em (242,18),
// linhas 300×44 a partir de y 64 e rodapé "Adicionar rede" depois de um divisor.
DeviceList {
  id: root
  property var service: stackController ? stackController.service : Wifi.State
  title: "Wi-Fi"
  viewportHeight: 306
  devices: service.wiredNetworks.concat(service.enabled ? service.networks : [])
  headerControl: Component { Toggle {
    checked: root.service.enabled
    enabled: root.interactive
    onToggled: checked => root.service.setWifiEnabled(checked)
  } }
  deviceDelegate: Component { NetworkRow {
    required property var modelData
    width: PanelStyle.rowWidth
    network: modelData
    interactive: root.interactive && !modelData.wired
    onDisconnectClicked: root.service.disconnect()
    onDetailsRequested: {
      if (modelData.connected || modelData.known)
        root.stackController.push("details", modelData);
    }
    onClicked: {
      if (modelData.connected)
        root.stackController.push("details", modelData);
      else if (modelData.locked && !modelData.known)
        root.stackController.push("join", modelData);
      else
        root.stackController.connectNetwork(modelData.ssid, "", false);
    }
  } }
  footer: Component { Item {
    width: PanelStyle.rowWidth
    height: 58

    Rectangle {
      x: 12; y: 8
      width: 276; height: 1
      color: Theme.border
    }
    ListRow {
      y: 14
      width: PanelStyle.rowWidth
      title: "Add network"
      iconName: "plus"
      labelSize: Theme.fontLabel
      titleColor: Theme.muted
      interactive: root.interactive
      onClicked: root.stackController.push("add", null)
    }
  } }
}
