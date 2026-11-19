pragma ComponentBehavior: Bound

import QtQuick
import ".."
import "../launcher" as Launcher
import "Clipboard.js" as Clipboard

// A página do histórico da área de transferência (ficha 18, board 13:19344; texto 13:19621, imagem 13:19678, busca 13:19746, fixados
// 13:19790 e vazio 13:19846): o corpo do launcher no lugar da busca e da lista, com o cabeçalho (o ícone `clipboard` e o campo
// "Search history"), a lista de 280 à esquerda, a prévia, os metadados e o vazio. O vidro, o divisor do cabeçalho em y 56 e o rodapé
// são do Panel.qml, que lê daqui as ações (`footerActions`), porque elas mudam com o item selecionado.
//
// `service` é o histórico (items, now, copy, togglePin e remove: clipboard/State.qml na shell, demo/ClipboardService.qml na vitrine).
// `launcher` é o serviço do launcher, de quem esta página só precisa de `closePage()` e `close()`. A busca é desta página: o texto
// do campo não é o do launcher, e abrir a página de novo o zera.
//
// A seleção anda por `selected`, o índice na lista de linhas (todas as seções em ordem), mas segue o item pelo `id` quando a lista muda:
// fixar o item o muda de seção e ele continua selecionado; apagar passa a seleção ao vizinho (a linha de baixo, ou a de cima se era a última).
FocusScope {
  id: root

  property var service: Clipboard.State
  property var launcher: null

  // O texto da busca e o índice da linha selecionada. Para fixar na vitrine.
  property string query: ""
  property int selected: 0
  // A linha sob o ponteiro, para fixar na vitrine (-1: vale o ponteiro de verdade).
  property int hoverIndex: -1
  property bool forceCursor: false
  // A rolagem da lista e o campo de busca (o teste lê e confere).
  property alias scrollY: flick.contentY
  readonly property alias searchField: field

  readonly property var items: service ? service.items : []
  readonly property real now: service ? service.now : 0
  readonly property bool searching: query.trim() !== ""
  readonly property real listTop: Theme.launcherSearchHeight + Theme.launcherDividerHeight
  readonly property var metrics: ({
    firstLabelY: Theme.clipboardFirstLabelY,
    labelHeight: Theme.launcherLabelHeight,
    rowHeight: Theme.clipboardRowHeight,
    labelGap: Theme.clipboardLabelGap,
    endGap: Theme.launcherFooterGap
  })
  readonly property var plan: Clipboard.layout(Clipboard.sections(items, query), metrics)
  readonly property var rows: plan.rows
  // Sem linha nenhuma: o bloco do vazio (nada copiado ainda) ou o do "sem resultado" (a busca não achou).
  readonly property bool none: rows.length === 0
  readonly property bool nothingCopied: none && (items || []).length === 0
  readonly property var current: selected >= 0 && selected < rows.length ? rows[selected].item : null
  // O `id` do item selecionado, para a seleção acompanhá-lo quando a lista muda.
  property var selectedId: undefined

  // As ações do rodapé. Com o item selecionado fixado, "Pin" vira "Unpin" (composição, A-05); sem lista, só "Close".
  readonly property var footerActions: none ? [
    { label: "Close", keys: ["Esc"], primary: true }
  ] : [
    { label: "Copy", keys: ["↵"], primary: true },
    { label: current && current.pinned ? "Unpin" : "Pin", keys: ["Ctrl", "P"], primary: false },
    { label: "Delete", keys: ["Del"], primary: false }
  ]

  implicitWidth: Theme.launcherWidth
  implicitHeight: Theme.clipboardFooterY

  function focusField() {
    field.focusEditor();
  }

  function syncSelectedId() {
    const entry = rows[selected];
    selectedId = entry ? entry.item.id : undefined;
  }

  onSelectedChanged: {
    syncSelectedId();
    ensureVisible();
  }

  // A lista mudou (um item novo, fixado, apagado ou outra busca): a seleção segue o item, ou vai ao vizinho se ele sumiu.
  onRowsChanged: {
    const index = Clipboard.reselect(rows, selectedId, selected);
    if (index >= 0 && index !== selected)
      selected = index;
    else
      syncSelectedId();
    Qt.callLater(ensureVisible);
  }

  // Rola só o necessário para a linha selecionada ficar à vista; com a primeira de uma seção o rótulo vem junto, e na primeira de
  // todas a lista vai ao topo.
  function ensureVisible() {
    if (flick.contentHeight <= flick.height) {
      flick.contentY = 0;
      return;
    }
    const entry = rows[selected];
    if (!entry)
      return;
    const top = selected === 0 ? 0 : (entry.first ? entry.labelY : entry.y) - listTop;
    const bottom = entry.y + Theme.clipboardRowHeight - listTop + (selected === rows.length - 1 ? Theme.launcherFooterGap : 0);
    if (top < flick.contentY)
      flick.contentY = top;
    else if (bottom > flick.contentY + flick.height)
      flick.contentY = bottom - flick.height;
  }

  // ↑ e ↓: uma linha, passando de uma seção à outra; param nas pontas.
  function step(delta) {
    if (rows.length === 0)
      return;
    selected = Math.max(0, Math.min(rows.length - 1, selected + delta));
  }

  function select(index) {
    selected = index;
  }

  // Enter e duplo clique: devolve o item à área de transferência e fecha o launcher (P-80). Colo com Ctrl+V.
  function copySelected() {
    const item = current;
    if (!item)
      return;
    service.copy(item);
    if (launcher)
      launcher.close();
  }

  // Ctrl+P.
  function togglePinSelected() {
    const item = current;
    if (item)
      service.togglePin(item);
  }

  // Del. A seleção passa para o vizinho quando a lista muda (onRowsChanged).
  function removeSelected() {
    const item = current;
    if (item)
      service.remove(item);
  }

  function back() {
    if (launcher)
      launcher.closePage();
  }

  // Texto novo ou página aberta de novo: seleção na primeira linha e lista no topo.
  function resetView() {
    selected = 0;
    flick.contentY = 0;
  }

  onQueryChanged: resetView()

  // A vitrine pode abrir com uma linha selecionada lá embaixo: espero a lista ter altura para mostrá-la.
  Component.onCompleted: Qt.callLater(root.ensureVisible)

  Connections {
    target: root.launcher
    function onPageChanged() {
      if (root.launcher.page === "clipboard") {
        root.query = "";
        root.resetView();
      }
    }
  }

  Launcher.SearchField {
    id: field
    width: parent.width
    iconName: "clipboard"
    placeholderText: "Search history"
    pageKeys: true
    itemKeys: true
    forceCursor: root.forceCursor
    text: root.query
    onEdited: text => root.query = text
    onUpPressed: root.step(-1)
    onDownPressed: root.step(1)
    onAccepted: root.copySelected()
    onPinPressed: root.togglePinSelected()
    onDeletePressed: root.removeSelected()
    onEscapePressed: root.back()
    onBackspaceOnEmpty: root.back()
  }

  // O divisor vertical entre a lista e a prévia: de y 57 até o rodapé. Sem lista ele não existe.
  Rectangle {
    visible: !root.none
    x: Theme.clipboardColumnWidth
    y: root.listTop
    width: 1
    height: Theme.clipboardFooterY - root.listTop
    color: Theme.border
  }

  Flickable {
    id: flick
    visible: !root.none
    y: root.listTop
    width: Theme.clipboardColumnWidth
    height: Theme.clipboardFooterY - root.listTop
    contentWidth: width
    contentHeight: root.plan.height - root.listTop
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    interactive: contentHeight > height
    onHeightChanged: root.ensureVisible()

    ScrollWheel { view: flick }

    Repeater {
      model: root.plan.labels

      delegate: Launcher.SectionLabel {
        required property var modelData
        x: Theme.launcherLabelX
        y: modelData.y - root.listTop
        text: modelData.text
      }
    }

    Repeater {
      model: root.rows

      delegate: ClipboardRow {
        required property var modelData
        required property int index
        x: Theme.launcherRowX
        y: modelData.y - root.listTop
        item: modelData.item
        now: root.now
        selected: index === root.selected
        forceHovered: index === root.hoverIndex
        onClicked: root.select(index)
        onActivated: {
          root.select(index);
          root.copySelected();
        }
      }
    }
  }

  ClipboardPreview {
    visible: !root.none && root.current !== null
    x: Theme.clipboardPreviewX
    y: Theme.clipboardPreviewY
    item: root.current
  }

  // Os metadados abaixo da prévia: o rótulo à esquerda em x 296 e o valor à direita, terminando em x 624.
  Repeater {
    model: root.none ? [] : Clipboard.metadata(root.current, root.now)

    delegate: Item {
      id: metaRow
      required property var modelData
      required property int index
      x: Theme.clipboardPreviewX
      y: Theme.clipboardMetaRowsTop + index * Theme.clipboardMetaRowHeight
      width: Theme.clipboardMetaValueRight - Theme.clipboardPreviewX
      height: Theme.clipboardMetaRowHeight

      Text {
        width: Theme.clipboardMetaLabelWidth
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        text: metaRow.modelData.label
        color: Theme.muted
        font.family: Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Theme.fontCaption
        font.letterSpacing: 0
      }

      Text {
        x: parent.width - width
        width: Theme.clipboardMetaValueWidth
        height: parent.height
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        text: metaRow.modelData.value
        color: Theme.text
        font.family: Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Theme.fontCaption
        font.letterSpacing: 0
      }
    }
  }

  // Nada copiado ainda (13:19846): o bloco do "sem resultado" do launcher com o ícone `clipboard`, o título e a dica de duas linhas.
  // Busca sem resultado (sem board, A-05): o mesmo bloco, com o `search-x` e o texto do launcher para a busca digitada.
  Launcher.NoResult {
    visible: root.none
    y: Theme.clipboardEmptyCircleY
    width: parent.width
    query: root.query.trim()
    iconName: root.nothingCopied ? "clipboard" : "search-x"
    titleText: root.nothingCopied ? "Nothing copied yet" : "Nothing found for “" + root.query.trim() + "”"
    hintText: root.nothingCopied ? "What you copy (text or image) shows up here.\nSuper+V opens this history from anywhere."
        : "Check the spelling or try another search."
    titleTop: Theme.clipboardEmptyTitleY - Theme.clipboardEmptyCircleY
    hintTop: Theme.clipboardEmptyHintY - Theme.clipboardEmptyCircleY
    hintLines: root.nothingCopied ? 2 : 1
    hintWidth: root.nothingCopied ? Theme.clipboardEmptyHintWidth : width - 2 * Theme.launcherNoResultTextMargin
  }
}
