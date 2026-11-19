pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import "." as Appearance
import ".." as Settings
import "../.." as Shell

// O seletor de papel de parede e o cartão Customize, empilhados como as páginas do Wi-Fi (F4-T24, P-67;
// ficha 05, seção "Pilha", e CardStack.qml). Não tem board: composição pela regra A-05, com os tokens
// `Theme.cardStack*` e `Theme.panel*` e nada novo. É a página `wallpaper` e a página `customize` dos Ajustes ao mesmo tempo (a
// Window carrega este componente nas duas), para o seletor ficar vivo atrás do cartão e a rolagem não se
// perder; `customizing` diz se o cartão está na frente.
//
// Sem o cartão, o seletor ocupa tudo e é idêntico ao WallpaperPicker sozinho. Com ele, o cartão (580) entra
// na frente e o seletor vira a carta de trás: na escala original, cortado em 548 (580 − 2 × panelBackOffset, a
// 16 de cada lado da frente), com o conteúdo a 50% e desfocado em 8 (inclusive no trecho de 32 acima da
// frente), e o raio, o vidro e o contorno do modal. A carta de trás tem a altura do conjunto, então a base
// dela fica rente à da frente. O conteúdo fica à esquerda, como no CardLayer, e o que passa da carta é cortado.
// A transição é a do CardStack: Theme.pageDuration e a mesma curva; a frente entra de escala 0,92 para 1
// com a opacidade de 0 a 1 e sai com a escala max(0, 1 − 2 × progresso); a carta de trás interpola a
// largura (624 a 548), a posição, a opacidade do conteúdo, o desfoque e a altura do conjunto.
FocusScope {
  id: root
  objectName: "wallpaperStack"

  property var service: Appearance.State
  // O cartão Customize está na frente. Na vitrine, fixa o estado sem animar (a animação só roda quando muda).
  property bool customizing: false
  property real availableHeight: 900
  // Só para a vitrine: fixa o hover numa linha do cartão e na miniatura do seletor.
  property string hoverRow: ""
  property int hoverIndex: -1

  // 0 com o seletor sozinho, 1 com o cartão na frente.
  property real progress: customizing ? 1 : 0
  readonly property bool sliding: slide.running
  readonly property real frontInset: Shell.Theme.cardStackFrontInsetStacked
  readonly property real frontX: (width - Shell.Theme.settingsModalWidth) / 2
  // A carta de trás encolhe até 548: a frente menos o recuo de 16 de cada lado.
  readonly property real backWidthStacked: Shell.Theme.settingsModalWidth - 2 * Shell.Theme.panelBackOffset
  // As duas páginas, para quem hospeda a pilha (a vitrine e a bancada).
  readonly property Item pickerPage: picker
  readonly property Item customizePage: card
  readonly property real frontScale: customizing ? 0.92 + 0.08 * progress : Math.max(0, 2 * progress - 1)

  implicitWidth: Shell.Theme.settingsWallpaperWidth
  implicitHeight: Shell.Theme.lerp(picker.implicitHeight, frontInset + card.implicitHeight, progress)

  Behavior on progress {
    NumberAnimation {
      id: slide
      duration: Shell.Theme.pageDuration
      easing.type: Easing.Bezier
      easing.bezierCurve: [0.19, 1, 0.22, 1, 1, 1]
    }
  }

  // A área de blur cobre a frente e a carta de trás, como o `Region` do CardStack. O Window lê esta
  // propriedade do item carregado.
  readonly property bool blurReady: root.enabled && (root.parent?.opacity ?? 1) > Shell.Theme.blurRevealOpacity
  readonly property Region blurRegion: Region {
    Region {
      item: root.blurReady && root.progress > 0.001 ? frontBounds : null
      radius: Shell.Theme.radiusModal
    }
    Region {
      item: root.blurReady ? backBounds : null
      radius: Shell.Theme.radiusModal
    }
  }
  onScaleChanged: blurRegion.changed()
  Item {
    id: frontBounds
    x: card.x; y: card.y; width: card.width; height: card.height
  }
  Item {
    id: backBounds
    x: back.x; y: back.y; width: back.width; height: back.height
  }

  // O foco vai para a página que ficou ativa quando a transição termina (a desativada o perde).
  onSlidingChanged: {
    if (sliding || !Settings.State.opened) return;
    (customizing ? card : picker).forceActiveFocus();
  }

  // Tocar numa linha do cartão volta ao seletor, que passa a escolher para aquele lugar; lugar gravado
  // reabre o cartão. A gravação vem do processo do serviço, então confiro que a página é a do seletor.
  Connections {
    target: root.service
    function onPlaceSaved() {
      if (root.enabled && Settings.State.page === "wallpaper") Settings.State.openPage("customize");
    }
  }

  // Carta de trás: o seletor. Vidro e contorno são da carta; o conteúdo (o seletor, sem vidro nem botão de
  // fechar) é cortado no raio, apagado e desfocado conforme o progresso.
  Item {
    id: back
    x: Shell.Theme.lerp(0, root.frontX + Shell.Theme.panelBackOffset, root.progress)
    y: 0
    width: Shell.Theme.lerp(root.width, root.backWidthStacked, root.progress)
    height: root.height

    Shell.GradientFill { radius: Shell.Theme.radiusModal }
    ClippingRectangle {
      anchors.fill: parent
      radius: Shell.Theme.radiusModal
      color: "transparent"

      Item {
        id: backContent
        anchors.fill: parent
        opacity: Shell.Theme.lerp(1, Shell.Theme.cardStackBackContentOpacity, root.progress)
        layer.enabled: root.progress > 0
        layer.effect: MultiEffect {
          autoPaddingEnabled: false
          blurEnabled: true
          blurMax: Shell.Theme.cardStackBackContentBlur
          blur: root.progress
        }

        Appearance.WallpaperPicker {
          id: picker
          service: root.service
          availableHeight: root.availableHeight
          hoverIndex: root.hoverIndex
          embedded: true
          behind: root.customizing || root.progress > 0
          enabled: !root.customizing && !root.sliding
          focus: !root.customizing
        }
      }
    }
    Shell.PanelBorder {
      radius: Shell.Theme.radiusModal
      z: 4
    }
    // Com o cartão na frente, clique na carta de trás não chega ao fundo que fecha os Ajustes.
    MouseArea {
      anchors.fill: parent
      enabled: root.customizing
      acceptedButtons: Qt.AllButtons
    }
  }

  // O botão de fechar do seletor, pendurado em (largura − 20, −13) da carta, como o do Modal. Some com o
  // cartão na frente: o de fechar passa a ser o do cartão.
  Shell.PanelCloseButton {
    objectName: "wallpaperPickerClose"
    x: back.x + back.width - 20
    y: back.y + picker.closeButtonY
    z: 5
    visible: root.progress < 0.999
    opacity: 1 - root.progress
    enabled: !root.customizing && !root.sliding
    Accessible.role: Accessible.Button
    Accessible.name: picker.closeLabel
    activeFocusOnTab: enabled
    Keys.onReturnPressed: picker.backRequested()
    Keys.onSpacePressed: picker.backRequested()
    onClicked: picker.backRequested()
  }

  // Cartão da frente, rente à base do conjunto: com o cartão estável ele fica 32 abaixo do topo da carta.
  Appearance.WallpaperCustomize {
    id: card
    x: root.frontX
    y: root.height - height
    availableHeight: root.availableHeight - root.frontInset
    service: root.service
    hoverRow: root.hoverRow
    visible: root.progress > 0.001 && root.frontScale > 0.001
    opacity: root.customizing ? root.progress : 1
    scale: root.frontScale
    transformOrigin: Item.Bottom
    enabled: root.customizing && !root.sliding
    focus: root.customizing
    z: 2
    onBackRequested: Settings.State.back()
    Keys.onEscapePressed: Settings.State.back()
    onPlaceRequested: key => {
      root.service.beginPlace(key);
      Settings.State.back();
    }
  }
}
