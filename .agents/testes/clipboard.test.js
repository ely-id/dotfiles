// Testes do histórico da área de transferência: wintermute-shell/clipboard/Clipboard.js (importa o launcher/Colors.js, e o script copia
// os dois, mantendo o caminho relativo). Os casos saem da ficha 18: "Como funciona" e "O que é composição" (F6-T05), e "O serviço:
// como funciona" e "Como classifico" (F6-T16, P-17 e P-80). Os exemplos de texto são os inventados da ficha (example.org).
//   .agents/scripts/testar.sh clipboard
.import "apoio.js" as T
.import "clipboard/Clipboard.js" as C

const test = T.test, equal = T.equal, check = T.check;

const SECOND = 1000, MINUTE = 60 * SECOND, HOUR = 60 * MINUTE, DAY = 24 * HOUR;
const NOW = 1000 * DAY;   // um relógio qualquer: só a diferença conta

// ---- o tempo relativo ----

test("o tempo relativo curto: now, N min, N h, yesterday e N days", () => {
  const rel = (elapsed) => C.relativeTime(NOW, NOW - elapsed, false);
  equal(rel(0), "now");
  equal(rel(59 * SECOND + 999), "now", "menos de um minuto");
  equal(rel(MINUTE), "1 min");
  equal(rel(2 * MINUTE), "2 min");
  equal(rel(59 * MINUTE + 59 * SECOND), "59 min");
  equal(rel(HOUR), "1 h");
  equal(rel(23 * HOUR + 59 * MINUTE), "23 h", "menos de 24 horas");
  equal(rel(DAY), "yesterday", "de 24 a 48 horas");
  equal(rel(47 * HOUR + 59 * MINUTE), "yesterday");
  equal(rel(2 * DAY), "2 days");
  equal(rel(3 * DAY + 5 * HOUR), "3 days");
});

test("nos metadados acrescento ago, e yesterday fica sem", () => {
  const rel = (elapsed) => C.relativeTime(NOW, NOW - elapsed, true);
  equal(rel(10 * SECOND), "just now");
  equal(rel(2 * MINUTE), "2 min ago");
  equal(rel(HOUR), "1 h ago");
  equal(rel(30 * HOUR), "yesterday");
  equal(rel(3 * DAY), "3 days ago");
});

test("o tempo é corrido, e não pela virada do dia: não depende do fuso", () => {
  // 23:59 e 00:01 do dia seguinte são 2 minutos, e 00:01 de ontem a 23:59 de hoje são 23 h 58 min: ainda 'h', e não 'yesterday'
  equal(C.relativeTime(NOW, NOW - 2 * MINUTE, false), "2 min");
  equal(C.relativeTime(NOW, NOW - (23 * HOUR + 58 * MINUTE), false), "23 h");
});

test("um item no futuro (relógio atrasado) conta como agora", () => {
  equal(C.relativeTime(NOW, NOW + HOUR, false), "now");
  equal(C.relativeTime(NOW, NOW + HOUR, true), "just now");
});

// ---- o tamanho ----

test("o tamanho em bytes: B, KB (base 1024) e MB com uma casa", () => {
  equal(C.byteText(0), "0 B");
  equal(C.byteText(900), "900 B");
  equal(C.byteText(1023), "1023 B");
  equal(C.byteText(1024), "1 KB");
  equal(C.byteText(412 * 1024), "412 KB");   // o exemplo da ficha
  equal(C.byteText(Math.round(1.3 * 1024 * 1024)), "1.3 MB");
  equal(C.byteText(2 * 1024 * 1024), "2 MB", "o .0 cai");
  equal(C.byteText(16 * 1024 * 1024), "16 MB");
});

test("o tamanho que não é número vale zero", () => {
  equal(C.byteText(undefined), "0 B");
  equal(C.byteText(-5), "0 B");
  equal(C.byteText("abc"), "0 B");
});

test("o texto de tamanho do texto: uma linha só diz '15 characters', e mais de uma, '3 lines · 84 characters'", () => {
  equal(C.sizeText({ kind: "text", text: "0123456789ABCDE" }), "15 characters");
  equal(C.sizeText({ kind: "text", text: "a" }), "1 character");
  const body = "x".repeat(41) + "\n" + "y".repeat(20) + "\n" + "z".repeat(21);   // 41 + 1 + 20 + 1 + 21 = 84 caracteres em 3 linhas
  equal(C.sizeText({ kind: "text", text: body }), "3 lines · 84 characters");   // o exemplo da ficha
});

