pragma ComponentBehavior: Bound

import QtQuick
import "." as Screenshot
import Quickshell
import Quickshell.Wayland

// Janela da captura de tela (ficha 17), uma por tela, no padrão da janela da lupa (launcher/LoupeWindow.qml): camada de
// sobreposição na tela inteira. Enquanto `CaptureState.opened`, mostra o quadro capturado do monitor (o `ScreencopyView`, uma captura
// só) e por cima a peça (Capture.qml): o véu, a mira, a dica, a barra de modos e a seleção.
//
// Tiro dois quadros por monitor quando a captura abre, um sem o cursor e um com (`paintCursor`), porque o quadro é congelado e o botão
// "mostrar o cursor" da barra pode ligar e desligar depois. A janela mostra o que corresponde ao botão (`shown`), e a captura sai
// do que está à mostra (FrameCropper.qml, registrado no CaptureState). Os dois ficam um sobre o outro, os dois visíveis, para o
// Quickshell manter os dois vivos; o de cima é o que aparece.
//
// O teclado é exclusivo só na janela do monitor em que o ponteiro está (`CaptureState.pointerOutput`); com vários
// monitores o foco acompanha o ponteiro. A mira, as coordenadas, a dica e a barra só aparecem nesse mesmo monitor. A seleção
// de área (F6-T11) é um estado só, no CaptureState, preso ao monitor em que começou: a peça de cada janela só a desenha se
// o nome do monitor for o dela. Os modos Window e Screen (F6-T12) também dependem do nome do monitor (o da pílula do modo Screen e o
// das janelas da foto do CaptureState) e do tamanho do quadro (os pixels do monitor que a pílula mostra), que a peça já recebe.
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

  // Os quadros só existem com a captura aberta: criar o `ScreencopyView` na hora é o que captura a tela naquele instante
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
      Component.onCompleted: {
        forceActiveFocus();
        // O CaptureState chama o recortador desta janela quando eu capturo; ele só vale enquanto o quadro existe.
        Screenshot.CaptureState.registerFrame(root.outputName, cropper);
      }
      Component.onDestruction: Screenshot.CaptureState.unregisterFrame(root.outputName, cropper)

      // O foco do teclado vai e volta entre as janelas quando o ponteiro troca de monitor.
      Connections {
        target: root
        function onHereChanged() { if (root.here) stage.forceActiveFocus(); }
      }

      // Os dois quadros pedem a captura no mesmo instante, antes de a peça aparecer, então nenhum dos dois leva a peça na imagem.
      ScreencopyView {
        id: framePlain
        anchors.fill: parent
        z: stage.shown === framePlain ? 1 : 0
        captureSource: root.screen
        live: false
        paintCursor: false

        onHasContentChanged: stage.frameArrived()
      }

      ScreencopyView {
        id: frameCursor
        anchors.fill: parent
        z: stage.shown === frameCursor ? 1 : 0
        captureSource: root.screen
        live: false
        paintCursor: true

        onHasContentChanged: stage.frameArrived()
      }

      // O quadro à mostra e o recortador dele: o botão "mostrar o cursor" troca um pelo outro.
      readonly property Item shown: Screenshot.CaptureState.showCursor ? frameCursor : framePlain
      readonly property bool framesReady: framePlain.hasContent && frameCursor.hasContent

      function frameArrived() {
        if (framesReady)
          Screenshot.CaptureState.markReady(root.outputName);
      }

      Screenshot.FrameCropper {
        id: cropper
        source: stage.shown
        frameWidth: stage.shown.sourceSize.width
        frameHeight: stage.shown.sourceSize.height
      }

      // Sem os quadros a peça não aparece: o véu sobre uma janela transparente piscaria antes de a captura chegar. Onde a
      // captura nunca chega, o CaptureState desiste em 2 s.
      Screenshot.Capture {
        id: capture
        anchors.fill: parent
        visible: stage.framesReady
        service: Screenshot.CaptureState
        outputName: root.outputName
        active: root.here
        pointerSeen: false
        // Os pixels do quadro, não os lógicos: com escala no monitor o quadro tem mais pixels que a tela.
        frameWidth: stage.shown.sourceSize.width
        frameHeight: stage.shown.sourceSize.height
      }

      // O ponteiro: no modo Area, sem seleção, o do sistema fica invisível sobre a área de captura (a mira faz o papel dele) e volta ao
      // normal sobre a dica e a barra; com seleção a peça escolhe a seta de mover, as de redimensionar ou a cruz; nos modos Window e
      // Screen ele é a seta normal em toda parte (Capture.cursorShape).
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
