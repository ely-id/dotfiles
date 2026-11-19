// Testes do editor de anotação da captura de tela: wintermute-shell/screenshot/Annotate.js. Os casos saem da ficha 17, seção "Editor de
// anotação: conferido no Figma e como funciona" (F6-T14): a área da imagem é de 688×408; o lápis, o contorno do retângulo e a haste da seta
// têm 3 de espessura; o retângulo tem raio 8; o marca-texto tem 20 a 35% com raio 2; a ponta da seta é um glifo de 20; o texto é de 17.
// "Numa imagem de 1600×1000, o contorno de 3 sai com 7 px."
//   .agents/scripts/testar.sh annotate
.import "apoio.js" as T
.import "screenshot/Annotate.js" as A

const test = T.test, equal = T.equal, check = T.check, near = T.near;

const AREA = { w: 688, h: 408 };
// Os valores da tela que quem chama lê do Theme.qml (os da ficha, acima); a cor é um texto qualquer.
const STYLE = { color: "mark-color", pencilWidth: 3, strokeWidth: 3, rectRadius: 8, thickness: 20, opacity: 0.35, stripRadius: 2, head: 20, fontSize: 17 };

const natural = A.fit(320, 200, AREA.w, AREA.h);            // a imagem pequena: tamanho natural, centrada em (184, 104)
const half = A.fit(640, 400, AREA.w, AREA.h, 0.5);          // monitor de escala 2: um pixel da imagem é um pixel do monitor
const big = A.fit(1600, 1000, AREA.w, AREA.h);              // a imagem grande, reduzida para caber

// Um ponto da tela com a origem da imagem de tamanho natural.
const onScreen = (x, y) => ({ x: natural.x + x, y: natural.y + y });

// ---- a vista: onde a imagem fica na área ----

test("a imagem menor que a área aparece no tamanho natural, centrada, em pixel inteiro", () => {
  equal([natural.scale, natural.x, natural.y, natural.width, natural.height], [1, 184, 104, 320, 200]);
  equal([natural.imageWidth, natural.imageHeight], [320, 200]);
});

test("a imagem maior que a área cabe inteira, sem deformar: 1600×1000 em 688×408 dá escala 0,408", () => {
  // min(688/1600, 408/1000) = min(0,43, 0,408) = 0,408
  near(big.scale, 0.408, 1e-9);
  near(big.width, 652.8, 1e-9);
  equal(big.height, 408);
  equal([big.x, big.y], [18, 0], "(688 - 652,8) / 2 = 17,6 arredonda para 18");
});

test("só a largura passa: a imagem encolhe até a largura e fica centrada na altura", () => {
  const view = A.fit(1376, 408, AREA.w, AREA.h);
  equal([view.scale, view.width, view.height, view.x, view.y], [0.5, 688, 204, 0, 102]);
});

test("num monitor com escala a captura aparece do tamanho que tinha na tela", () => {
  // a imagem de 640×400 pixels do monitor, com escala 2: 320×200 pixels lógicos, que é o que o maxScale 0,5 dá
  equal([half.scale, half.width, half.height, half.x, half.y], [0.5, 320, 200, 184, 104]);
});

test("sem imagem ou sem área, não há vista", () => {
  equal(A.fit(0, 100, AREA.w, AREA.h), null);
  equal(A.fit(100, -1, AREA.w, AREA.h), null);
  equal(A.fit(100, 100, 0, AREA.h), null);
  equal(A.fit(NaN, 100, AREA.w, AREA.h), null);
  equal(A.fit(100, 100, AREA.w, undefined), null);
});

test("o maxScale que não presta vale 1", () => {
  equal(A.fit(320, 200, AREA.w, AREA.h, 0).scale, 1);
  equal(A.fit(320, 200, AREA.w, AREA.h, undefined).scale, 1);
  equal(A.fit(320, 200, AREA.w, AREA.h, -3).scale, 1);
});

test("da tela para a imagem e de volta; o ponto fora da imagem fica preso à borda dela", () => {
  equal(A.toImage(natural, 184 + 100, 104 + 50), { x: 100, y: 50 });
  equal(A.toImage(half, 184 + 160, 104 + 100), { x: 320, y: 200 }, "com a escala 0,5 cada pixel da tela são 2 da imagem");
  equal(A.toImage(natural, 0, 0), { x: 0, y: 0 });
  equal(A.toImage(natural, 900, 900), { x: 320, y: 200 });
  equal(A.toScreen(natural, { x: 100, y: 50 }), { x: 284, y: 154 });
  equal(A.toScreen(half, { x: 320, y: 200 }), { x: 344, y: 204 });
});

