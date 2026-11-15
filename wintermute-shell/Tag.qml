import QtQuick

// Etiqueta Armitage (ficha 00):
// Altura 20, padding 8, raio 10, borda border, texto Geist 11 Medium.
// Tipos: "accent" (accentSubtle / accentText), "neutral" (control / muted),
// "success" (control / successText), "danger" (control / dangerText).
Rectangle {
  id: root

  // "accent" | "neutral" | "success" | "danger"
  property string kind: "accent"
  property string text: ""

  implicitWidth: Math.ceil(labelText.implicitWidth) + 16
  implicitHeight: 20
  radius: 10
  color: kind === "accent" ? Theme.accentSubtle : Theme.control
  border.width: 1
  border.color: Theme.border
  antialiasing: true

  Text {
    id: labelText
    anchors.centerIn: parent
    text: root.text
    color: root.kind === "accent" ? Theme.accentText
        : root.kind === "success" ? Theme.successText
        : root.kind === "danger" ? Theme.dangerText
        : Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
  }
}
