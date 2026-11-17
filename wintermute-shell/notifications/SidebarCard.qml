import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import "." as Notifications
import ".." as Shell

// Cartão de notificações da barra lateral (ficha 04):
// Aberto (156×48, r16):
//   Vazio: ícone bell 16 em (16,16) + texto "Notificações" em (40,0) 104×48.
//   Com itens: bell 16 em (16,16) + contagem em (40,0) + divisor 1×16 em (60,16)
//     + até 3 ícones de app 16×16 em (72,16), (96,16), (120,16) (2º e 3º a 40%).
// Recolhido (48×48, r16):
//   bell 16 no centro (16,16) + ponto não lido 6×6 accent em (28,14) quando não vazio.
// Chegando (ficha 10): cresce de 48 para 156 em 300 ms e mostra prévia 140×104 r12 em (8,44).
Item {
  id: root
  property real collapseProgress: 0
  // Estado das notificações; a vitrine troca por um fictício.
  property var service: Notifications.State
  // Propriedades opcionais para amostra visual no painel de demonstração
  property int previewCount: -1
  property var previewIcons: []
  property bool demoArrival: false

  readonly property alias blurRegion: background.blurRegion
  onYChanged: blurRegion.changed()
  readonly property int effectiveCount: previewCount >= 0
      ? previewCount : service.notificationCount
  readonly property bool empty: effectiveCount === 0
  readonly property real widthProgress: Shell.Theme.collapseWidth(collapseProgress)
  readonly property real heightProgress: Shell.Theme.collapseHeight(collapseProgress)
  signal panelRequested

  property real transientProgress: (demoArrival || (previewCount < 0 && service.transientVisible)) ? 1 : 0
  readonly property real inlineAmount: transientProgress * (1 - heightProgress)
  readonly property real previewOpacity: inlineAmount >= 0.54 ? 1 : 0
  readonly property var notification: service.currentTransient

  implicitWidth: Shell.Theme.lerp(Shell.Theme.sidebarCardExpandedWidth,
      Shell.Theme.sidebarCardCollapsedWidth, widthProgress)
  implicitHeight: 48 + (44 + preview.height + 8 - 48) * inlineAmount
  Behavior on transientProgress { Shell.Motion {} }

  Shell.Card {
    id: background
    anchors.fill: parent
    radius: Shell.Theme.sidebarCardRadius

    Item {
      id: summary
      width: parent.width
      height: 48
      implicitHeight: Shell.Theme.sidebarSimpleRowHeight

      Image {
        id: bellIcon
        x: 16
        y: 16
        width: 16
        height: 16
        source: Qt.resolvedUrl("../icons/bell.svg")
        sourceSize: Qt.size(32, 32)
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true
        layer.enabled: true
        layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
      }

      // Ponto não lido 6×6 accent em (28,14) quando recolhido e com notificações
      Rectangle {
        x: 28
        y: 14
        width: 6
        height: 6
        radius: 3
        color: Shell.Theme.accent
        opacity: !root.empty ? Shell.Theme.ramp(root.widthProgress, 0.5, 1.0) : 0
        visible: opacity > 0.001
        antialiasing: true
      }

      // Conteúdo expandido (x >= 40)
      Item {
        x: 40
        y: 0
        width: Math.max(0, summary.width - 40)
        height: 48
        opacity: 1 - Shell.Theme.ramp(root.collapseProgress, 0, 0.31)
        visible: opacity > 0.001

        // Meço o texto fora do próprio `Text`: ler `caption.implicitWidth` dentro de
        // `caption.width` fazia o Qt avisar de laço de binding quando a primeira
        // notificação chegava (o texto muda, o layout atualiza a largura implícita
        // no meio da avaliação da largura). O `TextMetrics` lê a mesma fonte e o
        // mesmo texto, mas não depende da largura de ninguém.
        TextMetrics {
          id: captionMetrics
          font: caption.font
          text: caption.text
        }

        Text {
          id: caption
          x: 0
          y: 0
          width: root.empty ? 104 : Math.max(16, Math.ceil(captionMetrics.advanceWidth))
          height: 48
          text: root.empty ? "Notifications" : String(root.effectiveCount)
          color: Shell.Theme.text
          font.family: Shell.Theme.fontFamily
          font.weight: Font.Medium
          font.pixelSize: Shell.Theme.fontBody
          font.letterSpacing: 0
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignLeft
        }

        Row {
          id: applications
          x: caption.width + 4
          y: 16
          height: 16
          spacing: 8
          visible: !root.empty

          Rectangle {
            width: 1
            height: 16
            color: Shell.Theme.border
          }

          Row {
            spacing: 8
            visible: root.previewIcons.length > 0
            Repeater {
              model: Math.min(3, root.previewIcons.length)
              delegate: Image {
                required property int index
                width: 16
                height: 16
                source: Qt.resolvedUrl("../icons/" + root.previewIcons[index] + ".svg")
                sourceSize: Qt.size(32, 32)
                fillMode: Image.PreserveAspectFit
                smooth: true
                antialiasing: true
                opacity: index === 0 ? 1.0 : 0.4
                layer.enabled: true
                layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
              }
            }
          }

          Row {
            spacing: 8
            visible: root.previewIcons.length === 0
            Repeater {
              model: root.service.recentApps
              delegate: IconImage {
                required property var modelData
                required property int index
                visible: index < 3
                implicitSize: width
                width: 16
                height: 16
                source: modelData.iconSource || ""
                asynchronous: true
                smooth: true
                opacity: index === 0 ? 1.0 : 0.4
              }
            }
          }
        }
      }
    }

    // Prévia (ficha 10): 140 de largura em (8,44), r12.
    Notifications.Card {
      id: preview
      service: root.service
      x: 8
      y: 44 + (1 - root.previewOpacity) * 4
      width: root.width - 16
      inlinePreview: true
      notification: root.notification
      closeEnabled: false
      extraHovered: inlineClose.hovered
      opacity: root.previewOpacity
      enabled: root.notification !== null && root.inlineAmount > 0.5
      onActivated: root.service.activate(root.notification)
    }
  }

  MouseArea {
    width: parent.width
    height: 48
    enabled: !root.empty && root.previewCount < 0
    hoverEnabled: true
    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: root.panelRequested()
  }

  Notifications.CloseButton {
    id: inlineClose
    compact: true
    x: root.width - width / 2
    y: 60
    z: 3
    opacity: preview.hovered && root.inlineAmount > 0.7 ? 1 : 0
    visible: opacity > 0.001
    enabled: opacity > 0.5
    onClicked: root.service.remove(root.notification)
  }
}
