pragma ComponentBehavior: Bound

import QtQuick
import ".."
import "Emoji.js" as Emoji

// Página do seletor de emoji (ficha 16, board 13:17120; grade 13:17552, busca 13:17675): o corpo do launcher no lugar da
// busca e da lista, com o cabeçalho (voltar e o campo de busca), as seis abas, o divisor em y 108 e a grade que rola.
// O vidro, o divisor do cabeçalho em y 56 e o rodapé são do Panel.qml, que lê daqui a prévia (`previewGlyph`, `previewName`).
// `service` é a fonte de tudo (emojiData, emojiQuery, emojiSections e as funções); a vitrine troca por um serviço fictício.
//
// A grade é uma lista só, que rola, com as seções que o serviço entrega (recentes e as categorias, ou os resultados da
// busca). Não crio as 1914 células: um Flickable com a altura toda e um punhado de fileiras de verdade (`poolSize`) que
// andam com a rolagem e trocam o conteúdo. A conta das fileiras, da navegação e das abas é de Emoji.js.
FocusScope {
  id: root

  property var service

  // A célula selecionada (número entre todas as células da lista). Há sempre uma, a primeira ao abrir e quando o resultado
  // da busca muda. Para fixar na vitrine.
  property int selected: 0
  // A célula sob o ponteiro, para fixar na vitrine (-1: vale o ponteiro de verdade).
  property int hoverIndex: -1
  // Para a vitrine: rola até a seção desta aba quando a página é criada (-1: não rola).
  property int startTab: -1
  property bool forceCursor: false
  // A coluna que as setas verticais querem manter.
  property int wanted: 0
  // A rolagem da grade (o teste lê e confere).
  property alias scrollY: flick.contentY

  readonly property var inventory: service ? service.emojiData : null
  readonly property string queryText: service ? String(service.emojiQuery).trim() : ""
  readonly property bool searching: queryText !== ""
  readonly property real listTop: Theme.launcherEmojiDividerY + Theme.launcherDividerHeight
  readonly property real listHeight: Theme.launcherEmojiFooterY - listTop
  readonly property var metrics: ({
    perRow: Theme.launcherEmojiPerRow,
    cell: Theme.launcherEmojiCellSize,
    step: Theme.launcherEmojiCellStep,
    labelHeight: Theme.launcherLabelHeight,
    topPad: Theme.launcherEmojiLabelY - listTop,
    sectionGap: Theme.launcherSectionGap,
    endGap: Theme.launcherEmojiEndGap,
    gridX: Theme.launcherEmojiGridX
  })
  readonly property var plan: Emoji.layout(service ? service.emojiSections : [], metrics)
  readonly property bool none: searching && plan.cells.length === 0

  // A aba da seção que está no topo da área visível (ou -1, na busca).
  readonly property int activeTab: searching ? -1 : Emoji.activeTab(plan, flick.contentY)
  readonly property var tabsAvailable: Emoji.TABS.map((tab, i) => !searching && Emoji.sectionOfTab(plan, i) >= 0)

  // A célula sob o ponteiro e a que o rodapé mostra: o emoji sob o ponteiro, se houver, senão o selecionado.
  property real pointerX: 0
  property real pointerY: 0
  property bool pointerInside: false
  readonly property int hoveredCell: hoverIndex >= 0 ? hoverIndex
      : pointerInside ? Emoji.cellAt(plan, pointerX, pointerY + flick.contentY, metrics) : -1
  readonly property int previewCell: hoveredCell >= 0 ? hoveredCell : selected
  readonly property var previewItem: inventory && previewCell >= 0 && previewCell < plan.cells.length
      ? inventory.items[plan.cells[previewCell]] : null
  readonly property string previewGlyph: previewItem ? previewItem.ch : ""
  readonly property string previewName: Emoji.displayName(previewItem)

  // O emoji da célula, ou "" se ela não existe (a célula de uma fileira velha enquanto a lista se refaz).
  function glyphAt(cell) {
    const item = inventory && plan.cells[cell] !== undefined ? inventory.items[plan.cells[cell]] : null;
    return item ? item.ch : "";
  }

  function focusField() {
    field.focusEditor();
  }

  // Rola só o necessário para a célula `cell` ficar à vista. Na primeira fileira de uma seção o rótulo vem junto, e nas
  // pontas a folga é a do começo e a do fim da lista.
  function reveal(cell) {
    const rowIndex = plan.cellRow[cell];
    const row = plan.rows[rowIndex];
    if (!row)
      return;
    let top = row.y;
    if (plan.rows[rowIndex - 1] && plan.rows[rowIndex - 1].kind === "label")
      top = plan.rows[rowIndex - 1].y;
    top = Math.max(0, top - metrics.topPad);
    const bottom = row.y + row.height + (rowIndex === plan.rows.length - 1 ? metrics.endGap : metrics.topPad);
    if (top < flick.contentY)
      flick.contentY = top;
    else if (bottom > flick.contentY + flick.height)
      flick.contentY = Math.min(bottom - flick.height, Math.max(0, flick.contentHeight - flick.height));
  }

  function select(cell) {
    selected = cell;
    wanted = Emoji.columnOf(plan, cell);
  }

  // As quatro setas. ← e → passam para a fileira vizinha nas pontas; ↑ e ↓ mantêm a coluna.
  function step(key) {
    if (plan.cells.length === 0)
      return;
    const next = Emoji.move(plan, selected, key, wanted);
    selected = next.index;
    wanted = next.column;
    reveal(selected);
  }

  // Rola até a seção (o número em `plan.sections`) e seleciona a primeira célula dela.
  function goToSection(section) {
    const info = plan.sections[section];
    if (!info)
      return;
    flick.contentY = Math.max(0, Math.min(info.scrollY, flick.contentHeight - flick.height));
    selected = info.firstCell;
    wanted = 0;
  }

  // Tab e Shift+Tab: a seção da aba seguinte ou da anterior. Com busca não há abas.
  function jumpTab(delta) {
    if (searching)
      return;
    const tab = Emoji.neighbourTab(plan, activeTab, delta);
    if (tab >= 0)
      goToSection(Emoji.sectionOfTab(plan, tab));
  }

  // Enter e clique: copia o emoji, grava nos recentes e fecha (State.copyEmoji).
  function copyCell(cell) {
    const item = inventory && plan.cells[cell] !== undefined ? inventory.items[plan.cells[cell]] : null;
    if (item)
      service.copyEmoji(item.ch);
  }

  // Texto novo ou página aberta de novo: seleção na primeira célula e lista no começo.
  function resetView() {
    selected = 0;
    wanted = 0;
    flick.contentY = 0;
  }

  Connections {
    target: root.service
    function onEmojiQueryChanged() {
      root.resetView();
    }
    function onPageChanged() {
      if (root.service.page === "emoji")
        root.resetView();
    }
  }

  // A vitrine pede uma aba: espero a lista ter altura.
  onStartTabChanged: Qt.callLater(root.applyStartTab)
  Component.onCompleted: Qt.callLater(root.applyStartTab)
  function applyStartTab() {
    if (startTab < 0)
      return;
    const section = Emoji.sectionOfTab(plan, startTab);
    if (section >= 0)
      flick.contentY = Math.max(0, Math.min(plan.sections[section].scrollY, flick.contentHeight - flick.height));
  }

  IconButton {
    x: Theme.launcherColorBackX
    y: Theme.launcherColorBackY
    iconName: "chevron-left"
    accessibleName: "Back to launcher"
    onClicked: root.service.closePage()
  }

  // O campo do launcher, sem o ícone de busca e sem sugestão fantasma; ← e → andam nas células, não no texto.
  SearchField {
    id: field
    width: parent.width
    showIcon: false
    pageKeys: true
    captureHorizontal: true
    placeholderText: "Search emoji"
    forceCursor: root.forceCursor
    text: root.service ? root.service.emojiQuery : ""
    onEdited: text => root.service.setEmojiQuery(text)
    onUpPressed: root.step("up")
    onDownPressed: root.step("down")
    onLeftPressed: root.step("left")
    onRightPressed: root.step("right")
    onAccepted: root.copyCell(root.selected)
    onTabPressed: root.jumpTab(1)
    onBacktabPressed: root.jumpTab(-1)
    onEscapePressed: root.service.closePage()
    onBackspaceOnEmpty: root.service.closePage()
  }

  EmojiTabs {
    y: Theme.launcherEmojiTabsY
    width: parent.width
    activeTab: root.activeTab
    dimmed: root.searching
    available: root.tabsAvailable
    onActivated: tab => root.goToSection(Emoji.sectionOfTab(root.plan, tab))
  }

  Rectangle {
    y: Theme.launcherEmojiDividerY
    width: parent.width
    height: Theme.launcherDividerHeight
    color: Theme.border
  }

  Flickable {
    id: flick
    y: root.listTop
    width: parent.width
    height: root.listHeight
    contentWidth: width
    contentHeight: root.plan.height
    clip: true
    visible: !root.none
    boundsBehavior: Flickable.StopAtBounds
    interactive: contentHeight > height

    ScrollWheel { view: flick }

    // As fileiras de verdade: `firstRow` é a primeira que aparece na área visível, e cada uma é a seguinte a ela.
    readonly property int firstRow: Math.max(0, Emoji.rowAt(root.plan, contentY))

    Repeater {
      model: 12

      delegate: Item {
        id: slot

        required property int index
        readonly property int rowIndex: flick.firstRow + index
        readonly property var rowData: rowIndex < root.plan.rows.length ? root.plan.rows[rowIndex] : null

        visible: rowData !== null
        y: rowData ? rowData.y : 0
        width: parent.width
        height: rowData ? rowData.height : 0

        SectionLabel {
          visible: slot.rowData !== null && slot.rowData.kind === "label"
          x: Theme.launcherLabelX
          text: slot.rowData ? slot.rowData.text : ""
        }

        Repeater {
          model: Theme.launcherEmojiPerRow

          delegate: EmojiCell {
            id: cell

            required property int index
            readonly property int cellIndex: slot.rowData ? slot.rowData.first + index : -1
            readonly property bool present: slot.rowData !== null && slot.rowData.kind === "cells" && index < slot.rowData.count

            visible: present
            x: Theme.launcherEmojiGridX + index * Theme.launcherEmojiCellStep
            glyph: present ? root.glyphAt(cellIndex) : ""
            selected: present && cellIndex === root.selected
            hovered: present && cellIndex === root.hoveredCell
          }
        }
      }
    }
  }

  // Ponteiro e clique da grade, no quadro da página: uma área só em vez de uma por célula.
  MouseArea {
    x: 0
    y: root.listTop
    width: parent.width
    height: root.listHeight
    visible: !root.none
    hoverEnabled: true
    onPositionChanged: mouse => {
      root.pointerX = mouse.x;
      root.pointerY = mouse.y;
      root.pointerInside = true;
    }
    onExited: root.pointerInside = false
    onClicked: mouse => {
      const cell = Emoji.cellAt(root.plan, mouse.x, mouse.y + flick.contentY, root.metrics);
      if (cell >= 0) {
        root.select(cell);
        root.copyCell(cell);
      }
    }
  }

  // Sem resultado: o bloco do launcher no lugar da grade, 24 abaixo do divisor das abas, a mesma distância que o círculo
  // tem do divisor do cabeçalho no launcher (y 80 contra o divisor em 56). Composição sem board (ajuste A-05).
  NoResult {
    visible: root.none
    y: Theme.launcherEmojiDividerY + Theme.launcherNoResultCircleY - Theme.launcherSearchHeight
    width: parent.width
    query: root.queryText
  }
}
