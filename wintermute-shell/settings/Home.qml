pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import "." as Settings
import ".." as Shell
import "../battery" as Battery
import "../updates" as Updates

// Tela inicial dos Ajustes (ficha 13; Figma 13:15797 e 13:15855), sem o véu.
// Composição de 672×536 no centro: quatro cartões de 264 em passo 272 e quatro botões de
// sessão de 128 em passo 136. Bandeja a 16 do topo, perfil de energia a 16 da borda direita
// e selo de atualização a 16 da base. Os cartões entram de 0,86 a 1 em ordem aleatória,
// 28 ms entre eles, cada um em 32 ms; fecham em 180 ms.
//
// A tela não executa nada sozinha: avisa pelos sinais, e a janela (Window.qml) decide.
// Assim a vitrine mostra esta mesma tela com serviços fictícios sem risco de desligar
// a máquina num clique (decisão 0011).
Item {
  id: root

  property bool open: false
  property var batteryService: Battery.State
  property var updatesService: Updates.State
  property var trayItems: SystemTray.items
  // Vitrine: fixa o hover num cartão ("appearance", "bluetooth", "system", "information")
  // ou num botão de sessão ("lock", "suspend", "reboot", "shutdown").
  property string previewHover: ""

  signal pageRequested(string page)
  signal bluetoothRequested
  signal sessionRequested(string action)

  property int revealStep: -1
  property var revealRanks: []
  readonly property int cardCount: categories.length + sessions.length
  readonly property var blurRegions: Array.from(composition.children).concat(profileSelector)
      .map(item => item.blurRegion).filter(Boolean)
  readonly property bool updating: updatesService.status === "updating"

  readonly property var categories: [
    { slot: 0, name: "Appearance", page: "appearance", icon: "palette" },
    { slot: 1, name: "Bluetooth", page: "", icon: "bluetooth" },
    { slot: 2, name: "System", page: "system", icon: "settings" },
    { slot: 3, name: "Information", page: "information", icon: "info" }
  ]

  readonly property var sessions: [
    { slot: 4, action: "lock", name: "Lock screen", icon: "lock" },
    { slot: 5, action: "suspend", name: "Sleep", icon: "moon" },
    {
      slot: 6, action: "reboot", name: "Restart", icon: "rotate-ccw",
      updatingName: "Restart after update", pendingName: "Restarting after update"
    },
    {
      slot: 7, action: "shutdown", name: "Power off", icon: "power", danger: true, dot: true,
      updatingName: "Shut down after update", pendingName: "Shutting down after update"
    }
  ]

  onOpenChanged: open ? beginReveal() : endReveal()
  Component.onCompleted: if (open) beginReveal()

  Item {
    id: composition
    z: 2
    width: Shell.Theme.settingsCompositionWidth
    height: Shell.Theme.settingsCompositionHeight
    anchors.centerIn: parent
    enabled: root.open
    visible: opacity > 0
    opacity: root.open ? 1 : 0
    Behavior on opacity {
      NumberAnimation { duration: Shell.Theme.settingsCloseDuration; easing.type: Easing.OutCubic }
    }

    Repeater {
      model: root.categories

      delegate: Settings.CategoryButton {
        required property var modelData
        required property int index

        x: (index % 2) * Shell.Theme.settingsCategoryPitch
        y: Math.floor(index / 2) * Shell.Theme.settingsCategoryPitch
        iconName: modelData.icon
        label: modelData.name
        forceHovered: root.previewHover === (modelData.page || "bluetooth")
        revealed: root.open && root.revealStep >= root.revealRanks[modelData.slot]
        onClicked: {
          if (modelData.page) root.pageRequested(modelData.page);
          else root.bluetoothRequested();
        }
      }
    }

    Repeater {
      model: root.sessions

      delegate: Settings.SessionButton {
        required property var modelData
        required property int index
        readonly property bool afterUpdate: root.updating && !!modelData.updatingName

        x: Shell.Theme.settingsCategoryPitch * 2
        y: index * Shell.Theme.settingsSessionPitch
        iconName: modelData.icon
        danger: !!modelData.danger
        showStatusDot: !!modelData.dot
        highlighted: modelData.action === "reboot" && updateBadge.restartHovered
        forceHovered: root.previewHover === modelData.action
        label: !afterUpdate ? modelData.name
            : root.updatesService.pending === modelData.action ? modelData.pendingName : modelData.updatingName
        revealed: root.open && root.revealStep >= root.revealRanks[modelData.slot]
        onClicked: afterUpdate ? root.updatesService.after(modelData.action)
            : root.sessionRequested(modelData.action)
      }
    }
  }

  Updates.Badge {
    id: updateBadge
    service: root.updatesService
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Shell.Theme.settingsEdgeMargin
    visible: root.open && status !== ""
    onRestartRequested: root.sessionRequested("reboot")
  }

  Battery.ProfileSelector {
    id: profileSelector
    z: 2
    service: root.batteryService
    anchors.right: parent.right
    anchors.rightMargin: Shell.Theme.settingsEdgeMargin
    anchors.verticalCenter: parent.verticalCenter
    enabled: root.open
    visible: opacity > 0
    opacity: root.open ? 1 : 0
    Behavior on opacity {
      NumberAnimation { duration: Shell.Theme.settingsCloseDuration; easing.type: Easing.OutCubic }
    }
  }

  Settings.Tray {
    id: tray
    z: 3
    anchors.fill: parent
    items: root.trayItems
    enabled: root.open
    visible: opacity > 0
    opacity: root.open ? 1 : 0
    Behavior on opacity {
      NumberAnimation { duration: Shell.Theme.settingsCloseDuration; easing.type: Easing.OutCubic }
    }
  }

  Timer {
    id: revealTimer
    interval: Shell.Theme.settingsCardStagger
    repeat: true
    onTriggered: {
      if (root.revealStep >= root.cardCount - 1) {
        stop();
        return;
      }
      root.revealStep += 1;
    }
  }

  function beginReveal() {
    revealTimer.stop();
    revealRanks = shuffledRanks();
    revealStep = -1;
    Qt.callLater(function() {
      if (!root.open)
        return;
      root.revealStep = 0;
      revealTimer.restart();
    });
  }

  function endReveal() {
    revealTimer.stop();
    revealStep = -1;
  }

  function shuffledRanks() {
    const order = Array.from({length: root.cardCount}, (_, index) => index);
    for (let index = order.length - 1; index > 0; --index) {
      const other = Math.floor(Math.random() * (index + 1));
      const held = order[index];
      order[index] = order[other];
      order[other] = held;
    }
    return order;
  }
}
