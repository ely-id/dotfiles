import QtQuick
import "../.." as Shell

// Slider de 9 passos da página Mouse e touchpad (ficha 13; Figma 13:15930 a 13:15945), em coordenadas
// a partir do rótulo em (30,84) do modal: rótulo Geist 15 em (0,0), valor "N of 9" 13 Medium muted
// alinhado à direita em 520, trilho de 480×12 raio 6 em (20,40) com o preenchimento accent até a alça,
// nove marcas borderStrong de 1×8 a cada 60 em y 60, alça de 24 em `knob` com a sombra do vidro pela
// metade e as legendas "Slow" e "Fast" 11 Medium muted em y 72.
Item {
  id: root

  property string title: ""
  property int value: 5
  readonly property int steps: 9
  signal moved(int value)

  width: Shell.Theme.settingsRowWidth
  height: 86

  activeFocusOnTab: true
  Accessible.role: Accessible.Slider
  Accessible.name: title + ", " + value + " of " + steps
  Keys.onLeftPressed: choose(value - 1)
  Keys.onRightPressed: choose(value + 1)

  function choose(step) {
    const clamped = Math.max(1, Math.min(steps, step));
    if (clamped !== value) moved(clamped);
  }

  readonly property real trackX: 20
  readonly property real trackY: 40
  readonly property real knobX: trackX + (value - 1) * Shell.Theme.settingsStepSliderPitch

  Text {
    width: 300
    height: 24
    verticalAlignment: Text.AlignVCenter
    text: root.title
    color: Shell.Theme.text
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Normal
    font.pixelSize: Shell.Theme.fontLabel
  }

  Text {
    anchors.right: parent.right
    width: 220
    height: 24
    horizontalAlignment: Text.AlignRight
    verticalAlignment: Text.AlignVCenter
    text: root.value + " of " + root.steps
    color: Shell.Theme.muted
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontBody
  }

  Rectangle {
    x: root.trackX
    y: root.trackY
    width: Shell.Theme.settingsStepSliderWidth
    height: 12
    radius: 6
    color: Shell.Theme.track
    antialiasing: true

    Rectangle {
      width: root.knobX - root.trackX
      height: parent.height
      radius: parent.radius
      color: Shell.Theme.accent
      antialiasing: true
    }
  }

  Repeater {
    model: root.steps
    delegate: Rectangle {
      required property int index
      x: root.trackX + index * Shell.Theme.settingsStepSliderPitch
      y: root.trackY + 20
      width: 1
      height: 8
      color: Shell.Theme.borderStrong
    }
  }

  Item {
    x: root.knobX - width / 2
    y: root.trackY + 6 - height / 2
    width: Shell.Theme.settingsStepSliderKnob
    height: width

    Behavior on x {
      NumberAnimation { duration: Shell.Theme.controlDuration; easing.type: Easing.OutCubic }
    }

    Shell.Shadow {
      anchors.fill: parent
      cornerRadius: width / 2
      strength: 0.5
    }
    Rectangle {
      anchors.fill: parent
      radius: width / 2
      color: Shell.Theme.knob
      antialiasing: true
    }
  }

  Text {
    x: root.trackX
    y: 72
    height: 14
    verticalAlignment: Text.AlignVCenter
    text: "Slow"
    color: Shell.Theme.muted
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontCaption
  }

  Text {
    x: root.trackX + Shell.Theme.settingsStepSliderWidth - width
    y: 72
    height: 14
    verticalAlignment: Text.AlignVCenter
    text: "Fast"
    color: Shell.Theme.muted
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontCaption
  }

  // Clicar ou arrastar em qualquer ponto do trilho vai para a marca mais próxima.
  MouseArea {
    x: root.trackX - Shell.Theme.settingsStepSliderKnob / 2
    y: root.trackY - 12
    width: Shell.Theme.settingsStepSliderWidth + Shell.Theme.settingsStepSliderKnob
    height: 36
    cursorShape: Qt.PointingHandCursor
    preventStealing: true
    function stepAt(mouseX) {
      return Math.round((mouseX - Shell.Theme.settingsStepSliderKnob / 2) / Shell.Theme.settingsStepSliderPitch) + 1;
    }
    onPressed: mouse => { root.forceActiveFocus(); root.choose(stepAt(mouse.x)); }
    onPositionChanged: mouse => { if (pressed) root.choose(stepAt(mouse.x)); }
  }
}
