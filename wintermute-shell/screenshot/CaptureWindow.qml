pragma ComponentBehavior: Bound

import QtQuick
import "." as Screenshot
import Quickshell
import Quickshell.Wayland

// Janela da captura de tela (ficha 17), uma por tela, no padrão da janela da lupa (launcher/LoupeWindow.qml): camada de
// sobreposição na tela inteira. Enquanto `CaptureState.opened`, mostra o quadro capturado do monitor (o `ScreencopyView`,
// uma captura só, sem o cursor) e por cima a peça (Capture.qml): o véu, a mira, a dica, a barra de modos e a seleção.
//
// O teclado é exclusivo só na janela do monitor em que o ponteiro está (`CaptureState.pointerOutput`); com vários
// monitores o foco acompanha o ponteiro. A mira, as coordenadas, a dica e a barra só aparecem nesse mesmo monitor. A seleção
// de área (F6-T11) é um estado só, no CaptureState, preso ao monitor em que começou: a peça de cada janela só a desenha se
// o nome do monitor for o dela.
PanelWindow {
  id: root

  required property var menuScreen

  readonly property string outputName: menuScreen ? menuScreen.name : ""
  readonly property bool here: Screenshot.CaptureState.pointerOutput === outputName

  screen: menuScreen
  visible: Screenshot.CaptureState.opened
  color: "transparent"

  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "wintermute-screenshot-" + (screen ? screen.name : "unknown")
  WlrLayershell.keyboardFocus: Screenshot.CaptureState.opened && root.here
      ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  WlrLayershell.exclusionMode: ExclusionMode.Ignore

  // O quadro só existe com a captura aberta: criar o `ScreencopyView` na hora é o que captura a tela naquele instante
  // (`live` falso é uma captura só). A janela ainda está vazia e transparente quando o pedido sai, então ela não aparece
  // no quadro, e o launcher e os Ajustes já saíram (CaptureState espera eles sumirem antes de abrir esta janela).
  Loader {
    anchors.fill: parent
    active: Screenshot.CaptureState.opened

    sourceComponent: Item {
      id: stage

      focus: true
      Keys.onPressed: event => { event.accepted = capture.handleKey(event.key, event.modifiers); }
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

        onHasContentChanged: if (hasContent) Screenshot.CaptureState.markReady(root.outputName)
      }

      // Sem o quadro a peça não aparece: o véu sobre uma janela transparente piscaria antes de a captura chegar. Onde a
      // captura nunca chega, o CaptureState desiste em 2 s.
      Screenshot.Capture {
        id: capture
        anchors.fill: parent
        visible: frame.hasContent
        service: Screenshot.CaptureState
        outputName: root.outputName
        active: root.here
        pointerSeen: false
        // Os pixels do quadro, não os lógicos: com escala no monitor o quadro tem mais pixels que a tela.
        frameWidth: frame.sourceSize.width
        frameHeight: frame.sourceSize.height
      }

      // O ponteiro: sem seleção o do sistema fica invisível sobre a área de captura (a mira faz o papel dele) e volta ao normal
      // sobre a dica e a barra; com seleção a peça escolhe a seta de mover, as de redimensionar ou a cruz (Capture.cursorShape).
      // É um HoverHandler, e não uma MouseArea, para a barra por cima continuar recebendo os cliques.
      HoverHandler {
        id: pointer
        cursorShape: capture.cursorShape

        onPointChanged: {
          Screenshot.CaptureState.pointerOutput = root.outputName;
          capture.pointerSeen = true;
          capture.pointX = point.position.x;
          capture.pointY = point.position.y;
        }
      }
    }
  }
}
