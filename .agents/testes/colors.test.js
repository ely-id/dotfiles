// Testes das cores do seletor de cor: wintermute-shell/launcher/Colors.js. Os casos saem da ficha 15 (seção "Como funciona", F5-T08,
// P-75 e P-76) e do estado "resultado" do board. As conversões abaixo conferi à mão, canal por canal; cada uma tem a conta no comentário.
//   .agents/scripts/testar.sh colors
.import "apoio.js" as T
.import "launcher/Colors.js" as C

const test = T.test, equal = T.equal, check = T.check, near = T.near;

// ---- o HEX ----

test("o HEX sai em maiúsculas com #, venha como vier", () => {
  equal(C.normalizeHex("#3fa9d9"), "#3FA9D9");
  equal(C.normalizeHex("3fa9d9"), "#3FA9D9", "sem #");
  equal(C.normalizeHex("  #3FA9D9\n"), "#3FA9D9", "com espaço nas pontas");
  equal(C.normalizeHex("#3Fa9D9"), "#3FA9D9", "caixa mista");
});

test("o que não é HEX de seis dígitos volta vazio, o #RGB inclusive", () => {
  ["#FFF", "fff", "#12345", "#1234567", "#GGGGGG", "#3FA9D", "#3FA9D9FF", "", "   ", "rgb(1, 2, 3)", "# 3FA9D9"].forEach((text) => {
    equal(C.normalizeHex(text), "", "'" + text + "'");
  });
  equal(C.normalizeHex(null), "");
  equal(C.normalizeHex(undefined), "");
  equal(C.normalizeHex(0x3FA9D9), "", "número não é texto");
});

test("isValidHex segue o normalizeHex", () => {
  check(C.isValidHex("#3fa9d9"));
  check(C.isValidHex("3FA9D9"));
  check(!C.isValidHex("#FFF"));
  check(!C.isValidHex(""));
});

// ---- RGB ----

test("toRgb: o exemplo do board, 3F A9 D9 = 63 169 217", () => {
  equal(C.toRgb("#3FA9D9"), [63, 169, 217]);   // 3F = 3×16+15 = 63; A9 = 10×16+9 = 169; D9 = 13×16+9 = 217
  equal(C.toRgb("3fa9d9"), [63, 169, 217]);
});

test("toRgb: os extremos e um HEX inválido", () => {
  equal(C.toRgb("#000000"), [0, 0, 0]);
  equal(C.toRgb("#FFFFFF"), [255, 255, 255]);
  equal(C.toRgb("#010203"), [1, 2, 3]);
  equal(C.toRgb("nope"), null);
  equal(C.toRgb("#FFF"), null);
});

// ---- HSL ----

test("toHsl sem arredondar: #3FA9D9", () => {
  // max = 217/255, min = 63/255, delta = 154/255, l = (217 + 63) / 2 / 255 = 140/255 = 54,902%
  // s = delta / (1 - |2l - 1|) = 154 / 230 = 66,957%; como o maior é o azul, h = ((63 - 169) / 154 + 4) × 60 = 198,70°
  const hsl = C.toHsl([63, 169, 217]);
  near(hsl[0], 198.7013, 0.001, "matiz");
  near(hsl[1], 66.9565, 0.001, "saturação");
  near(hsl[2], 54.9020, 0.001, "luminosidade");
});

test("os formatos do board: rgb(63, 169, 217) e hsl(199, 67%, 55%)", () => {
  // A ficha 15 explica que o board escreve 68% por deslize: a conta dá 66,96%, e a shell mostra o valor calculado, 67%.
  equal(C.formats("#3FA9D9"), { hex: "#3FA9D9", rgb: "rgb(63, 169, 217)", hsl: "hsl(199, 67%, 55%)" });
});

test("as cores primárias e secundárias, no HSL redondo", () => {
  equal(C.formats("#FF0000").hsl, "hsl(0, 100%, 50%)");
  equal(C.formats("#FFFF00").hsl, "hsl(60, 100%, 50%)");     // vermelho e verde empatam no maior; vale o vermelho: h = ((255 - 0) / 255) × 60 = 60
  equal(C.formats("#00FF00").hsl, "hsl(120, 100%, 50%)");
  equal(C.formats("#00FFFF").hsl, "hsl(180, 100%, 50%)");
  equal(C.formats("#0000FF").hsl, "hsl(240, 100%, 50%)");
  equal(C.formats("#FF00FF").hsl, "hsl(300, 100%, 50%)");
});

test("preto, branco e cinza: sem saturação e com matiz 0", () => {
  equal(C.formats("#000000").hsl, "hsl(0, 0%, 0%)");
  equal(C.formats("#FFFFFF").hsl, "hsl(0, 0%, 100%)");
  equal(C.formats("#808080").hsl, "hsl(0, 0%, 50%)");   // 128/255 = 50,2%
});

