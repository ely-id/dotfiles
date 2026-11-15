import QtQuick
import QtQuick.Effects
import QtQuick.Templates as T

// Slider Armitage (ficha 00):
// Caixa 276×32; trilho 276×12 em y 10, raio 6, fundo track.
// Preenchimento accent, altura 10 em y 11, raio 5.
// Alça 26 (repouso/hover/mudo, y 3) ou 20 (arrastando, y 6), cor knob (arrastando = accentHover).
// Hover: anel accentRing 4 px outside e bolha 28×22 raio 6 em y -28 com Geist Mono 11 textOnAccent.
// Mudo: trilho com borda borderStrong, preenchimento 2 px em muted, ícone volume-x 16 na alça.
T.Slider {
  id: root

  property real externalValue: 0
  property bool showInlineValue: true
  property bool muted: false
  property bool interactive: true
  property color trackColor: Theme.track
  // Opcional para fixar o estado na demonstração: "" | "rest" | "hover" | "dragging" | "muted"
  property string visualState: ""

  signal dragStarted
  signal dragFinished
  onPressedChanged: pressed ? dragStarted() : dragFinished()

  from: 0; to: 1
  leftPadding: 13; rightPadding: 13
  enabled: interactive
  hoverEnabled: true
  focusPolicy: Qt.NoFocus
  handle: Item { width: 0; height: 0 }
  // Retoma atualizações externas depois que o arraste termina.
  Binding on value { value: root.externalValue; when: !root.pressed; restoreMode: Binding.RestoreNone }

  readonly property bool isMutedState: visualState === "muted" || (visualState === "" && muted)
  readonly property bool isDraggingState: visualState === "dragging" || (visualState === "" && pressed)
  readonly property bool isHoverState: visualState === "hover" || (visualState === "" && handleHovered && !pressed && !muted)

  readonly property real visualValue: position
  readonly property real handleCenterX: Math.round(leftPadding + visualPosition * availableWidth)
  readonly property bool handleHovered: hovered
      && Math.abs(pointer.point.position.x - handleCenterX) <= 13
      && pointer.point.position.y >= 0 && pointer.point.position.y <= 32
  readonly property real handleSize: isDraggingState ? 20 : 26
  readonly property real handleTop: isDraggingState ? 6 : 3

  implicitWidth: Theme.panelFieldWidth
  implicitHeight: 32
  clip: false

  Item {
    anchors.fill: parent

    Rectangle {
      x: 0
      y: 10
      width: parent.width
      height: 12
      radius: 6
      color: root.isMutedState ? "transparent" : root.trackColor
      border.width: root.isMutedState ? 1 : 0
      border.color: Theme.borderStrong
      antialiasing: true
    }

    Rectangle {
      x: 1
      y: root.isMutedState ? 15 : 11
      width: Math.max(0, root.handleCenterX - x)
      height: root.isMutedState ? 2 : 10
      radius: height / 2
      color: root.isMutedState ? Theme.muted : Theme.accent
      antialiasing: true
    }
  }

  // Anel externo de 4 px no hover (accentRing)
  Rectangle {
    x: handle.x - 4
    y: handle.y - 4
    width: handle.width + 8
    height: handle.height + 8
    radius: width / 2
    visible: root.isHoverState
    color: "transparent"
    border.width: 4
    border.color: Theme.accentRing
    antialiasing: true
  }

  Item {
    id: handle
    x: Math.round(root.handleCenterX - width / 2)
    y: root.handleTop
    width: root.handleSize
    height: root.handleSize

    Behavior on width {
      NumberAnimation {
        duration: Theme.controlDuration
        easing.type: Easing.OutCubic
      }
    }
    Behavior on height {
      NumberAnimation {
        duration: Theme.controlDuration
        easing.type: Easing.OutCubic
      }
    }

    Shadow {
      anchors.fill: parent
      cornerRadius: width / 2
      strength: 0.5
    }

    Rectangle {
      anchors.fill: parent
      radius: width / 2
      color: root.isDraggingState ? Theme.accentHover : Theme.knob
      antialiasing: true

      Text {
        anchors.centerIn: parent
        visible: root.showInlineValue && !root.isMutedState && !root.isDraggingState
        text: Math.round(root.visualValue * 100)
        color: Theme.textOnAccent
        font.family: Theme.monoFontFamily
        font.weight: Font.Medium
        font.pixelSize: Theme.fontMonoCaption
        font.letterSpacing: 0
      }

      Image {
        x: 5
        y: 5
        visible: root.isMutedState
        width: 16
        height: 16
        source: Qt.resolvedUrl("icons/volume-x.svg")
        sourceSize: Qt.size(32, 32)
        layer.enabled: true
        layer.effect: MultiEffect {
          colorization: 1
          colorizationColor: Theme.textOnAccent
        }
      }
    }
  }

  Item {
    id: valueBubble
    z: 3
    x: Math.round(root.handleCenterX - 14)
    y: -28
    width: 28
    height: 22
    visible: opacity > 0.001
    opacity: root.isHoverState ? 1 : 0

    Behavior on opacity {
      NumberAnimation {
        duration: Theme.controlDuration
        easing.type: Easing.OutCubic
      }
    }

    Rectangle {
      anchors.fill: parent
      radius: 6
      color: Theme.knob
      antialiasing: true

      Text {
        anchors.centerIn: parent
        text: Math.round(root.visualValue * 100)
        color: Theme.textOnAccent
        font.family: Theme.monoFontFamily
        font.weight: Font.Medium
        font.pixelSize: Theme.fontMonoCaption
        font.letterSpacing: 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
  }

  HoverHandler {
    id: pointer
    enabled: root.hoverEnabled && root.visualState === ""
    cursorShape: root.pressed ? Qt.ClosedHandCursor
        : root.handleHovered ? Qt.OpenHandCursor : Qt.PointingHandCursor
  }
}
