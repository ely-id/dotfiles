pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "." as Battery
import ".." as Shell

// Perfil de energia na borda direita da tela inicial dos Ajustes (ficha 13; Figma 13:15845).
// Coluna de vidro de 48×136, raio 16, sem o brilho do acento, com três botões ícone de 40
// em (4,4), (4,48) e (4,92): Economia, Equilibrado e Desempenho (`zap`, P-07). O selecionado
// é o estado Selecionado do botão ícone (accent com o ícone em textOnAccent). Lê o estado por
// `service` (decisão 0011), com Battery.State como padrão.
Item {
  id: root

  property var service: Battery.State

  implicitWidth: Shell.Theme.settingsProfileWidth
  implicitHeight: Shell.Theme.settingsProfileHeight

  readonly property Region blurRegion: Region {
    item: root.enabled && root.opacity > Shell.Theme.blurRevealOpacity ? root : null
    radius: Shell.Theme.radiusCard
  }

  Shell.GlassSurface {
    anchors.fill: parent
    surfaceType: "card"
    showGlow: false

    // O clique entre os botões não pode chegar ao véu, que fecha os Ajustes.
    MouseArea { anchors.fill: parent }

    Column {
      x: Shell.Theme.settingsProfilePadding
      y: Shell.Theme.settingsProfilePadding
      spacing: Shell.Theme.settingsProfilePadding

      Repeater {
        model: root.service.profiles

        delegate: Shell.IconButton {
          id: button
          required property var modelData

          readonly property bool available: root.service.profileAvailable(modelData.key)

          buttonSize: 40
          iconName: modelData.icon
          checked: root.service.selectedProfile === modelData.key
          enabled: available
          accessibleName: modelData.name
          activeFocusOnTab: true

          Accessible.role: Accessible.RadioButton
          Accessible.name: modelData.name
          Accessible.checkable: true
          Accessible.checked: checked
          Accessible.onPressAction: choose()

          onClicked: choose()
          Keys.onSpacePressed: choose()
          Keys.onReturnPressed: choose()
          Keys.onEnterPressed: choose()

          function choose() {
            if (available)
              root.service.setProfile(modelData.key);
          }
        }
      }
    }
  }
}