test("conversões conferidas à mão", () => {
  // #336699: r 51, g 102, b 153 → l = (0,2 + 0,6)/2 = 40%, s = 0,4 / (1 - |0,8 - 1|) = 50%, h = ((0,2 - 0,4)/0,4 + 4) × 60 = 210°
  equal(C.formats("#336699").hsl, "hsl(210, 50%, 40%)");
  // #FF8000: h = (128/255) × 60 = 30,1°, s = 100%, l = 50%
  equal(C.formats("#FF8000").hsl, "hsl(30, 100%, 50%)");
  // #FF6347: h = (99 - 71)/184 × 60 = 9,1°, l = (255 + 71)/510 = 63,9%, s = 100%
  equal(C.formats("#FF6347").hsl, "hsl(9, 100%, 64%)");
});

test("o matiz que arredonda para 360 volta a 0, que é a mesma cor", () => {
  // #FF0001: h = (6 - 1/255) × 60 = 359,76°, que arredonda para 360
  equal(C.formats("#FF0001").hsl, "hsl(0, 100%, 50%)");
});

test("formats devolve null para HEX inválido", () => {
  equal(C.formats("#FFF"), null);
  equal(C.formats(""), null);
  equal(C.formats("azul"), null);
});

// ---- o nome da cor ----

test("a lista de nomes tem os 139 da ficha, sem os repetidos grey, aqua e fuchsia", () => {
  equal(C.NAMED.length, 139);
  const names = C.NAMED.map((entry) => entry[0]);
  equal(names.filter((name, i) => names.indexOf(name) !== i), [], "nomes repetidos");
  ["grey", "aqua", "fuchsia", "dark grey", "light grey"].forEach((name) => check(names.indexOf(name) < 0, name + " não devia estar"));
  ["gray", "cyan", "magenta"].forEach((name) => check(names.indexOf(name) >= 0, name + " devia estar"));
  C.NAMED.forEach((entry) => {
    check(C.isValidHex(entry[1]) && entry[1] === C.normalizeHex(entry[1]), entry[0] + ": " + entry[1]);
    check(entry[0] === entry[0].toLowerCase(), entry[0] + " em minúsculas");
  });
});

test("o #3FA9D9 do board se chama Deep sky blue", () => {
  equal(C.nameOf("#3FA9D9"), "Deep sky blue");   // ficha 15: "o 'Azul céu' de lá é só texto de exemplo"
});

test("a cor exata de um nome dá esse nome, só com a primeira letra maiúscula", () => {
  equal(C.nameOf("#FF0000"), "Red");
  equal(C.nameOf("#000000"), "Black");
  equal(C.nameOf("#FFFFFF"), "White");
  equal(C.nameOf("#0000FF"), "Blue");
  equal(C.nameOf("#00FF00"), "Lime");
  equal(C.nameOf("#008000"), "Green");
  equal(C.nameOf("#FFC0CB"), "Pink");
  equal(C.nameOf("#4682B4"), "Steel blue");
  equal(C.nameOf("#F0F8FF"), "Alice blue");
  equal(C.nameOf("#663399"), "Rebecca purple");
});

test("nas cores repetidas da lista do W3C fico com gray, cyan e magenta", () => {
  equal(C.nameOf("#808080"), "Gray");
  equal(C.nameOf("#00FFFF"), "Cyan");
  equal(C.nameOf("#FF00FF"), "Magenta");
});

test("uma cor sem nome exato vai para a mais próxima", () => {
  equal(C.nameOf("#FE0101"), "Red");
  equal(C.nameOf("#010101"), "Black");
  equal(C.nameOf("#FEFEFE"), "White");
});

test("o nome aceita o HEX sem # e em minúsculas, e HEX inválido não tem nome", () => {
  equal(C.nameOf("3fa9d9"), "Deep sky blue");
  equal(C.nameOf("#FFF"), "");
  equal(C.nameOf(""), "");
});

test("describe junta tudo: hex, rgb, hsl e nome", () => {
  equal(C.describe("3fa9d9"), {
    hex: "#3FA9D9", rgb: "rgb(63, 169, 217)", hsl: "hsl(199, 67%, 55%)", name: "Deep sky blue"
  });
  equal(C.describe("#nope"), null);
});

// ---- a origem sob o nome ----

test("a origem da cor que acabei de pegar: Picked just now · Firefox", () => {
  equal(C.originText({ app: "Firefox" }, true, "19/11/2026 14:32"), "Picked just now · Firefox");   // o texto do board
  equal(C.originText({ app: "Firefox" }, true, ""), "Picked just now · Firefox");
});

test("a origem de uma cor do histórico: a data e a hora, e o aplicativo depois", () => {
  equal(C.originText({ app: "Firefox" }, false, "19/11/2026 14:32"), "19/11/2026 14:32 · Firefox");
});

