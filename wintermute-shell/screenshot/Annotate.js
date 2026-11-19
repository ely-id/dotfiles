.pragma library

// A conta do editor de anotação da captura de tela (ficha 17, estado 5, F6-T14). Fica fora do QML para eu testar sem janela.
// Nenhum valor de desenho mora aqui: as espessuras, o raio, a opacidade, o tamanho da ponta e o da fonte chegam de quem chama, em
// `style`, e quem chama os lê do Theme.qml.
//
// Duas coisas diferentes convivem aqui, e é importante não misturar:
//   - a TELA: pixels do editor, com a origem no canto de cima à esquerda da área da imagem (688×408);
//   - a IMAGEM: pixels da imagem que está sendo anotada (a de origem, ou o pedaço que sobrou de um recorte).
// As marcas são guardadas SEMPRE em pixels da imagem. A `view` liga as duas: onde a imagem está na área e com que escala ela
// aparece (menor que 1 quando a imagem é reduzida para caber). As espessuras e o tamanho do texto que eu defino são os da TELA;
// ao criar a marca eu os divido pela escala, e é por isso que o PNG exportado sai com o traço igual ao que eu via: uma imagem
// reduzida à metade na tela tem o traço de 3 desenhado com 6 pixels no arquivo, e quando esse arquivo aparece de novo à metade o
// traço volta a medir 3.
//
// Uma marca é um objeto simples, em pixels da imagem:
//   pencil     { type, color, width, points: [{ x, y }] }
//   highlight  { type, color, opacity, thickness, radius, a: { x, y }, b: { x, y } }     faixa reta de `a` até `b`
//   rect       { type, color, strokeWidth, radius, x, y, width, height }                 só o contorno
//   arrow      { type, color, strokeWidth, radius, head, a, b }                          haste de `a` até `b`; a ponta (o glifo de lado `head`) centrada em `b`
//   text       { type, color, size, text, x, y, width, height }                          `x`, `y` é o canto de cima à esquerda; `width`, `height` é o que o texto mediu
//
// O documento (`state`) é imutável: cada função devolve um novo, e o QML só troca a referência.
//   { width, height, origin: { x, y }, marks: [...], history: [...] }
// `width` e `height` são os da imagem como ela está agora (depois do recorte); `origin` é onde esse pedaço começa na imagem de origem.

// Quanto o ponteiro precisa andar, na tela, para um arraste valer como marca. Não é medida de desenho: é o que separa um clique
// de um arraste (como o mínimo da seleção da captura, mas sem a alça, que aqui não existe).
var MIN_DRAG = 4;

function clamp(value, low, high) {
  return Math.max(low, Math.min(high, value));
}

function distance(a, b) {
  return Math.hypot(b.x - a.x, b.y - a.y);
}

// ---- a vista: onde a imagem fica na área ----

// A imagem de `imageWidth` × `imageHeight` na área de `areaWidth` × `areaHeight`: cabe inteira, sem deformar, centrada. Menor que a
// área, ela aparece no tamanho natural (não amplio): `maxScale` é a escala do tamanho natural, que é 1 quando um pixel da imagem é um
// pixel lógico da tela e 1 / (a escala do monitor) quando um pixel da imagem é um pixel do monitor (o padrão é 1). `x` e `y` são
// inteiros (a imagem cai no pixel); `width` e `height` são o tamanho desenhado, que pode ser fracionário quando há redução.
function fit(imageWidth, imageHeight, areaWidth, areaHeight, maxScale) {
  if (!(imageWidth > 0) || !(imageHeight > 0) || !(areaWidth > 0) || !(areaHeight > 0))
    return null;
  var scale = Math.min(maxScale > 0 ? maxScale : 1, areaWidth / imageWidth, areaHeight / imageHeight);
  var width = imageWidth * scale;
  var height = imageHeight * scale;
  return {
    scale: scale,
    x: Math.round((areaWidth - width) / 2),
    y: Math.round((areaHeight - height) / 2),
    width: width,
    height: height,
    imageWidth: imageWidth,
    imageHeight: imageHeight
  };
}

// Um ponto da tela em pixels da imagem, preso à imagem (um ponto na margem da área vira a borda da imagem).
function toImage(view, px, py) {
  return {
    x: clamp((px - view.x) / view.scale, 0, view.imageWidth),
    y: clamp((py - view.y) / view.scale, 0, view.imageHeight)
  };
}

// O contrário: um ponto da imagem na tela.
function toScreen(view, point) {
  return { x: view.x + point.x * view.scale, y: view.y + point.y * view.scale };
}

// O ponto da tela preso ao retângulo onde a imagem aparece.
function clampToView(view, px, py) {
  return { x: clamp(px, view.x, view.x + view.width), y: clamp(py, view.y, view.y + view.height) };
}

function inside(view, px, py) {
  return px >= view.x && px <= view.x + view.width && py >= view.y && py <= view.y + view.height;
}

// ---- criar as marcas ----

