import QtQuick

// Tecla Armitage (ficha 00):
// Altura 20, padding horizontal 6, raio 6, Geist Mono 11 Medium muted,
// fundo control + borda border.
Rectangle {
  id: root

  property string text: "Esc"

  implicitWidth: Math.max(20, Math.ceil(keyText.implicitWidth) + 12)
  implicitHeight: 20
  radius: 6
  color: Theme.control
  border.width: 1
  border.color: Theme.border
  antialiasing: true

  Text {
    id: keyText
    anchors.centerIn: parent
    text: root.text
    color: Theme.muted
    font.family: Theme.monoFontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontMonoCaption
    font.letterSpacing: 0
  }
}