test("a quebra de linha no fim não abre uma linha nova, mas conta como caractere", () => {
  equal(C.sizeText({ kind: "text", text: "uma linha\n" }), "10 characters");
  equal(C.sizeText({ kind: "text", text: "a\nb\n" }), "2 lines · 4 characters");
  equal(C.sizeText({ kind: "text", text: "a\r\nb" }), "2 lines · 4 characters");
});

test("o item de cor conta os caracteres do código", () => {
  equal(C.sizeText({ kind: "color", text: "#3FA9D9", color: "#3FA9D9" }), "7 characters");
});

test("o tamanho da imagem: '1920 × 1080 · PNG · 412 KB'", () => {
  equal(C.sizeText({ kind: "image", image: { width: 1920, height: 1080, format: "PNG", bytes: 412 * 1024 } }), "1920 × 1080 · PNG · 412 KB");
  equal(C.sizeText(null), "");
});

test("o número de linhas", () => {
  equal(C.lineCount("a"), 1);
  equal(C.lineCount("a\nb\nc"), 3);
  equal(C.lineCount("a\nb\n"), 2);
  equal(C.lineCount(""), 0);
  equal(C.lineCount(undefined), 0);
});

// ---- o link ----

test("o nome do servidor de uma URL: sem esquema, usuário, porta nem caminho", () => {
  equal(C.hostOf("https://www.example.org/a?b"), "www.example.org");   // o exemplo da ficha
  equal(C.hostOf("https://user:secret@example.org:8080/x"), "example.org");
  equal(C.hostOf("http://example.org#topo"), "example.org");
  equal(C.hostOf("https://example.org?q=1"), "example.org");
  equal(C.hostOf("  https://example.org/x  "), "example.org", "com espaço nas pontas");
});

test("sem esquema, o que vem antes da primeira barra; texto que não é URL volta como está", () => {
  equal(C.hostOf("www.example.org/design/x"), "www.example.org");
  equal(C.hostOf("example.org?x=1"), "example.org");
  equal(C.hostOf("just words"), "just words");
  equal(C.hostOf(""), "");
  equal(C.hostOf(undefined), "");
});

test("o título do link: o linkTitle do item; sem ele, o nome do servidor", () => {
  equal(C.linkTitleOf({ kind: "link", text: "https://www.example.org/design/x", linkTitle: "Design" }), "Design");
  equal(C.linkTitleOf({ kind: "link", text: "https://www.example.org/design/x" }), "www.example.org");
  equal(C.linkTitleOf({ kind: "link", text: "https://www.example.org/design/x", linkTitle: "" }), "www.example.org");
  equal(C.linkTitleOf(null), "");
});

test("o título da linha: o que o serviço deu; no link, o servidor; no texto, a primeira linha", () => {
  equal(C.titleOf({ title: "Meu título", text: "outro" }), "Meu título");
  equal(C.titleOf({ kind: "link", text: "https://www.example.org/a" }), "www.example.org");
  equal(C.titleOf({ kind: "text", text: "primeira\nsegunda" }), "primeira");
  equal(C.titleOf({ kind: "text", text: "primeira\r\nsegunda" }), "primeira");
  equal(C.titleOf(null), "");
});

// ---- a prévia e a meta ----

test("o texto da prévia: o texto, ou o código da cor no item de cor", () => {
  equal(C.previewText({ kind: "text", text: "olá" }), "olá");
  equal(C.previewText({ kind: "color", text: "", color: "#3FA9D9" }), "#3FA9D9");
  equal(C.previewText(null), "");
});

test("a prévia mede só os 2000 primeiros caracteres", () => {
  equal(C.previewText({ text: "a".repeat(5000) }).length, 2000);
  equal(C.previewText({ text: "a".repeat(2000) }).length, 2000);
  equal(C.previewText({ text: "a".repeat(1999) }).length, 1999);
});

test("o corte não deixa meio par de substituição na ponta", () => {
  const text = "a".repeat(1999) + "😀";   // o emoji ocupa 2 unidades, e o corte em 2000 cairia no meio dele
  equal(C.previewText({ text: text }).length, 1999);
  equal(C.cut("abc", 2), "ab");
  equal(C.cut("abc", 5), "abc");
  equal(C.cut("a😀", 2), "a", "o par inteiro não cabe");
  equal(C.cut("a😀", 3), "a😀");
});

test("a meta da linha: 'Ghostty · 2 min', 'PNG · 1920 × 1080' na imagem e 'Pinned' no fixado", () => {
  equal(C.metaOf({ kind: "text", source: "Ghostty", time: NOW - 2 * MINUTE }, NOW), "Ghostty · 2 min");   // o exemplo da ficha
  equal(C.metaOf({ kind: "image", image: { format: "PNG", width: 1920, height: 1080 }, time: NOW }, NOW), "PNG · 1920 × 1080");
  equal(C.metaOf({ kind: "text", source: "Ghostty", time: NOW - DAY, pinned: true }, NOW), "Pinned");
});

