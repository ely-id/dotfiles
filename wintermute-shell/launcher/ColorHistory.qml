pragma ComponentBehavior: Bound

import QtQuick
import ".."

// Histórico do seletor de cor (ficha 15): o rótulo "History" em Geist Medium 11 `muted` numa caixa de 400×24 em
// (20,336) e, em y 364, até 12 amostras de 32×32 (raio 8, borda `border` de 1), uma a cada 40 a partir de x 20.
// Sob o ponteiro a borda passa a `knob` de 2, e uma dica de vidro de 88×28 mostra o HEX, 4 abaixo da amostra e
// centrada nela; nas pontas ela não passa dos 20 de margem do launcher. As coordenadas são as do quadro do launcher,
// então esta peça ocupa a página inteira (640 de largura) e só desenha o que é dela.
Item {
  id: root

  // Lista de { hex, ... }, a mais nova primeiro.
  property var model: []
  // Amostra sob o ponteiro; fixável na vitrine (o ponteiro de verdade só vale enquanto não for fixado).
  property int hoverIndex: -1
  readonly property int shownHover: pinned >= 0 ? pinned : hoverIndex
  // Para fixar o hover na vitrine.
  property int pinned: -1

  signal picked(int index)

  // Uma lista nova refaz as amostras; o ponteiro que estava numa delas já não vale.
  onModelChanged: hoverIndex = -1

  implicitWidth: Theme.launcherWidth
  implicitHeight: Theme.launcherColorHistoryY + Theme.launcherColorHistorySize + Theme.launcherColorTipGap
      + Theme.launcherColorTipHeight

  Text {
    x: Theme.launcherLabelX
    y: Theme.launcherColorHistoryLabelY
    width: Theme.launcherLabelWidth
    height: Theme.launcherLabelHeight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: "History"
    color: Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
  }

  Repeater {
    model: root.model.slice(0, Theme.launcherColorHistoryMax)

    delegate: Rectangle {
      id: swatch
      required property var modelData
      required property int index
      readonly property bool hot: index === root.shownHover

      x: Theme.launcherLabelX + index * Theme.launcherColorHistoryStep
      y: Theme.launcherColorHistoryY
      width: Theme.launcherColorHistorySize
      height: Theme.launcherColorHistorySize
      radius: Theme.launcherColorHistoryRadius
      color: modelData.hex
      border.width: hot ? Theme.launcherColorHistoryHoverBorder : 1
      border.color: hot ? Theme.knob : Theme.border
      antialiasing: true

      HoverHandler {
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: {
          if (hovered)
            root.hoverIndex = swatch.index;
          else if (root.hoverIndex === swatch.index)
            root.hoverIndex = -1;
        }
      }

      TapHandler {
        onTapped: root.picked(swatch.index)
      }
    }
  }

  // Dica do valor: só com uma amostra em hover.
  GlassSurface {
    id: tip
    readonly property var entry: root.shownHover >= 0 ? root.model[root.shownHover] : undefined

    visible: entry !== undefined
    // Centrada na amostra, mas dentro dos 20 de margem dos dois lados.
    x: Math.max(Theme.launcherColorTipMargin,
        Math.min(root.width - Theme.launcherColorTipMargin - width,
            Theme.launcherLabelX + root.shownHover * Theme.launcherColorHistoryStep
                + (Theme.launcherColorHistorySize - width) / 2))
    y: Theme.launcherColorHistoryY + Theme.launcherColorHistorySize + Theme.launcherColorTipGap
    width: Theme.launcherColorTipWidth
    height: Theme.launcherColorTipHeight
    radius: Theme.launcherColorTipRadius
    showGlow: false

    Text {
      anchors.fill: parent
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      text: tip.entry ? tip.entry.hex : ""
      color: Theme.text
      font.family: Theme.monoFontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontMonoCaption
      font.letterSpacing: 0
    }
  }
}
