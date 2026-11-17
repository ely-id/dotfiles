import QtQuick
import ".."

// Rótulo de seção do launcher (ficha 14): caixa de 400×24 em x 20, Geist Medium 11 muted,
// centrado na vertical e à esquerda.
Text {
  width: Theme.launcherLabelWidth
  height: Theme.launcherLabelHeight
  verticalAlignment: Text.AlignVCenter
  horizontalAlignment: Text.AlignLeft
  elide: Text.ElideRight
  color: Theme.muted
  font.family: Theme.fontFamily
  font.weight: Font.Medium
  font.pixelSize: Theme.fontCaption
  font.letterSpacing: 0
}
