pragma ComponentBehavior: Bound
import QtQuick
import "." as Appearance
import ".." as Settings
import "../.." as Shell

// Cartão "Customize" do seletor de papel de parede (F4-T24, P-67). Não tem board: composição pela regra
// A-05, só com os componentes e os tokens que os Ajustes já usam (linhas Field de 520×52, chaves, setas e
// a miniatura da grade encolhida). Modal de 580 com o título em Serif 32; duas chaves em y 84 e 144, com
// passo 60, e depois uma linha por lugar, que depende das chaves:
//   as duas desligadas: nenhuma linha (vale o marcado na grade);
//   "Follow light and dark mode": "Light" e "Dark";
//   "One wallpaper per display": um monitor por linha, pelo nome do conector (eDP-1, HDMI-A-1);
//   as duas: "eDP-1 · Light", "eDP-1 · Dark" e o mesmo para cada monitor.
// A linha de lugar leva a miniatura de 64×36 em (8,8) e o título em x 84 (= 8 + 64 + 12; 12 é a folga entre
// o bloco e o texto do botão Manual das Informações); a seta chevron-right de 16 em (484,18) é a do Field.
// A altura é 84 + 60 × (2 + n) − 8 + 32: 228 sem linhas, 348 com duas e 468 com quatro. Passando da altura
// disponível o corpo rola, como em todo Modal. Tocar numa linha pede à pilha que volte ao seletor para
// escolher o papel de parede daquele lugar. Lê o estado por `service` (decisão 0011).
Settings.Modal {
  id: root
  objectName: "wallpaperCustomize"

  property var service: Appearance.State
  // Só para a vitrine: fixa o hover numa linha ("follow", "per-display" ou a chave de um lugar; "" nenhuma).
  property string hoverRow: ""
  signal placeRequested(string key)

  title: "Customize"
  closeLabel: "Back to Wallpaper"
  implicitWidth: Shell.Theme.settingsModalWidth
  bodyTop: 0
  contentHeight: fields.y + fields.height + Shell.Theme.settingsBottomPadding

  // Miniatura e título da linha de lugar: a miniatura em (8,8) tem 36 de altura e 8 de folga em volta.
  readonly property real thumbnailInset: 8
  readonly property real thumbnailWidth: 64
  readonly property real titleGap: 12

  function visualState(row) { return hoverRow === "" ? "" : hoverRow === row ? "hover" : "rest"; }

  Column {
    id: fields
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsBodyTop
    width: Shell.Theme.settingsRowWidth
    spacing: Shell.Theme.settingsRowPitch - Shell.Theme.settingsRowHeight

    Settings.Field {
      objectName: "customizeFollowScheme"
      title: "Follow light and dark mode"
      toggle: true
      checked: root.service.followScheme
      visualState: root.visualState("follow")
      enabled: !root.service.busy
      onToggled: checked => root.service.setFollowScheme(checked)
    }
    Settings.Field {
      objectName: "customizePerDisplay"
      title: "One wallpaper per display"
      toggle: true
      checked: root.service.perDisplay
      visualState: root.visualState("per-display")
      enabled: !root.service.busy
      onToggled: checked => root.service.setPerDisplay(checked)
    }

    Repeater {
      model: root.service.placeRows
      delegate: Settings.Field {
        id: place
        required property var modelData
        objectName: "customizePlace" + modelData.key
        title: modelData.name
        navigation: true
        titleX: root.thumbnailInset + root.thumbnailWidth + root.titleGap
        visualState: root.visualState(modelData.key)
        enabled: !root.service.busy
        onClicked: root.placeRequested(modelData.key)

        Appearance.PlaceThumbnail {
          x: root.thumbnailInset
          y: root.thumbnailInset
          dynamic: place.modelData.dynamic
          source: place.modelData.url
        }
      }
    }

    // Erro como nas outras páginas de linhas: depois da última, com quebra.
    Text {
      width: parent.width
      visible: root.service.error !== ""
      text: root.service.error
      wrapMode: Text.Wrap
      color: Shell.Theme.dangerText
      font.family: Shell.Theme.fontFamily
      font.pixelSize: Shell.Theme.fontBody
    }
  }
}