test("sem origem, Unknown", () => {
  equal(C.metaOf({ kind: "text", time: NOW }, NOW), "Unknown · now");
  equal(C.metaOf({ kind: "text", source: "", time: NOW - HOUR }, NOW), "Unknown · 1 h");
});

// ---- os metadados ----

test("texto e imagem: Source, Copied e Size", () => {
  equal(C.metadata({ kind: "text", text: "0123456789ABCDE", source: "Ghostty", time: NOW - 2 * MINUTE }, NOW), [
    { label: "Source", value: "Ghostty" }, { label: "Copied", value: "2 min ago" }, { label: "Size", value: "15 characters" }
  ]);
  equal(C.metadata({ kind: "image", source: "Screenshot", time: NOW - HOUR, image: { width: 1920, height: 1080, format: "PNG", bytes: 412 * 1024 } }, NOW), [
    { label: "Source", value: "Screenshot" }, { label: "Copied", value: "1 h ago" }, { label: "Size", value: "1920 × 1080 · PNG · 412 KB" }
  ]);
});

test("o fixado mostra Pinned, há quanto tempo fixei o item, e não há quanto o copiei", () => {
  const item = { kind: "text", text: "x", source: "Ghostty", time: NOW - 3 * DAY, pinned: true, pinnedTime: NOW - 5 * MINUTE };
  equal(C.metadata(item, NOW)[1], { label: "Pinned", value: "5 min ago" });
  equal(C.metadata(Object.assign({}, item, { pinnedTime: undefined }), NOW)[1], { label: "Pinned", value: "3 days ago" }, "sem a hora de fixar, a da cópia");
});

test("o link só tem Source e Copied", () => {
  equal(C.metadata({ kind: "link", text: "https://example.org", source: "Firefox", time: NOW }, NOW), [
    { label: "Source", value: "Firefox" }, { label: "Copied", value: "just now" }
  ]);
});

test("sem origem os metadados dizem Unknown, e sem item não há metadados", () => {
  equal(C.metadata({ kind: "text", text: "x", time: NOW }, NOW)[0], { label: "Source", value: "Unknown" });
  equal(C.metadata(null, NOW), []);
});

// ---- o ícone por tipo ----

test("o ícone de cada tipo, os da ficha", () => {
  equal(["command", "image", "link", "text", "email"].map(C.iconFor), ["terminal", "image", "link", "file-text", "mail"]);
});

// ---- filtrar ----

const items = [
  { id: "1", kind: "text", title: "git clone https://example.org/case/sprawl-tools", text: "git clone https://example.org/case/sprawl-tools", source: "Ghostty", time: NOW - 2 * MINUTE },
  { id: "2", kind: "link", title: "https://www.example.org/design/x", text: "https://www.example.org/design/x", linkTitle: "Design brief", source: "Firefox", time: NOW - 3 * MINUTE },
  { id: "3", kind: "color", title: "#3FA9D9", text: "#3FA9D9", color: "#3FA9D9", source: "Color picker", time: NOW - 4 * MINUTE },
  { id: "4", kind: "text", title: "nota", text: "comprar café", source: "Figma", time: NOW - 5 * MINUTE },
  { id: "5", kind: "email", title: "case@example.org", text: "case@example.org", source: "Firefox", time: NOW - 6 * MINUTE }
];
const ids = (list) => list.map((item) => item.id);

test("a busca olha o título, o texto, a URL, o título do link, a cor e o aplicativo de origem", () => {
  equal(ids(C.filter(items, "sprawl")), ["1"], "o texto");
  equal(ids(C.filter(items, "nota")), ["4"], "o título");
  equal(ids(C.filter(items, "design brief")), ["2"], "o título do link");
  equal(ids(C.filter(items, "3fa9d9")), ["3"], "a cor");
  equal(ids(C.filter(items, "figma")), ["4"], "o aplicativo de origem, como no board (figma)");
  equal(ids(C.filter(items, "firefox")), ["2", "5"], "dois itens do mesmo aplicativo, na ordem da lista");
  equal(ids(C.filter(items, "https://www.example.org/design")), ["2"], "a URL");
});

test("a busca não diferencia maiúsculas", () => {
  equal(ids(C.filter(items, "GHOSTTY")), ["1"]);
  equal(ids(C.filter(items, "#3fa9D9")), ["3"]);
  equal(ids(C.filter(items, "  figma  ")), ["4"], "e o espaço nas pontas não conta");
});

