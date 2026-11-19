.pragma library

// A conta da seleção de área da captura de tela (ficha 17, F6-T11). Fica fora do QML para eu testar sem a peça nem a
// janela. Tudo em pixels lógicos do monitor, com a origem no canto de cima à
// esquerda; um retângulo é { x, y, width, height }. Nenhum valor de desenho mora aqui: o tamanho mínimo, a área das alças, as
// folgas e as medidas das pílulas chegam de quem chama, que as lê do Theme.qml.

// As oito alças, pelo ponto cardeal em que ficam.
var HANDLES = ["nw", "n", "ne", "e", "se", "s", "sw", "w"];

function clamp(value, low, high) {
  return Math.max(low, Math.min(high, value));
}

// A seleção que sai de apertar em (ax, ay) e arrastar até (bx, by), em qualquer direção: o retângulo normalizado, preso ao
// monitor de `width` × `height`. Os pontos viram inteiros: a borda de 1 px da seleção precisa cair em pixel inteiro.
function fromDrag(ax, ay, bx, by, width, height) {
  const x1 = clamp(Math.round(ax), 0, width);
  const y1 = clamp(Math.round(ay), 0, height);
  const x2 = clamp(Math.round(bx), 0, width);
  const y2 = clamp(Math.round(by), 0, height);
  return { x: Math.min(x1, x2), y: Math.min(y1, y2), width: Math.abs(x2 - x1), height: Math.abs(y2 - y1) };
}

// Soltar com menos de `min` de largura ou de altura não cria seleção.
function isUsable(rect, min) {
  return !!rect && rect.width >= min && rect.height >= min;
}

// Mover a seleção por (dx, dy), sem sair do monitor: o que passa da borda fica na borda, e o tamanho não muda.
function move(rect, dx, dy, width, height) {
  return {
    x: clamp(rect.x + Math.round(dx), 0, Math.max(0, width - rect.width)),
    y: clamp(rect.y + Math.round(dy), 0, Math.max(0, height - rect.height)),
    width: rect.width,
    height: rect.height
  };
}

// Um eixo do redimensionamento. `fixed` é a borda que não se mexe, `moving` onde a outra foi parar. Passando para o lado
// oposto da fixa a seleção vira (a borda que se mexia passa a ser a de baixo ou da direita, e o contrário). O mínimo de
// `min` vale nos dois lados, e quando não há lugar para ele de um lado (a borda fixa está colada no monitor) vai para o outro.
function axis(fixed, moving, min, size) {
  const m = clamp(Math.round(moving), 0, size);
  const positive = m >= fixed ? fixed + min <= size : fixed - min < 0;
  let low, high;
  if (positive) {
    low = fixed;
    high = Math.max(m, fixed + min);
  } else {
    low = Math.min(m, fixed - min);
    high = fixed;
  }
  low = Math.max(0, low);
  high = Math.min(size, high);
  return { start: low, size: high - low };
}

// Redimensionar pela alça `handle`, a partir do retângulo `rect` de quando apertei e do quanto o ponteiro andou (dx, dy)
// desde então. Os cantos mexem nos dois eixos, as alças do meio das bordas em um só: n e s no vertical, e e w no horizontal.
function resize(rect, handle, dx, dy, width, height, min) {
  let horizontal = { start: rect.x, size: rect.width };
  let vertical = { start: rect.y, size: rect.height };
  if (handle.indexOf("w") >= 0)
    horizontal = axis(rect.x + rect.width, rect.x + dx, min, width);
  else if (handle.indexOf("e") >= 0)
    horizontal = axis(rect.x, rect.x + rect.width + dx, min, width);
  if (handle.indexOf("n") >= 0)
    vertical = axis(rect.y + rect.height, rect.y + dy, min, height);
  else if (handle.indexOf("s") >= 0)
    vertical = axis(rect.y, rect.y + rect.height + dy, min, height);
  return { x: horizontal.start, y: vertical.start, width: horizontal.size, height: vertical.size };
}

