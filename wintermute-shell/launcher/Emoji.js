.pragma library
.import "Search.js" as Search

// Seletor de emoji do launcher (ficha 16; P-14 e a proposta da P-79). Biblioteca pura: lê o
// inventário gerado por emoji/build.py, monta as seções da grade, casa a busca nas duas línguas, faz a conta das
// fileiras e da navegação por fileira e coluna e cuida da lista de recentes. Não toca em Quickshell nem em arquivo;
// quem lê o emoji.json e o arquivo dos recentes é o State.qml (e o serviço fictício da vitrine). Os testes exercitam
// estas funções com o inventário de verdade.
//
// Os números de medida (célula, passo, folgas) não moram aqui: chegam em `metrics`, tirados do Theme.qml.

// Quantos emojis os recentes guardam: uma fileira da grade, como no board.
var RECENTS_KEPT = 11;

// As seções da grade, na ordem em que aparecem. `group` é o grupo do Unicode (o nome em emoji.json); `tab` é a aba
// que leva a ela. O Unicode tem nove grupos e o board seis abas, então algumas abas levam a duas seções.
var SECTIONS = [
  { key: "recent", label: "Recent", group: "", tab: 0 },
  { key: "smileys", label: "Smileys & emotion", group: "Smileys & Emotion", tab: 1 },
  { key: "people", label: "People & body", group: "People & Body", tab: 1 },
  { key: "animals", label: "Animals & nature", group: "Animals & Nature", tab: 2 },
  { key: "food", label: "Food & drink", group: "Food & Drink", tab: 2 },
  { key: "activities", label: "Activities", group: "Activities", tab: 3 },
  { key: "objects", label: "Objects", group: "Objects", tab: 3 },
  { key: "travel", label: "Travel & places", group: "Travel & Places", tab: 4 },
  { key: "flags", label: "Flags", group: "Flags", tab: 4 },
  { key: "symbols", label: "Symbols", group: "Symbols", tab: 5 }
];

// As seis abas do board, da esquerda para a direita (13:17559 a 13:17569). `icon` é o nome em icons/.
var TABS = [
  { icon: "clock", name: "Recent" },
  { icon: "smile", name: "Smileys & people" },
  { icon: "leaf", name: "Animals & food" },
  { icon: "gamepad-2", name: "Activities & objects" },
  { icon: "globe", name: "Travel & flags" },
  { icon: "hash", name: "Symbols" }
];

// ---- Inventário ----

// Lê o texto do emoji.json. Devolve { version, cldr, items, index, byGroup } ou null se o arquivo não presta. Cada item é
// { ch, group, name, namePt, nameN, namePtN, keywordsN, keywordsPtN }: os campos terminados em N já estão normalizados
// (sem acento nem maiúsculas) para a busca, que roda a cada tecla. `index` leva o caractere ao número do item.
function parse(text) {
  let raw = null;
  try {
    raw = JSON.parse(String(text || ""));
  } catch (error) {
    return null;
  }
  if (!raw || !Array.isArray(raw.items) || !Array.isArray(raw.groups))
    return null;
  const items = [];
  const index = {};
  const byGroup = {};
  for (let i = 0; i < raw.items.length; ++i) {
    const row = raw.items[i];
    if (!Array.isArray(row) || row.length < 6 || typeof row[0] !== "string" || raw.groups[row[1]] === undefined)
      return null;
    const group = raw.groups[row[1]];
    items.push({
      ch: row[0],
      group: group,
      name: row[2],
      namePt: row[3],
      nameN: Search.normalize(row[2]),
      namePtN: Search.normalize(row[3]),
      // Uma palavra-chave por linha: o trecho buscado não tem quebra de linha, então não casa atravessando duas.
      keywordsN: Search.normalize(row[4].join("\n")),
      keywordsPtN: Search.normalize(row[5].join("\n"))
    });
    index[row[0]] = i;
    if (!byGroup[group])
      byGroup[group] = [];
    byGroup[group].push(i);
  }
  return { version: String(raw.emoji || ""), cldr: String(raw.cldr || ""), items: items, index: index, byGroup: byGroup };
}

// O nome que o rodapé mostra: o nome do CLDR em inglês com a primeira letra maiúscula (decisão 0012).
function displayName(item) {
  if (!item)
    return "";
  const name = String(item.name || "");
  return name.charAt(0).toUpperCase() + name.slice(1);
}

// ---- Recentes ----

// Lê o arquivo dos recentes: uma lista de emojis (o caractere), o mais novo primeiro. Ausente, estragado ou fora do
// formato vale como lista vazia, e o que não está no inventário é pulado.
function parseRecents(text, data) {
  const ids = Search.parseRecents(text, 1000);
  const known = [];
  ids.forEach(ch => {
    if (data && data.index[ch] !== undefined)
      known.push(ch);
  });
  return known.slice(0, RECENTS_KEPT);
}

