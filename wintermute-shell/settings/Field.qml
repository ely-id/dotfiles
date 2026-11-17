import QtQuick
import QtQuick.Effects
import ".." as Shell

// Linha de ajuste Armitage (ficha 00):
// 520×52, raio 12, fundo control (hover pressed).
// Título Geist 15 Regular em x 20; valor 13 Medium muted à direita.
// Tipos: Chave (toggle em x 446, y 12), Valor (x dir 500) ou Seta (chevron-right 16 em 484,18).
Rectangle {
  id: root
  property string title: ""
  property string value: ""
  property bool highlighted: false
  property bool toggle: false
  property bool checked: false
  property bool navigation: false
  property int step: 0
  // O x do título. O padrão é o de sempre (20, ou 54 com `step`); a linha de lugar do papel de parede
  // (F4-T24) o põe depois da miniatura.
  property real titleX: step > 0 ? 54 : 20
  // Opcional para fixar o estado na demonstração: "" | "rest" | "hover"
  property string visualState: ""
  signal clicked
  signal toggled(bool checked)

  readonly property bool isHoverState: visualState === "hover"
      || (visualState === "" && (highlighted || hover.hovered || activeFocus))

  implicitWidth: Shell.Theme.settingsRowWidth
  implicitHeight: Shell.Theme.settingsRowHeight
  width: Shell.Theme.settingsRowWidth
  height: Shell.Theme.settingsRowHeight
  radius: Shell.Theme.radiusRow
  color: isHoverState ? Shell.Theme.pressed : Shell.Theme.control
  antialiasing: true

  activeFocusOnTab: enabled && visualState === ""
  Accessible.role: toggle ? Accessible.CheckBox : navigation ? Accessible.Button : Accessible.ComboBox
  Accessible.name: title + (value !== "" ? ", " + value : "")
  Accessible.checked: checked
  Accessible.onPressAction: activate()
  function activate() { if (toggle) toggled(!checked); else clicked(); }
  Keys.onReturnPressed: activate()
  Keys.onSpacePressed: activate()

  Behavior on color {
    ColorAnimation {
      duration: Shell.Theme.settingsHoverDuration
      easing.type: Easing.OutCubic
    }
  }

  Rectangle {
    x: 20; anchors.verticalCenter: parent.verticalCenter
    visible: root.step > 0
    width: 24; height: 24; radius: 12
    color: "transparent"; border.color: Shell.Theme.muted
    Text {
      anchors.centerIn: parent
      text: root.step; color: Shell.Theme.muted
      font.family: Shell.Theme.monoFontFamily; font.weight: Font.Medium
      font.pixelSize: Shell.Theme.fontMonoCaption
      font.letterSpacing: 0
    }
  }

  Text {
    id: label
    x: root.titleX
    anchors.verticalCenter: parent.verticalCenter
    text: root.title
    color: Shell.Theme.text
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Normal
    font.pixelSize: Shell.Theme.fontLabel
    font.letterSpacing: 0
  }

  Text {
    anchors.right: parent.right
    anchors.rightMargin: root.navigation ? 44 : 20
    anchors.verticalCenter: parent.verticalCenter
    width: Math.max(0, parent.width - label.x - label.width - 20 - anchors.rightMargin)
    horizontalAlignment: Text.AlignRight
    elide: Text.ElideRight
    visible: !root.toggle
    text: root.value
    color: Shell.Theme.muted
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontBody
    font.letterSpacing: 0
  }

  Image {
    x: 484
    y: 18
    width: 16
    height: 16
    visible: root.navigation && !root.toggle
    source: Qt.resolvedUrl("../icons/chevron-right.svg")
    sourceSize: Qt.size(32, 32)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: Shell.Theme.muted
    }
  }

  HoverHandler {
    id: hover
    enabled: root.visualState === ""
    cursorShape: Qt.PointingHandCursor
  }
  TapHandler {
    enabled: !root.toggle && root.visualState === ""
    onTapped: root.clicked()
  }

  Shell.Toggle {
    objectName: "fieldToggle"
    x: 446
    y: 12
    visible: root.toggle
    checked: root.checked
    onToggled: checked => root.toggled(checked)
  }
}
