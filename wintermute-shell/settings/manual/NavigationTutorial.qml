pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "../.." as Shell

// Tutorial do Manual (ficha 13; Figma 13:16161): quadro de 440×240, raio 16, em cardHover com borda
// border, e a legenda 13 Medium muted numa caixa de 440×24 em y 192.
// - Touchpad (desenhado no Figma): touchpad de 200×128 em (120,48), control com borda borderStrong,
//   três dedos de 16 em accentText a 90% e quatro setas chevron de 16 em accentText.
// - Keyboard (P-53): o Figma não desenha. É o mini teclado de 209×86 e o mouse de 40×56 da origem, em
//   (84,69), com as cores dos tokens. Colunas são Super + A / D, como no meu keybinds.kdl (P-54).
// A sequência e os tempos da animação são os da origem (P-55). Parado, mostra o quadro do Figma.
Rectangle {
  id: root

  property string mode: "keyboard"
  property bool active: true
  readonly property bool live: active && visible

  readonly property color accent: Shell.Theme.accentText
  readonly property color outline: Shell.Theme.borderStrong

  // Dedos no quadro do Figma, e até onde deslizam: 8 px antes de cada seta.
  readonly property real fingersRestX: 64
  readonly property real fingersRestY: 56
  readonly property real swipeX: 16
  readonly property real swipeY: 8

  property real superFill: 0
  property real leftFill: 0
  property real rightFill: 0
  property color columnOutline: outline
  property real wheelFill: 0
  property real wheelY: 0
  readonly property real wheelCenter: 10 + 16 * wheelY

  property real fingersX: fingersRestX
  property real fingersY: fingersRestY
  property real fingersFill: 1
  property real fingersOpacity: 1

  property real trailOpacity: 0
  property real trailDir: 1
  property real trailTail: 0
  readonly property real wheelHead: trailDir > 0 ? Math.max(trailTail, wheelCenter - 5) : Math.min(trailTail, wheelCenter + 5)

  implicitWidth: Shell.Theme.settingsManualContentWidth
  implicitHeight: Shell.Theme.settingsManualTutorialHeight
  radius: Shell.Theme.radiusCard
  color: Shell.Theme.cardHover
  border.width: 1
  border.color: Shell.Theme.border
  antialiasing: true

  onModeChanged: {
    if (mode === "touchpad") { fingersX = fingersRestX; fingersY = fingersRestY; fingersOpacity = 1; }
    if (live) switchMotion.restart();
  }
  onLiveChanged: if (!live) rest()

  // O quadro parado: o do Figma na aba Touchpad, e o teclado só com a Super contornada.
  function rest() {
    switchMotion.stop();
    resetKeyboard();
    resetTouchpad();
    fingersFill = 1;
  }

  function resetKeyboard() {
    trailOpacity = 0;
    columnOutline = outline; superFill = 0; leftFill = 0; rightFill = 0; wheelFill = 0; wheelY = 0;
  }

  function resetTouchpad() {
    fingersX = fingersRestX; fingersY = fingersRestY; fingersFill = 0; fingersOpacity = 1;
  }

  function startTrail(to) {
    trailDir = to < wheelY ? -1 : 1;
    trailTail = wheelCenter - 6 * trailDir;
    trailOpacity = 1;
  }

  component Trail: Rectangle {
    id: trail
    property real tail: 0
    property real head: 0
    property real cross: 0
    property real thickness: 2
    property color tailColor: "transparent"
    property color headColor: Shell.Theme.text
    readonly property bool reversed: head < tail
    readonly property real length: Math.abs(head - tail)
    x: Math.round(cross - thickness / 2)
    y: Math.min(tail, head)
    width: thickness
    height: length
    radius: thickness / 2
    visible: opacity > 0 && length > 0
    gradient: Gradient {
      GradientStop { position: 0; color: trail.reversed ? trail.headColor : trail.tailColor }
      GradientStop { position: 1; color: trail.reversed ? trail.tailColor : trail.headColor }
    }
  }

  // Super + roda: acende, a roda anda com o rastro, apaga.
  component Scroll: SequentialAnimation {
    id: scroll
    property Item host
    property real to
    NumberAnimation { target: scroll.host; properties: "superFill,wheelFill"; to: 1; duration: 160; easing.type: Easing.OutCubic }
    PauseAnimation { duration: 140 }
    ScriptAction { script: scroll.host.startTrail(scroll.to) }
    NumberAnimation { target: scroll.host; property: "wheelY"; to: scroll.to; duration: 720; easing.type: Easing.InOutCubic }
    ParallelAnimation {
      NumberAnimation { target: scroll.host; property: "trailOpacity"; to: 0; duration: 450; easing.type: Easing.OutCubic }
      NumberAnimation { target: scroll.host; properties: "superFill,wheelFill"; to: 0; duration: 240; easing.type: Easing.OutCubic }
    }
  }

  // Super + uma tecla: acende, segura o tempo de um gesto, apaga.
  component Press: SequentialAnimation {
    id: press
    property Item host
    property string fills
    NumberAnimation { target: press.host; properties: press.fills; to: 1; duration: 160; easing.type: Easing.OutCubic }
    PauseAnimation { duration: 140 + 720 }
    ParallelAnimation {
      PauseAnimation { duration: 450 }
      NumberAnimation { target: press.host; properties: press.fills; to: 0; duration: 240; easing.type: Easing.OutCubic }
    }
  }

  // Três dedos: encostam, deslizam, soltam.
  component Swipe: SequentialAnimation {
    id: swipe
    property Item host
    property string move
    property real to
    NumberAnimation { target: swipe.host; property: "fingersFill"; to: 1; duration: 220; easing.type: Easing.OutCubic }
    PauseAnimation { duration: 160 }
    NumberAnimation { target: swipe.host; property: swipe.move; to: swipe.to; duration: 720; easing.type: Easing.InOutCubic }
    NumberAnimation { target: swipe.host; property: "fingersFill"; to: 0; duration: 280; easing.type: Easing.OutCubic }
  }

  component Recenter: SequentialAnimation {
    id: recenter
    property Item host
    NumberAnimation { target: recenter.host; property: "fingersOpacity"; to: 0; duration: 200; easing.type: Easing.InCubic }
    ScriptAction { script: { recenter.host.fingersX = recenter.host.fingersRestX; recenter.host.fingersY = recenter.host.fingersRestY; } }
    NumberAnimation { target: recenter.host; property: "fingersOpacity"; to: 1; duration: 280; easing.type: Easing.OutCubic }
  }

  component Fade: Behavior {
    id: fade
    SequentialAnimation {
      PauseAnimation { duration: fade.targetValue ? 100 : 0 }
      NumberAnimation { duration: fade.targetValue ? 280 : 150; easing.type: Easing.OutCubic }
    }
  }

  SequentialAnimation {
    id: keyboardLoop
    running: root.live && root.mode === "keyboard" && !switchMotion.running
    loops: Animation.Infinite
    ScriptAction { script: root.resetKeyboard() }
    PauseAnimation { duration: 300 }
    Scroll { host: root; to: 1 }
    PauseAnimation { duration: 450 }
    Scroll { host: root; to: 0 }
    PauseAnimation { duration: 150 }
    ColorAnimation { target: root; property: "columnOutline"; to: root.accent; duration: 280 }
    PauseAnimation { duration: 300 }
    Press { host: root; fills: "superFill,leftFill" }
    PauseAnimation { duration: 450 }
    Press { host: root; fills: "superFill,rightFill" }
    PauseAnimation { duration: 150 }
    ColorAnimation { target: root; property: "columnOutline"; to: root.outline; duration: 280 }
  }

  SequentialAnimation {
    id: touchpadLoop
    running: root.live && root.mode === "touchpad" && !switchMotion.running
    loops: Animation.Infinite
    ScriptAction { script: root.resetTouchpad() }
    PauseAnimation { duration: 150 }
    Swipe { host: root; move: "fingersX"; to: root.fingersRestX - root.swipeX }
    PauseAnimation { duration: 100 }
    Recenter { host: root }
    PauseAnimation { duration: 150 }
    Swipe { host: root; move: "fingersX"; to: root.fingersRestX + root.swipeX }
    PauseAnimation { duration: 100 }
    Recenter { host: root }
    PauseAnimation { duration: 150 }
    Swipe { host: root; move: "fingersY"; to: root.fingersRestY - root.swipeY }
    PauseAnimation { duration: 100 }
    Recenter { host: root }
    PauseAnimation { duration: 150 }
    Swipe { host: root; move: "fingersY"; to: root.fingersRestY + root.swipeY }
    PauseAnimation { duration: 100 }
    Recenter { host: root }
  }

  SequentialAnimation {
    id: switchMotion
    ParallelAnimation {
      NumberAnimation { target: root; property: "trailOpacity"; to: 0; duration: 220; easing.type: Easing.OutCubic }
      NumberAnimation { target: root; properties: "superFill,leftFill,rightFill,wheelFill,fingersFill,wheelY"; to: 0; duration: 300; easing.type: Easing.OutCubic }
      ColorAnimation { target: root; property: "columnOutline"; to: root.outline; duration: 300 }
    }
    PauseAnimation { duration: 200 }
  }

  // ---- aba Keyboard: mini teclado e mouse da origem ----
  Item {
    objectName: "manualTutorialKeyboard"
    x: 84; y: 69 + 8 * (1 - opacity)
    width: 273; height: 86
    opacity: root.mode === "keyboard" ? 1 : 0
    visible: opacity > 0
    Fade on opacity {}

    Repeater {
      model: [
        [0, 0, 28, "tl"], [30, 0, 20], [52, 0, 20], [75, 0, 20], [97, 0, 20], [119, 0, 20], [141, 0, 20], [163, 0, 20], [185, 0, 24, "tr"],
        [0, 22, 32], [34, 22, 20, "left"], [56, 22, 20], [78, 22, 20, "right"], [100, 22, 20], [122, 22, 20], [144, 22, 20], [166, 22, 20], [188, 22, 21],
        [0, 44, 36], [38, 44, 20], [60, 44, 20], [82, 44, 20], [104, 44, 20], [126, 44, 20], [148, 44, 20], [170, 44, 39],
        [0, 66, 20, "bl"], [22, 66, 20, "super"], [45, 66, 20], [67, 66, 76], [145, 66, 20], [167, 66, 20], [189, 66, 20, "br"]
      ]
      delegate: Rectangle {
        required property var modelData
        readonly property string role: modelData[3] || ""
        readonly property real fill: role === "super" ? root.superFill
            : role === "left" ? root.leftFill
            : role === "right" ? root.rightFill : 0
        x: modelData[0]; y: modelData[1]
        width: modelData[2]; height: 20
        topLeftRadius: role === "tl" ? 8 : 2
        topRightRadius: role === "tr" ? 8 : 2
        bottomRightRadius: role === "br" ? 8 : 2
        bottomLeftRadius: role === "bl" ? 8 : 2
        color: Qt.alpha(root.accent, fill)
        border.width: 1
        border.color: role === "super" ? root.accent
            : role === "left" || role === "right" ? root.columnOutline : root.outline
        antialiasing: true
      }
    }

    Rectangle {
      x: 233; width: 40; height: 56; radius: 12
      color: "transparent"
      border.width: 1; border.color: root.outline
      antialiasing: true
      Trail {
        tail: root.trailTail; head: root.wheelHead; cross: 20
        tailColor: Qt.alpha(root.accent, 0); headColor: root.accent
        opacity: root.trailOpacity
      }
      Rectangle {
        x: 15; y: root.wheelCenter - 5
        width: 10; height: 10; radius: 5
        color: Qt.alpha(root.accent, root.wheelFill)
        border.width: 1; border.color: root.accent
        antialiasing: true
      }
    }
  }

  // ---- aba Touchpad: Figma 13:16162 ----
  Rectangle {
    objectName: "manualTutorialTouchpad"
    x: 120; y: 48 + 8 * (1 - opacity)
    width: 200; height: 128
    radius: Shell.Theme.radiusRow
    color: Shell.Theme.control
    border.width: 1; border.color: root.outline
    antialiasing: true
    opacity: root.mode === "touchpad" ? 1 : 0
    visible: opacity > 0
    Fade on opacity {}

    Repeater {
      model: [["up", 92, 24], ["down", 92, 88], ["left", 24, 56], ["right", 160, 56]]
      delegate: Image {
        required property var modelData
        x: modelData[1]; y: modelData[2]
        width: 16; height: 16
        source: Qt.resolvedUrl("../../icons/chevron-" + modelData[0] + ".svg")
        sourceSize: Qt.size(32, 32)
        smooth: true
        layer.enabled: true
        layer.effect: MultiEffect { colorization: 1; colorizationColor: root.accent }
      }
    }

    Item {
      x: root.fingersX; y: root.fingersY
      width: 72; height: 16
      opacity: root.fingersOpacity
      Repeater {
        model: 3
        delegate: Rectangle {
          required property int index
          x: 28 * index
          width: 16; height: 16; radius: 8
          color: Qt.alpha(root.accent, 0.9 * root.fingersFill)
          border.width: 1; border.color: Qt.alpha(root.accent, 0.9)
          antialiasing: true
        }
      }
    }
  }

  Repeater {
    model: [
      { mode: "keyboard", text: "Super + wheel ↕ workspaces · Super + A / D ↔ columns" },
      { mode: "touchpad", text: "3 fingers ↕ workspaces · 3 fingers ↔ columns" }
    ]
    delegate: Text {
      required property var modelData
      y: Shell.Theme.settingsManualCaptionTop
      width: root.width
      height: Shell.Theme.settingsManualCaptionHeight
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      text: modelData.text
      color: Shell.Theme.muted
      font.family: Shell.Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Shell.Theme.fontBody
      font.letterSpacing: 0
      opacity: root.mode === modelData.mode ? 1 : 0
      visible: opacity > 0
      Fade on opacity {}
    }
  }
}