test("o ponto preso à vista, e se um ponto está dentro dela", () => {
  equal(A.clampToView(natural, 0, 0), { x: 184, y: 104 });
  equal(A.clampToView(natural, 900, 900), { x: 504, y: 304 });
  equal(A.clampToView(natural, 300, 200), { x: 300, y: 200 });
  check(A.inside(natural, 184, 104), "o canto");
  check(A.inside(natural, 504, 304), "o canto oposto");
  check(!A.inside(natural, 183, 200));
  check(!A.inside(natural, 300, 305));
});

// ---- as marcas, a partir do arraste ----

test("o lápis: traço livre de 3, com os pontos em pixels da imagem", () => {
  equal(A.build("pencil", STYLE, natural, [onScreen(5, 5), onScreen(15, 25), onScreen(30, 20)]), {
    type: "pencil", color: "mark-color", width: 3, points: [{ x: 5, y: 5 }, { x: 15, y: 25 }, { x: 30, y: 20 }]
  });
});

test("um clique sem arrastar vira um ponto: o traço de comprimento zero", () => {
  const mark = A.build("pencil", STYLE, natural, [onScreen(10, 10)]);
  equal(mark.points, [{ x: 10, y: 10 }, { x: 10, y: 10 }]);
  check(A.isDot(mark), "isDot");
  check(!A.isDot(A.build("pencil", STYLE, natural, [onScreen(10, 10), onScreen(11, 10)])), "um pixel de arraste já é traço");
});

test("o marca-texto: faixa reta de 20 a 35%, com raio 2, do aperto ao soltar", () => {
  equal(A.build("highlighter", STYLE, natural, [onScreen(0, 0), onScreen(50, 5), onScreen(100, 0)]), {
    type: "highlight", color: "mark-color", opacity: 0.35, thickness: 20, radius: 2, a: { x: 0, y: 0 }, b: { x: 100, y: 0 }
  });
});

test("o retângulo: contorno de 3 com raio 8, do canto onde apertei ao canto onde soltei, em qualquer direção", () => {
  const want = { type: "rect", color: "mark-color", strokeWidth: 3, radius: 8, x: 10, y: 20, width: 40, height: 40 };
  equal(A.build("rectangle", STYLE, natural, [onScreen(10, 20), onScreen(50, 60)]), want);
  equal(A.build("rectangle", STYLE, natural, [onScreen(50, 60), onScreen(10, 20)]), want, "de baixo à direita para cima à esquerda");
  equal(A.build("rectangle", STYLE, natural, [onScreen(50, 20), onScreen(10, 60)]), want);
});

test("a seta: haste de 3 com raio 2 e a ponta de 20, de a até b", () => {
  equal(A.build("arrow", STYLE, natural, [onScreen(10, 10), onScreen(90, 50)]), {
    type: "arrow", color: "mark-color", strokeWidth: 3, radius: 2, head: 20, a: { x: 10, y: 10 }, b: { x: 90, y: 50 }
  });
});

test("arrastar menos de 4 não cria marca-texto, retângulo nem seta", () => {
  equal(A.MIN_DRAG, 4);
  equal(A.build("highlighter", STYLE, natural, [onScreen(0, 0), onScreen(3, 0)]), null, "marca-texto com 3");
  check(A.build("highlighter", STYLE, natural, [onScreen(0, 0), onScreen(4, 0)]) !== null, "marca-texto com 4 vale");
  equal(A.build("arrow", STYLE, natural, [onScreen(0, 0), onScreen(2, 2)]), null, "seta de uns 2,8");
  check(A.build("arrow", STYLE, natural, [onScreen(0, 0), onScreen(0, 4)]) !== null, "seta com 4 vale");
  equal(A.build("rectangle", STYLE, natural, [onScreen(0, 0), onScreen(3, 50)]), null, "3 de largura");
  equal(A.build("rectangle", STYLE, natural, [onScreen(0, 0), onScreen(50, 3)]), null, "3 de altura");
  check(A.build("rectangle", STYLE, natural, [onScreen(0, 0), onScreen(4, 4)]) !== null, "4 por 4 vale");
});

