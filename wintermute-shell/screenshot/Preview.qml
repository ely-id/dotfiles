pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import "." as Screenshot
import ".." as Shell

// A prévia da captura de tela na barra (ficha 17, estado 4; board 13:19344): a miniatura de 156×112 acima dos controles
// (repouso 13:19531, hover 13:19557) e, com a barra recolhida, o quadrado de 48×48 (13:19592). Com o ponteiro em cima, véu
// de 50% e quatro botões redondos: copiar, salvar, anotar e fechar; recolhida, o véu e só o de copiar (composição, A-05).
// Não sabe o que cada ação faz: chama `service.copy()`, `save()`, `annotate()` e `dismiss()` (screenshot/State.qml na shell,
// demo/ScreenshotService.qml na vitrine), e escreve `service.hovered` para o relógio de sumir parar com o ponteiro em cima.
Item {
  id: root
  required property string outputName
  property var service: Screenshot.State
  property bool collapsed: false
  property bool dragging: false
  // Para fixar o estado na vitrine: o hover da prévia e o do botão sob o ponteiro ("copy", "save", "annotate" ou "dismiss").
  // Com `hoverPinned` o ponteiro de verdade não escreve em `service.hovered`.
  property bool hoverPinned: false
  property string hoverButton: ""
  readonly property bool hasScreenshot: service.imageSource !== ""
      && service.outputName === outputName
  readonly property bool pointerOver: hasScreenshot && hover.hovered
  readonly property bool showControls: hoverPinned || pointerOver
  width: collapsed ? Shell.Theme.capturePreviewCollapsedSize : Shell.Theme.capturePreviewWidth
  height: hasScreenshot
      ? (collapsed ? Shell.Theme.capturePreviewCollapsedSize : Shell.Theme.capturePreviewHeight) : 0
  visible: hasScreenshot
  opacity: dragging ? 0 : 1

  // O estado guarda se o ponteiro está em cima; só a peça que mostra a prévia escreve, e só quando o valor muda.
  onPointerOverChanged: if (!hoverPinned) service.hovered = pointerOver

  // Os botões, na ordem do board. Recolhida, só o de copiar, centrado (x 8 nos dois casos: (48 − 32) / 2 = 8).
  readonly property var buttons: [
    { key: "copy", icon: "copy", name: "Copy screenshot" },
    { key: "save", icon: "save", name: "Save screenshot" },
    { key: "annotate", icon: "pencil", name: "Annotate screenshot" },
    { key: "dismiss", icon: "x", name: "Dismiss screenshot" }
  ]

  // Chama a ação de um botão. Separado do clique para a vitrine testar sem o mouse.
  function trigger(key) {
    if (key === "copy") service.copy();
    else if (key === "save") service.save();
    else if (key === "annotate") service.annotate();
    else if (key === "dismiss") service.dismiss();
  }

  // O arraste da captura para outro aplicativo usa o plugin em C++ de native/, que precisa ser compilado (README da shell).
  // Não importo o módulo aqui: tento carregar NativeDrag.qml, e se o plugin não existir (a bancada, a tela de teste, uma
  // instalação sem o passo de compilação) a prévia fica com `refusal`, que recusa o arraste. Copiar, salvar, anotar e fechar
  // não dependem dele. Crio o componente antes do Loader para dar uma linha de aviso só, com o que fazer, em vez da mensagem
  // crua do Qt sobre o módulo que falta.
  readonly property Component nativeComponent: Qt.createComponent("NativeDrag.qml")
  Loader {
    id: nativeLoader
    sourceComponent: root.nativeComponent.status === Component.Ready ? root.nativeComponent : null
  }
  Component.onCompleted: {
    if (nativeComponent.status !== Component.Ready)
      console.warn("Screenshot drag plugin not found: dragging the preview to another app is off (see wintermute-shell/README.md).");
  }
  QtObject {
    id: refusal
    function start(source, imageSource, hotSpot, radius) { return false; }
  }
  readonly property bool nativeDragAvailable: nativeLoader.status === Loader.Ready
  readonly property var nativeDrag: nativeDragAvailable ? nativeLoader.item : refusal

  // A sombra do vidro por baixo; recolhida, sem sombra (o nó 13:19592 não tem).
  Shell.Shadow {
    anchors.fill: parent
    visible: !root.collapsed
    cornerRadius: Shell.Theme.capturePreviewRadius
  }
  // A imagem e o véu, cortados no raio. A borda fica por cima de tudo, como no board.
  ClippingRectangle {
    anchors.fill: parent
    radius: Shell.Theme.capturePreviewRadius
    color: "transparent"
    Image {
      id: thumbnail
      objectName: "screenshotThumbnail"
      anchors.fill: parent
      source: root.service.imageSource
      sourceSize: Qt.size(Shell.Theme.capturePreviewWidth * 2, Shell.Theme.capturePreviewHeight * 2)
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
    }
    Rectangle {
      objectName: "screenshotVeil"
      anchors.fill: parent
      color: Shell.Theme.capturePreviewVeil
      opacity: root.showControls ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: Shell.Theme.hoverDuration; easing.type: Easing.OutCubic } }
    }
  }
  Rectangle {
    anchors.fill: parent
    radius: Shell.Theme.capturePreviewRadius
    color: "transparent"
    border { width: Shell.Theme.capturePreviewBorderWidth; color: Shell.Theme.borderStrong }
    antialiasing: true
  }
  HoverHandler { id: hover }
  MouseArea {
    id: dragArea
    anchors.fill: parent
    property point pressPosition
    property bool started: false
    // A mão aberta promete um arraste: sem o plugin, o cursor fica o normal.
    cursorShape: !root.nativeDragAvailable ? Qt.ArrowCursor
        : root.service.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor
    onPressed: mouse => { pressPosition = Qt.point(mouse.x, mouse.y); started = false; }
    onPositionChanged: mouse => {
      if (!pressed || started || Math.hypot(mouse.x - pressPosition.x, mouse.y - pressPosition.y)
          < Qt.styleHints.startDragDistance) return;
      if (root.service.dragging) return;
      started = true;
      const generation = root.service.generation;
      root.service.dragging = root.dragging = true;
      const accepted = root.nativeDrag.start(root, root.service.imageSource, pressPosition,
          Shell.Theme.capturePreviewRadius);
      root.service.dragging = root.dragging = false;
      if (accepted && generation === root.service.generation) root.service.dismiss();
    }
  }

  Repeater {
    model: root.collapsed ? root.buttons.slice(0, 1) : root.buttons

    delegate: Screenshot.PreviewButton {
      id: button
      required property var modelData
      required property int index
      objectName: modelData.key + "Screenshot"
      x: Shell.Theme.capturePreviewButtonPadding + index * Shell.Theme.capturePreviewButtonStep
      y: Math.round((root.height - height) / 2)
      iconName: modelData.icon
      label: modelData.name
      done: modelData.key === "copy" && root.service.copied
      hoverPinned: root.hoverButton === modelData.key
      opacity: root.showControls ? 1 : 0
      enabled: root.showControls && !root.service.dragging
      Behavior on opacity { NumberAnimation { duration: Shell.Theme.hoverDuration; easing.type: Easing.OutCubic } }
      onActivated: root.trigger(modelData.key)
    }
  }
}
