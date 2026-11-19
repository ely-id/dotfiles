// Testes do seletor de emoji do launcher: wintermute-shell/launcher/Emoji.js (importa o launcher/Search.js, e o script copia os dois).
// Os casos saem da ficha 16 (seção "Como funciona", F5-T09, P-14 e P-79) e das medidas do Figma que ela confere.
//   .agents/scripts/testar.sh emoji
//
// O inventário de verdade (emoji.json, 1.914 emojis) não entra: uso um pequeno, no mesmo formato, com os emojis que cada caso precisa,
// inclusive os dois que a ficha cita como armadilha da busca ("avocado" e "identification card" para "cat").
.import "apoio.js" as T
.import "launcher/Emoji.js" as E

const test = T.test, equal = T.equal, check = T.check;

const GROUPS = ["Smileys & Emotion", "People & Body", "Animals & Nature", "Food & Drink", "Travel & Places", "Activities", "Objects", "Symbols", "Flags"];
// [caractere, grupo, nome, nome em português, palavras-chave, palavras-chave em português]
const ITEMS = [
  ["😀", 0, "grinning face", "rosto risonho", ["cheerful", "face", "grin", "happy", "smile"], ["feliz", "rindo", "rosto", "sorridente"]],
  ["🙀", 0, "weary cat", "gato cansado", ["cat", "face", "oh", "surprised", "weary"], ["cansado", "gato", "rosto"]],
  ["👋", 1, "waving hand", "mão acenando", ["hand", "hello", "hi", "wave", "waving"], ["acenando", "mão", "olá", "tchau"]],
  ["🐱", 2, "cat face", "rosto de gato", ["animal", "cat", "kitten", "pet"], ["animal", "felino", "gato", "gatinho"]],
  ["🐈", 2, "cat", "gato", ["animal", "cats", "kitten", "pet"], ["animal", "felino", "gato"]],
  ["🐯", 2, "tiger face", "rosto de tigre", ["big cat", "predator", "tiger"], ["felino", "gato grande", "tigre"]],
  ["🥑", 3, "avocado", "abacate", ["avocado", "food", "fruit"], ["abacate", "comida", "fruta"]],
  ["✈", 4, "airplane", "avião", ["aeroplane", "plane"], ["avião"]],
  ["⚽", 5, "soccer ball", "bola de futebol", ["ball", "football", "soccer"], ["bola", "futebol"]],
  ["💡", 6, "light bulb", "lâmpada", ["bulb", "idea", "light"], ["ideia", "lâmpada", "luz"]],
  ["❤", 7, "red heart", "coração vermelho", ["heart", "love"], ["amor", "coração"]],
  ["🏁", 8, "chequered flag", "bandeira quadriculada", ["checkered", "finish", "flag"], ["bandeira", "chegada"]],
  ["🪪", 6, "identification card", "cartão de identificação", ["card", "credentials", "identification", "id"], ["carta", "cartão", "crachá", "identidade"]]
];
const inventory = (items) => JSON.stringify({ emoji: "17.0", cldr: "48", groups: GROUPS, items: items || ITEMS });
const data = E.parse(inventory());
const at = (ch) => data.index[ch];
const chars = (section) => section.items.map((i) => data.items[i].ch);

// ---- o inventário ----

test("parse lê a versão, o CLDR, os itens, o índice por caractere e os índices por grupo", () => {
  equal([data.version, data.cldr, data.items.length], ["17.0", "48", 13]);
  equal(data.index["🐱"], 3);
  equal(data.byGroup["Animals & Nature"], [3, 4, 5]);
  equal(data.byGroup["Objects"], [9, 12]);
  equal(data.byGroup["Smileys & Emotion"], [0, 1]);
});

test("os campos de busca saem normalizados: sem acento e em minúsculas, uma palavra-chave por linha", () => {
  const wave = data.items[2];
  equal([wave.ch, wave.group, wave.name, wave.namePt], ["👋", "People & Body", "waving hand", "mão acenando"], "os originais ficam");
  equal([wave.nameN, wave.namePtN], ["waving hand", "mao acenando"]);
  equal(wave.keywordsN, "hand\nhello\nhi\nwave\nwaving");
  equal(wave.keywordsPtN, "acenando\nmao\nola\ntchau");
});