test("busca vazia devolve a lista como veio, e sem resultado a lista é vazia", () => {
  equal(ids(C.filter(items, "")), ["1", "2", "3", "4", "5"]);
  equal(ids(C.filter(items, "   ")), ["1", "2", "3", "4", "5"]);
  equal(ids(C.filter(items, undefined)), ["1", "2", "3", "4", "5"]);
  equal(C.filter(items, "xyzzy"), []);
  equal(C.filter(undefined, "x"), []);
});

test("filtrar devolve uma lista nova, mesmo sem busca", () => {
  const out = C.filter(items, "");
  check(out !== items, "a mesma lista");
  out.pop();
  equal(items.length, 5);
});

// ---- as seções ----

test("sem busca: Pinned (o fixado mais recente primeiro) e Today (o resto, na ordem do serviço)", () => {
  const list = [
    { id: "a", time: 5 },
    { id: "b", time: 4, pinned: true, pinnedTime: 100 },
    { id: "c", time: 3 },
    { id: "d", time: 2, pinned: true, pinnedTime: 200 }
  ];
  const sections = C.sections(list, "");
  equal(sections.map((s) => s.label), ["Pinned", "Today"]);
  equal(ids(sections[0].items), ["d", "b"], "fixei o d depois do b");
  equal(ids(sections[1].items), ["a", "c"]);
});

test("fixados com a mesma hora ficam na ordem da lista", () => {
  const list = [{ id: "a", pinned: true, pinnedTime: 50 }, { id: "b", pinned: true, pinnedTime: 50 }];
  equal(ids(C.sections(list, "")[0].items), ["a", "b"]);
});

test("seção sem item não existe, e sem nada o resultado é vazio", () => {
  equal(C.sections([{ id: "a" }], "").map((s) => s.label), ["Today"]);
  equal(C.sections([{ id: "a", pinned: true, pinnedTime: 1 }], "").map((s) => s.label), ["Pinned"]);
  equal(C.sections([], ""), []);
  equal(C.sections(undefined, ""), []);
});

test("com busca, uma seção só, '2 results', sem a divisão (e '1 result' no singular)", () => {
  const sections = C.sections(items, "firefox");
  equal(sections.map((s) => s.label), ["2 results"]);
  equal(ids(sections[0].items), ["2", "5"]);
  equal(C.sections(items, "figma").map((s) => s.label), ["1 result"]);
  equal(C.sections(items, "xyzzy"), []);
});

test("com busca os fixados não se separam", () => {
  const list = [{ id: "a", text: "alfa", pinned: true, pinnedTime: 1 }, { id: "b", text: "alfabeto" }];
  const sections = C.sections(list, "alf");
  equal(sections.map((s) => s.label), ["2 results"]);
  equal(ids(sections[0].items), ["a", "b"]);
});

// ---- a posição de cada linha ----

// As medidas da ficha 18: o primeiro rótulo em y 60, o rótulo de 24, a linha de 52 sem folga, 4 entre a última linha e o rótulo seguinte.
// O fim da lista (endGap) a ficha não dá; uso 10 só para ver que ele entra na altura.
const METRICS = { firstLabelY: 60, labelHeight: 24, rowHeight: 52, labelGap: 4, endGap: 10 };

test("o board dos fixados: linhas em 84 e 136, 'Today' em 192 e as linhas em 216 e 268", () => {
  const plan = C.layout([{ label: "Pinned", items: [{ id: "p1" }, { id: "p2" }] }, { label: "Today", items: [{ id: "t1" }, { id: "t2" }] }], METRICS);
  equal(plan.labels, [{ text: "Pinned", y: 60 }, { text: "Today", y: 192 }]);
  equal(plan.rows.map((r) => r.y), [84, 136, 216, 268]);
  equal(plan.height, 268 + 52 + 10);
});

test("uma seção só: as linhas empilhadas sem folga, em 84, 136, 188, 240 e 292", () => {
  const plan = C.layout([{ label: "Today", items: [1, 2, 3, 4, 5].map((n) => ({ id: "t" + n })) }], METRICS);
  equal(plan.rows.map((r) => r.y), [84, 136, 188, 240, 292]);
});

test("cada linha diz se é a primeira da seção e o y do rótulo dela, para a rolagem mostrar os dois juntos", () => {
  const plan = C.layout([{ label: "Pinned", items: [{ id: "p1" }, { id: "p2" }] }, { label: "Today", items: [{ id: "t1" }] }], METRICS);
  equal(plan.rows.map((r) => [r.item.id, r.first, r.labelY]), [["p1", true, 60], ["p2", false, 60], ["t1", true, 192]]);
});

test("sem seção a lista tem só o fim", () => {
  equal(C.layout([], METRICS), { labels: [], rows: [], height: 60 + 10 });
  equal(C.layout(undefined, METRICS).rows, []);
});