// O centro da alça `handle` de `rect`: cai em cima da linha da borda (cantos e meio de cada lado).
function handleCenter(rect, handle) {
  const cx = handle.indexOf("w") >= 0 ? rect.x : handle.indexOf("e") >= 0 ? rect.x + rect.width : rect.x + Math.round(rect.width / 2);
  const cy = handle.indexOf("n") >= 0 ? rect.y : handle.indexOf("s") >= 0 ? rect.y + rect.height : rect.y + Math.round(rect.height / 2);
  return { x: cx, y: cy };
}

// O que há sob o ponto (x, y): o nome de uma alça, "move" (dentro da seleção) ou "" (fora). A área de cada alça é um
// quadrado de `hit` de lado centrado nela, maior que o desenho para ser fácil de pegar. Numa seleção pequena a área encolhe
// para um terço do lado menor (no mínimo 4), senão as alças comeriam o miolo e ela não poderia mais ser movida. Os cantos
// ganham das alças do meio onde as áreas se encontram.
function hitTest(rect, x, y, hit) {
  const side = Math.max(4, Math.min(hit, Math.floor(Math.min(rect.width, rect.height) / 3)));
  const half = side / 2;
  const order = ["nw", "ne", "se", "sw", "n", "e", "s", "w"];
  for (let i = 0; i < order.length; i++) {
    const c = handleCenter(rect, order[i]);
    if (x >= c.x - half && x < c.x + half && y >= c.y - half && y < c.y + half)
      return order[i];
  }
  if (x >= rect.x && x < rect.x + rect.width && y >= rect.y && y < rect.y + rect.height)
    return "move";
  return "";
}

// Dois retângulos se tocam ou se cobrem. Encostar conta: a pílula não pode ficar colada na barra nem em outra pílula.
function touches(a, b) {
  return a.x <= b.x + b.width && b.x <= a.x + a.width && a.y <= b.y + b.height && b.y <= a.y + a.height;
}

// A pílula de tamanho (largura `w`, altura `h`): alinhada à esquerda da seleção, `gap` acima dela. Sem lugar em cima
// (seleção a menos de gap + h do topo) vai para dentro, a `gap` do canto de cima à esquerda. Na horizontal fica no monitor.
function sizePill(rect, w, h, gap, width) {
  let x = rect.x;
  let y = rect.y - gap - h;
  let where = "above";
  if (y < 0) {
    x = rect.x + gap;
    y = rect.y + gap;
    where = "inside";
  }
  return { x: clamp(x, 0, Math.max(0, width - w)), y: y, width: w, height: h, where: where };
}

// A pílula de ações (largura `w`, altura `h`): alinhada à direita da seleção, `gap` abaixo dela. Se ali ela sair do monitor
// ou encostar em `bar` (o retângulo da barra de modos), vai para cima, alinhada à direita, `gap` acima. Se em cima também
// não couber, ou se cobrir `size` (a pílula de tamanho), vai para dentro, a `gap` do canto de baixo à direita. Na horizontal
// nunca sai do monitor: fica a pelo menos `edge` das bordas.
function actionsPill(rect, w, h, gap, edge, width, height, size, bar) {
  const right = rect.x + rect.width;
  const x = clamp(right - w, edge, Math.max(edge, width - w - edge));
  let candidate = { x: x, y: rect.y + rect.height + gap, width: w, height: h };
  if (candidate.y + h <= height && !(bar && touches(candidate, bar)))
    return { x: candidate.x, y: candidate.y, width: w, height: h, where: "below" };
  candidate = { x: x, y: rect.y - gap - h, width: w, height: h };
  if (candidate.y >= 0 && !(size && touches(candidate, size)))
    return { x: candidate.x, y: candidate.y, width: w, height: h, where: "above" };
  return {
    x: clamp(right - gap - w, edge, Math.max(edge, width - w - edge)),
    y: clamp(rect.y + rect.height - gap - h, 0, Math.max(0, height - h)),
    width: w,
    height: h,
    where: "inside"
  };
}
