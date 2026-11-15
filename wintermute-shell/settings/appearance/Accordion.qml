import QtQuick
import "../.." as Shell

// Linha de ajuste da Aparência (ficha 11): 520×52, raio 12, fundo `control` (hover `pressed`), título 15
// Regular em x 20, valor 13 Medium `muted` à direita e chevron de 16 em (largura − 36, 18).
// Abre em 240 ms InOutCubic; aberta, mostra o conteúdo abaixo do cabeçalho e o chevron vira. As linhas
// que só navegam também levam o chevron para baixo, como no print (a origem apontava para a direita).
Rectangle {
  id: root
  default property alias content: body.data
  property string title
  property string summary
  property bool navigation: false
  property bool expanded: false
  property real expandedHeight: 111
  signal toggled
  implicitHeight: expanded ? expandedHeight : 52
  radius: Shell.Theme.radiusRow
  color: header.containsMouse || activeFocus ? Shell.Theme.pressed : Shell.Theme.control
  clip: true
  activeFocusOnTab: true
  Accessible.role: Accessible.Button
  Accessible.name: title + ", " + summary + (navigation || !enabled ? "" : expanded ? ", aberto" : ", fechado")
  Accessible.onPressAction: if (enabled) toggled()
  Keys.onReturnPressed: toggled()
  Keys.onSpacePressed: toggled()
  Behavior on implicitHeight {
    NumberAnimation { duration: 240; easing.type: Easing.InOutCubic }
  }
  Behavior on color {
    ColorAnimation { duration: Shell.Theme.hoverDuration; easing.type: Easing.OutCubic }
  }
  Text {
    x: 20; y: 0; height: 52
    text: root.title; color: Shell.Theme.text
    font.family: Shell.Theme.fontFamily; font.weight: Font.Normal; font.pixelSize: Shell.Theme.fontLabel
    font.letterSpacing: 0
    verticalAlignment: Text.AlignVCenter
  }
  Text {
    x: parent.width * 0.48; y: 0; width: parent.width - x - (root.enabled ? 40 : 20); height: 52
    text: root.summary; color: Shell.Theme.muted
    font.family: Shell.Theme.fontFamily; font.weight: Font.Medium; font.pixelSize: Shell.Theme.fontBody
    font.letterSpacing: 0
    verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignRight
    elide: Text.ElideRight
  }
  Image {
    x: parent.width - 36; y: 18; width: 16; height: 16
    source: Qt.resolvedUrl("../../icons/chevron-down.svg")
    sourceSize: Qt.size(32, 32)
    objectName: "settingsRowChevron"
    visible: root.enabled
    rotation: root.expanded ? 180 : 0
    Behavior on rotation { NumberAnimation { duration: 220; easing.type: Easing.InOutCubic } }
  }
  MouseArea {
    id: header
    width: parent.width; height: 52
    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
    onClicked: root.toggled()
  }
  Item {
    id: body
    x: 20; y: 52; width: parent.width - 40; height: root.expandedHeight - 52
    enabled: root.expanded
    visible: root.height > 52
  }
}
