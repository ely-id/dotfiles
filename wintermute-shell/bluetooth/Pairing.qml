import QtQuick
import "." as Bluetooth
import ".." as Shell

// Parear dispositivo (ficha 06, 316×236): título Serif 20 em (20,16), instrução 13 Regular muted em
// (20,72) com quebra de linha, código Serif 32 accentText centrado, "Cancelar" 146×40 em (8,184)
// e "Parear" primário compacto em (162,184). Com PIN ou senha para digitar, o campo fica em (20,100).
Item {
  id: root
  readonly property bool headerDividerVisible: !needsInput
  property var stackController
  property bool interactive: true
  property var service: stackController ? stackController.service : Bluetooth.State
  readonly property var prompt: service.prompt
  readonly property bool needsInput: prompt.kind === "pin" || prompt.kind === "passkey"
  readonly property var promptDevice: service.deviceFor(prompt.path || "")
  readonly property string deviceName: promptDevice ? promptDevice.name : "your device"
  readonly property string codeText: String(prompt.code || "").replace(/^(\d{3})(\d{3})$/, "$1 $2")
  readonly property bool canSubmit: prompt.kind === "pin" ? code.text.length > 0 && code.text.length <= 16
      : prompt.kind === "passkey" ? /^\d{1,6}$/.test(code.text) : true
  implicitWidth: Shell.PanelStyle.width
  implicitHeight: 236
  Shell.PanelBackground {
    anchors.fill: parent
    stacked: true
    Text {
      x: 20; y: 16
      width: 276; height: 32
      verticalAlignment: Text.AlignVCenter
      text: "Pair device"
      color: Shell.Theme.text
      font.family: Shell.Theme.titleFontFamily
      font.weight: Font.Normal
      font.pixelSize: Shell.Theme.fontPanelTitle
      font.letterSpacing: 0
    }
    Text {
      x: 20; y: 72; width: 276
      wrapMode: Text.Wrap
      text: root.prompt.kind === "display" ? "Type this code on your Bluetooth device and press Enter."
          : root.prompt.kind === "confirm" ? "Confirm that this code is shown on “" + root.deviceName + "”."
          : root.needsInput ? "Type the pairing code shown on your device."
          : "Allow this device to pair?"
      color: Shell.Theme.muted
      font.family: Shell.Theme.fontFamily
      font.weight: Font.Normal
      font.pixelSize: Shell.Theme.fontBody
      font.letterSpacing: 0
    }
    Text {
      x: 20; y: 119; width: 276; height: 40
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      visible: !root.needsInput
      text: root.codeText
      color: Shell.Theme.accentText
      font.family: Shell.Theme.titleFontFamily
      font.weight: Font.Normal
      font.pixelSize: Shell.Theme.fontModalTitle
      font.letterSpacing: 0
    }
    Shell.Field {
      id: code; x: 20; y: 100
      visible: root.needsInput
      placeholderText: "Pairing code"
      onAccepted: if (root.canSubmit) root.service.answer(true, text)
    }
    Shell.ActionButton {
      x: 8; y: 184
      text: "Cancel"
      interactive: root.interactive
      onClicked: root.service.cancelPairing()
    }
    Shell.ActionButton {
      x: 162; y: 184
      kind: "primary"
      compact: true
      text: "Pair"
      visible: root.prompt.kind !== "display"
      interactive: root.interactive && root.canSubmit
      onClicked: root.service.answer(true, code.text)
    }
  }
}
