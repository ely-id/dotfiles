pragma ComponentBehavior: Bound

import QtQuick
import "." as Launcher
import Quickshell
import Quickshell.Wayland

// Janela da lupa do seletor de cor (ficha 15, "Pegando a cor"), uma por tela, no padrão da janela do launcher: camada
// de sobreposição na tela inteira. Enquanto `LoupeState.picking`, mostra o quadro capturado do monitor (o
// `ScreencopyView`, uma captura só, sem o cursor) do tamanho da tela, e por cima a lupa (ColorLoupe.qml). Não há véu: a
// tela congelada aparece como ela é. O ponteiro fica invisível sobre a janela.
//
// O teclado é exclusivo só na janela do monitor em que o ponteiro está (`LoupeState.pointerOutput`); com vários
// monitores o foco acompanha o ponteiro. A lupa só aparece nesse mesmo monitor.
PanelWindow {
  id: root

  required property var menuScreen

  readonly property string outputName: menuScreen ? menuScreen.name : ""
  readonly property bool here: Launcher.LoupeState.pointerOutput === outputName

  // A janela some um instante depois de a lupa fechar, e não no mesmo passo. No QA ao vivo o Quickshell caía com falha de
  // segmentação dentro do Qt (QWaylandWindow::handleScreensChanged) sempre que esta janela sumia logo depois de um clique nela.
  // O conteúdo é desmontado na hora (o Loader abaixo); só o sumiço da janela espera. O atraso é técnico, não é valor de desenho.
  property bool presented: false
  readonly property bool wanted: Launcher.LoupeState.picking
  onWantedChanged: {
    if (wanted) {
      hideTimer.stop();
      presented = true;
    } else {
      hideTimer.restart();
    }
  }
  Timer {
    id: hideTimer
    interval: 150
    onTriggered: root.presented = root.wanted
  }

  screen: menuScreen
  visible: presented
  color: "transparent"

  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "wintermute-colorpicker-" + (screen ? screen.name : "unknown")
  WlrLayershell.keyboardFocus: Launcher.LoupeState.picking && root.here
      ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  WlrLayershell.exclusionMode: ExclusionMode.Ignore

  // O quadro só existe com a lupa aberta: criar o `ScreencopyView` na hora é o que captura a tela naquele instante
  // (`live` falso é uma captura só). A janela ainda está vazia e transparente quando o pedido sai, então ela não aparece
  // no quadro, e o launcher já saiu (LoupeState espera ele sumir antes de abrir esta janela).
  Loader {
    anchors.fill: parent
    active: Launcher.LoupeState.picking

    sourceComponent: Item {
      id: stage

      focus: true
      Keys.onPressed: event => { event.accepted = loupe.handleKey(event.key, event.modifiers); }
      onVisibleChanged: if (visible) forceActiveFocus()
      Component.onCompleted: forceActiveFocus()

      // O foco do teclado vai e volta entre as janelas quando o ponteiro troca de monitor.
      Connections {
        target: root
        function onHereChanged() { if (root.here) stage.forceActiveFocus(); }
      }

      ScreencopyView {
        id: frame
        anchors.fill: parent
        captureSource: root.screen
        live: false
        paintCursor: false
      }

      Launcher.ColorLoupe {
        id: loupe
        anchors.fill: parent
        source: frame
        // Os pixels do quadro, não os lógicos: com escala no monitor o quadro tem mais pixels que a tela.
        frameWidth: frame.sourceSize.width
        frameHeight: frame.sourceSize.height
        sourceReady: frame.hasContent
        // Sem o ponteiro visto neste monitor a lupa não sabe onde pôr o ponto.
        active: root.here && pointerSeen
        property bool pointerSeen: false

        onReadyChanged: if (ready) Launcher.LoupeState.markReady(root.outputName)
        onPicked: hex => Launcher.LoupeState.pick(hex, root.outputName)
        onCancelRequested: Launcher.LoupeState.cancel()
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.BlankCursor

        function track(x, y) {
          Launcher.LoupeState.pointerOutput = root.outputName;
          loupe.pointerSeen = true;
          loupe.follow(x, y);
        }

        onEntered: track(mouseX, mouseY)
        onPositionChanged: mouse => track(mouse.x, mouse.y)
        onClicked: mouse => {
          if (mouse.button === Qt.RightButton)
            Launcher.LoupeState.cancel();
          else
            loupe.pick();
        }
      }
    }
  }
}
