pragma ComponentBehavior: Bound
import QtQuick
import "." as Appearance
import ".." as Settings
import "../.." as Shell

// Seletor de papel de parede (ficha 13; Figma 13:16208): modal de 624×608 com a grade de miniaturas de
// 276×156 em duas colunas (x 24 e 324), com linhas a cada 172 a partir de y 84 (o board desenha três).
// Ordem: "Choose an image", Dynamic, as três nativas (com nome) e depois as acrescentadas, numeradas de 01
// em diante na ordem em que entram (P-59). A grade não tem tamanho travado: cresce para baixo, e o espaço
// depois da última fica vazio, para as imagens novas entrarem nele. Passando de seis miniaturas ela rola
// dentro do modal, que continua com 608. A área rolante começa em y 80 e a grade em y 4 dentro dela, para
// o anel de seleção (4 px para fora) não ser cortado. As setas e o `reveal` valem com qualquer número.
// Com erro, a mensagem aparece em y 58 e empurra a grade 28 para baixo, como na origem.
// O botão "Customize" (F4-T24, P-67; sem board, composição A-05) é o "Arrange" da página Tela: ActionButton
// pequeno de 96×32, alinhado à direita com a grade (x 504 = 624 − 24 − 96) e centrado na caixa do título
// (y 26 = 20 + (44 − 32) / 2). Abre o cartão Customize na frente do seletor. Quando a grade escolhe para
// um lugar o título passa a ser o nome dele (o mesmo texto da linha do cartão), anel e marca mostram o que
// vale ali, tocar numa miniatura grava no lugar, e o botão some. Fechar ou Escape voltam ao cartão.
// Lê o estado por `service` (decisão 0011).
Settings.Modal {
  id: root
  objectName: "wallpaperPicker"

  property var service: Appearance.State
  // Só para a vitrine: fixa o hover numa miniatura (índice na grade; -1 para nenhuma).
  property int hoverIndex: -1
  // A pilha (WallpaperStack.qml) é quem desenha o vidro, o contorno e o botão de fechar do seletor.
  property bool embedded: false
  // O seletor é a carta de trás do cartão Customize: sem o botão "Customize".
  property bool behind: false

  title: service.choosingName || "Wallpaper"
  closeLabel: service.choosingPlace ? "Back to Customize" : "Back to Appearance"
  showGlass: !embedded
  showOutline: !embedded
  closeVisible: !embedded
  implicitWidth: Shell.Theme.settingsWallpaperWidth
  implicitHeight: Math.min(Shell.Theme.settingsWallpaperHeight, availableHeight)
  bodyTop: Shell.Theme.settingsWallpaperListTop + (service.error ? Shell.Theme.settingsWallpaperErrorShift : 0)
  roundedContent: true
  contentHeight: grid.y + grid.height + Shell.Theme.settingsWallpaperBottomPadding
  onBackRequested: goBack()
  Keys.onEscapePressed: goBack()

  // Escolhendo para um lugar, voltar devolve o cartão Customize sem mudar nada.
  function goBack() {
    if (service.choosingPlace) {
      service.cancelPlace();
      Settings.State.openPage("customize");
    } else {
      Settings.State.back();
    }
  }
  function openCustomize() { Settings.State.openPage("customize"); }
  function focusTile(index) {
    const tile = tiles.itemAt(index);
    if (tile) tile.forceActiveFocus(Qt.TabFocusReason);
  }
  // Mantém a miniatura focada à vista, com o anel de 4 px incluído.
  function reveal(tile) {
    const ring = Shell.Theme.settingsWallpaperRingGap;
    const top = grid.y + tile.y - ring;
    const bottom = grid.y + tile.y + tile.height + ring;
    if (top < scrollItem.contentY) scrollItem.contentY = Math.max(0, top);
    else if (bottom > scrollItem.contentY + scrollItem.height)
      scrollItem.contentY = Math.min(contentHeight - scrollItem.height, bottom - scrollItem.height);
  }

  Grid {
    id: grid
    x: Shell.Theme.settingsWallpaperGridInset; y: Shell.Theme.settingsWallpaperGridTop
    columns: 2
    columnSpacing: Shell.Theme.settingsWallpaperColumnGap
    rowSpacing: Shell.Theme.settingsWallpaperRowGap
    enabled: !root.service.busy
    Repeater {
      id: tiles
      model: [{adding: true, title: "Choose an image"}].concat(root.service.wallpapers)
      delegate: WallpaperTile {
        required property var modelData
        required property int index
        objectName: "wallpaperTile" + index
        adding: !!modelData.adding
        dynamic: !!modelData.dynamic
        title: modelData.title || ""
        subtitle: modelData.subtitle || ""
        number: modelData.number || 0
        source: modelData.thumbnail || modelData.url || ""
        forceHovered: index === root.hoverIndex
        selected: dynamic ? root.service.markedMode === "dynamic"
            : !adding && root.service.markedMode === "custom"
                && root.service.markedPath === modelData.path
        onClicked: {
          if (adding) root.service.pickWallpaper();
          else if (dynamic) root.service.selectDynamic();
          else root.service.selectWallpaper(modelData.path);
        }
        onActiveFocusChanged: if (activeFocus) root.reveal(this)
        Keys.onLeftPressed: root.focusTile(index - 1)
        Keys.onRightPressed: root.focusTile(index + 1)
        Keys.onUpPressed: root.focusTile(index - 2)
        Keys.onDownPressed: root.focusTile(index + 2)
      }
    }
  }
  overlay: [
    Text {
      x: Shell.Theme.settingsWallpaperErrorX; y: Shell.Theme.settingsWallpaperErrorY
      width: parent.width - 2 * Shell.Theme.settingsWallpaperErrorX
      visible: !!root.service.error
      text: root.service.error
      elide: Text.ElideRight
      color: Shell.Theme.dangerText
      font.family: Shell.Theme.fontFamily
      font.pixelSize: Shell.Theme.fontBody
      font.letterSpacing: 0
    },
    Shell.ActionButton {
      objectName: "customizeWallpapers"
      // O de sempre da página Tela (settings/display/Panel.qml), com o mesmo foco e teclado.
      x: root.width - Shell.Theme.settingsWallpaperGridInset - width
      y: 20 + (44 - height) / 2 // centrado na caixa do título (y 20, altura 44, do Modal)
      width: Shell.Theme.settingsDisplayArrangeWidth
      small: true
      text: "Customize"
      visible: !root.service.choosingPlace && !root.behind
      activeFocusOnTab: visible && enabled
      Accessible.role: Accessible.Button
      Accessible.name: "Customize wallpapers"
      Accessible.onPressAction: root.openCustomize()
      Keys.onReturnPressed: root.openCustomize()
      Keys.onSpacePressed: root.openCustomize()
      onClicked: root.openCustomize()
    }
  ]
}
