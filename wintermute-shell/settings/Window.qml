pragma ComponentBehavior: Bound

import QtQuick
import "." as Settings
import ".." as Shell
import "appearance" as Appearance
import "display" as Display
import "information" as Information
import "manual" as Manual
import "system" as System
import Quickshell
import Quickshell.Wayland

// Janela dos Ajustes: o véu, a tela inicial (Home.qml) e o modal da página aberta.
// A tela inicial só avisa pelos sinais; daqui eu chamo Settings.State.
PanelWindow {
  id: root

  required property var menuScreen

  property bool presented: false
  property string displayedPage: Settings.State.page || "appearance"

  readonly property bool targetOpen: Settings.State.opened
      && Settings.State.outputName === (menuScreen ? menuScreen.name : "")
  readonly property bool cardsOpen: targetOpen && Settings.State.page === ""
  readonly property bool modalOpen: targetOpen && Settings.State.page !== ""

  screen: menuScreen
  visible: presented && !Appearance.State.pickingWallpaper
  color: "transparent"
  BackgroundEffect.blurRegion: Shell.Theme.translucent ? cardBlur : null
  onWidthChanged: cardBlur.changed()
  onHeightChanged: cardBlur.changed()
  Region {
    id: cardBlur
    regions: home.blurRegions.concat(modal.item ? [modal.item.blurRegion] : []).filter(Boolean)
  }

  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "pond-settings-"
      + (screen ? screen.name : "unknown")
  WlrLayershell.keyboardFocus: root.targetOpen
      ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  WlrLayershell.exclusionMode: ExclusionMode.Ignore

  mask: Region {
    x: 0
    y: 0
    width: root.presented ? root.width : 0
    height: root.presented ? root.height : 0
  }

  onTargetOpenChanged: {
    if (targetOpen)
      beginOpen();
    else
      beginClose();
  }
  Connections {
    target: Settings.State
    function onPageChanged() {
      // Retain the outgoing page until its exit transition finishes.
      if (Settings.State.page !== "") root.displayedPage = Settings.State.page;
    }
  }

  // Véu `scrim` (#0D0E11 a 80%) na tela inteira.
  Rectangle {
    anchors.fill: parent
    color: Shell.Theme.scrim
    opacity: root.targetOpen ? 1 : 0

    Behavior on opacity {
      NumberAnimation {
        duration: Shell.Theme.settingsCloseDuration
        easing.type: Easing.OutCubic
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.targetOpen
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    onClicked: Settings.State.close()
  }

  Settings.Home {
    id: home
    anchors.fill: parent
    open: root.cardsOpen
    onPageRequested: page => Settings.State.openPage(page)
    onBluetoothRequested: Settings.State.openBluetooth()
    onSessionRequested: action => Settings.State.requestSessionAction(action)
  }

  // Keep navigation, transitions, and outside-click dismissal in the host.
  Loader {
    id: modal
    z: 3
    anchors.centerIn: parent
    active: root.presented && (root.modalOpen || opacity > 0)
    sourceComponent: ({
      wallpaper: wallpaperPage, customize: wallpaperPage, information: informationPage, manual: manualPage, display: displayPage, arrange: arrangePage,
      system: systemPage, mouse: mousePage, lock: lockPage, keyboard: keyboardPage
    })[root.displayedPage] || appearancePage
    enabled: root.modalOpen
    opacity: root.modalOpen ? 1 : 0
    scale: root.modalOpen ? 1 : 0.96
    Behavior on opacity {
      enabled: root.displayedPage !== "appearance"
      NumberAnimation { duration: Shell.Theme.settingsCloseDuration; easing.type: Easing.OutCubic }
    }
    Behavior on scale { NumberAnimation { duration: Shell.Theme.settingsCloseDuration; easing.type: Easing.OutCubic } }
    onLoaded: item.forceActiveFocus()
    onXChanged: cardBlur.changed()
    onYChanged: cardBlur.changed()
    onScaleChanged: cardBlur.changed()
  }
  Component {
    id: displayPage
    Display.Panel {
      availableHeight: root.height - 80
      scale: Math.min(1, (root.width - 60) / implicitWidth)
    }
  }
  Component {
    id: arrangePage
    Display.Arrange {
      availableHeight: root.height - 80
      scale: Math.min(1, (root.width - 60) / implicitWidth)
    }
  }
  Component {
    id: appearancePage
    Appearance.Panel {
      availableHeight: Math.max(200, root.height - 70)
      scale: Math.min(1, (root.width - 60) / implicitWidth)
    }
  }
  // O seletor e o cartão Customize são o mesmo componente (a pilha): o seletor continua vivo atrás do
  // cartão, com a rolagem onde estava, e a página `customize` só põe o cartão na frente.
  Component {
    id: wallpaperPage
    Appearance.WallpaperStack {
      customizing: root.displayedPage === "customize"
      availableHeight: Math.max(200, root.height - 70)
      scale: Math.min(1, (root.width - 60) / implicitWidth)
    }
  }
  Component {
    id: informationPage
    Information.Panel {
      availableHeight: Math.max(200, root.height - 70)
      scale: Math.min(1, (root.width - 60) / implicitWidth)
    }
  }
  Component {
    id: systemPage
    System.Panel {
      availableHeight: Math.max(200, root.height - 70)
      scale: Math.min(1, (root.width - 60) / implicitWidth)
    }
  }
  Component {
    id: mousePage
    System.Mouse {
      availableHeight: Math.max(200, root.height - 70)
      scale: Math.min(1, (root.width - 60) / implicitWidth)
    }
  }
  Component {
    id: lockPage
    System.Lock {
      availableHeight: Math.max(200, root.height - 70)
      scale: Math.min(1, (root.width - 60) / implicitWidth)
    }
  }
  Component {
    id: keyboardPage
    System.Picker {
      title: "Keyboard language"; closeLabel: "Back to System"; placeholder: "Search languages"; multiple: true
      options: System.State.languages; selected: System.State.selectedLanguages
      onPicked: id => System.State.toggleLanguage(id)
      availableHeight: Math.max(200, root.height - 70)
      scale: Math.min(1, (root.width - 60) / implicitWidth)
    }
  }
  Component {
    id: manualPage
    Manual.Panel {
      availableHeight: Math.max(200, root.height - 70)
      scale: Math.min(1, (root.width - 60) / implicitWidth)
    }
  }
  Item {
    focus: root.cardsOpen
    Keys.onEscapePressed: Settings.State.close()
  }

  Timer {
    id: closeCleanup
    interval: Shell.Theme.settingsCloseDuration
    onTriggered: {
      if (!root.targetOpen)
        root.presented = false;
    }
  }

  function beginOpen() {
    closeCleanup.stop();
    presented = true;
  }

  function beginClose() {
    if (presented)
      closeCleanup.restart();
  }
}
