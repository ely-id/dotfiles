import QtQuick
import "." as System
import ".." as Settings
import "../.." as Shell

// Página Sistema (ficha 13; Figma 13:15915): modal de 580 com três linhas com seta de 520×52 a cada 60,
// a partir de (30,84). O Fuso horário saiu (P-34): trocar o fuso pede a senha de administrador pelo
// polkit, e a sessão do Niri não tem agente do polkit; o relógio segue o horário do sistema.
// Lê o estado por `service` e `idle` (decisão 0011).
Settings.Modal {
  id: root
  objectName: "systemPanel"

  property var service: System.State
  property var idle: System.Idle

  title: "System"
  bodyTop: 0
  contentHeight: fields.y + fields.height + Shell.Theme.settingsBottomPadding
  onBackRequested: Settings.State.back()
  Keys.onEscapePressed: Settings.State.back()

  readonly property string mouseSummary: root.service.mouse.touchpadSpeed === 5 && root.service.mouse.mouseSpeed === 5
      ? "Default" : "Custom"

  Column {
    id: fields
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsBodyTop
    width: Shell.Theme.settingsRowWidth
    spacing: Shell.Theme.settingsRowPitch - Shell.Theme.settingsRowHeight

    Settings.Field {
      objectName: "systemMouse"
      navigation: true
      title: "Mouse & touchpad"
      value: root.mouseSummary
      onClicked: Settings.State.openPage("mouse")
    }
    Settings.Field {
      objectName: "systemLock"
      navigation: true
      title: "Lock & sleep"
      value: root.idle.label(root.idle.current.lock)
      onClicked: Settings.State.openPage("lock")
    }
    Settings.Field {
      objectName: "systemKeyboard"
      navigation: true
      title: "Keyboard language"
      value: root.service.languageNames.join(", ")
      onClicked: Settings.State.openPage("keyboard")
    }
    Text {
      width: parent.width
      visible: root.service.error !== ""
      text: root.service.error
      wrapMode: Text.Wrap
      color: Shell.Theme.dangerText
      font.family: Shell.Theme.fontFamily
      font.pixelSize: Shell.Theme.fontBody
    }
  }
}