// A marca que o arraste da ferramenta `tool` produz. `points` são os pontos do arraste na tela, do aperto ao ponto atual (só o
// lápis usa todos; os outros usam o primeiro e o último). `style` tem os valores da tela: { color, pencilWidth, strokeWidth,
// rectRadius, thickness, opacity, stripRadius, head }. Devolve null quando o arraste ainda não vale como marca.
function build(tool, style, view, points) {
  if (!view || !points || points.length === 0)
    return null;
  var inv = 1 / view.scale;
  // A cor vira texto ("#rrggbb"): no QML o valor de uma propriedade `color` guardado num objeto continua ligado à propriedade, e a marca
  // mudaria de cor quando eu trocasse a cor das próximas.
  var color = String(style.color);
  var first = points[0];
  var last = points[points.length - 1];
  var a = toImage(view, first.x, first.y);
  var b = toImage(view, last.x, last.y);
  switch (tool) {
  case "pencil": {
    var pts = [];
    for (var i = 0; i < points.length; ++i)
      pts.push(toImage(view, points[i].x, points[i].y));
    // Um clique sem arrastar vira um ponto: o traço de comprimento zero (`isDot`), que a AnnotateMark desenha como um círculo, porque o
    // traçador do Qt não desenha nada num caminho sem comprimento.
    if (pts.length === 1)
      pts.push({ x: pts[0].x, y: pts[0].y });
    return { type: "pencil", color: color, width: style.pencilWidth * inv, points: pts };
  }
  case "highlighter":
    if (distance(first, last) < MIN_DRAG)
      return null;
    return { type: "highlight", color: color, opacity: style.opacity, thickness: style.thickness * inv,
        radius: style.stripRadius * inv, a: a, b: b };
  case "rectangle": {
    var w = Math.abs(last.x - first.x);
    var h = Math.abs(last.y - first.y);
    if (w < MIN_DRAG || h < MIN_DRAG)
      return null;
    return { type: "rect", color: color, strokeWidth: style.strokeWidth * inv, radius: style.rectRadius * inv,
        x: Math.min(a.x, b.x), y: Math.min(a.y, b.y), width: Math.abs(b.x - a.x), height: Math.abs(b.y - a.y) };
  }
  case "arrow":
    if (distance(first, last) < MIN_DRAG)
      return null;
    return { type: "arrow", color: color, strokeWidth: style.strokeWidth * inv, radius: style.stripRadius * inv,
        head: style.head * inv, a: a, b: b };
  }
  return null;
}

// A marca de texto confirmada em `point` (da tela, o canto de cima à esquerda do texto). `measuredWidth` e `measuredHeight` são o que o
// texto mediu na tela. Texto vazio, ou só de espaços, não vira marca.
function textMark(style, view, point, text, measuredWidth, measuredHeight) {
  if (!view || typeof text !== "string" || text.trim() === "")
    return null;
  var inv = 1 / view.scale;
  var at = toImage(view, point.x, point.y);
  return { type: "text", color: String(style.color), size: style.fontSize * inv, text: text, x: at.x, y: at.y,
      width: measuredWidth * inv, height: measuredHeight * inv };
}

// O traço do lápis não saiu do lugar: um clique. Vira um círculo do diâmetro da espessura.
function isDot(mark) {
  for (var i = 1; i < mark.points.length; ++i) {
    if (mark.points[i].x !== mark.points[0].x || mark.points[i].y !== mark.points[0].y)
      return false;
  }
  return true;
}

// ---- as caixas das marcas ----

// A caixa que contém a marca, em pixels da imagem: { x0, y0, x1, y1 }. É a que decide se uma marca sobrevive a um recorte.
function bounds(mark) {
  switch (mark.type) {
  case "pencil": {
    var x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;
    for (var i = 0; i < mark.points.length; ++i) {
      x0 = Math.min(x0, mark.points[i].x);
      y0 = Math.min(y0, mark.points[i].y);
      x1 = Math.max(x1, mark.points[i].x);
      y1 = Math.max(y1, mark.points[i].y);
    }
    var half = mark.width / 2;
    return { x0: x0 - half, y0: y0 - half, x1: x1 + half, y1: y1 + half };
  }
  case "highlight":
  case "arrow": {
    // A haste engrossa por metade da espessura de cada lado; a ponta da seta, por metade do lado do glifo em volta de `b`.
    var pad = mark.type === "highlight" ? mark.thickness / 2 : Math.max(mark.strokeWidth, mark.head) / 2;
    return { x0: Math.min(mark.a.x, mark.b.x) - pad, y0: Math.min(mark.a.y, mark.b.y) - pad,
        x1: Math.max(mark.a.x, mark.b.x) + pad, y1: Math.max(mark.a.y, mark.b.y) + pad };
  }
  case "rect":
  case "text":
    return { x0: mark.x, y0: mark.y, x1: mark.x + mark.width, y1: mark.y + mark.height };
  }
  return { x0: 0, y0: 0, x1: 0, y1: 0 };
}

