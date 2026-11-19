// Testes da conta da seleção de área da captura de tela: wintermute-shell/screenshot/Selection.js (ficha 17, "Seleção de área:
// conferido no Figma e como funciona", F6-T11). Partem dos casos que escrevi na F6-T11 (o teste da seleção guardado na P-82), no formato do apoio.js.
//   .agents/scripts/testar.sh selection
.import "apoio.js" as T
.import "screenshot/Selection.js" as S

const test = T.test, equal = T.equal, check = T.check;
const eq = equal;

// Os valores do board e do Theme.qml (ficha 17), repetidos aqui só para os casos serem legíveis.
const W = 720, H = 450;       // o palco do board
const MIN = 8;                // captureHandleSize
const HIT = 16;               // captureHandleHit
const SIZE = { w: 88, h: 24 };        // pílula de tamanho do board
const ACT = { w: 208, h: 48 };        // pílula de ações
const BAR = { x: 112, y: 370, width: 496, height: 56 };
const GAP = 8;

// ---- arrastar para criar ----
test("as quatro direções dão o mesmo retângulo", () => {
  const want = { x: 200, y: 104, width: 320, height: 200 };
  eq(S.fromDrag(200, 104, 520, 304, W, H), want, "de cima à esquerda para baixo à direita");
  eq(S.fromDrag(520, 104, 200, 304, W, H), want, "de cima à direita para baixo à esquerda");
  eq(S.fromDrag(200, 304, 520, 104, W, H), want, "de baixo à esquerda para cima à direita");
  eq(S.fromDrag(520, 304, 200, 104, W, H), want, "de baixo à direita para cima à esquerda");
});

test("o arraste fica preso ao monitor", () => {
  eq(S.fromDrag(600, 300, 900, 700, W, H), { x: 600, y: 300, width: 120, height: 150 });
  eq(S.fromDrag(100, 100, -50, -20, W, H), { x: 0, y: 0, width: 100, height: 100 });
});

test("os pontos viram inteiros", () => {
  eq(S.fromDrag(10.4, 20.6, 30.5, 40.2, W, H), { x: 10, y: 21, width: 21, height: 19 });
});

test("menos de 8 num eixo não cria seleção", () => {
  check(!S.isUsable(S.fromDrag(100, 100, 107, 200, W, H), MIN), "7 de largura");
  check(!S.isUsable(S.fromDrag(100, 100, 200, 107, W, H), MIN), "7 de altura");
  check(!S.isUsable(S.fromDrag(100, 100, 100, 100, W, H), MIN), "clique sem arrastar");
  check(S.isUsable(S.fromDrag(100, 100, 108, 108, W, H), MIN), "8 por 8 vale");
  check(!S.isUsable(null, MIN));
});

// ---- mover ----
test("mover anda o quanto o ponteiro andou", () => {
  eq(S.move({ x: 200, y: 104, width: 320, height: 200 }, 30, -20, W, H), { x: 230, y: 84, width: 320, height: 200 });
});

test("mover não sai do monitor, em nenhum dos quatro lados", () => {
  const r = { x: 200, y: 104, width: 320, height: 200 };
  eq(S.move(r, -500, 0, W, H).x, 0);
  eq(S.move(r, 500, 0, W, H).x, W - 320);
  eq(S.move(r, 0, -500, W, H).y, 0);
  eq(S.move(r, 0, 500, W, H).y, H - 200);
  eq(S.move(r, 500, 500, W, H), { x: 400, y: 250, width: 320, height: 200 }, "o tamanho não muda");
});

// ---- redimensionar ----
const R = { x: 200, y: 104, width: 320, height: 200 };
const area = (rect) => [rect.x, rect.y, rect.x + rect.width, rect.y + rect.height];

test("cada alça mexe nos eixos certos", () => {
  // a seleção original ocupa de (200,104) a (520,304); dx = +10, dy = +6
  const cases = {
    nw: [210, 110, 520, 304],
    n: [200, 110, 520, 304],
    ne: [200, 110, 530, 304],
    e: [200, 104, 530, 304],
    se: [200, 104, 530, 310],
    s: [200, 104, 520, 310],
    sw: [210, 104, 520, 310],
    w: [210, 104, 520, 304]
  };
  S.HANDLES.forEach((handle) => eq(area(S.resize(R, handle, 10, 6, W, H, MIN)), cases[handle], handle));
});