test("a origem sem aplicativo, ou sem data", () => {
  equal(C.originText({ app: "" }, true, ""), "Picked just now");
  equal(C.originText({}, true, ""), "Picked just now");
  equal(C.originText(null, false, "19/11/2026 14:32"), "19/11/2026 14:32");
  equal(C.originText({ app: "Firefox" }, false, ""), "Firefox", "sem data fica só o aplicativo");
  equal(C.originText({ app: "  Firefox " }, true, ""), "Picked just now · Firefox", "sem espaço nas pontas");
  equal(C.originText({ app: 42 }, true, ""), "Picked just now", "aplicativo que não é texto não conta");
  equal(C.originText({}, false, ""), "");
});

// ---- o histórico ----

const when = "2026-11-19T14:32:00.000Z";
const entry = (hex, extra) => Object.assign({ hex: hex, pickedAt: when, app: "" }, extra || {});

test("o histórico guarda as 12 últimas", () => {
  equal(C.MAX_HISTORY, 12);
  const many = [];
  for (let i = 0; i < 15; ++i)
    many.push(entry("#0000" + (i < 10 ? "0" : "") + i));
  equal(C.parseHistory(JSON.stringify(many)).length, 12);
  equal(C.parseHistory(JSON.stringify(many))[0].hex, "#000000", "ficam as primeiras do arquivo, as mais novas");
  equal(C.parseHistory(JSON.stringify(many), 3).length, 3, "o corte pode ser outro");
});

test("arquivo vazio, estragado ou fora do formato vale como lista vazia", () => {
  equal(C.parseHistory(""), []);
  equal(C.parseHistory("isto não é JSON"), []);
  equal(C.parseHistory("{}"), []);
  equal(C.parseHistory('{"hex":"#3FA9D9"}'), []);
  equal(C.parseHistory("null"), []);
  equal(C.parseHistory('"texto"'), []);
  equal(C.parseHistory("[]"), []);
});

test("a entrada malformada é descartada e as outras seguem", () => {
  const text = JSON.stringify([
    entry("#111111"),
    null,
    "texto",
    42,
    { pickedAt: when },
    { hex: "#FFF", pickedAt: when },
    { hex: "#222222" },
    { hex: "#333333", pickedAt: "ontem" },
    { hex: "#444444", pickedAt: 12345 },
    entry("#555555")
  ]);
  equal(C.parseHistory(text).map((item) => item.hex), ["#111111", "#555555"]);
});

test("o HEX do arquivo é normalizado, e o aplicativo que falta vira vazio", () => {
  const list = C.parseHistory(JSON.stringify([{ hex: "3fa9d9", pickedAt: when }, { hex: "#abcdef", pickedAt: when, app: 7 }]));
  equal(list, [{ hex: "#3FA9D9", pickedAt: when, app: "" }, { hex: "#ABCDEF", pickedAt: when, app: "" }]);
});

test("cor repetida no arquivo fica só a mais nova (a primeira)", () => {
  const list = C.parseHistory(JSON.stringify([entry("#111111", { app: "novo" }), entry("#222222"), entry("#111111", { app: "velho" }), entry("#111111")]));
  equal(list.map((item) => item.hex), ["#111111", "#222222"]);
  equal(list[0].app, "novo");
});

test("serializar e ler de volta dá a mesma lista, e o texto termina em quebra de linha", () => {
  const list = [entry("#3FA9D9", { app: "Firefox" }), entry("#000000")];
  const text = C.serializeHistory(list);
  check(text.charAt(text.length - 1) === "\n", "termina em \\n");
  equal(C.parseHistory(text), list);
  equal(C.serializeHistory([]), "[]\n");
});

test("serializar guarda só hex, data e aplicativo", () => {
  const text = C.serializeHistory([{ hex: "#3FA9D9", pickedAt: when, app: "x", extra: "não" }]);
  equal(JSON.parse(text), [{ hex: "#3FA9D9", pickedAt: when, app: "x" }]);
});

test("pegar uma cor põe a entrada na frente", () => {
  const list = [entry("#111111"), entry("#222222")];
  equal(C.pushHistory(list, entry("#333333")).map((item) => item.hex), ["#333333", "#111111", "#222222"]);
});

test("pegar de novo uma cor leva-a para a frente, sem repetir", () => {
  const list = [entry("#111111"), entry("#222222"), entry("#333333")];
  const out = C.pushHistory(list, entry("#333333", { app: "agora" }));
  equal(out.map((item) => item.hex), ["#333333", "#111111", "#222222"]);
  equal(out[0].app, "agora", "vale a entrada nova");
});

test("pegar corta a lista em 12, e a lista que recebi não muda", () => {
  const list = [];
  for (let i = 0; i < 12; ++i)
    list.push(entry("#0000" + (i < 10 ? "0" : "") + i));
  const before = JSON.stringify(list);
  const out = C.pushHistory(list, entry("#ABCDEF"));
  equal(out.length, 12);
  equal(out[0].hex, "#ABCDEF");
  equal(out[11].hex, "#000010", "a mais antiga (#000011) saiu");
  equal(JSON.stringify(list), before, "a lista original ficou como estava");
});
