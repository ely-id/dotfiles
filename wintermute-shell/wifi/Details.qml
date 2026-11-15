import QtQuick
import "." as Wifi
import ".."

// Detalhes da rede (ficha 05, 316×424 com 6 linhas).
DeviceDetails {
  id: root
  property var service: stackController ? stackController.service : Wifi.State
  readonly property bool connected: selection.ssid === service.connectedSsid
  title: String(selection.ssid || service.connectedSsid)
  titleIcon: Component { SignalIcon { bars: Number(root.selection.bars || 3); tint: Theme.accentText } }
  primaryText: "Esquecer"
  primaryEnabled: (selection.uuids || []).length > 0
  secondaryText: connected ? "Desconectar" : "Conectar"
  detailRows: connected ? [
    {label: "Velocidade", value: service.linkSpeed},
    {label: "IPv4", value: service.ipv4},
    {label: "Banda", value: service.band},
    {label: "Gateway", value: service.gateway},
    {label: "DNS", value: service.dns},
    {label: "Interface", value: service.device || "—"}
  ] : []
  Component.onCompleted: service.refreshDetails()
  onPrimaryClicked: {
    service.forget(selection);
    stackController.showStatus();
  }
  onSecondaryClicked: {
    if (connected) {
      service.disconnect();
      stackController.showStatus();
    } else {
      stackController.connectNetwork(selection.ssid, "", false);
    }
  }
}