test("as alças do meio das bordas não mexem no outro eixo", () => {
  eq(S.resize(R, "n", 40, 10, W, H, MIN).x, 200);
  eq(S.resize(R, "n", 40, 10, W, H, MIN).width, 320);
  eq(S.resize(R, "e", 40, 10, W, H, MIN).y, 104);
  eq(S.resize(R, "e", 40, 10, W, H, MIN).height, 200);
});

test("passar do lado oposto vira o retângulo", () => {
  // a alça e arrastada 400 para a esquerda: a borda direita (520) passa para 120, à esquerda da fixa (200)
  eq(area(S.resize(R, "e", -400, 0, W, H, MIN)), [120, 104, 200, 304]);
  eq(area(S.resize(R, "w", 400, 0, W, H, MIN)), [520, 104, 600, 304]);
  eq(area(S.resize(R, "s", 0, -250, W, H, MIN)), [200, 54, 520, 104]);
  eq(area(S.resize(R, "n", 0, 250, W, H, MIN)), [200, 304, 520, 354]);
  eq(area(S.resize(R, "se", -400, -250, W, H, MIN)), [120, 54, 200, 104], "o canto vira nos dois eixos");
  eq(area(S.resize(R, "nw", 400, 250, W, H, MIN)), [520, 304, 600, 354]);
});

test("redimensionar não sai do monitor", () => {
  eq(area(S.resize(R, "se", 900, 900, W, H, MIN)), [200, 104, W, H]);
  eq(area(S.resize(R, "nw", -900, -900, W, H, MIN)), [0, 0, 520, 304]);
  eq(area(S.resize(R, "e", -900, 0, W, H, MIN)), [0, 104, 200, 304], "virar também fica preso");
  eq(area(S.resize(R, "w", 900, 0, W, H, MIN)), [520, 104, W, 304]);
});

test("a seleção não encolhe abaixo do mínimo", () => {
  // arrastar a borda direita até a esquerda a 3 px da fixa: fica com 8, do lado em que o ponteiro está
  eq(S.resize(R, "e", -317, 0, W, H, MIN).width, 8, "do lado positivo");
  eq(S.resize(R, "e", -323, 0, W, H, MIN).width, 8, "do lado oposto");
  eq(S.resize(R, "e", -320, 0, W, H, MIN), { x: 200, y: 104, width: 8, height: 200 }, "no zero exato vai para o lado positivo");
});

test("o mínimo muda de lado quando a borda fixa está colada no monitor", () => {
  const colada = { x: 600, y: 100, width: 120, height: 100 };      // borda direita em 720
  eq(area(S.resize(colada, "w", 200, 0, W, H, MIN)), [712, 100, 720, 200], "w arrastada para além da borda direita");
  const noTopo = { x: 100, y: 0, width: 100, height: 100 };        // borda de cima em 0
  eq(area(S.resize(noTopo, "s", 0, -200, W, H, MIN)), [100, 0, 200, 8], "s arrastada para cima de 0");
});

test("o mesmo ponteiro dá a mesma seleção de qualquer ponto de partida (sem acumular erro)", () => {
  const a = S.resize(R, "se", 50, 40, W, H, MIN);
  const b = S.resize(R, "se", 50, 40, W, H, MIN);
  eq(a, b);
});

// ---- o que há sob o ponteiro ----
test("as alças ficam centradas nos cantos e nos meios, como no board", () => {
  const centers = {};
  S.HANDLES.forEach((handle) => { centers[handle] = S.handleCenter(R, handle); });
  eq(centers.nw, { x: 200, y: 104 });
  eq(centers.n, { x: 360, y: 104 });
  eq(centers.ne, { x: 520, y: 104 });
  eq(centers.e, { x: 520, y: 204 });
  eq(centers.se, { x: 520, y: 304 });
  eq(centers.s, { x: 360, y: 304 });
  eq(centers.sw, { x: 200, y: 304 });
  eq(centers.w, { x: 200, y: 204 });
  // o desenho de 8×8 começa 4 antes do centro: x 196, 356 e 516, y 100, 200 e 300
  eq([centers.nw.x - 4, centers.n.x - 4, centers.ne.x - 4], [196, 356, 516]);
  eq([centers.nw.y - 4, centers.w.y - 4, centers.sw.y - 4], [100, 200, 300]);
});

