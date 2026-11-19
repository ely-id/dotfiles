pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import "." as Screenshot
import "Annotate.js" as Ann
import ".."

// A área da imagem do editor de anotação (ficha 17, estado 5; board 13:19505): 688×408, raio `radiusRow`, borda `border` de 1. A imagem
// (a cena, AnnotateScene.qml) cabe inteira na área, sem deformar e centrada; se for menor que a área aparece no tamanho natural. A cena
// tem o tamanho da imagem em pixels e vai dentro de um item com `scale`, que a reduz na tela; o PNG exportado lê a cena sem essa escala
// (`scene`, para o FrameCropper), por isso o desenho sai igual ao que eu vejo.
//
// Aqui moram o ponteiro e o que é só da tela: o arraste que desenha a marca da ferramenta, o texto sendo digitado (um `TextInput` na
// tela, no tamanho da tela) e o recorte em andamento (o escurecimento e a borda da seleção de área da captura, sem as alças). Nada
// disso entra no PNG: só as marcas confirmadas, que estão no documento. As contas são do Annotate.js.
//
// O ponteiro fica em funções (`pressAt`, `dragTo`, `releaseAt`) para a vitrine e os testes o dirigirem sem o mouse.
Item {
  id: root

  // O AnnotateDocument (AnnotateState.document na shell, o do serviço fictício na vitrine) e a URL da imagem.
  required property var document
  property string imageSource: ""
  // Quem recebe o teclado quando o texto acaba (a peça).
  property Item focusTarget
  // Quem trata as teclas do campo de texto (a peça: `handleKey`).
  property var keyHandler: null

  readonly property alias scene: scene
  readonly property alias input: input
  readonly property bool textActive: input.visible
  readonly property bool hasCrop: cropRect !== null

  // O tamanho natural: um pixel da imagem é um pixel do monitor, e não um pixel lógico. Num monitor de escala 1,5 uma captura de 480×300 pixels
  // (320×200 lógicos) aparece como era na tela, em 320×200, e não ampliada.
  readonly property real naturalScale: 1 / (Window.window ? Window.window.devicePixelRatio : 1)

  // Onde a imagem está na área; null enquanto o documento não existe.
  readonly property var view: document.ready
      ? Ann.fit(document.state.width, document.state.height, width, height, naturalScale) : null

  // Os valores de desenho da tela, do Theme; o Annotate.js os divide pela escala ao criar a marca.
  readonly property var markStyle: ({
    color: document.color,
    pencilWidth: Theme.captureAnnotatePencilWidth,
    strokeWidth: Theme.captureAnnotateStrokeWidth,
    rectRadius: Theme.captureAnnotateRectRadius,
    thickness: Theme.captureAnnotateThickness,
    opacity: Theme.captureAnnotateHighlightOpacity,
    stripRadius: Theme.captureAnnotateStripRadius,
    head: Theme.captureAnnotateHeadSize,
    fontSize: Theme.captureAnnotateFontSize
  })

  // O arraste em andamento: os pontos da tela, a marca provisória e o recorte (em pixels da tela, ou null).
  property var dragPoints: []
  property bool dragging: false
  property var draft: null
  property var cropRect: null
  property point cropOrigin: Qt.point(0, 0)

  // ---- a imagem carregou: o documento começa com o tamanho dela ----

  function sync() {
    const image = scene.image;
    if (document.ready || image.status !== Image.Ready || image.implicitWidth <= 0 || image.implicitHeight <= 0)
      return;
    document.begin(image.implicitWidth, image.implicitHeight);
  }

  Connections {
    target: scene.image
    function onStatusChanged() {
      if (scene.image.status === Image.Error)
        console.warn("screenshot: não consegui carregar a imagem do editor de anotação");
      root.sync();
    }
  }

  Connections {
    target: root.document
    // O documento mudou (marca nova, desfazer, recorte): o recorte em andamento não vale mais, a tela dele pode ser outra.
    function onStateChanged() { root.clearCrop(); }
    // Abertura nova: o que é só desta peça volta ao zero. Abrir de novo com a mesma imagem não a recarrega (o `Image` não muda de estado),
    // então é o documento zerado que pede o tamanho de novo. Fica para depois: começar o documento de dentro do aviso de que ele deixou
    // de existir faz o `ready` ser avaliado em volta.
    function onGenerationChanged() {
      root.clearLocal();
      Qt.callLater(root.sync);
    }
  }

  Component.onCompleted: sync()

  function clearLocal() {
    cancelText();
    clearCrop();
    dragging = false;
    draft = null;
    dragPoints = [];
  }

  // ---- o ponteiro ----

  // Apertei em (x, y), em pixels da área. Um aperto sempre confirma o texto em andamento; fora da imagem não começa nada.
  function pressAt(x, y) {
    if (!view)
      return;
    commitText();
    if (!Ann.inside(view, x, y))
      return;
    const p = Ann.clampToView(view, x, y);
    const tool = document.tool;
    if (tool === "text") {
      beginText(p.x, p.y);
      return;
    }
    dragging = true;
    dragPoints = [p];
    if (tool === "crop") {
      cropOrigin = Qt.point(p.x, p.y);
      cropRect = null;
      return;
    }
    draft = Ann.build(tool, markStyle, view, dragPoints);
  }

  // O ponteiro andou até (x, y) com o botão apertado.
  function dragTo(x, y) {
    if (!dragging || !view)
      return;
    const p = Ann.clampToView(view, x, y);
    const tool = document.tool;
    if (tool === "crop") {
      cropRect = Ann.cropFromDrag(view, cropOrigin.x, cropOrigin.y, p.x, p.y);
      return;
    }
    if (tool === "pencil") {
      // Pontos a menos de 1 px do anterior não acrescentam traço.
      const last = dragPoints[dragPoints.length - 1];
      if (Math.hypot(p.x - last.x, p.y - last.y) < 1)
        return;
      dragPoints.push(p);
    } else {
      dragPoints = [dragPoints[0], p];
    }
    draft = Ann.build(tool, markStyle, view, dragPoints);
  }

  // Soltei em (x, y): a marca provisória vira marca do documento; o recorte pequeno demais não fica.
  function releaseAt(x, y) {
    if (!dragging)
      return;
    dragTo(x, y);
    dragging = false;
    if (document.tool === "crop") {
      if (!Ann.cropUsable(cropRect, Theme.captureSelectionMinSize))
        cropRect = null;
      return;
    }
    const mark = draft;
    draft = null;
    dragPoints = [];
    if (mark)
      document.addMark(mark);
  }

  // O sistema tirou o ponteiro de mim no meio do arraste: descarto o que estava sendo desenhado.
  function cancelDrag() {
    dragging = false;
    draft = null;
    dragPoints = [];
    if (document.tool === "crop")
      cropRect = null;
  }

  // ---- o texto ----

  // Um clique põe o cursor em (x, y): o canto de cima à esquerda do texto.
  function beginText(x, y) {
    input.x = x;
    input.y = y;
    input.text = "";
    input.visible = true;
    input.forceActiveFocus();
  }

  // Enter: o texto vira marca. Vazio não vira nada.
  function commitText() {
    if (!input.visible)
      return;
    const mark = Ann.textMark(markStyle, view, Qt.point(input.x, input.y), input.text, input.contentWidth, input.contentHeight);
    closeInput();
    if (mark)
      document.addMark(mark);
  }

  // Esc: o texto some, e só ele.
  function cancelText() {
    if (input.visible)
      closeInput();
  }

  function closeInput() {
    input.visible = false;
    input.text = "";
    if (focusTarget)
      focusTarget.forceActiveFocus();
  }

  // ---- o recorte ----

  function clearCrop() {
    cropRect = null;
  }

  // Enter com o recorte feito: a imagem passa a ser só aquele pedaço, e as marcas que ficaram fora somem com ele.
  function applyCrop() {
    if (!cropRect || !view)
      return;
    const rect = Ann.cropToImage(view, cropRect);
    cropRect = null;
    document.applyCrop(rect);
  }

  // Antes de trocar de ferramenta, de cor, desfazer ou copiar: o texto em andamento vira marca; com `dropCrop`, o recorte em andamento
  // some (trocar de ferramenta o abandona).
  function settle(dropCrop) {
    commitText();
    if (dropCrop)
      clearCrop();
  }

  // ---- o desenho ----

  ClippingRectangle {
    anchors.fill: parent
    radius: Theme.radiusRow
    color: "transparent"

    // A cena reduzida: o item de fora leva a escala, e a cena de dentro continua em pixels da imagem.
    Item {
      x: root.view ? root.view.x : 0
      y: root.view ? root.view.y : 0
      width: scene.width
      height: scene.height
      scale: root.view ? root.view.scale : 1
      transformOrigin: Item.TopLeft

      Screenshot.AnnotateScene {
        id: scene
        imageSource: root.imageSource
        state: root.document.state
        draft: root.draft
      }
    }

    // O escurecimento por fora do recorte e a borda dele, os da seleção de área da captura (sem as alças), só sobre a imagem.
    Item {
      id: cropLayer
      visible: root.hasCrop && root.view !== null
      x: root.view ? root.view.x : 0
      y: root.view ? root.view.y : 0
      width: root.view ? root.view.width : 0
      height: root.view ? root.view.height : 0

      readonly property var sel: root.cropRect && root.view
          ? { x: root.cropRect.x - root.view.x, y: root.cropRect.y - root.view.y, width: root.cropRect.width, height: root.cropRect.height }
          : { x: 0, y: 0, width: 0, height: 0 }

      Rectangle { x: 0; y: 0; width: cropLayer.width; height: cropLayer.sel.y; color: Theme.captureDim }
      Rectangle {
        x: 0
        y: cropLayer.sel.y + cropLayer.sel.height
        width: cropLayer.width
        height: cropLayer.height - y
        color: Theme.captureDim
      }
      Rectangle { x: 0; y: cropLayer.sel.y; width: cropLayer.sel.x; height: cropLayer.sel.height; color: Theme.captureDim }
      Rectangle {
        x: cropLayer.sel.x + cropLayer.sel.width
        y: cropLayer.sel.y
        width: cropLayer.width - x
        height: cropLayer.sel.height
        color: Theme.captureDim
      }
      Screenshot.CaptureSelection {
        rect: cropLayer.sel
        showHandles: false
      }
    }

    MouseArea {
      anchors.fill: parent
      enabled: root.view !== null
      acceptedButtons: Qt.LeftButton
      cursorShape: root.document.tool === "text" ? Qt.IBeamCursor : Qt.CrossCursor
      onPressed: mouse => root.pressAt(mouse.x, mouse.y)
      onPositionChanged: mouse => { if (pressed) root.dragTo(mouse.x, mouse.y); }
      onReleased: mouse => root.releaseAt(mouse.x, mouse.y)
      onCanceled: root.cancelDrag()
    }

    // O texto sendo digitado, no tamanho da tela. Fica acima do `MouseArea`: um clique dentro dele põe o cursor, e um clique fora
    // confirma o texto e começa outro.
    TextInput {
      id: input
      visible: false
      color: root.document.color
      selectionColor: Theme.accent
      selectedTextColor: Theme.textOnAccent
      font.family: Theme.fontFamily
      font.weight: Font.DemiBold
      font.pixelSize: Theme.captureAnnotateFontSize
      font.letterSpacing: 0
      selectByMouse: true
      Keys.onPressed: event => { event.accepted = root.keyHandler ? root.keyHandler(event.key, event.modifiers) : false; }
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.radiusRow
    color: "transparent"
    border.width: Theme.captureAnnotateAreaBorder
    border.color: Theme.border
    antialiasing: true
  }
}
