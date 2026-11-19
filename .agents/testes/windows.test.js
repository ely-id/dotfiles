// Testes dos modos Window e Screen da captura de tela: wintermute-shell/screenshot/Windows.js. Os casos saem da ficha 17, seção "Modo
// janela e modo tela: conferido no Figma e como funcionam" (F6-T12). O exemplo do board é a janela de 320×300 em (360,56), com o
// anel de 2 px em (358,54) e a pílula "Firefox · 320 × 300" de 152 de largura.
//   .agents/scripts/testar.sh windows
.import "apoio.js" as T
.import "screenshot/Windows.js" as W

const test = T.test, equal = T.equal, check = T.check;

// O `layout` cru do IPC do Niri: o bloco da janela na vista do workspace, o deslocamento da janela dentro do bloco e o tamanho dela.
const layout = (tile, offset, size) => ({ tile_pos_in_workspace_view: tile, window_offset_in_tile: offset, window_size: size });
const win = (id, extra) => Object.assign({ id: id, appId: "app" + id, title: "", entryName: "", isFloating: false, layout: layout([0, 0], [0, 0], [100, 100]) }, extra || {});

// ---- onde a janela está ----

test("a posição é o bloco mais o deslocamento, e o tamanho é o da janela", () => {
  // a ficha: posição = tile_pos_in_workspace_view + window_offset_in_tile; tamanho = window_size
  equal(W.place(layout([352, 48], [8, 8], [320, 300])), { x: 360, y: 56, width: 320, height: 300 });   // a janela do board
  equal(W.place(layout([0, 0], [0, 0], [1920, 1080])), { x: 0, y: 0, width: 1920, height: 1080 });
});

test("a posição arredonda para pixel inteiro, e o tamanho fica como o Niri deu", () => {
  equal(W.place(layout([100.4, 20.6], [0.3, 0.3], [320, 300])), { x: 101, y: 21, width: 320, height: 300 });
});

test("sem a posição, o tamanho ou o deslocamento, a janela fica de fora", () => {
  equal(W.place(null), null);
  equal(W.place(undefined), null);
  equal(W.place({}), null);
  equal(W.place({ window_offset_in_tile: [0, 0], window_size: [1, 1] }), null, "sem o bloco");
  equal(W.place({ tile_pos_in_workspace_view: [0, 0], window_size: [1, 1] }), null, "sem o deslocamento");
  equal(W.place({ tile_pos_in_workspace_view: [0, 0], window_offset_in_tile: [0, 0] }), null, "sem o tamanho");
});

// ---- o nome da pílula ----

test("o nome: o da entrada .desktop; sem ela o título; sem título o appId; sem nada, Window", () => {
  equal(W.label({ entryName: "Firefox", title: "Docs", appId: "org.mozilla.firefox" }), "Firefox");
  equal(W.label({ entryName: "", title: "Docs", appId: "org.mozilla.firefox" }), "Docs");
  equal(W.label({ title: "", appId: "org.mozilla.firefox" }), "org.mozilla.firefox");
  equal(W.label({ entryName: "", title: "", appId: "" }), "Window");
  equal(W.label({}), "Window");
});

// ---- quais janelas, e de cima para baixo ----

test("as flutuantes ficam acima das lado a lado, e entre flutuantes a mais nova (id maior) fica em cima", () => {
  const list = W.rects([win(1), win(5, { isFloating: true }), win(2), win(3, { isFloating: true })]);
  equal(list.slice(0, 2).map((r) => r.id), [5, 3], "as flutuantes primeiro, a mais nova na frente");
  equal(list.slice(2).map((r) => r.id).sort(), [1, 2], "e depois as lado a lado");
  equal(list.map((r) => r.floating), [true, true, false, false]);
});

test("a janela sem posição fica de fora, e cada retângulo leva id, caixa, se flutua e o nome", () => {
  const list = W.rects([
    win(1, { entryName: "Firefox", layout: layout([352, 48], [8, 8], [320, 300]) }),
    win(2, { layout: null }),
    win(3, { layout: {} })
  ]);
  equal(list, [{ id: 1, x: 360, y: 56, width: 320, height: 300, floating: false, name: "Firefox" }]);
  equal(W.rects(undefined), []);
  equal(W.rects([]), []);
});

test("organizar as janelas não mexe na lista que recebi", () => {
  const input = [win(1), win(2, { isFloating: true })];
  const before = JSON.stringify(input);
  W.rects(input);
  equal(JSON.stringify(input), before);
  const rects = [{ id: 1, floating: false }, { id: 2, floating: true }];
  W.stack(rects);
  equal(rects.map((r) => r.id), [1, 2]);
});

// ---- a janela sob o ponteiro ----

test("a janela sob o ponteiro é a primeira de cima para baixo que o contém", () => {
  const rects = W.rects([
    win(1, { layout: layout([0, 0], [0, 0], [400, 300]) }),                          // lado a lado, atrás
    win(2, { isFloating: true, layout: layout([200, 100], [0, 0], [400, 300]) })    // flutuante, sobreposta
  ]);
  equal(W.windowAt(rects, 300, 200).id, 2, "no meio da sobreposição vale a de cima");
  equal(W.windowAt(rects, 50, 50).id, 1, "fora da sobreposição vale a de baixo");
  equal(W.windowAt(rects, 500, 350).id, 2);
});

test("sem janela sob o ponteiro, null", () => {
  const rects = W.rects([win(1, { layout: layout([100, 100], [0, 0], [200, 200]) })]);
  equal(W.windowAt(rects, 10, 10), null);
  equal(W.windowAt([], 10, 10), null);
  equal(W.windowAt(undefined, 10, 10), null);
});

