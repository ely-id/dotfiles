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
// Cinco formas. A página do seletor de cor (`service.page`, F5-T08) tira a busca e a lista de cena e vale por si; as
// outras quatro são escolhidas pelo texto da busca (`plan.kind`):
//   color  `service.page === "color"`: o cabeçalho de busca vira voltar e título, o corpo é o resultado do seletor de cor
//          (ColorPage.qml) e o divisor do rodapé fica fixo em y 432, com 476 de altura no total, sem rolar.
//   calc   `service.calculation` não nulo: o launcher inteiro é o cálculo, com o rótulo "Calculator" em y 64, o
//          cartão de 128 logo abaixo e, 16 depois dele, as linhas de ação sem rótulo. As seções não aparecem.
//   empty  busca vazia: "Recent" (as linhas de `service.recents`) e "Tools" (a fila de chips de `service.tools`),
//          com o divisor do rodapé 16 abaixo dos chips.
//   none   há texto, não é cálculo e o serviço não achou nada: o bloco "Nothing found" e, 16 abaixo da dica, as
//          linhas de `service.fallbackRows` (sem rótulo). Sem elas o divisor do rodapé fica nos 16 da dica.
//   list   as seções do serviço.
// Os chips entram na seleção pelo teclado (P-72): ↓ depois da última linha (ou direto, sem recentes) vai ao
// primeiro chip, ← e → andam entre eles, ↑ volta às linhas. Com um chip em foco nenhuma linha fica selecionada.
Item {
  id: root

  property var service: Launcher.State
  // Índice da linha selecionada, contando as linhas de todas as seções em ordem.
  property int selected: 0
  // Para fixar o hover e o cursor na vitrine.
  property int hoverIndex: -1
  property bool forceCursor: false
  // Amostra do histórico do seletor de cor sob o ponteiro (-1: nenhuma). Para fixar o hover na vitrine.
  property int historyHoverIndex: -1
  // Chip das ferramentas com o foco do teclado (índice em `service.tools`), ou -1. Para fixar na vitrine.
  property int chipIndex: -1
  // Chip sob o ponteiro, para fixar o hover na vitrine.
  property int chipHoverIndex: -1
  // Altura máxima do vidro; passando dela, a lista rola.
  property real maxHeight: 100000

  readonly property alias blurRegion: glass.blurRegion

  // Posições absolutas (no quadro) de cada rótulo e de cada linha, e do divisor do rodapé.
  readonly property var plan: buildPlan(service.page, service.sections, service.calculation,
      String(service.query).trim(), service.recents, service.tools, service.fallbackRows)
  readonly property int rowCount: plan.rows.length
  readonly property int chipCount: plan.chips ? plan.chips.items.length : 0
  readonly property real listTop: Theme.launcherSearchHeight + Theme.launcherDividerHeight
  // Sem lista, o divisor do rodapé é o próprio divisor do cabeçalho.
  // A página do seletor de cor tem altura fixa (476): não encolhe para caber, porque não rola.
  readonly property real footerY: plan.kind === "color" ? plan.footerY
      : Math.max(Theme.launcherSearchHeight, Math.min(plan.footerY, maxHeight - Theme.launcherFooterHeight))

  implicitWidth: Theme.launcherWidth
  implicitHeight: footerY + Theme.launcherFooterHeight
  width: implicitWidth
  height: implicitHeight

  function buildPlan(page, sections, calculation, query, recents, tools, fallbackRows) {
    if (page === "color") {
      return { kind: "color", labels: [], rows: [], card: null, chips: null, notice: null,
          footerY: Theme.launcherColorFooterY };
    }
    const labels = [];
    const rows = [];
    let y = Theme.launcherSearchHeight + Theme.launcherSectionTop;
    let lastEnd = -1;
    let card = null;
    let chips = null;
    let notice = null;
    let kind = "list";
    let footerY = -1;
    if (calculation) {
      kind = "calc";
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
    } else if (query === "") {
      // Busca vazia: o que o serviço tem de seções fica de fora; valem os recentes e as ferramentas.
      kind = "empty";
      sections = (recents || []).length > 0 ? [{ label: "Recent", rows: recents }] : [];
    } else if (!(sections || []).some(section => (section.rows || []).length > 0)) {
      kind = "none";
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
    if (kind === "empty" && (tools || []).length > 0) {
      // O rótulo vem 8 abaixo da última linha (ou em y 64 sem recentes), os chips 4 abaixo dele.
      labels.push({ text: "Tools", y: y });
      const chipsY = y + Theme.launcherLabelHeight + Theme.launcherChipsGap;
      chips = { y: chipsY, items: tools };
      footerY = chipsY + Theme.launcherChipHeight + Theme.launcherChipsFooterGap;
    } else if (kind === "none") {
      notice = { y: Theme.launcherNoResultCircleY, query: query };
      y = Theme.launcherNoResultHintY + Theme.launcherNoResultHintHeight + Theme.launcherNoResultActionsGap;
      (fallbackRows || []).forEach(row => {
        rows.push({ row: row, y: y, first: false, labelY: y });
        y += Theme.launcherResultHeight;
      });
      footerY = rows.length > 0 ? y + Theme.launcherFooterGap
          : Theme.launcherNoResultHintY + Theme.launcherNoResultHintHeight + Theme.launcherNoResultActionsGap;
    }
    if (footerY < 0)
      footerY = lastEnd < 0 ? Theme.launcherSearchHeight : lastEnd + Theme.launcherFooterGap;
    return {
      kind: kind,
      labels: labels,
      rows: rows,
      card: card,
      chips: chips,
      notice: notice,
      footerY: footerY
    };
  }

  // O foco do teclado: no campo de busca, ou, na página do seletor de cor (que não tem campo), na própria página.
  function focusCurrent() {
    if (plan.kind === "color")
      colorPage.forceActiveFocus(Qt.OtherFocusReason);
    else
      search.focusEditor();
  }

  function focusSearch() {
    focusCurrent();
  }

  function move(delta) {
    if (rowCount === 0)
      return;
    selected = Math.max(0, Math.min(rowCount - 1, selected + delta));
  }

  // ↓: da última linha (ou sem linha nenhuma) entra no primeiro chip; com um chip em foco não há mais para baixo.
  function moveDown() {
    if (chipIndex >= 0)
      return;
    if (chipCount > 0 && (rowCount === 0 || selected >= rowCount - 1))
      chipIndex = 0;
    else
      move(1);
  }

  // ↑: do chip volta para a última linha (a de onde ele entrou); sem chip, sobe uma linha.
  function moveUp() {
    if (chipIndex >= 0)
      chipIndex = -1;
    else
      move(-1);
  }

  // ← e →: só andam com um chip em foco, e param nas pontas.
  function moveChip(delta) {
    if (chipIndex < 0)
      return;
    chipIndex = Math.max(0, Math.min(chipCount - 1, chipIndex + delta));
  }

  function activateIndex(index) {
    const entry = plan.rows[index];
    if (entry)
      service.activate(entry.row);
  }

  function openChip(index) {
    if (plan.chips && plan.chips.items[index])
      service.openTool(plan.chips.items[index].key);
  }

  // Enter: o chip em foco, se houver; senão a linha selecionada.
  function activateCurrent() {
    if (chipIndex >= 0)
      openChip(chipIndex);
    else
      activateIndex(selected);
  }

  // Rola só o necessário para que o trecho [top, bottom] (no quadro) fique à vista.
  function reveal(top, bottom) {
    top -= listTop;
    bottom -= listTop;
    if (top < list.contentY)
      list.contentY = Math.max(0, top);
    else if (bottom > list.contentY + list.height)
      list.contentY = bottom - list.height;
  }

  // Mantém a selecionada à vista: com a primeira linha de um grupo, mostra o rótulo junto. Com um chip em foco,
  // mostra a seção "Tools" inteira.
  function ensureVisible() {
    // Cabendo tudo, não há o que rolar (e a lista ainda pode estar sem altura na criação).
    if (list.contentHeight <= list.height) {
      list.contentY = 0;
      return;
    }
    if (chipIndex >= 0 && plan.chips) {
      reveal(plan.chips.y - Theme.launcherChipsGap - Theme.launcherLabelHeight,
          plan.chips.y + Theme.launcherChipHeight + Theme.launcherChipsFooterGap);
      return;
    }
    const entry = plan.rows[selected];
    if (!entry)
      return;
    reveal(selected === 0 ? listTop : (entry.first ? entry.labelY : entry.y),
        entry.y + Theme.launcherResultHeight + (selected === rowCount - 1 ? Theme.launcherFooterGap : 0));
  }

  onSelectedChanged: ensureVisible()
  onChipIndexChanged: ensureVisible()
  onRowCountChanged: {
    if (selected > rowCount - 1)
      selected = Math.max(0, rowCount - 1);
  }
  // Se as ferramentas somem ou diminuem, o foco não fica num chip que não existe.
  onChipCountChanged: {
    if (chipIndex > chipCount - 1)
      chipIndex = chipCount - 1;
  }

  Connections {
    target: root.service
    // Texto novo, seleção na primeira linha e nenhum chip em foco.
    function onQueryChanged() {
      root.selected = 0;
      root.chipIndex = -1;
      list.contentY = 0;
    }
    // Entrar na página ou voltar dela: o campo some ou volta, e o foco acompanha (depois que a cena se refaz).
    function onPageChanged() {
      Qt.callLater(root.focusCurrent);
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
      visible: root.plan.kind !== "color"
      width: parent.width
      text: root.service.query
      // Sem sugestão fantasma no modo cálculo.
      ghost: root.service.calculation ? "" : root.service.ghost
      iconName: root.service.searchIcon
      forceCursor: root.forceCursor
      captureHorizontal: root.chipIndex >= 0
      contextLabel: root.service.contextLabel
      onEdited: text => root.service.setQuery(text)
      onUpPressed: root.moveUp()
      onDownPressed: root.moveDown()
      onLeftPressed: root.moveChip(-1)
      onRightPressed: root.moveChip(1)
      onAccepted: root.activateCurrent()
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
      visible: root.plan.kind !== "color"
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

      Launcher.NoResult {
        visible: root.plan.notice !== null
        y: root.plan.notice ? root.plan.notice.y - root.listTop : 0
        width: parent.width
        query: root.plan.notice ? root.plan.notice.query : ""
      }

      Launcher.ChipRow {
        visible: root.plan.chips !== null
        x: Theme.launcherChipsX
        y: root.plan.chips ? root.plan.chips.y - root.listTop : 0
        model: root.plan.chips ? root.plan.chips.items : []
        selectedIndex: root.chipIndex
        hoverIndex: root.chipHoverIndex
        onActivated: key => root.service.openTool(key)
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
          selected: index === root.selected && root.chipIndex < 0
          forceHovered: index === root.hoverIndex
          onClicked: root.activateIndex(index)
        }
      }
    }

    Launcher.ColorPage {
      id: colorPage
      visible: root.plan.kind === "color"
      width: parent.width
      height: Theme.launcherColorFooterY
      service: root.service
      historyHoverIndex: root.historyHoverIndex
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