test("o que eu vejo é o que sai: numa imagem reduzida, as espessuras são divididas pela escala", () => {
  // 1600×1000 na tela a 0,408: o contorno de 3 sai com 3 / 0,408 = 7,35 → 7 px no arquivo (o número que a ficha dá)
  const p = (x, y) => ({ x: big.x + x * big.scale, y: big.y + y * big.scale });
  const rect = A.build("rectangle", STYLE, big, [p(100, 100), p(500, 400)]);
  near(rect.strokeWidth, 7.3529, 0.001);
  equal(Math.round(rect.strokeWidth), 7);
  near(rect.radius, 8 / 0.408, 1e-9);
  near(rect.width, 400, 1e-6);
  const arrow = A.build("arrow", STYLE, big, [p(0, 0), p(300, 300)]);
  near(arrow.head, 20 / 0.408, 1e-9);
  near(A.build("highlighter", STYLE, big, [p(0, 0), p(300, 0)]).thickness, 20 / 0.408, 1e-9);
});

test("com a escala 0,5 o traço do lápis de 3 sai com 6 pixels no arquivo", () => {
  const mark = A.build("pencil", STYLE, half, [{ x: 184 + 10, y: 104 + 10 }, { x: 184 + 20, y: 104 + 20 }]);
  equal(mark.width, 6);
  equal(mark.points, [{ x: 20, y: 20 }, { x: 40, y: 40 }]);
});

test("a cor vira texto: a marca não muda de cor quando eu troco a cor das próximas", () => {
  const live = { toString: function () { return "#abcdef"; } };
  const mark = A.build("rectangle", Object.assign({}, STYLE, { color: live }), natural, [onScreen(0, 0), onScreen(50, 50)]);
  equal(typeof mark.color, "string");
  equal(mark.color, "#abcdef");
});

test("o texto e o recorte não saem do build, e sem vista ou sem pontos não há marca", () => {
  equal(A.build("text", STYLE, natural, [onScreen(0, 0), onScreen(50, 50)]), null);
  equal(A.build("crop", STYLE, natural, [onScreen(0, 0), onScreen(50, 50)]), null);
  equal(A.build("pencil", STYLE, null, [onScreen(0, 0)]), null);
  equal(A.build("pencil", STYLE, natural, []), null);
  equal(A.build("pencil", STYLE, natural, null), null);
});

test("a marca de texto: o canto de cima à esquerda, o tamanho 17 e o que o texto mediu, tudo em pixels da imagem", () => {
  equal(A.textMark(STYLE, natural, onScreen(10, 20), "hi", 30, 20), { type: "text", color: "mark-color", size: 17, text: "hi", x: 10, y: 20, width: 30, height: 20 });
  equal(A.textMark(STYLE, half, { x: 184 + 10, y: 104 + 20 }, "hi", 30, 20),
      { type: "text", color: "mark-color", size: 34, text: "hi", x: 20, y: 40, width: 60, height: 40 }, "com escala 0,5, o dobro");
});

test("texto vazio, só de espaços ou que não é texto não vira marca", () => {
  equal(A.textMark(STYLE, natural, onScreen(0, 0), "", 0, 0), null);
  equal(A.textMark(STYLE, natural, onScreen(0, 0), "   \n ", 10, 10), null);
  equal(A.textMark(STYLE, natural, onScreen(0, 0), null, 10, 10), null);
  equal(A.textMark(STYLE, null, onScreen(0, 0), "oi", 10, 10), null);
  check(A.textMark(STYLE, natural, onScreen(0, 0), " oi ", 10, 10).text === " oi ", "o texto confirmado fica como digitei");
});

// ---- as caixas das marcas ----

test("a caixa de cada marca: o lápis engrossa meia espessura, a faixa e a seta também", () => {
  equal(A.bounds({ type: "pencil", width: 4, points: [{ x: 10, y: 10 }, { x: 20, y: 30 }] }), { x0: 8, y0: 8, x1: 22, y1: 32 });
  equal(A.bounds({ type: "highlight", thickness: 20, a: { x: 0, y: 0 }, b: { x: 100, y: 0 } }), { x0: -10, y0: -10, x1: 110, y1: 10 });
  // na seta vale o maior entre a haste e a ponta: 20 / 2 = 10 de cada lado
  equal(A.bounds({ type: "arrow", strokeWidth: 3, head: 20, a: { x: 50, y: 50 }, b: { x: 10, y: 90 } }), { x0: 0, y0: 40, x1: 60, y1: 100 });
  equal(A.bounds({ type: "rect", x: 5, y: 6, width: 10, height: 20 }), { x0: 5, y0: 6, x1: 15, y1: 26 });
  equal(A.bounds({ type: "text", x: 5, y: 6, width: 10, height: 20 }), { x0: 5, y0: 6, x1: 15, y1: 26 });
  equal(A.bounds({ type: "desconhecida" }), { x0: 0, y0: 0, x1: 0, y1: 0 });
});