// ---- a seleção segue o item ----

const rowsOf = (list) => list.map((id) => ({ item: { id: id } }));

test("depois de fixar, a seleção continua no mesmo item, pelo id, mesmo que ele tenha mudado de seção", () => {
  equal(C.reselect(rowsOf(["b", "a", "c"]), "a", 0), 1);
});

test("depois de apagar, a seleção passa para o vizinho de baixo, ou para o de cima se era o último", () => {
  equal(C.reselect(rowsOf(["a", "c", "d"]), "b", 1), 1, "o b era o 1; agora o 1 é o c, a linha de baixo");
  equal(C.reselect(rowsOf(["a", "b"]), "c", 2), 1, "o c era o último: fica o novo último");
  equal(C.reselect(rowsOf(["a", "b"]), "c", 9), 1);
  equal(C.reselect(rowsOf(["a", "b"]), undefined, -3), 0);
});

test("sem linha nenhuma, nenhuma seleção", () => {
  equal(C.reselect([], "a", 0), -1);
  equal(C.reselect(undefined, "a", 0), -1);
});

// ---- classificar o que foi copiado ----

test("a cor em HEX: o texto inteiro, com #, em qualquer caixa", () => {
  equal(C.classify("#3FA9D9", false), { kind: "color", title: "#3FA9D9", color: "#3FA9D9" });
  equal(C.classify("#3fa9d9", false), { kind: "color", title: "#3fa9d9", color: "#3FA9D9" }, "o título é o texto, e a cor é em maiúsculas");
  equal(C.classify("  #3FA9D9\n", false), { kind: "color", title: "#3FA9D9", color: "#3FA9D9" }, "com espaço nas pontas");
});

test("o HEX sem # não conta: 'facade' e 'decade' são palavras", () => {
  equal(C.classify("facade", false).kind, "text");
  equal(C.classify("decade", false).kind, "text");
  equal(C.classify("3FA9D9", false).kind, "text");
  equal(C.classify("#FFF", false).kind, "text", "o #RGB o seletor nunca grava");
  equal(C.classify("#GGGGGG", false).kind, "text");
});

test("a cor em rgb(): vira o HEX, e fora da faixa é texto", () => {
  equal(C.classify("rgb(63, 169, 217)", false).color, "#3FA9D9");   // o formato que o seletor de cor copia
  equal(C.classify("rgb(63,169,217)", false).color, "#3FA9D9", "sem espaços");
  equal(C.classify("rgb(0, 0, 0)", false).color, "#000000");
  equal(C.classify("rgb(255, 255, 255)", false).color, "#FFFFFF");
  equal(C.classify("rgb(256, 0, 0)", false).kind, "text");
  equal(C.classify("rgb(1, 2)", false).kind, "text");
  equal(C.classify("rgb(1, 2, 3) mais texto", false).kind, "text", "o texto inteiro tem de ser a cor");
});

test("a cor em hsl(): vira o HEX, e fora da faixa é texto", () => {
  // conferidos à mão: chroma = (1 - |2l - 1|) × s, e depois cada canal é (parte do chroma + l - chroma/2) × 255
  equal(C.classify("hsl(0, 100%, 50%)", false).color, "#FF0000");
  equal(C.classify("hsl(120, 100%, 50%)", false).color, "#00FF00");
  equal(C.classify("hsl(240, 100%, 50%)", false).color, "#0000FF");
  equal(C.classify("hsl(210, 50%, 40%)", false).color, "#336699");   // chroma 0,4; x = 0,2; m = 0,2 → 51, 102, 153
  equal(C.classify("hsl(0, 0%, 100%)", false).color, "#FFFFFF");
  equal(C.classify("hsl(361, 50%, 50%)", false).kind, "text");
  equal(C.classify("hsl(0, 101%, 50%)", false).kind, "text");
  equal(C.classify("hsl(0, 50%, 101%)", false).kind, "text");
});

test("o hsl que o seletor copia, em inteiros, dá a cor com 1 ou 2 níveis de diferença (a ficha avisa)", () => {
  // hsl(199, 67%, 55%): chroma 0,603; x = 0,4121; m = 0,2485 → r 63,4, g 168,4, b 217,1 → 3F A8 D9, e o HEX original era 3F A9 D9
  equal(C.classify("hsl(199, 67%, 55%)", false).color, "#3FA8D9");
});

