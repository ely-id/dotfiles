pragma ComponentBehavior: Bound

import QtQuick
import "." as Launcher
import ".."

// O launcher (ficha 14): vidro de 640, cabeçalho de busca, lista por seções que rola entre o cabeçalho e o
// rodapé, e rodapé com o modo e as ações. `service` é a fonte de tudo (query, sugestão, seções, ações); a
// vitrine troca por um serviço fictício. A seleção mora aqui.
//
// Medidas no quadro do launcher: o primeiro rótulo em y 64, cada linha de 44 logo abaixo do rótulo, o rótulo
// seguinte 8 abaixo da última linha do grupo e o divisor do rodapé 4 abaixo da última linha (P-68).
//
// No modo cálculo (`service.calculation` não nulo) o launcher inteiro é o cálculo: o rótulo "Calculator" em
// y 64, o cartão de 128 logo abaixo e, 16 depois dele, as linhas de ação sem rótulo. As seções do serviço
// não aparecem.
Item {
  id: root

  property var service: Launcher.State
  // Índice da linha selecionada, contando as linhas de todas as seções em ordem.
  property int selected: 0
  // Para fixar o hover e o cursor na vitrine.
  property int hoverIndex: -1
  property bool forceCursor: false
  // Altura máxima do vidro; passando dela, a lista rola.
  property real maxHeight: 100000

  readonly property alias blurRegion: glass.blurRegion

  // Posições absolutas (no quadro) de cada rótulo e de cada linha, e do divisor do rodapé.
  readonly property var plan: buildPlan(service.sections, service.calculation)
  readonly property int rowCount: plan.rows.length
  readonly property real listTop: Theme.launcherSearchHeight + Theme.launcherDividerHeight
  // Sem lista, o divisor do rodapé é o próprio divisor do cabeçalho.
  readonly property real footerY: Math.max(Theme.launcherSearchHeight,
      Math.min(plan.footerY, maxHeight - Theme.launcherFooterHeight))

  implicitWidth: Theme.launcherWidth
  implicitHeight: footerY + Theme.launcherFooterHeight
  width: implicitWidth
  height: implicitHeight

  function buildPlan(sections, calculation) {
    const labels = [];
    const rows = [];
    let y = Theme.launcherSearchHeight + Theme.launcherSectionTop;
    let lastEnd = -1;
    let card = null;
    if (calculation) {
      labels.push({ text: "Calculator", y: y });
      y += Theme.launcherLabelHeight;
      card = { y: y, expression: calculation.expression, result: calculation.result };
      y += Theme.launcherCalcCardHeight + Theme.launcherCalcCardGap;
      (calculation.rows || []).forEach((row, i) => {
        rows.push({ row: row, y: y, first: false, labelY: y });
        y += Theme.launcherResultHeight;
      });
      lastEnd = y;
      sections = [];
    }
    (sections || []).forEach(section => {
      const list = section.rows || [];
      if (list.length === 0)
        return;
      labels.push({ text: section.label, y: y });
      y += Theme.launcherLabelHeight;
      list.forEach((row, i) => {
        rows.push({ row: row, y: y, first: i === 0, labelY: y - Theme.launcherLabelHeight });
        y += Theme.launcherResultHeight;
      });
      lastEnd = y;
      y += Theme.launcherSectionGap;
    });
    return {
      labels: labels,
      rows: rows,
      card: card,
      footerY: lastEnd < 0 ? Theme.launcherSearchHeight : lastEnd + Theme.launcherFooterGap
    };
  }

  function focusSearch() {
    search.focusEditor();
  }

  function move(delta) {
    if (rowCount === 0)
      return;
    selected = Math.max(0, Math.min(rowCount - 1, selected + delta));
  }

  function activateIndex(index) {
    const entry = plan.rows[index];
    if (entry)
      service.activate(entry.row);
  }

  // Mantém a selecionada à vista: com a primeira linha de um grupo, mostra o rótulo junto.
  function ensureVisible() {
    const entry = plan.rows[selected];
    if (!entry)
      return;
    // Cabendo tudo, não há o que rolar (e a lista ainda pode estar sem altura na criação).
    if (list.contentHeight <= list.height) {
      list.contentY = 0;
      return;
    }
    const top = (selected === 0 ? 0 : (entry.first ? entry.labelY : entry.y)) - listTop;
    const bottom = entry.y + Theme.launcherResultHeight + (selected === rowCount - 1 ? Theme.launcherFooterGap : 0) - listTop;
    if (top < list.contentY)
      list.contentY = Math.max(0, top);
    else if (bottom > list.contentY + list.height)
      list.contentY = bottom - list.height;
  }

  onSelectedChanged: ensureVisible()
  onRowCountChanged: {
    if (selected > rowCount - 1)
      selected = Math.max(0, rowCount - 1);
  }

  Connections {
    target: root.service
    // Texto novo, seleção na primeira linha.
    function onQueryChanged() {
      root.selected = 0;
      list.contentY = 0;
    }
  }

  GlassSurface {
    id: glass
    anchors.fill: parent
    surfaceType: "launcher"

    // Cliques no vidro que não caem numa linha não chegam ao véu, então não fecham o launcher.
    MouseArea {
      anchors.fill: parent
    }

    Launcher.SearchField {
      id: search
      width: parent.width
      text: root.service.query
      // Sem sugestão fantasma no modo cálculo.
      ghost: root.service.calculation ? "" : root.service.ghost
      iconName: root.service.searchIcon
      forceCursor: root.forceCursor
      onEdited: text => root.service.setQuery(text)
      onUpPressed: root.move(-1)
      onDownPressed: root.move(1)
      onAccepted: root.activateIndex(root.selected)
      onEscapePressed: root.service.close()
      onTabPressed: {
        root.service.acceptGhost();
        search.moveCursorToEnd();
      }
    }

    Rectangle {
      y: Theme.launcherSearchHeight
      width: parent.width
      height: Theme.launcherDividerHeight
      color: Theme.border
    }

    Flickable {
      id: list
      y: root.listTop
      width: parent.width
      height: Math.max(0, root.footerY - root.listTop)
      contentWidth: width
      contentHeight: Math.max(0, root.plan.footerY - root.listTop)
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      interactive: contentHeight > height
      onHeightChanged: root.ensureVisible()

      ScrollWheel { view: list }

      Repeater {
        model: root.plan.labels

        delegate: Launcher.SectionLabel {
          required property var modelData
          x: Theme.launcherLabelX
          y: modelData.y - root.listTop
          text: modelData.text
        }
      }

      Launcher.CalculatorCard {
        visible: root.plan.card !== null
        x: Theme.launcherRowX
        y: root.plan.card ? root.plan.card.y - root.listTop : 0
        expression: root.plan.card ? root.plan.card.expression : ""
        result: root.plan.card ? root.plan.card.result : ""
      }

      Repeater {
        model: root.plan.rows

        delegate: Launcher.ResultRow {
          required property var modelData
          required property int index
          x: Theme.launcherRowX
          y: modelData.y - root.listTop
          title: modelData.row.title || ""
          detail: modelData.row.detail || ""
          kind: modelData.row.kind || ""
          iconName: modelData.row.icon || ""
          iconSource: modelData.row.iconSource || ""
          danger: !!modelData.row.danger
          selected: index === root.selected
          forceHovered: index === root.hoverIndex
          onClicked: root.activateIndex(index)
        }
      }
    }

    Launcher.Footer {
      y: root.footerY
      width: parent.width
      modeIcon: root.service.modeIcon
      modeLabel: root.service.modeLabel
      actions: root.service.actions
    }
  }
}
