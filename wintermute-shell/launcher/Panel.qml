pragma ComponentBehavior: Bound

import QtQuick
import "." as Launcher
import "../clipboard" as Clipboard
import ".."

// O launcher (ficha 14): vidro de 640, cabeçalho de busca, lista por seções que rola entre o cabeçalho e o
// rodapé, e rodapé com o modo e as ações. `service` é a fonte de tudo (query, sugestão, seções, ações); a
// vitrine troca por um serviço fictício. A seleção mora aqui.
//
// Medidas no quadro do launcher: o primeiro rótulo em y 64, cada linha de 44 logo abaixo do rótulo, o rótulo
// seguinte 8 abaixo da última linha do grupo e o divisor do rodapé 4 abaixo da última linha (P-68).
//
// Oito formas. A página do seletor de cor (`service.page`, F5-T08) tira a busca e a lista de cena e vale por si, e a do
// seletor de emoji (F5-T09) e a do histórico da área de transferência (F6-T05) também; a do menu de ações (F5-T05) tira só a busca; as outras quatro são escolhidas pelo
// texto da busca (`plan.kind`):
//   color  `service.page === "color"`: o cabeçalho de busca vira voltar e título, o corpo é o resultado do seletor de cor
//          (ColorPage.qml) e o divisor do rodapé fica fixo em y 432, com 476 de altura no total, sem rolar.
//   emoji  `service.page === "emoji"`: o cabeçalho com voltar e o campo "Search emoji", as seis abas e a grade que rola
//          (EmojiPage.qml), com o divisor do rodapé fixo em y 392, 436 de altura no total. O rodapé troca o modo pela prévia
//          do emoji e pelo nome dele.
//   clipboard `service.page === "clipboard"` (o chip "Clipboard"): o cabeçalho com o ícone `clipboard` e o campo "Search history", a
//          lista de 280 à esquerda, a prévia e os metadados à direita, ou o vazio (ClipboardPage.qml, com os dados de
//          `clipboardService`), com o divisor do rodapé fixo em y 392, 436 de altura no total. As ações do rodapé são da página.
//   actions `service.page === "actions"` (Ctrl+K numa linha, ou na página do histórico): o cabeçalho de busca vira voltar e o nome do item
//          (ActionsHeader.qml) e a lista é a de `service.actionSections`, com o rótulo em y 64, uma linha por ação a partir
//          de y 88 e o divisor do rodapé 4 abaixo da última, como em toda lista. ↑↓ andam, Enter roda, Esc, Backspace, o
//          botão de voltar e Ctrl+K voltam à busca com o texto e a seleção de antes (guardados em `savedSelection`).
//   calc   `service.calculation` não nulo: o launcher inteiro é o cálculo, com o rótulo "Calculator" em y 64, o
//          cartão de 128 logo abaixo e, 16 depois dele, as linhas de ação sem rótulo. As seções não aparecem.
//   empty  busca vazia: "Recent" (as linhas de `service.recents`) e "Tools" (a fila de chips de `service.tools`),
//          com o divisor do rodapé 16 abaixo dos chips.
//   none   há texto, não é cálculo e o serviço não achou nada: o bloco "Nothing found" e, 16 abaixo da dica, as
//          linhas de `service.fallbackRows` (sem rótulo). Sem elas o divisor do rodapé fica nos 16 da dica. Só vale com
//          a busca de arquivos terminada (`service.searching` falso); enquanto ela dura, sem nenhuma linha para mostrar,
//          a lista fica vazia em vez de piscar o aviso. A exceção é a busca profunda (F5-T11): o aviso que já estava na
//          tela fica até a resposta (`service.holdNotice`), para o launcher não piscar uma lista vazia entre o Enter em
//          "Search files" e o resultado.
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
  // Seletor de emoji, para fixar na vitrine: a célula selecionada, a célula sob o ponteiro (-1: o ponteiro de verdade) e a
  // aba cuja seção a grade mostra no começo (-1: no topo).
  property alias emojiSelected: emojiPage.selected
  property alias emojiHover: emojiPage.hoverIndex
  property alias emojiStartTab: emojiPage.startTab
  // O histórico da área de transferência (F6-T05): o serviço dele (o de verdade é clipboard/State.qml, e a vitrine troca por um
  // fictício), e, para fixar na vitrine, a linha selecionada, a linha sob o ponteiro e o texto da busca.
  property var clipboardService: Clipboard.State
  property alias clipboardSelected: clipboardPage.selected
  property alias clipboardHover: clipboardPage.hoverIndex
  property alias clipboardQuery: clipboardPage.query
  // Chip das ferramentas com o foco do teclado (índice em `service.tools`), ou -1. Para fixar na vitrine.
  property int chipIndex: -1
  // Chip sob o ponteiro, para fixar o hover na vitrine.
  property int chipHoverIndex: -1
  // Altura máxima do vidro; passando dela, a lista rola.
  property real maxHeight: 100000

  readonly property alias blurRegion: glass.blurRegion

  // Posições absolutas (no quadro) de cada rótulo e de cada linha, e do divisor do rodapé.
  readonly property var plan: buildPlan(service.page, service.sections, service.calculation,
      String(service.query).trim(), service.recents, service.tools, service.fallbackRows, service.searching,
      service.actionSections, service.holdNotice)
  readonly property int rowCount: plan.rows.length
  readonly property int chipCount: plan.chips ? plan.chips.items.length : 0
  readonly property real listTop: Theme.launcherSearchHeight + Theme.launcherDividerHeight
  // Sem lista, o divisor do rodapé é o próprio divisor do cabeçalho.
  // As páginas do seletor de cor (476), do de emoji (436) e do histórico da área de transferência (436) têm altura fixa: não
  // encolhem para caber, porque a rolagem delas é a da própria grade ou lista.
  readonly property real footerY: plan.kind === "color" || plan.kind === "emoji" || plan.kind === "clipboard" ? plan.footerY
      : Math.max(Theme.launcherSearchHeight, Math.min(plan.footerY, maxHeight - Theme.launcherFooterHeight))

  implicitWidth: Theme.launcherWidth
  implicitHeight: footerY + Theme.launcherFooterHeight
  width: implicitWidth
  height: implicitHeight

  function buildPlan(page, sections, calculation, query, recents, tools, fallbackRows, searching, actionSections, holdNotice) {
    if (page === "color") {
      return { kind: "color", labels: [], rows: [], card: null, chips: null, notice: null,
          footerY: Theme.launcherColorFooterY };
    }
    if (page === "emoji") {
      return { kind: "emoji", labels: [], rows: [], card: null, chips: null, notice: null,
          footerY: Theme.launcherEmojiFooterY };
    }
    if (page === "clipboard") {
      return { kind: "clipboard", labels: [], rows: [], card: null, chips: null, notice: null,
          footerY: Theme.clipboardFooterY };
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
    if (page === "actions") {
      // As ações do item entram como uma seção comum: rótulo em y 64 e as linhas a partir de y 88.
      kind = "actions";
      sections = actionSections;
    } else if (calculation) {
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
      // Sem linha e com a busca de arquivos em andamento, ainda não sei que não há nada: a lista fica vazia, a não ser que
      // o aviso já estivesse na tela (busca profunda), e então ele continua.
      if (!searching || holdNotice)
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

  // O foco do teclado: no campo de busca, ou, nas páginas sem campo (seletor de cor e ações), na própria página. A do emoji
  // e a do histórico da área de transferência têm o campo delas.
  function focusCurrent() {
    if (plan.kind === "color")
      colorPage.forceActiveFocus(Qt.OtherFocusReason);
    else if (plan.kind === "emoji")
      emojiPage.focusField();
    else if (plan.kind === "clipboard")
      clipboardPage.focusField();
    else if (plan.kind === "actions")
      actionsHeader.forceActiveFocus(Qt.OtherFocusReason);
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

  // Ctrl+K: as ações da linha selecionada. Com um chip em foco ou sem linha (a lista vazia, o "sem resultado" sem
  // ações) não faz nada, e o serviço também recusa a linha que não tem ação.
  function openActions() {
    if (chipIndex >= 0)
      return;
    const entry = plan.rows[selected];
    if (!entry)
      return;
    savedSelection[0] = { index: selected, key: rowIdentity(entry.row) };
    service.openActions(entry.row);
  }

  // A camada do menu que a seleção atual vale (0 a lista, 1 as ações, 2 os workspaces) e a seleção de cada camada que
  // deixei para trás: { index, key }, o índice e a identidade da linha (`rowIdentity`). Ao descer uma camada a primeira
  // ação entra selecionada; ao voltar, a linha de antes. Guardo a linha na hora do pedido (Ctrl+K, Enter ou clique), e
  // não quando a camada muda, porque o plano novo pode encolher a lista e empurrar a seleção antes de eu olhar.
  // `shownDepth` não é uma ligação com o serviço: ele só muda em `followDepth`, para eu ver a diferença.
  property int shownDepth: 0
  property var savedSelection: []
  // Entrei na busca profunda e a primeira resposta ainda não chegou (ver `onDeepFilesChanged`).
  property bool resetOnAnswer: false
  // A camada cuja seleção ainda estou repondo, ou -1. Ver `followDepth`.
  property int restoreDepth: -1
  Component.onCompleted: shownDepth = service.actionsDepth || 0

  // O que identifica uma linha de um plano para o outro: o alvo dela (tipo mais id, caminho, página ou ação), o texto de
  // `copy` na linha do cálculo, ou a ação do menu (mais o workspace, na segunda camada). "" se a linha não tem nada disso.
  function rowIdentity(row) {
    if (!row)
      return "";
    if (row.act)
      return "act:" + row.act + ":" + (row.workspaceId !== undefined ? row.workspaceId : "");
    if (row.copy !== undefined)
      return "copy:" + row.copy;
    const target = row.target;
    if (!target)
      return "";
    if (target.type === "app")
      return "app:" + target.id;
    if (target.type === "file")
      return "file:" + target.path;
    if (target.type === "setting")
      return "setting:" + target.page;
    if (target.type === "command")
      return "command:" + target.action;
    return "";
  }

  // Seleciona a linha guardada da camada que estou repondo. A seleção segue a linha, e não o índice: se a lista mudou
  // enquanto o menu estava aberto (a resposta do `fd` que chegou nesse meio-tempo, um recente que removi), procuro a
  // linha onde ela está agora. Se ela não existe mais, vale o índice de antes, limitado à última linha.
  function applyRestore() {
    if (restoreDepth < 0)
      return;
    // Ao voltar para a lista o plano pode ainda ser o do menu; o `onPlanChanged` repõe quando ele chegar.
    if (restoreDepth === 0 && plan.kind === "actions")
      return;
    const saved = savedSelection[restoreDepth] || { index: 0, key: "" };
    const found = saved.key === "" ? -1 : plan.rows.findIndex(entry => rowIdentity(entry.row) === saved.key);
    selected = found >= 0 ? found : Math.max(0, Math.min(saved.index, rowCount - 1));
  }

  // A volta de uma camada acontece em passos seguidos (o serviço troca a página, depois publica a lista, que pode ter
  // outro tamanho), e o plano se refaz entre eles. Por isso repor a seleção não é um ajuste único: aplico agora, de novo a
  // cada plano novo e uma última vez no turno seguinte, quando tudo já assentou.
  function followDepth() {
    const depth = service.actionsDepth || 0;
    if (depth === shownDepth)
      return;
    const descending = depth > shownDepth;
    shownDepth = depth;
    if (descending) {
      restoreDepth = -1;
      selected = 0;
    } else {
      restoreDepth = depth;
      applyRestore();
      Qt.callLater(finishRestore);
    }
    // O plano novo ainda não tem a altura nova; o ajuste de rolagem espera o turno seguinte.
    Qt.callLater(ensureVisible);
  }

  function finishRestore() {
    applyRestore();
    restoreDepth = -1;
  }

  function activateIndex(index) {
    const entry = plan.rows[index];
    if (!entry)
      return;
    // Dentro do menu, "Open on workspace…" desce uma camada: a volta cai na linha que o pedi.
    if (shownDepth > 0)
      savedSelection[shownDepth] = { index: index, key: rowIdentity(entry.row) };
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

  // Avisa o serviço qual linha está selecionada (nenhuma, com um chip em foco): mudar a seleção desarma o comando
  // perigoso que esperava a confirmação. Também quando o plano se refaz, porque a linha selecionada pode ter mudado.
  function reportSelection() {
    if (!service.selectRow)
      return;
    const entry = chipIndex < 0 ? plan.rows[selected] : null;
    service.selectRow(entry ? entry.row : null);
  }

  onSelectedChanged: {
    ensureVisible();
    reportSelection();
  }
  onChipIndexChanged: {
    ensureVisible();
    reportSelection();
  }
  onPlanChanged: {
    applyRestore();
    reportSelection();
  }
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
    // Entrei na busca profunda: a seleção volta à primeira linha quando a resposta chega, e não antes, porque até lá o
    // "Nothing found" segurado ainda mostra "Search files" selecionada.
    function onDeepFilesChanged() {
      root.resetOnAnswer = root.service.deepFiles;
    }
    function onSearchingChanged() {
      if (root.resetOnAnswer && !root.service.searching) {
        root.resetOnAnswer = false;
        root.selected = 0;
        list.contentY = 0;
      }
    }
    // Entrar na página ou voltar dela: o campo some ou volta, e o foco acompanha (depois que a cena se refaz).
    function onPageChanged() {
      Qt.callLater(root.focusCurrent);
    }
    // Entrar no menu, descer para os workspaces ou voltar: a seleção acompanha.
    function onActionsDepthChanged() {
      root.followDepth();
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
      visible: root.plan.kind !== "color" && root.plan.kind !== "actions" && root.plan.kind !== "emoji"
          && root.plan.kind !== "clipboard"
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
      onActionsPressed: root.openActions()
      onTabPressed: {
        root.service.acceptGhost();
        search.moveCursorToEnd();
      }
    }

    Launcher.ActionsHeader {
      id: actionsHeader
      visible: root.plan.kind === "actions"
      width: parent.width
      title: root.service.actionsTitle || ""
      onUpPressed: root.moveUp()
      onDownPressed: root.moveDown()
      onAccepted: root.activateCurrent()
      onBackRequested: root.service.backActions()
      onMenuRequested: root.service.closeActions()
    }

    Rectangle {
      y: Theme.launcherSearchHeight
      width: parent.width
      height: Theme.launcherDividerHeight
      color: Theme.border
    }

    Flickable {
      id: list
      visible: root.plan.kind !== "color" && root.plan.kind !== "emoji" && root.plan.kind !== "clipboard"
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
          // O clique também seleciona a linha: depois do primeiro clique num comando perigoso, o Enter vale para ele.
          onClicked: {
            root.selected = index;
            root.activateIndex(index);
          }
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

    Launcher.EmojiPage {
      id: emojiPage
      visible: root.plan.kind === "emoji"
      width: parent.width
      height: Theme.launcherEmojiFooterY
      service: root.service
      forceCursor: root.forceCursor
    }

    Clipboard.ClipboardPage {
      id: clipboardPage
      visible: root.plan.kind === "clipboard"
      width: parent.width
      height: Theme.clipboardFooterY
      service: root.clipboardService
      launcher: root.service
      forceCursor: root.forceCursor
    }

    Launcher.Footer {
      y: root.footerY
      width: parent.width
      modeIcon: root.service.modeIcon
      modeLabel: root.service.modeLabel
      actions: root.plan.kind === "clipboard" ? clipboardPage.footerActions : root.service.actions
      previewMode: root.plan.kind === "emoji"
      previewGlyph: emojiPage.previewGlyph
      previewName: emojiPage.previewName
    }
  }
}