function pushRecent(list, ch) {
  return Search.pushRecent(list, ch, RECENTS_KEPT);
}

function serializeRecents(list) {
  return Search.serializeRecents(list);
}

// ---- Seções ----

function section(spec, items) {
  return { key: spec.key, label: spec.label, tab: spec.tab, items: items };
}

// O texto é o começo de uma palavra de `text` (os dois já normalizados). As palavras-chave vêm uma por linha.
var WORD_BREAKS = " \n\t-_.,:;()/'’“”";

function startsWord(needle, text) {
  for (let at = text.indexOf(needle); at >= 0; at = text.indexOf(needle, at + 1)) {
    if (at === 0 || WORD_BREAKS.indexOf(text.charAt(at - 1)) >= 0)
      return true;
  }
  return false;
}

// As seções da grade para o texto da busca. Sem texto: "Recent" (se houver) e os grupos, na ordem de SECTIONS.
// Com texto: "Results for “texto” (N)", com os que casam no nome (em qualquer das duas línguas), na ordem prefixo do
// nome, prefixo de palavra e depois a ordem do Unicode, e "Related", com os que casam só nas palavras-chave, na ordem do
// Unicode. Só vale o começo de palavra: um trecho no meio dela não casa, senão "cat" traria o abacate ("avocado") e o
// crachá ("identification card"). Seção vazia não aparece. `recents` é a lista de caracteres.
function buildSections(data, query, recents) {
  if (!data)
    return [];
  const text = String(query === undefined || query === null ? "" : query).trim();
  if (text === "") {
    const list = [];
    const recentItems = [];
    (recents || []).forEach(ch => {
      if (data.index[ch] !== undefined)
        recentItems.push(data.index[ch]);
    });
    SECTIONS.forEach(spec => {
      const items = spec.key === "recent" ? recentItems : (data.byGroup[spec.group] || []);
      if (items.length > 0)
        list.push(section(spec, items));
    });
    return list;
  }
  const needle = Search.normalize(text);
  const named = [];
  const related = [];
  for (let i = 0; i < data.items.length; ++i) {
    const item = data.items[i];
    const score = Math.max(Search.titleScore(needle, item.nameN), Search.titleScore(needle, item.namePtN));
    if (score >= Search.SCORE_WORD_PREFIX)
      named.push({ index: i, score: score });
    else if (startsWord(needle, item.keywordsN) || startsWord(needle, item.keywordsPtN))
      related.push(i);
  }
  // Nota maior primeiro; no empate, a ordem do Unicode (a do inventário).
  named.sort((a, b) => a.score !== b.score ? b.score - a.score : a.index - b.index);
  const list = [];
  if (named.length > 0) {
    list.push({
      key: "results",
      label: "Results for “" + text + "” (" + named.length + ")",
      tab: -1,
      items: named.map(entry => entry.index)
    });
  }
  if (related.length > 0)
    list.push({ key: "related", label: "Related", tab: -1, items: related });
  return list;
}

// ---- Fileiras e coordenadas ----

// Monta a lista de fileiras da grade e o que a navegação precisa. `metrics`:
//   perRow       células por fileira (11)
//   cell, step   lado da célula (48) e passo (52)
//   labelHeight  altura da caixa do rótulo (24)
//   topPad       folga entre o topo da área rolável e o primeiro rótulo
//   sectionGap   folga entre a última fileira de uma seção e o rótulo da seguinte (8)
//   endGap       folga depois da última fileira (20)
// Devolve:
//   rows      { kind: "label", y, height, text } ou { kind: "cells", y, height, first, count } (`first` é o número da
//             primeira célula da fileira, entre todas as células da lista)
//   cells     o número do item (em data.items) de cada célula, na ordem em que aparecem; o mesmo emoji pode aparecer
//             duas vezes (nos recentes e na categoria dele), e cada lugar é uma célula
//   cellRow   o número, em `rows`, da fileira de cada célula
//   cellRows  os números, em `rows`, das fileiras de células, na ordem
//   sections  { key, label, tab, row (do rótulo), y (do rótulo), scrollY (a rolagem que põe o rótulo na posição do
//             primeiro), firstCell }
//   height    a altura total do conteúdo
function layout(sections, metrics) {
  const rows = [];
  const cells = [];
  const cellRow = [];
  const cellRows = [];
  const info = [];
  let y = metrics.topPad;
  (sections || []).forEach((entry, s) => {
    if (s > 0)
      y += metrics.sectionGap;
    info.push({
      key: entry.key,
      label: entry.label,
      tab: entry.tab,
      row: rows.length,
      y: y,
      scrollY: y - metrics.topPad,
      firstCell: cells.length
    });
    rows.push({ kind: "label", y: y, height: metrics.labelHeight, text: entry.label, first: 0, count: 0 });
    y += metrics.labelHeight;
    const list = entry.items;
    for (let start = 0; start < list.length; start += metrics.perRow) {
      const count = Math.min(metrics.perRow, list.length - start);
      const rowIndex = rows.length;
      rows.push({ kind: "cells", y: y, height: metrics.cell, first: cells.length, count: count, text: "" });
      cellRows.push(rowIndex);
      for (let c = 0; c < count; ++c) {
        cells.push(list[start + c]);
        cellRow.push(rowIndex);
      }
      y += metrics.cell;
      // O passo é maior que a célula: a folga entre fileiras só vale se vem outra depois.
      if (start + metrics.perRow < list.length)
        y += metrics.step - metrics.cell;
    }
  });
  return {
    rows: rows,
    cells: cells,
    cellRow: cellRow,
    cellRows: cellRows,
    sections: info,
    height: y + (rows.length > 0 ? metrics.endGap : 0)
  };
}

