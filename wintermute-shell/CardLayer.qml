import QtQuick
import QtQuick.Effects

// Uma página da pilha de cartões. A página fica viva enquanto passa para trás do
// cartão da frente (ficha 05): a superfície encolhe de 316 para 284, o conteúdo
// continua na escala original e é cortado em 284, fica a 50% e recebe blur 8
// (também no trecho que aparece acima da frente), como no Figma.
Item {
  id: root

  property Component cardComponent
  property var selection: ({})
  property var stackController
  property bool interactive: false
  property real backingAmount: 0

  readonly property real naturalHeight: cardLoader.item
      ? cardLoader.item.implicitHeight : 0
  readonly property bool ready: cardLoader.status === Loader.Ready
  readonly property real dividerY: cardLoader.item?.headerDividerY ?? Theme.cardStackHeaderDividerY
  readonly property bool hasHeaderDivider: cardLoader.item?.headerDividerVisible ?? true

  clip: false

  Shadow {
    anchors.fill: parent
    cornerRadius: Theme.radiusPanel
    shadows: Theme.glassShadows
  }

  Item {
    anchors.fill: parent
    clip: true

    Rectangle {
      anchors.fill: parent
      radius: Theme.radiusPanel
      color: "transparent"
      border.width: 0
      antialiasing: true
      GradientFill { radius: parent.radius }
      PanelBorder { radius: parent.radius; z: 3 }
    }

    Item {
      id: content
      anchors.fill: parent
      opacity: Theme.lerp(1, Theme.cardStackBackContentOpacity, root.backingAmount)
      layer.enabled: root.backingAmount > 0
      layer.effect: MultiEffect {
        autoPaddingEnabled: false
        blurEnabled: true
        blurMax: Theme.cardStackBackContentBlur
        blur: root.backingAmount
      }

      Loader {
        id: cardLoader
        width: Theme.panelWidth
        height: item ? item.implicitHeight : 0
        sourceComponent: root.cardComponent
        enabled: root.interactive

        onLoaded: {
          root.configureCard();
        }
      }

      // O divisor do cabeçalho: (20, 60), 276×1. Some quando um menu cobre o cabeçalho.
      Rectangle {
        x: Theme.cardStackHeaderDividerX
        y: root.dividerY
        width: Theme.cardStackHeaderDividerWidth
        height: 1
        z: 2
        visible: root.hasHeaderDivider
        color: Theme.border
        antialiasing: false
      }
    }
  }

  onSelectionChanged: configureCard()
  onInteractiveChanged: configureCard()

  function configureCard() {
    const item = cardLoader.item;
    if (!item)
      return;
    item.stackController = root.stackController;
    item.interactive = root.interactive;
    if ("selection" in item)
      item.selection = root.selection || ({});
  }

}
