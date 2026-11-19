import QtQuick
import ".."

// Célula da grade do seletor de emoji (ficha 16, nó 13:17574): 48×48, raio 12, o emoji de 28 centrado. Sem fundo no repouso,
// `hover` sob o ponteiro e `accentSubtle` com borda `accentRing` de 1 na selecionada (a selecionada vence o hover). O
// ponteiro não é desta peça: a página decide qual célula está sob ele.
Item {
  id: root

  property string glyph: ""
  property bool selected: false
  property bool hovered: false

  implicitWidth: Theme.launcherEmojiCellSize
  implicitHeight: Theme.launcherEmojiCellSize

  Rectangle {
    anchors.fill: parent
    radius: Theme.radiusRow
    color: root.selected ? Theme.accentSubtle
        : root.hovered ? Theme.hover
        : "transparent"
    border.width: root.selected ? 1 : 0
    border.color: Theme.accentRing
    antialiasing: true

    Behavior on color {
      ColorAnimation {
        duration: Theme.controlDuration
        easing.type: Easing.OutCubic
      }
    }
  }

  Text {
    anchors.centerIn: parent
    text: root.glyph
    color: Theme.text
    font.family: Theme.emojiFontFamily
    font.pixelSize: Theme.launcherEmojiGlyphSize
  }
}
