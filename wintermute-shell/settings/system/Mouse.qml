pragma ComponentBehavior: Bound
import QtQuick
import "." as System
import ".." as Settings
import "../.." as Shell

// Página Mouse e touchpad (ficha 13; Figma 13:15927): modal de 580×452. Velocidade do touchpad e do
// mouse em 9 passos cada, chave "Pointer acceleration" em y 300 e a linha "Natural scrolling" em y 360
// com o seletor de 168×40 em (346,6). A rolagem natural é por aparelho (nota do Figma): cada metade do
// seletor liga ou desliga a rolagem natural do próprio aparelho, e a metade acesa é a que está ligada;
// as duas podem ficar acesas ou apagadas (P-47). As mudanças vão para o input.kdl do Niri 300 ms depois do último movimento.
Settings.Modal {
  id: root
  objectName: "mousePanel"

  property var service: System.State

  title: "Mouse & touchpad"
  closeLabel: "Back to System"
  bodyTop: 0
  contentHeight: 452
  onBackRequested: Settings.State.back()
  Keys.onEscapePressed: Settings.State.back()

  System.StepSlider {
    objectName: "touchpadSpeed"
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsBodyTop
    title: "Touchpad speed"
    value: root.service.mouse.touchpadSpeed
    onMoved: value => root.service.setMouse("touchpadSpeed", value)
  }

  System.StepSlider {
    objectName: "mouseSpeed"
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsBodyTop + Shell.Theme.settingsStepSliderGroup
    title: "Mouse speed"
    value: root.service.mouse.mouseSpeed
    onMoved: value => root.service.setMouse("mouseSpeed", value)
  }

  Settings.Field {
    objectName: "mouseAcceleration"
    x: Shell.Theme.settingsBodyInset
    y: 300
    toggle: true
    title: "Pointer acceleration"
    checked: root.service.mouse.acceleration
    onToggled: checked => root.service.setMouse("acceleration", checked)
  }

  Rectangle {
    x: Shell.Theme.settingsBodyInset
    y: 300 + Shell.Theme.settingsRowPitch
    width: Shell.Theme.settingsRowWidth
    height: Shell.Theme.settingsRowHeight
    radius: Shell.Theme.radiusRow
    color: Shell.Theme.control
    antialiasing: true

    Text {
      x: 20
      height: parent.height
      verticalAlignment: Text.AlignVCenter
      text: "Natural scrolling"
      color: Shell.Theme.text
      font.family: Shell.Theme.fontFamily
      font.weight: Font.Normal
      font.pixelSize: Shell.Theme.fontLabel
    }

    // Mesmo desenho do seletor segmentado (ficha 00), com as duas metades independentes.
    Rectangle {
      objectName: "mouseNatural"
      x: 346
      y: 6
      width: 168
      height: 40
      radius: 12
      color: "transparent"
      border.width: 1
      border.color: Shell.Theme.border
      antialiasing: true

      Repeater {
        model: [
          { key: "naturalTouchpad", label: "Touchpad" },
          { key: "naturalMouse", label: "Mouse" }
        ]

        delegate: Rectangle {
          id: half
          required property var modelData
          required property int index
          readonly property bool on: !!root.service.mouse[modelData.key]

          x: 4 + index * 80
          y: 4
          width: 80
          height: 32
          radius: 8
          color: on ? Shell.Theme.accentSubtle : Qt.alpha(Shell.Theme.accentSubtle, 0)
          antialiasing: true
          activeFocusOnTab: true
          Accessible.role: Accessible.CheckBox
          Accessible.name: "Natural scrolling, " + modelData.label
          Accessible.checked: on
          Accessible.onPressAction: toggle()
          Keys.onSpacePressed: toggle()
          Keys.onReturnPressed: toggle()

          function toggle() { root.service.setMouse(modelData.key, !on); }

          Behavior on color {
            ColorAnimation { duration: Shell.Theme.controlDuration; easing.type: Easing.OutCubic }
          }

          Text {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: half.modelData.label
            color: half.on || halfHover.hovered ? Shell.Theme.text : Shell.Theme.muted
            font.family: Shell.Theme.fontFamily
            font.weight: Font.Medium
            font.pixelSize: Shell.Theme.fontBody
          }

          HoverHandler { id: halfHover; cursorShape: Qt.PointingHandCursor }
          TapHandler { onTapped: half.toggle() }
        }
      }
    }
  }

  Text {
    x: Shell.Theme.settingsBodyInset
    y: 300 + Shell.Theme.settingsRowPitch * 2
    width: Shell.Theme.settingsRowWidth
    visible: root.service.error !== ""
    text: root.service.error
    wrapMode: Text.Wrap
    color: Shell.Theme.dangerText
    font.family: Shell.Theme.fontFamily
    font.pixelSize: Shell.Theme.fontBody
  }
}