test("inventário estragado dá null: texto que não é JSON, sem itens, sem grupos, linha curta ou grupo que não existe", () => {
  equal(E.parse(""), null);
  equal(E.parse("isto não é JSON"), null);
  equal(E.parse("null"), null);
  equal(E.parse(JSON.stringify({ items: [] })), null);
  equal(E.parse(JSON.stringify({ groups: GROUPS })), null);
  equal(E.parse(inventory([["😀", 0, "grinning face"]])), null);
  equal(E.parse(inventory([["😀", 99, "grinning face", "rosto risonho", [], []]])), null);
  equal(E.parse(inventory([[7, 0, "grinning face", "rosto risonho", [], []]])), null);
});

test("o nome do rodapé é o do CLDR em inglês, com a primeira letra maiúscula", () => {
  equal(E.displayName(data.items[2]), "Waving hand");   // "Mão acenando" no board
  equal(E.displayName({ name: "cat" }), "Cat");
  equal(E.displayName(null), "");
  equal(E.displayName({ name: "" }), "");
});

test("as seis abas do board, com os ícones da ficha", () => {
  equal(E.TABS.map((tab) => tab.icon), ["clock", "smile", "leaf", "gamepad-2", "globe", "hash"]);
});

// ---- a grade sem busca ----

test("sem busca, as seções vêm na ordem das abas, e os nove grupos do Unicode viram dez seções com a dos recentes", () => {
  const sections = E.buildSections(data, "", ["🐱"]);
  equal(sections.map((s) => s.label), [
    "Recent", "Smileys & emotion", "People & body", "Animals & nature", "Food & drink",
    "Activities", "Objects", "Travel & places", "Flags", "Symbols"
  ]);
  equal(sections.map((s) => s.tab), [0, 1, 1, 2, 2, 3, 3, 4, 4, 5], "a aba que leva a cada seção");
});

test("sem recentes a seção Recent não aparece e a lista começa em Smileys & emotion", () => {
  const sections = E.buildSections(data, "", []);
  equal(sections[0].label, "Smileys & emotion");
  equal(sections.length, 9);
  equal(E.buildSections(data, "   ", undefined)[0].label, "Smileys & emotion", "busca só com espaço é busca vazia");
});

test("os recentes mostram os que estão no inventário, na ordem; o que não existe é pulado", () => {
  const sections = E.buildSections(data, "", ["🐈", "❓", "😀"]);
  equal(sections[0].label, "Recent");
  equal(chars(sections[0]), ["🐈", "😀"]);
});

test("grupo sem emoji não vira seção", () => {
  const small = E.parse(inventory([ITEMS[0], ITEMS[3]]));
  equal(E.buildSections(small, "", []).map((s) => s.label), ["Smileys & emotion", "Animals & nature"]);
  equal(E.buildSections(null, "", []), []);
});

// ---- a busca ----

test("a busca por nome em inglês: 'Results for “cat” (3)', primeiro os que começam pelo texto", () => {
  const sections = E.buildSections(data, "cat", []);
  equal(sections[0].label, "Results for “cat” (3)");
  // 🐱 e 🐈 começam por "cat"; 🙀 tem "cat" no começo da segunda palavra e vem depois, mesmo com o número menor no Unicode
  equal(chars(sections[0]), ["🐱", "🐈", "🙀"]);
});

test("a busca por nome em português: 'gato' acha pelo nome, e o empate segue a ordem do Unicode", () => {
  const sections = E.buildSections(data, "gato", []);
  equal(sections[0].label, "Results for “gato” (3)");   // o board: "Resultados para “gato” (6)"
  equal(chars(sections[0]), ["🙀", "🐈", "🐱"], "gato cansado e gato começam pelo texto; rosto de gato, no meio");
});

test("'Related' traz os que só casam nas palavras-chave, na ordem do Unicode", () => {
  const cat = E.buildSections(data, "cat", []);
  equal(cat[1].label, "Related");
  equal(chars(cat[1]), ["🐯"], "'big cat' nas palavras-chave");
  const gato = E.buildSections(data, "gato", []);
  equal(chars(gato[1]), ["🐯"], "'gato grande' nas palavras-chave em português");
});

test("só o começo de palavra vale: 'cat' não traz o abacate nem o crachá", () => {
  const all = [].concat.apply([], E.buildSections(data, "cat", []).map(chars));
  check(all.indexOf("🥑") < 0, "o abacate ('abacate' tem cat no meio)");
  check(all.indexOf("🪪") < 0, "o crachá ('identification' tem cat no meio)");
  equal(E.buildSections(data, "ato", []), [], "'ato' está só no meio de 'gato'");
});