// A marca deslocada por (dx, dy), em pixels da imagem.
function shift(mark, dx, dy) {
  var copy = {};
  for (var key in mark)
    copy[key] = mark[key];
  switch (mark.type) {
  case "pencil":
    copy.points = mark.points.map(function (p) { return { x: p.x + dx, y: p.y + dy }; });
    break;
  case "highlight":
  case "arrow":
    copy.a = { x: mark.a.x + dx, y: mark.a.y + dy };
    copy.b = { x: mark.b.x + dx, y: mark.b.y + dy };
    break;
  default:
    copy.x = mark.x + dx;
    copy.y = mark.y + dy;
  }
  return copy;
}

// ---- o documento ----

function create(width, height) {
  return { width: width, height: height, origin: { x: 0, y: 0 }, marks: [], history: [] };
}

function addMark(state, mark) {
  return {
    width: state.width,
    height: state.height,
    origin: state.origin,
    marks: state.marks.concat([mark]),
    history: state.history.concat([{ type: "mark" }])
  };
}

function canUndo(state) {
  return !!state && state.history.length > 0;
}

// Desfaz o último passo: a última marca, ou o último recorte (que devolve a imagem, a origem e as marcas de antes dele).
function undo(state) {
  if (!canUndo(state))
    return state;
  var last = state.history[state.history.length - 1];
  var history = state.history.slice(0, -1);
  if (last.type === "crop") {
    return { width: last.before.width, height: last.before.height, origin: last.before.origin, marks: last.before.marks,
        history: history };
  }
  return { width: state.width, height: state.height, origin: state.origin, marks: state.marks.slice(0, -1), history: history };
}

// Recorta a imagem em `rect` ({ x, y, width, height }, em pixels da imagem de agora, inteiros). A imagem passa a ser só aquele
// pedaço; as marcas que ficam inteiras fora dele somem, e as que tocam o pedaço são deslocadas para a origem nova (a parte que sai
// da imagem é cortada pela própria imagem). Um retângulo vazio, ou o da imagem inteira, não muda nada.
function crop(state, rect) {
  if (!state || !rect)
    return state;
  var x0 = clamp(Math.round(rect.x), 0, state.width);
  var y0 = clamp(Math.round(rect.y), 0, state.height);
  var x1 = clamp(Math.round(rect.x + rect.width), 0, state.width);
  var y1 = clamp(Math.round(rect.y + rect.height), 0, state.height);
  if (x1 - x0 < 1 || y1 - y0 < 1)
    return state;
  if (x0 === 0 && y0 === 0 && x1 === state.width && y1 === state.height)
    return state;
  var kept = [];
  for (var i = 0; i < state.marks.length; ++i) {
    var box = bounds(state.marks[i]);
    if (box.x1 <= x0 || box.x0 >= x1 || box.y1 <= y0 || box.y0 >= y1)
      continue;
    kept.push(shift(state.marks[i], -x0, -y0));
  }
  return {
    width: x1 - x0,
    height: y1 - y0,
    origin: { x: state.origin.x + x0, y: state.origin.y + y0 },
    marks: kept,
    history: state.history.concat([{ type: "crop",
        before: { width: state.width, height: state.height, origin: state.origin, marks: state.marks } }])
  };
}

// ---- o recorte na tela ----

// O retângulo do recorte que sai de apertar em (ax, ay) e arrastar até (bx, by): normalizado e preso ao retângulo onde a imagem
// aparece. Em pixels da tela, inteiros.
function cropFromDrag(view, ax, ay, bx, by) {
  var a = clampToView(view, ax, ay);
  var b = clampToView(view, bx, by);
  var x1 = Math.round(Math.min(a.x, b.x));
  var y1 = Math.round(Math.min(a.y, b.y));
  var x2 = Math.round(Math.max(a.x, b.x));
  var y2 = Math.round(Math.max(a.y, b.y));
  return { x: x1, y: y1, width: x2 - x1, height: y2 - y1 };
}

// Soltar com menos de `min` num eixo não deixa recorte.
function cropUsable(rect, min) {
  return !!rect && rect.width >= min && rect.height >= min;
}

// O retângulo do recorte da tela em pixels da imagem, inteiros e presos à imagem.
function cropToImage(view, rect) {
  var x0 = clamp(Math.round((rect.x - view.x) / view.scale), 0, view.imageWidth);
  var y0 = clamp(Math.round((rect.y - view.y) / view.scale), 0, view.imageHeight);
  var x1 = clamp(Math.round((rect.x + rect.width - view.x) / view.scale), 0, view.imageWidth);
  var y1 = clamp(Math.round((rect.y + rect.height - view.y) / view.scale), 0, view.imageHeight);
  return { x: x0, y: y0, width: x1 - x0, height: y1 - y0 };
}

// O ângulo, em graus, da direção de `a` para `b` (0 aponta para a direita, como o `chevron-right`).
function angle(a, b) {
  return Math.atan2(b.y - a.y, b.x - a.x) * 180 / Math.PI;
}
