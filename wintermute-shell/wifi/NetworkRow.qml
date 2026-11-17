import QtQuick
import QtQuick.Effects
import ".."

// Linha de rede (ficha 05): ListRow 300×44 r12 com o sinal em (12,12), cadeado em (272,14)
// e, na rede conectada, fundo accentSubtle e botão "Desconectar" 100×32 em (192,6).
ListRow {
  id: root
  property var network: ({})
  readonly property bool canDisconnect: !!network.connected && !network.wired
  signal detailsRequested
  signal disconnectClicked

  title: String(network.wired ? network.name : network.ssid || "")
  selected: !!network.connected
  trailingIconName: !!network.locked && !network.connected ? "lock" : ""
  labelRight: canDisconnect ? 184 : (showTrailingIcon ? 264 : 288)
  leading: Component { Item {
    SignalIcon {
      visible: !root.network.wired
      anchors.fill: parent
      bars: Number(root.network.bars || 1)
    }
    Image {
      visible: !!root.network.wired
      anchors.fill: parent
      // Rede cabeada: ícone Lucide `cable` (P-39).
      source: Qt.resolvedUrl("../icons/cable.svg")
      sourceSize: Qt.size(40, 40)
      fillMode: Image.PreserveAspectFit
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.text }
    }
  } }

  MouseArea {
    anchors.fill: parent
    enabled: root.interactive
    acceptedButtons: Qt.RightButton
    onClicked: root.detailsRequested()
  }

  ActionButton {
    visible: root.canDisconnect
    x: 192; y: 6
    width: 100
    small: true
    text: "Disconnect"
    interactive: root.interactive
    onClicked: root.disconnectClicked()
  }
}
