pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import ".."

// Rodapé do launcher (ficha 14): 44 de altura, com o divisor de 640×1 no topo. À esquerda o ícone do modo
// (16 a 80%) e o nome; à direita as ações do serviço, cada uma com o texto e as teclas, separadas por um
// divisor de 1×16. A ação principal usa `text` e as outras `muted`. Na página do seletor de emoji (ficha 16) o lugar do
// modo é da prévia do emoji (20, numa caixa de 32×44 em x 12) e do nome dele (Geist Medium 11 `text`, caixa de 220×44 em x 48).
Item {
  id: root

  property string modeIcon: "sparkles"
  property string modeLabel: ""
  // Lista de { label, keys, primary }.
  property var actions: []
  // Com a prévia, o modo não aparece: o emoji e o nome dele tomam o lugar.
  property bool previewMode: false
  property string previewGlyph: ""
  property string previewName: ""

  implicitWidth: Theme.launcherWidth
  implicitHeight: Theme.launcherFooterHeight

  Rectangle {
    width: parent.width
    height: Theme.launcherDividerHeight
    color: Theme.border
  }

  Image {
    visible: !root.previewMode
    x: Theme.launcherFooterIconX
    y: Theme.launcherFooterIconY
    width: Theme.launcherFooterIconSize
    height: Theme.launcherFooterIconSize
    opacity: Theme.launcherFooterIconOpacity
    source: root.modeIcon !== "" ? Qt.resolvedUrl("../icons/" + root.modeIcon + ".svg") : ""
    sourceSize: Qt.size(width * 2, height * 2)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    layer.enabled: true
    layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.text }
  }

  Text {
    visible: !root.previewMode
    x: Theme.launcherFooterModeX
    width: Theme.launcherFooterModeWidth
    height: parent.height
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.modeLabel
    color: Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
  }

  Text {
    visible: root.previewMode
    x: Theme.launcherEmojiPreviewX
    width: Theme.launcherEmojiPreviewWidth
    height: parent.height
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    text: root.previewGlyph
    color: Theme.text
    font.family: Theme.emojiFontFamily
    font.pixelSize: Theme.launcherEmojiPreviewSize
  }

  Text {
    visible: root.previewMode
    x: Theme.launcherEmojiNameX
    width: Theme.launcherEmojiNameWidth
    height: parent.height
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.previewName
    color: Theme.text
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
  }

  // Faixa de ações: os itens terminam em x 624.
  Row {
    id: strip
    x: Theme.launcherFooterActionsRight - width
    y: Theme.launcherFooterActionsY
    height: Theme.launcherFooterActionsHeight
    spacing: Theme.launcherFooterActionsGap

    Repeater {
      model: root.actions

      delegate: Row {
        id: action
        required property var modelData
        required property int index
        height: Theme.launcherFooterActionsHeight
        spacing: Theme.launcherFooterActionsGap

        Rectangle {
          visible: action.index > 0
          anchors.verticalCenter: parent.verticalCenter
          width: 1
          height: Theme.launcherFooterDividerHeight
          color: Theme.border
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: action.modelData.label
          color: action.modelData.primary ? Theme.text : Theme.muted
          font.family: Theme.fontFamily
          font.weight: Font.Medium
          font.pixelSize: Theme.fontCaption
          font.letterSpacing: 0
        }

        Repeater {
          model: action.modelData.keys

          delegate: KeyCap {
            required property string modelData
            // Ao trocar de modo a lista de ações é refeita e o pai some antes da tecla.
            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            text: modelData
          }
        }
      }
    }
  }
}