test("a área da alça é de 16×16 em volta do centro", () => {
  eq(S.hitTest(R, 192, 96, HIT), "nw");
  eq(S.hitTest(R, 207, 111, HIT), "nw");
  eq(S.hitTest(R, 208, 111, HIT), "move", "um pixel depois da área");
  eq(S.hitTest(R, 191, 96, HIT), "", "um pixel antes");
  eq(S.hitTest(R, 360, 100, HIT), "n");
  eq(S.hitTest(R, 522, 204, HIT), "e");
  eq(S.hitTest(R, 515, 310, HIT), "se");
});

test("por dentro move, por fora é nova seleção", () => {
  eq(S.hitTest(R, 300, 200, HIT), "move");
  eq(S.hitTest(R, 100, 50, HIT), "");
  eq(S.hitTest(R, 700, 430, HIT), "");
});

test("numa seleção pequena a área das alças encolhe e o miolo continua pegável", () => {
  const small = { x: 100, y: 100, width: 30, height: 30 };
  eq(S.hitTest(small, 115, 115, HIT), "move", "o miolo");
  eq(S.hitTest(small, 100, 100, HIT), "nw");
  const tiny = { x: 100, y: 100, width: 8, height: 8 };
  eq(S.hitTest(tiny, 98, 98, HIT), "nw", "a área mínima é de 4");
  eq(S.hitTest(tiny, 104, 104, HIT), "move");
});

test("a área de cada alça é um terço do lado menor, não a metade (seleção de 30×30: 10 de lado, não 15)", () => {
  // O comentário de hitTest e a ficha 17: a área "encolhe numa seleção pequena, para o miolo continuar movível". 30 / 3 = 10, então a área do
  // canto vai de 95 a 105 em volta do centro (100, 100). Com a metade do lado (15) iria até 107,5.
  const small = { x: 100, y: 100, width: 30, height: 30 };
  eq(S.hitTest(small, 104, 104, HIT), "nw", "a 4 do canto é da alça");
  eq(S.hitTest(small, 106, 106, HIT), "move", "a 6 do canto já é do miolo (seria da alça com metade do lado)");
  eq(S.hitTest(small, 95, 95, HIT), "nw", "a borda de dentro da área, a 5 antes do centro");
  eq(S.hitTest(small, 94, 95, HIT), "", "um pixel antes");
  // o lado menor é que conta: 60 × 24 dá 24 / 3 = 8 (área de 4 em volta do centro), e não 60 / 3 = 20
  const wide = { x: 100, y: 100, width: 60, height: 24 };
  eq(S.hitTest(wide, 103, 103, HIT), "nw", "a 3 do canto");
  eq(S.hitTest(wide, 105, 105, HIT), "move", "a 5 do canto, que só seria da alça se valesse o lado maior");
});

test("a área mínima da alça é de 4: ao lado do canto, o pixel certo já é da alça do meio", () => {
  const tiny = { x: 100, y: 100, width: 8, height: 8 };       // o lado da área seria 8 / 3 = 2, e o mínimo de 4 vale
  eq(S.hitTest(tiny, 101, 100, HIT), "nw", "a área do canto vai de 98 a 101");
  eq(S.hitTest(tiny, 102, 100, HIT), "n", "e a da alça n começa em 102");
});

// ---- as pílulas ----
test("a pílula de tamanho do board: alinhada à esquerda, 8 acima", () => {
  const p = S.sizePill(R, SIZE.w, SIZE.h, GAP, W);
  eq([p.x, p.y, p.where], [200, 72, "above"]);
});

