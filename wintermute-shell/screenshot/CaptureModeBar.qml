pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import ".."

// A barra de modos da captura (ficha 17, board 13:19344, nó 13:19381): vidro de 496×56 (raio radiusCard, sem o brilho do
// acento) com os três modos, o atraso, o botão de mostrar o cursor e o de fechar. Não sabe de onde vem o estado:
// `service` tem `mode`, `showCursor` e `delaySeconds` e as funções `setMode`, `toggleCursor` e `close` (CaptureState.qml
// na shell, demo/CaptureService.qml na vitrine).
//
// O atraso não é clicável: a captura não tem seletor de atraso (P-16). O "0 s" fica como o board o desenha e só mostra os segundos.
GlassSurface {
  id: root

  property var service

  // Para fixar o hover na vitrine: o índice do modo sob o ponteiro (-1: o ponteiro de verdade).
  property int hoverMode: -1

  width: Theme.captureBarWidth
  height: Theme.captureBarHeight
  radius: Theme.radiusCard
  showGlow: false

  readonly property var modeList: [
    { key: "area", label: "Area", icon: "crop" },
    { key: "window", label: "Window", icon: "app-window" },
    { key: "screen", label: "Screen", icon: "monitor" }
  ]

  // A barra engole o clique: o que for clicado no vazio dela não pode chegar à captura que está por baixo (a seleção da
  // área, na F6-T11).
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.AllButtons
  }

  Repeater {
    model: root.modeList

    delegate: Rectangle {
      id: tile

      required property var modelData
      required property int index

      readonly property bool selected: root.service && root.service.mode === modelData.key
      readonly property bool hovered: !selected && (root.hoverMode >= 0 ? root.hoverMode === index : tileHover.hovered)

      x: Theme.captureBarPadding + index * Theme.captureModeStep
      y: Theme.captureBarPadding
      width: Theme.captureModeWidth
      height: Theme.captureModeHeight
      radius: Theme.radiusChip
      antialiasing: true
      // Selecionado: accentSubtle com anel accentRing de 1. Os outros não têm desenho de hover no board: fundo `hover` (A-05).
      color: selected ? Theme.accentSubtle : hovered ? Theme.hover : "transparent"
      border.width: selected ? 1 : 0
      border.color: Theme.accentRing

      Behavior on color {
        ColorAnimation {
          duration: Theme.hoverDuration
          easing.type: Easing.OutCubic
        }
      }

      // O ícone é `text` nos três modos.
      Image {
        x: Theme.captureModeIconX
        y: Theme.captureModeIconY
        width: Theme.captureModeIconSize
        height: Theme.captureModeIconSize
        source: Qt.resolvedUrl("../icons/" + tile.modelData.icon + ".svg")
        sourceSize: Qt.size(Theme.captureModeIconSize * 2, Theme.captureModeIconSize * 2)
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true
        layer.enabled: true
        layer.effect: MultiEffect {
          colorization: 1
          colorizationColor: Theme.text
        }
      }

      Text {
        x: Theme.captureModeLabelX
        width: Theme.captureModeLabelWidth
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        text: tile.modelData.label
        color: tile.selected ? Theme.text : Theme.muted
        font.family: Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Theme.fontBody
        font.letterSpacing: 0
      }

      HoverHandler {
        id: tileHover
        cursorShape: Qt.PointingHandCursor
      }
      TapHandler {
        onTapped: if (root.service) root.service.setMode(tile.modelData.key)
      }
    }
  }

  Rectangle {
    x: Theme.captureDividerLeftX
    y: Theme.captureDividerY
    width: 1
    height: Theme.captureDividerHeight
    color: Theme.border
  }

  // O atraso: relógio e segundos. Sem clique e sem hover (P-16: a captura não tem seletor de atraso).
  Item {
    x: Theme.captureDelayX
    y: Theme.captureBarPadding
    width: Theme.captureDelayWidth
    height: Theme.captureModeHeight

    Image {
      x: Theme.captureDelayIconX
      y: Theme.captureDelayIconY
      width: Theme.captureModeIconSize
      height: Theme.captureModeIconSize
      source: Qt.resolvedUrl("../icons/clock.svg")
      sourceSize: Qt.size(Theme.captureModeIconSize * 2, Theme.captureModeIconSize * 2)
      fillMode: Image.PreserveAspectFit
      smooth: true
      antialiasing: true
      layer.enabled: true
      layer.effect: MultiEffect {
        colorization: 1
        colorizationColor: Theme.text
      }
    }

    Text {
      x: Theme.captureDelayLabelX
      width: Theme.captureDelayLabelWidth
      height: parent.height
      verticalAlignment: Text.AlignVCenter
      text: (root.service ? root.service.delaySeconds : 0) + " s"
      color: Theme.muted
      font.family: Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontBody
      font.letterSpacing: 0
    }
  }

  // Mostrar o cursor na captura: ligado, usa o estado selecionado do próprio IconButton.
  IconButton {
    x: Theme.captureCursorX
    y: Theme.captureBarPadding
    buttonSize: Theme.captureButtonSize
    iconName: "mouse-pointer-2"
    checked: root.service ? root.service.showCursor : false
    onClicked: if (root.service) root.service.toggleCursor()
  }

  Rectangle {
    x: Theme.captureDividerRightX
    y: Theme.captureDividerY
    width: 1
    height: Theme.captureDividerHeight
    color: Theme.border
  }

  IconButton {
    x: Theme.captureCloseX
    y: Theme.captureBarPadding
    buttonSize: Theme.captureButtonSize
    iconName: "x"
    onClicked: if (root.service) root.service.close()
  }
}