// A primeira fileira que termina depois de `y` (a que está no topo da área visível), por busca binária.
function rowAt(plan, y) {
  const rows = plan.rows;
  let low = 0;
  let high = rows.length - 1;
  if (high < 0)
    return -1;
  while (low < high) {
    const mid = (low + high) >> 1;
    if (rows[mid].y + rows[mid].height <= y)
      low = mid + 1;
    else
      high = mid;
  }
  return low;
}

// A célula sob o ponto (x, y) do conteúdo, ou -1 (nas folgas entre as células, nos rótulos e fora da lista).
function cellAt(plan, x, y, metrics) {
  const row = rowAt(plan, y);
  if (row < 0 || plan.rows[row].kind !== "cells")
    return -1;
  const entry = plan.rows[row];
  if (y < entry.y || y >= entry.y + entry.height)
    return -1;
  const offset = x - metrics.gridX;
  if (offset < 0)
    return -1;
  const column = Math.floor(offset / metrics.step);
  if (column >= entry.count || offset - column * metrics.step >= metrics.cell)
    return -1;
  return entry.first + column;
}

// ---- Seleção ----

// A coluna da célula na fileira dela.
function columnOf(plan, cell) {
  const row = plan.rows[plan.cellRow[cell]];
  return row ? cell - row.first : 0;
}

// Anda a seleção. `key` é "left", "right", "up" ou "down"; `wanted` é a coluna que a seleção queria manter nas setas
// verticais (uma fileira mais curta a limita, mas a coluna de antes volta na fileira seguinte). ← e → passam para a
// fileira vizinha nas pontas, atravessando as seções; ↑ e ↓ andam uma fileira de células. Nas pontas da lista fica onde
// está. Devolve { index, column }: a nova célula e a coluna a lembrar.
function move(plan, index, key, wanted) {
  const total = plan.cells.length;
  if (total === 0)
    return { index: -1, column: 0 };
  let current = Math.max(0, Math.min(total - 1, index));
  if (key === "left" || key === "right") {
    current = Math.max(0, Math.min(total - 1, current + (key === "left" ? -1 : 1)));
    return { index: current, column: columnOf(plan, current) };
  }
  let ordinal = plan.cellRows.indexOf(plan.cellRow[current]);
  ordinal += key === "up" ? -1 : 1;
  if (ordinal < 0 || ordinal >= plan.cellRows.length)
    return { index: current, column: wanted };
  const target = plan.rows[plan.cellRows[ordinal]];
  return { index: target.first + Math.min(wanted, target.count - 1), column: wanted };
}

// A seção a que a célula pertence (o número em `plan.sections`).
function sectionOfCell(plan, cell) {
  let found = 0;
  for (let i = 0; i < plan.sections.length; ++i) {
    if (plan.sections[i].firstCell <= cell)
      found = i;
  }
  return found;
}

// ---- Abas ----

// A aba ativa para a rolagem `scrollY`: a da última seção cujo começo já chegou ao topo da área visível. -1 se não há
// seção (a busca não tem abas ativas: as seções dela têm `tab` -1).
function activeTab(plan, scrollY) {
  let tab = -1;
  for (let i = 0; i < plan.sections.length; ++i) {
    if (plan.sections[i].scrollY <= scrollY + 0.5)
      tab = plan.sections[i].tab;
  }
  return tab;
}

// A primeira seção de uma aba (o número em `plan.sections`), ou -1 se a aba não tem seção (a dos recentes, sem recentes).
function sectionOfTab(plan, tab) {
  for (let i = 0; i < plan.sections.length; ++i) {
    if (plan.sections[i].tab === tab)
      return i;
  }
  return -1;
}

// A aba seguinte ou a anterior a `tab` que tem seção, ou -1 se não há (nas pontas a aba não anda).
function neighbourTab(plan, tab, delta) {
  for (let t = tab + delta; t >= 0 && t < TABS.length; t += delta) {
    if (sectionOfTab(plan, t) >= 0)
      return t;
  }
  return -1;
}