test("link: uma linha só com http://, https:// ou www., sem espaço", () => {
  equal(C.classify("https://www.example.org/design/x", false), { kind: "link", title: "https://www.example.org/design/x", color: "" });
  equal(C.classify("http://example.org", false).kind, "link");
  equal(C.classify("www.example.org", false).kind, "link");
  equal(C.classify("  https://example.org/x \n", false).title, "https://example.org/x");
  equal(C.classify("https://a b", false).kind, "text", "com espaço no meio");
  equal(C.classify("https://a.org\nhttps://b.org", false).kind, "text", "duas linhas");
  equal(C.classify("example.org", false).kind, "text", "sem esquema nem www");
});

test("e-mail: uma linha só com um endereço", () => {
  equal(C.classify("case@example.org", false), { kind: "email", title: "case@example.org", color: "" });
  equal(C.classify("a@b", false).kind, "text", "sem ponto no domínio");
  equal(C.classify("a b@c.d", false).kind, "text");
  equal(C.classify("escrevi a@b.co hoje", false).kind, "text");
});

test("comando: o texto copiado de um terminal; fora dele é texto", () => {
  equal(C.classify("git clone https://example.org/case/sprawl-tools", true), { kind: "command", title: "git clone https://example.org/case/sprawl-tools", color: "" });
  equal(C.classify("git clone https://example.org/case/sprawl-tools", false).kind, "text");
});

test("a ordem é cor, link, e-mail, comando, texto: do terminal, a URL é link", () => {
  equal(C.classify("https://example.org", true).kind, "link");
  equal(C.classify("case@example.org", true).kind, "email");
  equal(C.classify("#3FA9D9", true).kind, "color");
  equal(C.classify("ls -la", true).kind, "command");
});

test("o título é a primeira linha não vazia do texto, sem espaços nas pontas", () => {
  equal(C.classify("primeira\nsegunda", false).title, "primeira");
  equal(C.classify("\n\n  segunda linha  \nterceira", false).title, "segunda linha");
  equal(C.classify("só uma", false), { kind: "text", title: "só uma", color: "" });
  equal(C.classify("", false), { kind: "text", title: "", color: "" });
  equal(C.classify(undefined, false).kind, "text");
});

test("o título guardado tem no máximo 256 caracteres", () => {
  equal(C.classify("a".repeat(300), false).title.length, 256);
  equal(C.classify("https://example.org/" + "a".repeat(300), false).title.length, 256, "no link também");
  equal(C.classify("a".repeat(256), false).title.length, 256);
  equal(C.classify("a".repeat(200), false).title.length, 200);
});

test("o título de uma imagem: 'Screenshot HH:MM' vindo da captura da shell e 'Image HH:MM' nos outros casos, na hora local", () => {
  const when = new Date(2026, 10, 19, 14, 32).getTime();
  equal(C.imageTitle(true, when), "Screenshot 14:32");
  equal(C.imageTitle(false, when), "Image 14:32");
  equal(C.imageTitle(true, new Date(2026, 10, 19, 9, 5).getTime()), "Screenshot 09:05", "com o zero");
});

// ---- só o que o serviço escreveu ----

const DIR = "/run/user/1000/wintermute-shell/clipboard";
const HASH = "0123456789abcdef".repeat(4);   // 64 dígitos hexadecimais, como o SHA-256

test("o arquivo que o serviço pode apagar: <hash>.png direto dentro da pasta do histórico", () => {
  check(C.isOwnFile(DIR, DIR + "/" + HASH + ".png"));
  check(C.isOwnFile(DIR, DIR + "/abcdef01.png"), "o hash de 8 dígitos ainda vale");
});

test("fora da pasta, em subpasta, com outro nome ou outra extensão, o serviço não apaga", () => {
  check(!C.isOwnFile(DIR, "/run/user/1000/wintermute-shell/" + HASH + ".png"), "fora da pasta");
  check(!C.isOwnFile(DIR, DIR + "/sub/" + HASH + ".png"), "em subpasta");
  check(!C.isOwnFile(DIR, DIR + "/" + HASH + ".jpg"), "outra extensão");
  check(!C.isOwnFile(DIR, DIR + "/abc.png"), "hash curto demais");
  check(!C.isOwnFile(DIR, DIR + "/" + HASH.toUpperCase() + ".png"), "hash em maiúsculas");
  check(!C.isOwnFile(DIR, DIR + "/" + HASH + ".png.tmp"), "o temporário");
  check(!C.isOwnFile(DIR, DIR + "/../" + HASH + ".png"), "com ..");
  check(!C.isOwnFile(DIR, DIR + "/" + HASH + ".png/"), "barra no fim");
  check(!C.isOwnFile(DIR, DIR + "/capture.png"), "o PNG da captura de tela não é do histórico");
});