test("a busca não diferencia maiúsculas nem acentos, nas duas línguas", () => {
  equal(chars(E.buildSections(data, "mao", [])[0]), ["👋"]);
  equal(chars(E.buildSections(data, "MÃO", [])[0]), ["👋"]);
  equal(chars(E.buildSections(data, "LAMPADA", [])[0]), ["💡"]);
  equal(chars(E.buildSections(data, "aviao", [])[0]), ["✈"]);
  equal(chars(E.buildSections(data, "Soccer", [])[0]), ["⚽"]);
});

test("o texto que só está nas palavras-chave dá uma seção só, a Related", () => {
  const sections = E.buildSections(data, "olá", []);
  equal(sections.map((s) => s.label), ["Related"]);
  equal(chars(sections[0]), ["👋"]);
  equal(E.buildSections(data, "hel", []).map((s) => s.label), ["Related"], "'hello' começa por 'hel'");
});

test("o rótulo da busca leva o texto sem espaço nas pontas, como foi digitado, e a contagem", () => {
  equal(E.buildSections(data, "  Cat ", [])[0].label, "Results for “Cat” (3)");
  equal(E.buildSections(data, "soccer", [])[0].label, "Results for “soccer” (1)");
});

test("na busca as seções não têm aba (a barra de abas fica a 50% e sem ativa)", () => {
  E.buildSections(data, "cat", []).forEach((s) => equal(s.tab, -1, s.label));
});

test("sem nenhum resultado a lista é vazia (o 'Nothing found' ocupa a grade)", () => {
  equal(E.buildSections(data, "xyzzy", []), []);
});

// ---- recentes ----

test("o arquivo dos recentes: ausente ou estragado vale lista vazia, e o que não está no inventário é pulado", () => {
  equal(E.parseRecents('["🐱","🐈"]', data), ["🐱", "🐈"]);
  equal(E.parseRecents('["🐱","❓","🐈"]', data), ["🐱", "🐈"]);
  equal(E.parseRecents("", data), []);
  equal(E.parseRecents("não é JSON", data), []);
  equal(E.parseRecents('{"a":1}', data), []);
  equal(E.parseRecents('["🐱"]', null), [], "sem inventário nada é conhecido");
});

test("os recentes guardam os últimos 11, uma fileira da grade", () => {
  equal(E.RECENTS_KEPT, 11);
  const rows = [];
  const list = [];
  for (let i = 0; i < 15; ++i) {
    rows.push(["e" + i, 0, "emoji " + i, "emoji " + i, [], []]);
    list.push("e" + i);
  }
  const big = E.parse(inventory(rows));
  equal(E.parseRecents(JSON.stringify(list), big).length, 11);
  equal(E.pushRecent(list.slice(0, 11), "novo").length, 11);
  equal(E.pushRecent(list.slice(0, 11), "novo")[0], "novo");
  equal(E.pushRecent(list.slice(0, 11), "novo")[10], "e9", "o mais antigo saiu");
});

test("copiar um emoji o põe na frente, sem repetir", () => {
  equal(E.pushRecent(["🐱", "🐈", "😀"], "😀"), ["😀", "🐱", "🐈"]);
  equal(E.pushRecent([], "😀"), ["😀"]);
});

test("serializar os recentes dá JSON com recuo de 2 e quebra de linha no fim", () => {
  equal(E.serializeRecents(["🐱"]), '[\n  "🐱"\n]\n');
});

// ---- as fileiras: as medidas do board ----

// A grade rola entre y 109 e y 392, e o primeiro rótulo está em y 116 (ficha 16): são 7 de folga no topo. A ficha dá: células 48 com passo 52,
// 11 por fileira, rótulo de 24, 8 entre a última fileira e o rótulo seguinte, 20 depois da última fileira.
const METRICS = { perRow: 11, cell: 48, step: 52, labelHeight: 24, topPad: 7, sectionGap: 8, endGap: 20, gridX: 36 };
const range = (from, to) => { const out = []; for (let i = from; i < to; ++i) out.push(i); return out; };
const sec = (key, tab, items) => ({ key: key, label: key, tab: tab, items: items });

test("o layout do board: recentes em 116 e 140; a segunda seção em 196, com as fileiras em 220, 272 e 324", () => {
  const plan = E.layout([sec("recent", 0, range(0, 11)), sec("smileys", 1, range(11, 44))], METRICS);
  const top = 109;   // o topo da área rolável, no quadro do board
  equal(plan.rows.map((r) => [r.kind, r.y + top, r.height]), [
    ["label", 116, 24], ["cells", 140, 48],
    ["label", 196, 24], ["cells", 220, 48], ["cells", 272, 48], ["cells", 324, 48]
  ]);
  equal(plan.height, 283, "até y 392, que é o divisor do rodapé: a lista termina onde a área rolável termina");
});

