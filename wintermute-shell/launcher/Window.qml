pragma ComponentBehavior: Bound

import QtQuick
import "." as Launcher
import ".." as Shell
import Quickshell
import Quickshell.Wayland

// Janela do launcher (ficha 14), uma por tela, no padrão dos Ajustes: camada de sobreposição na tela
// inteira, teclado exclusivo enquanto aberta e um véu atrás. A peça é a Panel.qml; aqui só ficam a posição
// (centrada na largura, com o topo a 160/900 da altura da tela), o véu, a animação e o clique fora.
PanelWindow {
  id: root

  required property var menuScreen

  property bool presented: false

  readonly property bool targetOpen: Launcher.State.opened
      && Launcher.State.outputName === (menuScreen ? menuScreen.name : "")
  // O topo, em pixel inteiro, e a mesma folga embaixo para a lista rolar quando não couber.
  readonly property int panelTop: Math.round(height * Shell.Theme.launcherTopRatio)

  screen: menuScreen
  visible: presented
  color: "transparent"
  BackgroundEffect.blurRegion: panelBlur
  onWidthChanged: panelBlur.changed()
  onHeightChanged: panelBlur.changed()
  Region {
    id: panelBlur
    regions: loader.item ? [loader.item.blurRegion] : []
  }

  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "wintermute-launcher-" + (screen ? screen.name : "unknown")
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

  // Véu: preto a 20% na tela inteira.
  Rectangle {
    anchors.fill: parent
    color: Shell.Theme.launcherScrim
    opacity: root.targetOpen ? 1 : 0

    Behavior on opacity {
      NumberAnimation {
        duration: Shell.Theme.settingsCloseDuration
        easing.type: Easing.OutCubic
      }
    }
  }

  // Clicar no véu fecha, como o Esc.
  MouseArea {
    anchors.fill: parent
    enabled: root.targetOpen
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    onClicked: Launcher.State.close()
  }

  Loader {
    id: loader
    x: Math.round((root.width - width) / 2)
    y: root.panelTop
    active: root.presented
    enabled: root.targetOpen
    opacity: root.targetOpen ? 1 : 0
    scale: root.targetOpen ? 1 : 0.96
    Behavior on opacity {
      NumberAnimation { duration: Shell.Theme.settingsCloseDuration; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
      NumberAnimation { duration: Shell.Theme.settingsCloseDuration; easing.type: Easing.OutCubic }
    }
    onXChanged: panelBlur.changed()
    onYChanged: panelBlur.changed()
    onScaleChanged: panelBlur.changed()
    onLoaded: {
      item.focusSearch();
      panelBlur.changed();
    }

    sourceComponent: Launcher.Panel {
      maxHeight: root.height - 2 * root.panelTop
      onHeightChanged: panelBlur.changed()
    }
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
    // Reabrindo durante a animação de fechar a peça já existe, então o onLoaded não vem de novo.
    Qt.callLater(() => { if (loader.item) loader.item.focusSearch(); });
  }

  function beginClose() {
    if (presented)
      closeCleanup.restart();
  }
}