test("sem pasta, com pasta que não é absoluta, ou sem caminho, nada é do serviço", () => {
  check(!C.isOwnFile("", "/" + HASH + ".png"));
  check(!C.isOwnFile("relativa", "relativa/" + HASH + ".png"));
  check(!C.isOwnFile(undefined, DIR + "/" + HASH + ".png"));
  check(!C.isOwnFile(DIR, ""));
  check(!C.isOwnFile(DIR, undefined));
});

// ---- guardar, fixar, apagar e cortar ----

const text = (id, body, extra) => Object.assign({ id: id, kind: "text", text: body, time: 1 }, extra || {});
const image = (id, hash, bytes, extra) => Object.assign({ id: id, kind: "image", time: 1, image: { hash: hash, bytes: bytes } }, extra || {});

test("o item novo entra no topo", () => {
  const out = C.push([text("a", "um")], text("b", "dois"));
  equal(ids(out.items), ["b", "a"]);
  equal(out.duplicate, false);
  equal(out.item.id, "b");
});

test("o mesmo texto de novo não duplica: sobe com a hora nova e mantém o id, o fixado e a origem", () => {
  const list = [text("a", "um"), text("b", "dois", { pinned: true, pinnedTime: 5, source: "Ghostty", time: 2 })];
  const out = C.push(list, text("n", "dois", { time: 99, source: "Firefox" }));
  equal(ids(out.items), ["b", "a"]);
  equal(out.duplicate, true);
  equal(out.item, out.items[0]);
  equal([out.item.time, out.item.pinned, out.item.pinnedTime, out.item.source], [99, true, 5, "Ghostty"]);
});

test("a imagem com o mesmo hash não duplica, e com outro hash entra", () => {
  const list = [image("i1", "h1", 100)];
  equal(C.push(list, image("n", "h1", 100)).duplicate, true);
  equal(ids(C.push(list, image("n", "h1", 100)).items), ["i1"]);
  const other = C.push(list, image("n", "h2", 100));
  equal([other.duplicate, ids(other.items)], [false, ["n", "i1"]]);
});

test("uma imagem não é igual a um texto, e a lista que recebi não muda", () => {
  const list = [text("a", "um"), image("i1", "h1", 100)];
  equal(C.push(list, image("n", "h9", 1)).duplicate, false);
  equal(C.push(list, text("n", "um")).duplicate, true);
  equal(list.length, 2);
  equal(ids(list), ["a", "i1"]);
});

test("a soma dos bytes das imagens guardadas, as fixadas incluídas", () => {
  equal(C.imageBytes([text("a", "um"), image("i1", "h1", 100), image("i2", "h2", 50, { pinned: true })]), 150);
  equal(C.imageBytes([]), 0);
  equal(C.imageBytes(undefined), 0);
});

test("o limite de itens: no máximo N não fixados, saem os mais antigos, e os fixados não contam nem saem", () => {
  // a lista vem do mais novo para o mais antigo
  const list = [text("u1", "1"), text("p1", "p", { pinned: true }), text("u2", "2"), text("u3", "3"), text("u4", "4"), text("p2", "q", { pinned: true }), text("u5", "5")];
  const out = C.trim(list, 3, Infinity);
  equal(ids(out.items), ["u1", "p1", "u2", "u3", "p2"]);
  equal(ids(out.dropped), ["u5", "u4"], "na ordem em que saíram: o mais antigo primeiro");
});

test("o limite de 50 não fixados da P-17, com os fixados a mais", () => {
  const list = [];
  for (let i = 0; i < 52; ++i)
    list.push(text("u" + i, "t" + i));
  list.splice(10, 0, text("p1", "p1", { pinned: true }), text("p2", "p2", { pinned: true }));
  const out = C.trim(list, 50, Infinity);
  equal(out.items.filter((item) => !item.pinned).length, 50);
  equal(out.items.filter((item) => item.pinned).length, 2);
  equal(ids(out.dropped), ["u51", "u50"]);
});

test("dentro dos limites a lista fica como está, e a que recebi não muda", () => {
  const list = [text("a", "1"), text("b", "2")];
  const out = C.trim(list, 50, 1000);
  equal(ids(out.items), ["a", "b"]);
  equal(out.dropped, []);
  C.trim([text("a", "1"), text("b", "2"), text("c", "3")], 1, 1000);
  equal(C.trim(undefined, 5, 5), { items: [], dropped: [] });
});

test("o teto das imagens: passando dele saem primeiro as imagens não fixadas mais antigas, e o texto não sai por isso", () => {
  const list = [image("i1", "h1", 60), text("t", "texto"), image("i2", "h2", 50), image("i3", "h3", 40, { pinned: true })];   // 150 no total
  const out = C.trim(list, 50, 100);
  equal(ids(out.items), ["i1", "t", "i3"], "saiu a i2, a não fixada mais antiga");
  equal(ids(out.dropped), ["i2"]);
  equal(C.imageBytes(out.items), 100);
});