test("o layout: as células, as fileiras de cada uma e as seções", () => {
  const plan = E.layout([sec("recent", 0, range(0, 11)), sec("smileys", 1, range(11, 44))], METRICS);
  equal(plan.cells, range(0, 44));
  equal([plan.cellRow[0], plan.cellRow[10], plan.cellRow[11], plan.cellRow[22], plan.cellRow[43]], [1, 1, 3, 4, 5]);
  equal(plan.cellRows, [1, 3, 4, 5]);
  equal(plan.rows[3], { kind: "cells", y: 111, height: 48, first: 11, count: 11, text: "" });
  equal(plan.sections, [
    { key: "recent", label: "recent", tab: 0, row: 0, y: 7, scrollY: 0, firstCell: 0 },
    { key: "smileys", label: "smileys", tab: 1, row: 2, y: 87, scrollY: 80, firstCell: 11 }
  ]);
});

test("a última fileira fica com o que sobrar, e o mesmo emoji pode ser duas células (recentes e categoria)", () => {
  const plan = E.layout([sec("recent", 0, [3, 4]), sec("animals", 2, [3, 4, 5])], METRICS);
  equal(plan.cells, [3, 4, 3, 4, 5]);
  equal(plan.rows.filter((r) => r.kind === "cells").map((r) => r.count), [2, 3]);
});

test("cada fileira de células traz o número da primeira célula", () => {
  const plan = E.layout([sec("a", 0, range(0, 25))], METRICS);
  equal(plan.rows.filter((r) => r.kind === "cells").map((r) => [r.first, r.count]), [[0, 11], [11, 11], [22, 3]]);
});

// ---- o que há sob o ponteiro ----

const plan2 = E.layout([sec("recent", 0, range(0, 11)), sec("smileys", 1, range(11, 24))], METRICS);   // a última fileira tem 2 células

test("a célula sob o ponto: 48 de lado, com passo de 52 a partir de x 36", () => {
  equal(E.cellAt(plan2, 36 + 10, 31 + 10, METRICS), 0);
  equal(E.cellAt(plan2, 36 + 52 + 1, 40, METRICS), 1);
  equal(E.cellAt(plan2, 36 + 52 * 10 + 47, 40, METRICS), 10, "o último pixel da última célula");
  equal(E.cellAt(plan2, 36, 31, METRICS), 0, "o primeiro pixel");
});

test("nas folgas entre as células, nos rótulos, antes da grade e depois da última coluna não há célula", () => {
  equal(E.cellAt(plan2, 36 + 48, 40, METRICS), -1, "a folga entre duas células");
  equal(E.cellAt(plan2, 35, 40, METRICS), -1, "antes do x 36");
  equal(E.cellAt(plan2, 36 + 52 * 11 + 5, 40, METRICS), -1, "depois da 11ª coluna");
  equal(E.cellAt(plan2, 40, 10, METRICS), -1, "no rótulo");
  equal(E.cellAt(plan2, 40, 111 + 48 + 2, METRICS), -1, "a folga entre duas fileiras");
  equal(E.cellAt(plan2, 40, 5000, METRICS), -1, "abaixo de tudo");
});

test("na fileira curta só as células que existem respondem", () => {
  const lastRowY = plan2.rows[plan2.rows.length - 1].y + 5;
  equal(E.cellAt(plan2, 36 + 5, lastRowY, METRICS), 22);
  equal(E.cellAt(plan2, 36 + 52 + 5, lastRowY, METRICS), 23);
  equal(E.cellAt(plan2, 36 + 104 + 5, lastRowY, METRICS), -1);
});

test("a primeira fileira que termina depois de y", () => {
  equal(E.rowAt(plan2, 0), 0);
  equal(E.rowAt(plan2, 7 + 24 - 1), 0, "ainda no rótulo");
  equal(E.rowAt(plan2, 31), 1);
  equal(E.rowAt(plan2, 79), 2, "a fileira de células termina em 79");
  equal(E.rowAt(E.layout([], METRICS), 10), -1);
});

// ---- a seleção pelo teclado ----

