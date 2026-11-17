import QtQuick
import QtQuick.Effects
import Quickshell
import "." as Settings
import ".." as Shell

// Página de ajustes centralizada (ficha 11): vidro Armitage r32, título Serif 32 e corpo rolante.
Rectangle {
  id: root
  default property alias content: body.contentItem.data
  property string title
  property real bodyTop: 82
  property real titleOpacity: 1
  property string closeLabel: "Back to Settings"
  property alias overlay: overlays.data
  property alias scrollItem: body
  property real contentHeight: 0
  property real availableHeight: 900
  property bool roundedContent: false
  property bool showOutline: true
  // Para a pilha do papel de parede (F4-T24): quando o cartão é a carta de trás, quem desenha o vidro, o
  // contorno e o botão de fechar é a pilha, porque o conteúdo é cortado, apagado e desfocado e o vidro não.
  property bool showGlass: true
  property bool closeVisible: true
  property Gradient fill: null
  property real closeButtonY: -13
  signal backRequested
  implicitWidth: 580
  // Accordion heights already animate. Follow them directly so the shell and
  // hit targets stay in step instead of starting another animation each frame.
  implicitHeight: Math.min(contentHeight + bodyTop, availableHeight)
  radius: 32
  color: "transparent"
  readonly property Region blurRegion: Region {
    item: root.enabled && root.parent?.opacity > Shell.PanelStyle.blurRevealOpacity
        && root.color.a < 1 ? root : null
    radius: root.radius
  }
  onScaleChanged: blurRegion.changed()

  Shell.GradientFill { visible: root.showGlass; fill: root.fill }
  // Stop dialog clicks from reaching the outside-dismiss area.
  MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }
  // Título Serif 32 em (30,20), caixa (w − 80)×44 (fichas 11 e 13).
  Text {
    x: 30; y: 20; width: root.width - 80; height: 44
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.title
    opacity: root.titleOpacity
    color: Shell.Theme.text
    font.family: Shell.Theme.titleFontFamily
    font.weight: Font.Normal
    font.pixelSize: Shell.Theme.fontModalTitle
    font.letterSpacing: 0
  }
  Flickable {
    id: body
    objectName: "settingsModalScroll"
    x: 0; y: root.bodyTop
    width: parent.width
    height: Math.max(0, parent.height - y)
    contentHeight: root.contentHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    interactive: contentHeight > height
    Shell.ScrollWheel { view: body }
    layer.enabled: root.roundedContent
    layer.smooth: true
    layer.effect: MultiEffect {
      autoPaddingEnabled: false
      maskEnabled: true
      maskThresholdMin: 0.5
      maskSpreadAtMin: 1.0
      maskSource: ShaderEffectSource {
        sourceItem: Rectangle {
          width: body.width; height: body.height
          radius: root.radius
          color: Shell.Theme.text
          antialiasing: true
        }
      }
    }
  }
  Shell.PanelBorder {
    radius: root.radius
    visible: Shell.Theme.translucent && root.showOutline
    z: 4
  }
  Item { id: overlays; anchors.fill: parent; z: 6 }
  Shell.PanelCloseButton {
    objectName: "settingsModalClose"
    visible: root.closeVisible
    x: parent.width - 20; y: root.closeButtonY; z: 5
    Accessible.role: Accessible.Button
    Accessible.name: root.closeLabel
    activeFocusOnTab: true
    Keys.onReturnPressed: root.backRequested()
    Keys.onSpacePressed: root.backRequested()
    onClicked: root.backRequested()
  }
}