test("a borda de cima e a da esquerda pertencem à janela; a de baixo e a da direita, não", () => {
  const rects = W.rects([win(1, { layout: layout([360, 56], [0, 0], [320, 300]) })]);   // vai de 360 a 679 e de 56 a 355
  check(W.windowAt(rects, 360, 56) !== null, "o canto de cima à esquerda");
  check(W.windowAt(rects, 679, 355) !== null, "o último pixel");
  equal(W.windowAt(rects, 680, 100), null, "a borda da direita");
  equal(W.windowAt(rects, 400, 356), null, "a borda de baixo");
  equal(W.windowAt(rects, 359, 100), null);
});

// ---- onde cai a pílula ----

test("a pílula do board: alinhada à esquerda da janela, terminando 8 acima do anel de 2", () => {
  // janela em (360,56): o anel começa em y 54, a pílula de 24 termina em 46 e começa em 22
  equal(W.pillPlace({ x: 360, y: 56, width: 320, height: 300 }, 152, 24, 8, 2, 720), { x: 360, y: 22, where: "above" });
});

test("sem lugar em cima a pílula vai para dentro, a 8 do canto de cima à esquerda", () => {
  equal(W.pillPlace({ x: 100, y: 30, width: 300, height: 200 }, 152, 24, 8, 2, 1920), { x: 108, y: 38, where: "inside" });
  equal(W.pillPlace({ x: 0, y: 0, width: 1920, height: 1080 }, 152, 24, 8, 0, 1920), { x: 8, y: 8, where: "inside" }, "o monitor inteiro");
});

test("o limite entre em cima e dentro: cabendo justo, fica em cima", () => {
  // y = 34 - 2 - 8 - 24 = 0
  equal(W.pillPlace({ x: 100, y: 34, width: 300, height: 200 }, 152, 24, 8, 2, 1920).where, "above");
  equal(W.pillPlace({ x: 100, y: 33, width: 300, height: 200 }, 152, 24, 8, 2, 1920).where, "inside");
});

test("no modo tela o anel é por dentro: ring 0, e a pílula do monitor fica 8 acima do alvo, se couber", () => {
  equal(W.pillPlace({ x: 0, y: 100, width: 1920, height: 980 }, 152, 24, 8, 0, 1920), { x: 0, y: 68, where: "above" });
});

test("na horizontal a pílula não sai do monitor", () => {
  equal(W.pillPlace({ x: 700, y: 200, width: 100, height: 100 }, 152, 24, 8, 2, 800).x, 648, "a pílula termina no fim do monitor");
  equal(W.pillPlace({ x: -30, y: 200, width: 100, height: 100 }, 152, 24, 8, 2, 800).x, 0, "nem passa da esquerda");
  equal(W.pillPlace({ x: 0, y: 200, width: 50, height: 50 }, 152, 24, 8, 2, 100).x, 0, "monitor mais estreito que a pílula");
});

// ---- o tamanho em pixels do monitor, e o texto ----

test("o tamanho em pixels do monitor: com escala o quadro tem mais pixels que a tela", () => {
  equal(W.pixelSize({ width: 320, height: 300 }, 1, 1), { width: 320, height: 300 });
  equal(W.pixelSize({ width: 320, height: 300 }), { width: 320, height: 300 }, "sem razão, escala 1");
  equal(W.pixelSize({ width: 320, height: 300 }, 2, 2), { width: 640, height: 600 });
  equal(W.pixelSize({ width: 333, height: 201 }, 1.5, 1.5), { width: 500, height: 302 }, "499,5 e 301,5 arredondam para cima");
});

test("com razões diferentes nos dois eixos, a largura usa a horizontal e a altura a vertical", () => {
  // 320 × 2 = 640 e 300 × 1,25 = 375; se trocasse os eixos daria 400 e 600
  equal(W.pixelSize({ width: 320, height: 300 }, 2, 1.25), { width: 640, height: 375 });
  equal(W.pixelSize({ width: 320, height: 300 }, 1.25, 2), { width: 400, height: 600 });
  equal(W.pixelSize({ width: 100, height: 100 }, 1, 3), { width: 100, height: 300 }, "uma razão 1 não mexe no outro eixo");
  equal(W.pillText("Firefox", { width: 320, height: 300 }, 2, 1.25), "Firefox · 640 × 375", "a pílula mostra o tamanho em pixels do quadro");
  equal(W.pillSuffix({ width: 320, height: 300 }, 2, 1.25), " · 640 × 375");
});

test("a pílula da janela: 'Nome · 320 × 300', com o ponto do meio e o sinal de vezes", () => {
  equal(W.pillText("Firefox", { width: 320, height: 300 }, 1, 1), "Firefox · 320 × 300");   // o texto do board
  equal(W.pillSuffix({ width: 320, height: 300 }, 1, 1), " · 320 × 300");
  equal(W.pillSuffix({ width: 320, height: 300 }, 1, 1), " · 320 × 300", "U+00B7 e U+00D7");
});

test("a pílula do monitor: 'eDP-1 · 1920 × 1080', e em pixels do monitor mesmo com escala", () => {
  equal(W.pillText("eDP-1", { width: 1920, height: 1080 }, 1, 1), "eDP-1 · 1920 × 1080");   // o texto da ficha
  equal(W.pillText("eDP-1", { width: 1920, height: 1080 }, 2, 2), "eDP-1 · 3840 × 2160");
});
