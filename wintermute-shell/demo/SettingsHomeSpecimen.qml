import QtQuick
import ".."
import "../settings" as Settings

// A tela inicial dos Ajustes (settings/Home.qml) de verdade, com estado fictício, num quadro
// de 1120×680 como o do Figma (13:15797): fundo escuro, véu `scrim` e a tela por cima.
// Os sinais da tela não fazem nada aqui; nenhum clique na vitrine bloqueia ou desliga a máquina.
// `hover`: "" | "appearance" | "bluetooth" | "system" | "information" | "lock" | "suspend" | "reboot" | "shutdown".
Item {
  id: root
  property string hover: ""
  property string profile: "balanced"
  property string updateStatus: "available"
  property int updateCount: 3
  property bool open: true

  implicitWidth: 1120
  implicitHeight: 680
  clip: true

  // Ícones Lucide no lugar dos aplicativos da bandeja, como no Figma.
  readonly property var trayItems: ["globe", "music", "shield", "cpu", "ellipsis"].map(name => ({
    id: name, title: name, tooltipTitle: "", onlyMenu: false, hasMenu: false,
    icon: Qt.resolvedUrl("../icons/" + name + ".svg"),
    activate: function() {}, secondaryActivate: function() {}
  }))

  Rectangle {
    anchors.fill: parent
    radius: Theme.radiusCard
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#07080B" }
      GradientStop { position: 0.71; color: "#10131C" }
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.radiusCard
    color: Theme.scrim
  }

  BatteryService { id: battery; selectedProfile: root.profile }
  UpdatesService { id: updates; status: root.updateStatus; availableCount: root.updateCount }

  Settings.Home {
    anchors.fill: parent
    open: root.open
    batteryService: battery
    updatesService: updates
    trayItems: root.trayItems
    previewHover: root.hover
  }
}