test("deslocar uma marca mexe só na posição, e não na marca original", () => {
  const rect = { type: "rect", color: "c", strokeWidth: 3, x: 10, y: 20, width: 5, height: 6 };
  equal(A.shift(rect, -4, 3), { type: "rect", color: "c", strokeWidth: 3, x: 6, y: 23, width: 5, height: 6 });
  equal(rect.x, 10);
  const arrow = { type: "arrow", a: { x: 1, y: 2 }, b: { x: 3, y: 4 }, head: 20 };
  equal(A.shift(arrow, 10, 10), { type: "arrow", a: { x: 11, y: 12 }, b: { x: 13, y: 14 }, head: 20 });
  const pencil = { type: "pencil", width: 3, points: [{ x: 1, y: 1 }, { x: 2, y: 2 }] };
  equal(A.shift(pencil, 1, -1).points, [{ x: 2, y: 0 }, { x: 3, y: 1 }]);
  equal(pencil.points[0], { x: 1, y: 1 });
  equal(A.shift({ type: "text", x: 1, y: 2, text: "t" }, 5, 5), { type: "text", x: 6, y: 7, text: "t" });
});

// ---- o documento: marcas e desfazer ----

const rect = (x, y, w, h) => ({ type: "rect", color: "c", strokeWidth: 3, radius: 8, x: x, y: y, width: w, height: h });

test("o documento começa vazio, sem nada para desfazer", () => {
  const state = A.create(1000, 800);
  equal(state, { width: 1000, height: 800, origin: { x: 0, y: 0 }, marks: [], history: [] });
  check(!A.canUndo(state));
  check(!A.canUndo(null));
  check(A.undo(state) === state, "desfazer sem nada devolve o mesmo documento");
});

test("pôr uma marca devolve um documento novo, e o de antes não muda", () => {
  const state = A.create(1000, 800);
  const next = A.addMark(state, rect(1, 2, 3, 4));
  equal(next.marks.length, 1);
  equal(next.history, [{ type: "mark" }]);
  equal(state.marks.length, 0);
  check(A.canUndo(next));
});

test("desfazer tira a última marca, uma por vez", () => {
  let state = A.create(100, 100);
  state = A.addMark(state, rect(1, 1, 5, 5));
  state = A.addMark(state, rect(2, 2, 5, 5));
  state = A.undo(state);
  equal(state.marks.map((m) => m.x), [1]);
  state = A.undo(state);
  equal(state.marks, []);
  check(!A.canUndo(state));
});

// ---- o recorte ----

const R1 = rect(100, 100, 50, 50);       // dentro do recorte
const R2 = rect(800, 600, 50, 50);       // fora dele
const R3 = rect(180, 150, 100, 100);     // metade dentro, metade fora
const full = [R1, R2, R3].reduce((state, mark) => A.addMark(state, mark), A.create(1000, 800));
const cropRect = { x: 50, y: 50, width: 200, height: 200 };

test("recortar: a imagem vira só o pedaço, e a origem diz onde ele começava", () => {
  const out = A.crop(full, cropRect);
  equal([out.width, out.height, out.origin], [200, 200, { x: 50, y: 50 }]);
});

test("recortar: as marcas fora do pedaço somem e as que o tocam vão para a origem nova", () => {
  const out = A.crop(full, cropRect);
  equal(out.marks, [rect(50, 50, 50, 50), rect(130, 100, 100, 100)]);
});

test("a marca que só encosta na borda do recorte está fora dele", () => {
  const edge = A.addMark(A.create(1000, 800), rect(0, 100, 50, 50));   // vai de x 0 a 50, e o recorte começa em 50
  equal(A.crop(edge, cropRect).marks, []);
});

test("recortar guarda o que havia, e desfazer devolve a imagem, a origem e as marcas de antes", () => {
  const out = A.crop(full, cropRect);
  equal(out.history.map((h) => h.type), ["mark", "mark", "mark", "crop"]);
  const back = A.undo(out);
  equal([back.width, back.height, back.origin], [1000, 800, { x: 0, y: 0 }]);
  equal(back.marks, [R1, R2, R3]);
  equal(back.history.map((h) => h.type), ["mark", "mark", "mark"]);
});

