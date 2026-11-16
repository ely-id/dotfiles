import QtQuick
import QtQuick.Effects
import "../.." as Shell

// Monitor no desenho da Tela e na área de Organizar (ficha 13; Figma 13:16041 e 13:16062).
// Repouso: raised com borda borderStrong de 1, raio 8, nome 13 Medium em text e conector 11 Medium
// em muted, as duas linhas de 20 centradas juntas. Selecionado (Tela) e arrastado (Organizar):
// accentSubtle com anel accentRing de 2, e o conector passa a text (regra 5 do tema). O arrastado
// ganha a sombra do vidro, a legenda "Dragging" e o glifo move em accentText 22 abaixo do centro.
// Hover e foco: o mesmo raised com a camada hover por cima. O Figma não desenha esse estado; uso o
// token dos botões e linhas.
Rectangle {
  id: root
  property string label
  property string detail
  property bool selected: false
  property bool dragging: false
  property bool hovered: false

  readonly property bool highlighted: selected || dragging
  readonly property int lineHeight: Shell.Theme.settingsDisplayLineHeight
  // Num monitor estreito (em retrato) o nome quebra em até duas linhas; o bloco continua centrado.
  readonly property int nameLines: Math.max(1, Math.min(2, name.lineCount))
  readonly property real blockTop: Math.round(height / 2 - (nameLines + 1) * lineHeight / 2)

  radius: Shell.Theme.settingsDisplayTileRadius
  color: highlighted ? Shell.Theme.accentSubtle
      : hovered || activeFocus ? Qt.tint(Shell.Theme.raised, Shell.Theme.hover) : Shell.Theme.raised
  border.width: highlighted ? 2 : 1
  border.color: highlighted ? Shell.Theme.accentRing : Shell.Theme.borderStrong
  antialiasing: true

  Behavior on color {
    ColorAnimation { duration: Shell.Theme.hoverDuration; easing.type: Easing.OutCubic }
  }

  Shell.Shadow {
    anchors.fill: parent
    z: -1
    visible: root.dragging
    cornerRadius: root.radius
  }

  Text {
    id: name
    x: 0; width: parent.width
    y: root.blockTop
    // Sem altura fixa: com ela o elide cortaria antes de quebrar e lineCount ficaria em 1.
    leftPadding: 8; rightPadding: 8
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    wrapMode: Text.Wrap
    maximumLineCount: 2
    lineHeightMode: Text.FixedHeight
    lineHeight: root.lineHeight
    elide: Text.ElideRight
    text: root.label
    color: Shell.Theme.text
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontBody
    font.letterSpacing: 0
  }

  Text {
    x: 0; width: parent.width
    y: root.blockTop + root.nameLines * root.lineHeight
    height: root.lineHeight
    leftPadding: 8; rightPadding: 8
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    visible: text !== "" && parent.height >= 2 * root.lineHeight
    text: root.dragging ? "Dragging" : root.detail
    color: root.highlighted ? Shell.Theme.text : Shell.Theme.muted
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontCaption
    font.letterSpacing: 0
  }

  Image {
    anchors.horizontalCenter: parent.horizontalCenter
    y: root.blockTop + (root.nameLines + 1) * root.lineHeight + 2
    width: 16; height: 16
    visible: root.dragging && y + height <= parent.height - 4
    source: Qt.resolvedUrl("../../icons/move.svg")
    sourceSize: Qt.size(32, 32)
    smooth: true
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: Shell.Theme.accentText
    }
  }
}