test("o teto das imagens corta o quanto for preciso, da mais antiga para a mais nova", () => {
  const list = [image("i1", "h1", 40), image("i2", "h2", 40), image("i3", "h3", 40)];
  const out = C.trim(list, 50, 50);
  equal(ids(out.items), ["i1"]);
  equal(ids(out.dropped), ["i3", "i2"]);
});

test("os fixados nunca saem, nem quando só eles passam do teto das imagens", () => {
  const list = [image("i1", "h1", 80, { pinned: true }), image("i2", "h2", 80, { pinned: true })];
  const out = C.trim(list, 50, 100);
  equal(ids(out.items), ["i1", "i2"]);
  equal(out.dropped, []);
});

test("fixar põe pinnedTime na hora, e soltar o zera; só o item pedido muda", () => {
  const list = [text("a", "1"), text("b", "2", { pinned: true, pinnedTime: 5 })];
  const pinned = C.togglePin(list, "a", 777);
  equal([pinned[0].pinned, pinned[0].pinnedTime], [true, 777]);
  equal(pinned[1], list[1], "o outro item é o mesmo objeto");
  const released = C.togglePin(list, "b", 777);
  equal([released[1].pinned, released[1].pinnedTime], [false, 0]);
  equal(list[0].pinned, undefined, "a lista que recebi não muda");
  equal(list[1].pinned, true);
});

test("fixar um id que não existe deixa a lista como está", () => {
  const list = [text("a", "1")];
  equal(C.togglePin(list, "zzz", 1), list);
  equal(C.togglePin(undefined, "a", 1), []);
});

test("apagar tira o item e diz qual saiu; id que não existe não tira nada", () => {
  const list = [text("a", "1"), text("b", "2")];
  const out = C.remove(list, "a");
  equal(ids(out.items), ["b"]);
  equal(out.removed.id, "a");
  const none = C.remove(list, "zzz");
  equal([ids(none.items), none.removed], [["a", "b"], null]);
  equal(list.length, 2);
});

test("'Clear history' tira todos os não fixados, na ordem, e deixa os fixados", () => {
  const list = [text("a", "1"), text("p", "2", { pinned: true }), text("b", "3"), text("q", "4", { pinned: true })];
  const out = C.clearUnpinned(list);
  equal(ids(out.items), ["p", "q"]);
  equal(ids(out.removed), ["a", "b"]);
  equal(C.clearUnpinned([]), { items: [], removed: [] });
  equal(list.length, 4);
});

// ---- bytes e linhas em UTF-8 ----

test("o teto de texto é em bytes UTF-8: 1, 2, 3 e 4 por caractere", () => {
  equal(C.utf8Length("abc"), 3);
  equal(C.utf8Length("é"), 2);
  equal(C.utf8Length("€"), 3);
  equal(C.utf8Length("😀"), 4, "o par de substituição é um caractere só");
  equal(C.utf8Length("aé€😀"), 10);
  equal(C.utf8Length(""), 0);
  equal(C.utf8Length(undefined), 0);
  equal(C.utf8Length(null), 0);
  equal(C.utf8Length("\ud800"), 3, "meio par de substituição");
});

test("a primeira linha não vazia, sem espaços nas pontas", () => {
  equal(C.firstLine("um\ndois"), "um");
  equal(C.firstLine("\n \n  dois  \ntrês"), "dois");
  equal(C.firstLine("a\rb"), "a");
  equal(C.firstLine("   \n  "), "");
  equal(C.firstLine(undefined), "");
});

// ---- as cores por dentro ----

test("de HSL para RGB, arredondado", () => {
  equal(C.hslToRgb(0, 100, 50), [255, 0, 0]);
  equal(C.hslToRgb(120, 100, 50), [0, 255, 0]);
  equal(C.hslToRgb(240, 100, 50), [0, 0, 255]);
  equal(C.hslToRgb(60, 100, 50), [255, 255, 0]);
  equal(C.hslToRgb(210, 50, 40), [51, 102, 153]);
  equal(C.hslToRgb(0, 0, 50), [128, 128, 128], "127,5 arredonda para cima");
  equal(C.hslToRgb(360, 100, 50), [255, 0, 0], "o matiz 360 é o 0");
  equal(C.hslToRgb(-120, 100, 50), [0, 0, 255], "e o negativo dá a volta");
});

test("de RGB para HEX em maiúsculas, com dois dígitos por canal", () => {
  equal(C.hexOf([0, 10, 255]), "#000AFF");
  equal(C.hexOf([63, 169, 217]), "#3FA9D9");
});
