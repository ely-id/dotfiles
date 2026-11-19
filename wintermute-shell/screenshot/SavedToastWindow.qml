import QtQuick
import "." as Screenshot
import "../notifications" as Notifications
import ".." as Shell
import Quickshell
import Quickshell.Wayland

// A janela do aviso de captura salva (ficha 17, F6-T03), uma por tela, no molde da notifications/ToastWindow.qml: camada de sobreposição,
// sem zona exclusiva, sem teclado e sem aceitar clique (máscara vazia), encostada na barra lateral com a borda esquerda acompanhando a
// borda animada da barra (a mesma conta do toast de notificação). Diferenças para ele, tudo composição (A-05): aparece com a barra aberta
// ou recolhida, e fica embaixo, com a base do cartão na base da barra, ao lado de onde a prévia da captura mora, para não disputar
// lugar com o toast de notificação, que fica em cima. Só aparece no monitor do aviso (`SavedState.outputName`).
//
// A janela ocupa a altura da tela (ancorada em cima e embaixo, como a barra) e o cartão é posto pela base, em vez de a janela ter margem
// negativa para a sombra. Entra e sai com a opacidade e 4 de deslize, em `panelDuration` (180 ms).
PanelWindow {
  id: root

  required property var bar

  readonly property string outputName: bar && bar.screen ? bar.screen.name : ""
  readonly property bool requested: Screenshot.SavedState.visible
      && Screenshot.SavedState.outputName === outputName
  property real reveal: requested ? 1 : 0

  screen: bar.screen
  visible: requested || reveal > 0.001
  color: "transparent"
  // O desfoque do compositor atrás do cartão; sem ler a camada de compatibilidade do tema, como o editor e a captura.
  BackgroundEffect.blurRegion: savedBlur
  onRevealChanged: savedBlur.changed()
  Region {
    id: savedBlur
    item: root.requested ? card : null
    radius: card.radius
  }
  implicitWidth: Shell.Theme.captureSavedWidth + Shell.Theme.captureSavedShadowPadding * 2
  mask: Region {}

  anchors {
    left: true
    top: true
    bottom: true
  }
  margins {
    left: Math.round(Shell.Theme.sidebarOuterMargin + bar.cardWidth
                     + Notifications.Style.desktopMargin) - Shell.Theme.captureSavedShadowPadding
  }

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "wintermute-screenshot-saved-" + (outputName || "unknown")
  WlrLayershell.exclusionMode: ExclusionMode.Ignore
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  Behavior on reveal { Shell.Motion { duration: Notifications.Style.panelDuration } }

  Screenshot.SavedToast {
    id: card
    x: Shell.Theme.captureSavedShadowPadding - (1 - root.reveal) * Shell.Theme.captureSavedSlide
    y: root.height - Shell.Theme.sidebarOuterMargin - height
    opacity: root.reveal
    onXChanged: savedBlur.changed()
    onYChanged: savedBlur.changed()
  }
}