test("desfazer anda um passo por vez: a marca nova, depois o recorte", () => {
  let state = A.crop(full, cropRect);
  state = A.addMark(state, rect(0, 0, 10, 10));
  equal(state.marks.length, 3);
  state = A.undo(state);
  equal([state.width, state.marks.length], [200, 2], "tirou a marca e ficou recortado");
  state = A.undo(state);
  equal([state.width, state.marks.length], [1000, 3], "desfez o recorte");
});

test("o segundo recorte soma a origem ao primeiro", () => {
  const second = A.crop(A.crop(full, cropRect), { x: 10, y: 10, width: 100, height: 100 });
  equal([second.width, second.height, second.origin], [100, 100, { x: 60, y: 60 }]);
});

test("recortar a imagem inteira, um retângulo vazio ou nenhum não muda nada", () => {
  check(A.crop(full, { x: 0, y: 0, width: 1000, height: 800 }) === full, "a imagem inteira");
  check(A.crop(full, { x: 0, y: 0, width: 2000, height: 2000 }) === full, "passando dela, que é a imagem inteira");
  check(A.crop(full, { x: 10, y: 10, width: 0, height: 50 }) === full, "largura zero");
  check(A.crop(full, { x: 10, y: 10, width: 50, height: 0.4 }) === full, "altura que arredonda para zero");
  check(A.crop(full, null) === full, "nenhum retângulo");
  check(A.crop(null, cropRect) === null);
});

test("o recorte que passa da imagem fica preso a ela, e os números arredondam", () => {
  const clamped = A.crop(full, { x: -20, y: -20, width: 120, height: 120 });
  equal([clamped.width, clamped.height, clamped.origin], [100, 100, { x: 0, y: 0 }]);
  const rounded = A.crop(full, { x: 10.4, y: 10.6, width: 100.2, height: 50 });
  equal([rounded.width, rounded.height, rounded.origin], [101, 50, { x: 10, y: 11 }]);
});

// ---- o recorte na tela ----

test("arrastar o recorte: o retângulo normalizado e preso ao lugar onde a imagem aparece", () => {
  equal(A.cropFromDrag(natural, 500, 300, 300, 150), { x: 300, y: 150, width: 200, height: 150 });
  equal(A.cropFromDrag(natural, 100, 50, 600, 400), { x: 184, y: 104, width: 320, height: 200 }, "começando e acabando fora da imagem");
  equal(A.cropFromDrag(natural, 300.4, 150.6, 500.5, 300.4), { x: 300, y: 151, width: 201, height: 149 }, "inteiros");
});

test("soltar com menos de 8 num eixo não deixa recorte, como na seleção de área", () => {
  check(!A.cropUsable({ x: 0, y: 0, width: 7, height: 100 }, 8), "7 de largura");
  check(!A.cropUsable({ x: 0, y: 0, width: 100, height: 7 }, 8), "7 de altura");
  check(A.cropUsable({ x: 0, y: 0, width: 8, height: 8 }, 8), "8 por 8 vale");
  check(!A.cropUsable(null, 8));
});

test("o recorte da tela em pixels da imagem, inteiros e presos a ela", () => {
  equal(A.cropToImage(natural, { x: 184 + 10, y: 104 + 20, width: 100, height: 60 }), { x: 10, y: 20, width: 100, height: 60 });
  equal(A.cropToImage(half, { x: 184 + 100, y: 104 + 50, width: 100, height: 60 }), { x: 200, y: 100, width: 200, height: 120 }, "escala 0,5");
  equal(A.cropToImage(half, { x: 100, y: 104, width: 100, height: 50 }), { x: 0, y: 0, width: 32, height: 100 }, "começando fora da imagem");
  equal(A.cropToImage(natural, { x: 400, y: 250, width: 500, height: 500 }), { x: 216, y: 146, width: 104, height: 54 }, "passando do fim");
});

// ---- a direção da seta ----

test("o ângulo da direção de a para b, em graus: 0 para a direita, como o chevron-right", () => {
  equal(A.angle({ x: 0, y: 0 }, { x: 10, y: 0 }), 0);
  equal(A.angle({ x: 0, y: 0 }, { x: 0, y: 10 }), 90, "para baixo, como na tela");
  equal(A.angle({ x: 0, y: 0 }, { x: -10, y: 0 }), 180);
  equal(A.angle({ x: 0, y: 0 }, { x: 0, y: -10 }), -90);
  near(A.angle({ x: 5, y: 5 }, { x: 15, y: 15 }), 45, 1e-9);
});