test("a pílula de tamanho vai para dentro perto do topo", () => {
  eq(S.sizePill({ x: 200, y: 32, width: 100, height: 100 }, SIZE.w, SIZE.h, GAP, W).where, "above", "com 32 ainda cabe");
  const p = S.sizePill({ x: 200, y: 31, width: 100, height: 100 }, SIZE.w, SIZE.h, GAP, W);
  eq([p.x, p.y, p.where], [208, 39, "inside"]);
});

test("a pílula de tamanho não sai do monitor na horizontal", () => {
  const p = S.sizePill({ x: 700, y: 200, width: 20, height: 100 }, SIZE.w, SIZE.h, GAP, W);
  eq(p.x, W - SIZE.w);
});

test("a pílula de ações do board: alinhada à direita, 8 abaixo", () => {
  const size = S.sizePill(R, SIZE.w, SIZE.h, GAP, W);
  const p = S.actionsPill(R, ACT.w, ACT.h, GAP, GAP, W, H, size, BAR);
  eq([p.x, p.y, p.where], [312, 312, "below"]);
});

test("as ações vão para cima quando embaixo sai do monitor", () => {
  const sel = { x: 100, y: 200, width: 400, height: 240 };         // base em 440; 448 + 48 > 450
  const size = S.sizePill(sel, SIZE.w, SIZE.h, GAP, W);
  const p = S.actionsPill(sel, ACT.w, ACT.h, GAP, GAP, W, H, size, null);
  eq([p.x, p.y, p.where], [292, 144, "above"]);
});

test("as ações vão para cima quando embaixo encostaria na barra", () => {
  const sel = { x: 160, y: 150, width: 400, height: 190 };         // base em 340; 348 + 48 = 396, e a barra começa em 370
  const size = S.sizePill(sel, SIZE.w, SIZE.h, GAP, W);
  const p = S.actionsPill(sel, ACT.w, ACT.h, GAP, GAP, W, H, size, BAR);
  eq([p.x, p.y, p.where], [352, 94, "above"]);
});

test("a barra só interessa se a pílula chega nela", () => {
  const sel = { x: 100, y: 100, width: 100, height: 100 };         // ações em x 0..208: a barra começa em x 112, então toca
  eq(S.actionsPill(sel, ACT.w, ACT.h, GAP, GAP, W, H, null, { x: 400, y: 300, width: 100, height: 50 }).where, "below", "a barra está longe");
});

test("encostar conta: com a borda de baixo da pílula exatamente na barra (sem sobrepor), as ações vão para cima", () => {
  // O comentário de touches: "encostar conta: a pílula não pode ficar colada na barra". A base da seleção é 314, as ações ficariam em y 322..370 e
  // a barra começa em y 370: as bordas são adjacentes, sem sobreposição, e mesmo assim a pílula não pode ficar ali.
  const sel = { x: 160, y: 124, width: 400, height: 190 };
  const p = S.actionsPill(sel, ACT.w, ACT.h, GAP, GAP, W, H, null, BAR);
  eq([p.x, p.y, p.where], [352, 68, "above"]);
  // com a barra um pixel mais abaixo há folga de 1 e a pílula fica embaixo
  const folga = S.actionsPill(sel, ACT.w, ACT.h, GAP, GAP, W, H, null, { x: BAR.x, y: 371, width: BAR.width, height: BAR.height });
  eq([folga.x, folga.y, folga.where], [352, 322, "below"], "um pixel de folga basta");
});

test("encostar conta também na horizontal: a pílula de ações adjacente à lateral da barra vai para cima", () => {
  // seleção de 200 de largura em x 200: as ações ocupam x 192..400, y 308..356; a barra começa em x 400 e cobre y 330..380 na vertical.
  const sel = { x: 200, y: 100, width: 200, height: 200 };
  const lateral = { x: 400, y: 330, width: 100, height: 50 };
  const p = S.actionsPill(sel, ACT.w, ACT.h, GAP, GAP, W, H, null, lateral);
  eq([p.x, p.y, p.where], [192, 44, "above"]);
  const folga = S.actionsPill(sel, ACT.w, ACT.h, GAP, GAP, W, H, null, { x: 401, y: 330, width: 100, height: 50 });
  eq([folga.x, folga.y, folga.where], [192, 308, "below"], "um pixel de folga basta");
});

