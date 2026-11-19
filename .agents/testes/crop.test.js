// Testes do recorte da captura de tela: wintermute-shell/screenshot/Crop.js (importa o screenshot/Windows.js, e o script copia os dois).
// Os casos saem da ficha 17, seção "Capturar e copiar: como funciona" (F6-T13, decisão 0017): o recorte é em pixels do quadro congelado,
// e "a seleção de 320×200 num monitor de escala 2 dá 640×400, o mesmo número que a pílula de tamanho mostra". As contas conferi à mão.
//   .agents/scripts/testar.sh crop
.import "apoio.js" as T
.import "screenshot/Crop.js" as C
.import "screenshot/Windows.js" as W

const test = T.test, equal = T.equal, check = T.check;

// O monitor de 1280×720 pixels lógicos, e o quadro dele em cada escala.
const MON = { width: 1280, height: 720 };
const FRAME = { 1: { w: 1280, h: 720 }, 1.5: { w: 1920, h: 1080 }, 2: { w: 2560, h: 1440 } };
const crop = (rect, scale) => C.toPixels(rect, MON.width, MON.height, FRAME[scale].w, FRAME[scale].h);

// ---- a conta: escala 1, 2 e 1,5 ----

test("escala 1: o recorte é o próprio retângulo", () => {
  equal(crop({ x: 100, y: 60, width: 320, height: 200 }, 1), { x: 100, y: 60, width: 320, height: 200 });
});

test("escala 2: a seleção de 320×200 dá um PNG de 640×400", () => {
  equal(crop({ x: 100, y: 60, width: 320, height: 200 }, 2), { x: 200, y: 120, width: 640, height: 400 });
});

test("escala 1,5: tudo vezes 1,5, nos números inteiros", () => {
  equal(crop({ x: 100, y: 60, width: 320, height: 200 }, 1.5), { x: 150, y: 90, width: 480, height: 300 });
});

test("escala 1,5 com meio pixel: arredondo a origem e o tamanho, cada um, e não as duas bordas", () => {
  // x 101 × 1,5 = 151,5 → 152; largura 321 × 1,5 = 481,5 → 482. Pelas bordas seria a direita 422 × 1,5 = 633 menos 152 = 481, e o PNG sairia
  // com 1 px a menos do que a pílula de tamanho mostra.
  const rect = { x: 101, y: 61, width: 321, height: 201 };
  const out = crop(rect, 1.5);
  equal(out, { x: 152, y: 92, width: 482, height: 302 });
  const shown = W.pixelSize(rect, 1.5, 1.5);
  equal([out.width, out.height], [shown.width, shown.height], "o PNG tem o tamanho que a pílula mostra");
});

test("o PNG tem sempre o tamanho que a pílula de tamanho mostra, em qualquer escala", () => {
  [1, 1.5, 2].forEach((scale) => {
    [{ x: 0, y: 0, width: 7, height: 9 }, { x: 33, y: 17, width: 333, height: 201 }, { x: 5, y: 5, width: 1000, height: 600 }].forEach((rect) => {
      const out = crop(rect, scale);
      const shown = W.pixelSize(rect, scale, scale);
      equal([out.width, out.height], [shown.width, shown.height], JSON.stringify([scale, rect]));
    });
  });
});

test("o monitor inteiro dá o quadro todo", () => {
  equal(crop({ x: 0, y: 0, width: 1280, height: 720 }, 1.5), { x: 0, y: 0, width: 1920, height: 1080 });
  equal(crop({ x: 0, y: 0, width: 1280, height: 720 }, 2), { x: 0, y: 0, width: 2560, height: 1440 });
});

test("razões diferentes em cada eixo: cada eixo usa a sua", () => {
  // o monitor de 100×50 num quadro de 200×150: a razão é 2 na horizontal e 3 na vertical
  equal(C.toPixels({ x: 10, y: 10, width: 50, height: 20 }, 100, 50, 200, 150), { x: 20, y: 30, width: 100, height: 60 });
});

// ---- o que sai do monitor ----

test("a janela que sai da tela entrega só a parte que se vê", () => {
  equal(crop({ x: -50, y: -20, width: 200, height: 100 }, 1), { x: 0, y: 0, width: 150, height: 80 }, "saindo por cima e pela esquerda");
  equal(crop({ x: 1200, y: 700, width: 200, height: 100 }, 1), { x: 1200, y: 700, width: 80, height: 20 }, "saindo por baixo e pela direita");
  equal(crop({ x: -100, y: -100, width: 2000, height: 2000 }, 2), { x: 0, y: 0, width: 2560, height: 1440 }, "cobrindo o monitor todo");
});

