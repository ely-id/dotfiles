import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import ".."
import "Clipboard.js" as Clipboard

// A prévia do item selecionado (ficha 18): caixa de 328×208, raio 12, borda `border` de 1 e fundo `cardHover`.
//   texto  (command, text, email e color): Geist Mono Medium 12, linha de 20, `text`, numa caixa de 296×176 a 16 da borda de dentro,
//          que quebra linha e corta o que passar.
//   imagem a imagem inteira, sem deformar e centrada, cortada no raio, com a borda por cima. No board ela preenche a caixa; mostrar
//          inteira é composição minha (A-05): quero ver a imagem que copiei, e não um pedaço dela.
//   link   bloco de 40 com o `globe` de 20, o título (Geist Medium 15) e a URL (Geist Mono Medium 11, `muted`, quebrando linha).
Item {
  id: root

  property var item: null
  readonly property string kind: item ? item.kind : ""

  implicitWidth: Theme.clipboardPreviewWidth
  implicitHeight: Theme.clipboardPreviewHeight
  width: implicitWidth
  height: implicitHeight

  // O fundo e o conteúdo da imagem ficam cortados no raio; a borda vem depois, por cima.
  ClippingRectangle {
    anchors.fill: parent
    radius: Theme.radiusRow
    color: Theme.cardHover

    Image {
      visible: root.kind === "image"
      anchors.fill: parent
      source: root.kind === "image" && root.item.image ? root.item.image.url : ""
      sourceSize: Qt.size(width * 2, height * 2)
      fillMode: Image.PreserveAspectFit
      horizontalAlignment: Image.AlignHCenter
      verticalAlignment: Image.AlignVCenter
      smooth: true
      cache: false
      asynchronous: true
    }

    Text {
      visible: root.kind !== "image" && root.kind !== "link"
      x: Theme.clipboardPreviewPadding
      y: Theme.clipboardPreviewPadding
      width: Theme.clipboardPreviewTextWidth
      height: Theme.clipboardPreviewTextHeight
      clip: true
      wrapMode: Text.Wrap
      lineHeight: Theme.clipboardPreviewLineHeight
      lineHeightMode: Text.FixedHeight
      text: Clipboard.previewText(root.item)
      color: Theme.text
      textFormat: Text.PlainText
      font.family: Theme.monoFontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontClipboardPreview
      font.letterSpacing: 0
    }

    Rectangle {
      visible: root.kind === "link"
      x: Theme.clipboardPreviewPadding
      y: Theme.clipboardPreviewPadding
      width: Theme.clipboardLinkBlockSize
      height: Theme.clipboardLinkBlockSize
      radius: Theme.radiusChip
      color: Theme.accentSubtle
      antialiasing: true

      Image {
        x: Theme.clipboardLinkIconOffset
        y: Theme.clipboardLinkIconOffset
        width: Theme.clipboardLinkIconSize
        height: Theme.clipboardLinkIconSize
        source: Qt.resolvedUrl("../icons/globe.svg")
        sourceSize: Qt.size(width * 2, height * 2)
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true
        layer.enabled: true
        layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.accentText }
      }
    }

    Text {
      visible: root.kind === "link"
      x: Theme.clipboardPreviewPadding
      y: Theme.clipboardLinkTitleY
      width: Theme.clipboardPreviewTextWidth
      height: Theme.clipboardLinkTitleHeight
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      text: Clipboard.linkTitleOf(root.item)
      color: Theme.text
      font.family: Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontLabel
      font.letterSpacing: 0
    }

    Text {
      visible: root.kind === "link"
      x: Theme.clipboardPreviewPadding
      y: Theme.clipboardLinkUrlY
      width: Theme.clipboardPreviewTextWidth
      wrapMode: Text.Wrap
      lineHeight: Theme.clipboardLinkUrlLineHeight
      lineHeightMode: Text.FixedHeight
      text: root.item ? String(root.item.text || "") : ""
      color: Theme.muted
      textFormat: Text.PlainText
      font.family: Theme.monoFontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontMonoCaption
      font.letterSpacing: 0
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.radiusRow
    color: "transparent"
    border.width: 1
    border.color: Theme.border
    antialiasing: true
  }
}