test("← e → andam uma célula, passam para a fileira vizinha nas pontas e param nas pontas da lista", () => {
  equal(E.move(plan2, 5, "right", 5), { index: 6, column: 6 });
  equal(E.move(plan2, 5, "left", 5), { index: 4, column: 4 });
  equal(E.move(plan2, 10, "right", 10), { index: 11, column: 0 }, "da ponta da primeira fileira para a seguinte, atravessando a seção");
  equal(E.move(plan2, 11, "left", 0), { index: 10, column: 10 });
  equal(E.move(plan2, 0, "left", 0), { index: 0, column: 0 });
  equal(E.move(plan2, 23, "right", 1), { index: 23, column: 1 });
});

test("↑ e ↓ andam uma fileira e mantêm a coluna, atravessando as seções", () => {
  equal(E.move(plan2, 5, "down", 5), { index: 16, column: 5 });
  equal(E.move(plan2, 16, "up", 5), { index: 5, column: 5 });
  equal(E.move(plan2, 16, "down", 5), { index: 23, column: 5 }, "a última fileira só tem 2 células: fica na última, e a coluna 5 é lembrada");
});

test("a fileira mais curta limita a coluna, mas a coluna de antes volta na fileira seguinte", () => {
  // de 20 (coluna 9 da segunda fileira da seção) para a fileira de 2 células: fica na última, e o 9 é lembrado
  const down = E.move(plan2, 20, "down", 9);
  equal(down, { index: 23, column: 9 });
  equal(E.move(plan2, down.index, "up", down.column), { index: 20, column: 9 });
});

test("nas pontas da lista ↑ e ↓ ficam onde estão", () => {
  equal(E.move(plan2, 5, "up", 5), { index: 5, column: 5 });
  equal(E.move(plan2, 23, "down", 1), { index: 23, column: 1 });
});

test("o índice fora da lista é preso a ela, e a lista vazia não tem seleção", () => {
  equal(E.move(plan2, 99, "left", 0).index, 22);
  equal(E.move(plan2, -5, "right", 0).index, 1);
  equal(E.move(E.layout([], METRICS), 0, "down", 0), { index: -1, column: 0 });
});

test("a coluna e a seção de uma célula", () => {
  equal([E.columnOf(plan2, 14), E.columnOf(plan2, 22), E.columnOf(plan2, 0)], [3, 0, 0]);
  equal([E.sectionOfCell(plan2, 0), E.sectionOfCell(plan2, 10), E.sectionOfCell(plan2, 11), E.sectionOfCell(plan2, 23)], [0, 0, 1, 1]);
});

// ---- as abas ----

test("a aba ativa é a da última seção cujo rótulo já chegou ao topo", () => {
  equal(E.activeTab(plan2, 0), 0);
  equal(E.activeTab(plan2, 79), 0);
  equal(E.activeTab(plan2, 80), 1);
  equal(E.activeTab(plan2, 79.5), 1, "meio pixel de folga");
  equal(E.activeTab(plan2, 500), 1);
});

test("na busca (seções sem aba) e sem seção nenhuma, nenhuma aba é a ativa", () => {
  const search = E.layout(E.buildSections(data, "cat", []), METRICS);
  equal(E.activeTab(search, 0), -1);
  equal(E.activeTab(E.layout([], METRICS), 0), -1);
});

test("a primeira seção de uma aba; a aba sem seção (os recentes, sem recentes) devolve -1", () => {
  equal(E.sectionOfTab(plan2, 0), 0);
  equal(E.sectionOfTab(plan2, 1), 1);
  equal(E.sectionOfTab(plan2, 3), -1);
  const noRecents = E.layout(E.buildSections(data, "", []), METRICS);
  equal(E.sectionOfTab(noRecents, 0), -1, "a aba clock fica a 50% e não responde");
  equal(E.sectionOfTab(noRecents, 1), 0);
});

test("Tab e Shift+Tab: a aba seguinte e a anterior que têm seção, e nas pontas a aba não anda", () => {
  equal(E.neighbourTab(plan2, 0, 1), 1);
  equal(E.neighbourTab(plan2, 1, -1), 0);
  equal(E.neighbourTab(plan2, 1, 1), -1);
  equal(E.neighbourTab(plan2, 0, -1), -1);
  const gaps = E.layout([sec("a", 1, [0]), sec("b", 3, [1])], METRICS);   // sem seção nas abas 0 e 2
  equal(E.neighbourTab(gaps, 1, 1), 3, "pula a aba sem seção");
  equal(E.neighbourTab(gaps, 3, -1), 1);
});