test("a janela toda fora do monitor, ou sem área, não dá recorte", () => {
  equal(crop({ x: 1300, y: 100, width: 100, height: 100 }, 1), null, "à direita");
  equal(crop({ x: -200, y: 100, width: 100, height: 100 }, 1), null, "à esquerda");
  equal(crop({ x: 100, y: 800, width: 100, height: 100 }, 1), null, "embaixo");
  equal(crop({ x: 100, y: 100, width: 0, height: 50 }, 1), null, "largura zero");
  equal(crop({ x: 100, y: 100, width: 50, height: -5 }, 1), null, "altura negativa");
  equal(crop({ x: 1280, y: 0, width: 50, height: 50 }, 1), null, "encostada na borda de fora");
});

test("sem retângulo, ou com monitor ou quadro inválidos, não dá recorte", () => {
  const rect = { x: 0, y: 0, width: 10, height: 10 };
  equal(C.toPixels(null, 1280, 720, 1280, 720), null);
  equal(C.toPixels(undefined, 1280, 720, 1280, 720), null);
  equal(C.toPixels(rect, 0, 720, 1280, 720), null, "monitor sem largura");
  equal(C.toPixels(rect, 1280, 0, 1280, 720), null);
  equal(C.toPixels(rect, 1280, 720, 0, 720), null, "quadro sem largura");
  equal(C.toPixels(rect, 1280, 720, 1280, NaN), null);
  equal(C.toPixels(rect, 1280, 720, undefined, 720), null);
});

test("o arredondamento nunca passa do quadro, e o recorte tem ao menos 1 pixel", () => {
  // um monitor de 3 pixels num quadro de 4: razão 1,333; a origem 2 vira 2,667 → 3, e a largura de 1 vira 1,333 → 1
  equal(C.toPixels({ x: 2, y: 0, width: 1, height: 3 }, 3, 3, 4, 3), { x: 3, y: 0, width: 1, height: 3 });
  let checked = 0;
  [[1000, 1001], [1000, 1999], [7, 11], [3, 4], [1920, 2881]].forEach((pair) => {
    for (let x = 0; x < pair[0]; x += Math.max(1, Math.floor(pair[0] / 9))) {
      for (const w of [1, 2, Math.floor(pair[0] / 3), pair[0] - x]) {
        const out = C.toPixels({ x: x, y: x, width: w, height: w }, pair[0], pair[0], pair[1], pair[1]);
        if (out === null)
          continue;
        checked++;
        check(out.width >= 1 && out.height >= 1, "menos de 1 pixel: " + JSON.stringify([pair, x, w, out]));
        check(out.x >= 0 && out.y >= 0 && out.x + out.width <= pair[1] && out.y + out.height <= pair[1], "passou do quadro: " + JSON.stringify([pair, x, w, out]));
      }
    }
  });
  check(checked > 30, "poucos casos conferidos: " + checked);
});

// ---- o modo tela ----

test("o modo tela é o quadro inteiro", () => {
  equal(C.screenPixels(1920, 1080), { x: 0, y: 0, width: 1920, height: 1080 });
  equal(C.screenPixels(0, 1080), null);
  equal(C.screenPixels(1920, undefined), null);
});

// ---- a janela escolhida ----

const layout = (x, y, w, h) => ({ tile_pos_in_workspace_view: [x - 8, y - 8], window_offset_in_tile: [8, 8], window_size: [w, h] });
const snapshot = {
  "eDP-1": [{ id: 7, layout: layout(360, 56, 320, 300) }, { id: 8, layout: null }],
  "HDMI-A-1": [{ id: 9, layout: layout(0, 0, 800, 600) }]
};

test("o retângulo da janela e o monitor dela, achados na foto das janelas", () => {
  equal(C.findWindow(snapshot, 7), { output: "eDP-1", rect: { x: 360, y: 56, width: 320, height: 300 } });
  equal(C.findWindow(snapshot, 9), { output: "HDMI-A-1", rect: { x: 0, y: 0, width: 800, height: 600 } });
  equal(C.findWindow(snapshot, 7).rect, W.place(snapshot["eDP-1"][0].layout), "a conta da posição é a do Windows.place");
});

test("janela que não está em monitor nenhum, ou que não tem posição, não é achada", () => {
  equal(C.findWindow(snapshot, 99), null);
  equal(C.findWindow(snapshot, 8), null, "sem posição");
  equal(C.findWindow({}, 7), null);
  equal(C.findWindow(null, 7), null);
  equal(C.findWindow(undefined, 7), null);
  equal(C.findWindow({ "eDP-1": null }, 7), null);
});
