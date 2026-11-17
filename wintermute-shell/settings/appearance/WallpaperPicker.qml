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
// Lê o estado por `service` (decisão 0011).
Settings.Modal {
  id: root
  objectName: "wallpaperPicker"

  property var service: Appearance.State
  // Só para a vitrine: fixa o hover numa miniatura (índice na grade; -1 para nenhuma).
  property int hoverIndex: -1

  title: "Wallpaper"
  closeLabel: "Back to Appearance"
  implicitWidth: Shell.Theme.settingsWallpaperWidth
  implicitHeight: Math.min(Shell.Theme.settingsWallpaperHeight, availableHeight)
  bodyTop: Shell.Theme.settingsWallpaperListTop + (service.error ? Shell.Theme.settingsWallpaperErrorShift : 0)
  roundedContent: true
  contentHeight: grid.y + grid.height + Shell.Theme.settingsWallpaperBottomPadding
  onBackRequested: Settings.State.back()
  Keys.onEscapePressed: Settings.State.back()

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
        selected: dynamic ? root.service.wallpaperMode === "dynamic"
            : !adding && root.service.wallpaperMode === "custom"
                && root.service.wallpaperPath === modelData.path
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
  overlay: Text {
    x: Shell.Theme.settingsWallpaperErrorX; y: Shell.Theme.settingsWallpaperErrorY
    width: parent.width - 2 * Shell.Theme.settingsWallpaperErrorX
    visible: !!root.service.error
    text: root.service.error
    elide: Text.ElideRight
    color: Shell.Theme.dangerText
    font.family: Shell.Theme.fontFamily
    font.pixelSize: Shell.Theme.fontBody
    font.letterSpacing: 0
  }
}
