pragma ComponentBehavior: Bound

import QtQuick
import "." as Screenshot
import ".." as Shell
import Quickshell
import Quickshell.Wayland

// Janela do editor de anotação (ficha 17, estado 5, F6-T14), uma por tela, no padrão do launcher (launcher/Window.qml): camada de
// sobreposição na tela inteira, teclado exclusivo enquanto aberta e o véu do launcher atrás. A peça é a Annotate.qml, centrada nos dois
// eixos do monitor da captura; aqui só ficam a posição, o véu, a animação e o clique fora.
//
// Clicar no véu NÃO fecha: um clique errado não pode jogar fora o desenho. Quem fecha é o Esc (sem texto nem recorte em andamento) e o
// "Copy". O véu engole os cliques para eles não chegarem às janelas de baixo.
PanelWindow {
  id: root

  required property var menuScreen

  property bool presented: false

  readonly property bool targetOpen: Screenshot.AnnotateState.opened
      && Screenshot.AnnotateState.outputName === (menuScreen ? menuScreen.name : "")

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
  WlrLayershell.namespace: "wintermute-annotate-" + (screen ? screen.name : "unknown")
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

  // O véu do launcher: preto a 20% na tela inteira.
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

  MouseArea {
    anchors.fill: parent
    enabled: root.presented
    acceptedButtons: Qt.AllButtons
  }

  Loader {
    id: loader
    x: Math.round((root.width - width) / 2)
    y: Math.round((root.height - height) / 2)
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
      item.forceActiveFocus();
      panelBlur.changed();
    }

    sourceComponent: Screenshot.Annotate {
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
    Qt.callLater(() => { if (loader.item) loader.item.forceActiveFocus(); });
  }

  function beginClose() {
    if (presented)
      closeCleanup.restart();
  }
}