test("encostar conta também para a pílula de tamanho: as ações em cima, adjacentes a ela na horizontal, vão para dentro", () => {
  // seleção em x 200..496: a pílula de tamanho ocupa x 200..288 (y 72..96) e as ações, em cima, ocupariam x 288..496 (y 48..96). A borda direita
  // da pílula de tamanho (288) é a esquerda das ações, sem sobrepor. Embaixo não cabe (a base está em 448).
  const sel = { x: 200, y: 104, width: 296, height: 344 };
  const size = S.sizePill(sel, SIZE.w, SIZE.h, GAP, W);
  eq([size.x, size.y, size.width], [200, 72, 88]);
  const p = S.actionsPill(sel, ACT.w, ACT.h, GAP, GAP, W, H, size, null);
  eq(p.where, "inside");
  // com a seleção 1 pixel mais larga as ações passam a x 289 e há folga: ficam em cima
  const larga = { x: 200, y: 104, width: 297, height: 344 };
  const p2 = S.actionsPill(larga, ACT.w, ACT.h, GAP, GAP, W, H, S.sizePill(larga, SIZE.w, SIZE.h, GAP, W), null);
  eq([p2.x, p2.y, p2.where], [289, 48, "above"], "um pixel de folga basta");
});

test("as ações vão para dentro quando em cima também não cabe", () => {
  const sel = { x: 100, y: 20, width: 600, height: 430 };          // embaixo: sai do monitor; em cima: y < 0
  const size = S.sizePill(sel, SIZE.w, SIZE.h, GAP, W);
  const p = S.actionsPill(sel, ACT.w, ACT.h, GAP, GAP, W, H, size, BAR);
  eq([p.x, p.y, p.where], [484, 394, "inside"]);
});

test("as ações vão para dentro quando em cima cobririam a pílula de tamanho", () => {
  const sel = { x: 440, y: 250, width: 280, height: 200 };         // encostada na direita e na base
  const size = S.sizePill(sel, SIZE.w, SIZE.h, GAP, W);
  const p = S.actionsPill(sel, ACT.w, ACT.h, GAP, GAP, W, H, size, BAR);
  eq(p.where, "inside");
  eq([p.x, p.y], [W - GAP - ACT.w, H - GAP - ACT.h]);
});

test("as ações ficam a pelo menos 8 das bordas na horizontal", () => {
  const left = S.actionsPill({ x: 0, y: 100, width: 60, height: 60 }, ACT.w, ACT.h, GAP, GAP, W, H, null, null);
  eq(left.x, GAP, "seleção colada na esquerda");
  const right = S.actionsPill({ x: 660, y: 100, width: 60, height: 60 }, ACT.w, ACT.h, GAP, GAP, W, H, null, null);
  eq(right.x, W - GAP - ACT.w, "seleção colada na direita");
});

test("nenhuma pílula sai do monitor, em seleções de todo tipo", () => {
  const sizes = [8, 20, 60, 200, 400, 720];
  let cases = 0;
  for (const sw of sizes) {
    for (const sh of sizes.filter((v) => v <= H)) {
      for (const sx of [0, 100, W - sw]) {
        for (const sy of [0, 30, 150, H - sh]) {
          if (sx + sw > W || sy + sh > H || sx < 0 || sy < 0)
            continue;
          const sel = { x: sx, y: sy, width: sw, height: sh };
          const size = S.sizePill(sel, SIZE.w, SIZE.h, GAP, W);
          const act = S.actionsPill(sel, ACT.w, ACT.h, GAP, GAP, W, H, size, BAR);
          cases++;
          const within = (p) => p.x >= 0 && p.x + p.width <= W && p.y >= 0 && p.y + p.height <= H;
          check(within(act), "ações fora: " + JSON.stringify([sel, act]));
          check(act.x >= GAP && act.x + act.width <= W - GAP, "ações a menos de 8 da borda: " + JSON.stringify([sel, act]));
          check(size.x >= 0 && size.x + size.width <= W && size.y >= 0, "tamanho fora: " + JSON.stringify([sel, size]));
        }
      }
    }
  }
  check(cases > 50);
});
