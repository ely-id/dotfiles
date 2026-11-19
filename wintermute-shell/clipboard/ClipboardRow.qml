import QtQuick
import QtQuick.Effects
import ".."
import "Clipboard.js" as Clipboard

// Linha do histórico da área de transferência (ficha 18): 264×52, raio 12. Sem fundo no repouso, `hover` sob o ponteiro e
// `accentSubtle` na selecionada (a selecionada vence o hover). Bloco de 28 em (8,12) com o ícone do tipo em 16, ou, no item de cor,
// uma amostra de 28 na cor dele com borda `border`; o título (Geist Medium 13) e a meta (Geist Medium 11) à direita do bloco, e o
// `pin` de 16 em `accentText` na linha fixada. É a linha do launcher (ResultRow) com a altura e o texto do board do histórico.
Item {
  id: root

  // O item do histórico (ver Clipboard.js) e o relógio do serviço, para o tempo da meta.
  property var item: null
  property real now: 0
  property bool selected: false
  // Para fixar o hover na vitrine.
  property bool forceHovered: false
  readonly property bool hovered: forceHovered || pointer.hovered
  readonly property bool pinned: !!(item && item.pinned)
  readonly property bool isColor: !!(item && item.kind === "color")

  signal clicked
  signal activated

  implicitWidth: Theme.clipboardRowWidth
  implicitHeight: Theme.clipboardRowHeight

  Rectangle {
    anchors.fill: parent
    radius: Theme.radiusRow
    color: root.selected ? Theme.accentSubtle
        : root.hovered ? Theme.hover
        : "transparent"
    antialiasing: true

    Behavior on color {
      ColorAnimation {
        duration: Theme.controlDuration
        easing.type: Easing.OutCubic
      }
    }
  }

  // O bloco do tipo, ou a amostra da cor.
  Rectangle {
    x: Theme.launcherBlockOffset
    y: Theme.clipboardBlockY
    width: Theme.launcherBlockSize
    height: Theme.launcherBlockSize
    radius: Theme.launcherBlockRadius
    color: root.isColor && root.item.color ? root.item.color : Theme.control
    border.width: root.isColor ? 1 : 0
    border.color: Theme.border
    antialiasing: true

    Image {
      visible: !root.isColor
      x: Theme.launcherBlockIconOffset
      y: Theme.launcherBlockIconOffset
      width: Theme.launcherBlockIconSize
      height: Theme.launcherBlockIconSize
      source: root.item ? Qt.resolvedUrl("../icons/" + Clipboard.iconFor(root.item.kind) + ".svg") : ""
      sourceSize: Qt.size(width * 2, height * 2)
      fillMode: Image.PreserveAspectFit
      smooth: true
      antialiasing: true
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.text }
    }
  }

  Text {
    x: Theme.clipboardTitleX
    y: Theme.clipboardTitleY
    width: root.pinned ? Theme.clipboardTitleWidthPinned : Theme.clipboardTitleWidth
    height: Theme.clipboardTitleHeight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: Clipboard.titleOf(root.item)
    color: Theme.text
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }

  // A meta é centrada em y 35: uma caixa de 20 de altura que começa 10 acima disso.
  Text {
    x: Theme.clipboardTitleX
    y: Theme.clipboardMetaCenterY - height / 2
    width: Theme.clipboardTitleWidth
    height: Theme.clipboardTitleHeight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.item ? Clipboard.metaOf(root.item, root.now) : ""
    color: root.selected ? Theme.text : Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
  }

  Image {
    visible: root.pinned
    x: Theme.clipboardPinX
    y: Theme.clipboardPinY
    width: Theme.clipboardPinSize
    height: Theme.clipboardPinSize
    source: Qt.resolvedUrl("../icons/pin.svg")
    sourceSize: Qt.size(width * 2, height * 2)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    layer.enabled: true
    layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.accentText }
  }

  HoverHandler {
    id: pointer
    cursorShape: Qt.PointingHandCursor
  }

  // O clique seleciona; o duplo clique copia (o mesmo que o Enter).
  TapHandler {
    onTapped: root.clicked()
    onDoubleTapped: root.activated()
  }
}
