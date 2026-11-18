.pragma library

// Cores do seletor de cor do launcher (ficha 15; pendências P-75 e P-76). Biblioteca pura: valida o HEX,
// escreve os três formatos, dá o nome da cor e cuida do histórico. O serviço de verdade (State.qml) e o
// fictício (demo/LauncherService.qml) usam esta mesma biblioteca, para o espécime medir o que a shell faz.
//
// Não leio arquivo nem rodo processo aqui: quem lê e grava o histórico é o State.qml, e esta biblioteca só
// transforma texto em lista e lista em texto.

var MAX_HISTORY = 12;

// As cores nomeadas do CSS, da lista pública do CSS Color Module do W3C (https://www.w3.org/TR/css-color-4/#named-colors).
// Escrevi os nomes já separados em palavras, que é como a interface os mostra ("steel blue"). Os nomes repetidos
// da lista (`grey` para `gray`, `aqua` para `cyan`, `fuchsia` para `magenta`) contam uma vez só; fiquei com
// `gray`, `cyan` e `magenta`. O valor de cada uma conferi com os nomes de cor que o próprio Qt entende.
var NAMED = [
  ["alice blue", "#F0F8FF"],
  ["antique white", "#FAEBD7"],
  ["aquamarine", "#7FFFD4"],
  ["azure", "#F0FFFF"],
  ["beige", "#F5F5DC"],
  ["bisque", "#FFE4C4"],
  ["black", "#000000"],
  ["blanched almond", "#FFEBCD"],
  ["blue", "#0000FF"],
  ["blue violet", "#8A2BE2"],
  ["brown", "#A52A2A"],
  ["burlywood", "#DEB887"],
  ["cadet blue", "#5F9EA0"],
  ["chartreuse", "#7FFF00"],
  ["chocolate", "#D2691E"],
  ["coral", "#FF7F50"],
  ["cornflower blue", "#6495ED"],
  ["cornsilk", "#FFF8DC"],
  ["crimson", "#DC143C"],
  ["cyan", "#00FFFF"],
  ["dark blue", "#00008B"],
  ["dark cyan", "#008B8B"],
  ["dark goldenrod", "#B8860B"],
  ["dark gray", "#A9A9A9"],
  ["dark green", "#006400"],
  ["dark khaki", "#BDB76B"],
  ["dark magenta", "#8B008B"],
  ["dark olive green", "#556B2F"],
  ["dark orange", "#FF8C00"],
  ["dark orchid", "#9932CC"],
  ["dark red", "#8B0000"],
  ["dark salmon", "#E9967A"],
  ["dark sea green", "#8FBC8F"],
  ["dark slate blue", "#483D8B"],
  ["dark slate gray", "#2F4F4F"],
  ["dark turquoise", "#00CED1"],
  ["dark violet", "#9400D3"],
  ["deep pink", "#FF1493"],
  ["deep sky blue", "#00BFFF"],
  ["dim gray", "#696969"],
  ["dodger blue", "#1E90FF"],
  ["firebrick", "#B22222"],
  ["floral white", "#FFFAF0"],
  ["forest green", "#228B22"],
  ["gainsboro", "#DCDCDC"],
  ["ghost white", "#F8F8FF"],
  ["gold", "#FFD700"],
  ["goldenrod", "#DAA520"],
  ["gray", "#808080"],
  ["green", "#008000"],
  ["green yellow", "#ADFF2F"],
  ["honeydew", "#F0FFF0"],
  ["hot pink", "#FF69B4"],
  ["indian red", "#CD5C5C"],
  ["indigo", "#4B0082"],
  ["ivory", "#FFFFF0"],
  ["khaki", "#F0E68C"],
  ["lavender", "#E6E6FA"],
  ["lavender blush", "#FFF0F5"],
  ["lawn green", "#7CFC00"],
  ["lemon chiffon", "#FFFACD"],
  ["light blue", "#ADD8E6"],
  ["light coral", "#F08080"],
  ["light cyan", "#E0FFFF"],
  ["light goldenrod yellow", "#FAFAD2"],
  ["light gray", "#D3D3D3"],
  ["light green", "#90EE90"],
  ["light pink", "#FFB6C1"],
  ["light salmon", "#FFA07A"],
  ["light sea green", "#20B2AA"],
  ["light sky blue", "#87CEFA"],
  ["light slate gray", "#778899"],
  ["light steel blue", "#B0C4DE"],
  ["light yellow", "#FFFFE0"],
  ["lime", "#00FF00"],
  ["lime green", "#32CD32"],
  ["linen", "#FAF0E6"],
  ["magenta", "#FF00FF"],
  ["maroon", "#800000"],
  ["medium aquamarine", "#66CDAA"],
  ["medium blue", "#0000CD"],
  ["medium orchid", "#BA55D3"],
  ["medium purple", "#9370DB"],
  ["medium sea green", "#3CB371"],
  ["medium slate blue", "#7B68EE"],
  ["medium spring green", "#00FA9A"],
  ["medium turquoise", "#48D1CC"],
  ["medium violet red", "#C71585"],
  ["midnight blue", "#191970"],
  ["mint cream", "#F5FFFA"],
  ["misty rose", "#FFE4E1"],
  ["moccasin", "#FFE4B5"],
  ["navajo white", "#FFDEAD"],
  ["navy", "#000080"],
  ["old lace", "#FDF5E6"],
  ["olive", "#808000"],
  ["olive drab", "#6B8E23"],
  ["orange", "#FFA500"],
  ["orange red", "#FF4500"],
  ["orchid", "#DA70D6"],
  ["pale goldenrod", "#EEE8AA"],
  ["pale green", "#98FB98"],
  ["pale turquoise", "#AFEEEE"],
  ["pale violet red", "#DB7093"],
  ["papaya whip", "#FFEFD5"],
  ["peach puff", "#FFDAB9"],
  ["peru", "#CD853F"],
  ["pink", "#FFC0CB"],
  ["plum", "#DDA0DD"],
  ["powder blue", "#B0E0E6"],
  ["purple", "#800080"],
  ["rebecca purple", "#663399"],
  ["red", "#FF0000"],
  ["rosy brown", "#BC8F8F"],
  ["royal blue", "#4169E1"],
  ["saddle brown", "#8B4513"],
  ["salmon", "#FA8072"],
  ["sandy brown", "#F4A460"],
  ["sea green", "#2E8B57"],
  ["seashell", "#FFF5EE"],
  ["sienna", "#A0522D"],
  ["silver", "#C0C0C0"],
  ["sky blue", "#87CEEB"],
  ["slate blue", "#6A5ACD"],
  ["slate gray", "#708090"],
  ["snow", "#FFFAFA"],
  ["spring green", "#00FF7F"],
  ["steel blue", "#4682B4"],
  ["tan", "#D2B48C"],
  ["teal", "#008080"],
  ["thistle", "#D8BFD8"],
  ["tomato", "#FF6347"],
  ["turquoise", "#40E0D0"],
  ["violet", "#EE82EE"],
  ["wheat", "#F5DEB3"],
  ["white", "#FFFFFF"],
  ["white smoke", "#F5F5F5"],
  ["yellow", "#FFFF00"],
  ["yellow green", "#9ACD32"]
];

// O HEX no formato do seletor: `#RRGGBB` em maiúsculas. Aceito com ou sem `#` e em qualquer caixa, com espaço
// nas pontas. Qualquer outra coisa (inclusive o `#RGB` de três dígitos, que o seletor nunca grava) volta "".
function normalizeHex(text) {
  if (typeof text !== "string")
    return "";
  var match = /^#?([0-9a-fA-F]{6})$/.exec(text.trim());
  return match ? "#" + match[1].toUpperCase() : "";
}

function isValidHex(text) {
  return normalizeHex(text) !== "";
}

// [r, g, b] de 0 a 255 de um HEX válido, ou null.
function toRgb(hex) {
  var clean = normalizeHex(hex);
  if (clean === "")
    return null;
  return [
    parseInt(clean.substring(1, 3), 16),
    parseInt(clean.substring(3, 5), 16),
    parseInt(clean.substring(5, 7), 16)
  ];
}

// [h, s, l]: matiz em graus (0 a 360), saturação e luminosidade em porcentagem (0 a 100), ainda sem arredondar.
function toHsl(rgb) {
  var r = rgb[0] / 255;
  var g = rgb[1] / 255;
  var b = rgb[2] / 255;
  var max = Math.max(r, g, b);
  var min = Math.min(r, g, b);
  var delta = max - min;
  var l = (max + min) / 2;
  var h = 0;
  var s = 0;
  if (delta > 0) {
    s = delta / (1 - Math.abs(2 * l - 1));
    if (max === r)
      h = ((g - b) / delta + 6) % 6;
    else if (max === g)
      h = (b - r) / delta + 2;
    else
      h = (r - g) / delta + 4;
    h *= 60;
  }
  return [h, s * 100, l * 100];
}

// Os três textos de uma cor, com inteiros: { hex, rgb, hsl }; null se o HEX for inválido. O matiz que arredonda
// para 360 volta a 0, que é a mesma cor.
function formats(hex) {
  var clean = normalizeHex(hex);
  if (clean === "")
    return null;
  var rgb = toRgb(clean);
  var hsl = toHsl(rgb);
  return {
    hex: clean,
    rgb: "rgb(" + rgb[0] + ", " + rgb[1] + ", " + rgb[2] + ")",
    hsl: "hsl(" + (Math.round(hsl[0]) % 360) + ", " + Math.round(hsl[1]) + "%, " + Math.round(hsl[2]) + "%)"
  };
}

// sRGB (0 a 255) para CIELAB, com o branco de referência D65.
function toLab(rgb) {
  function linear(channel) {
    var c = channel / 255;
    return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  }
  var r = linear(rgb[0]);
  var g = linear(rgb[1]);
  var b = linear(rgb[2]);
  var x = (0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047;
  var y = 0.2126729 * r + 0.7151522 * g + 0.0721750 * b;
  var z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / 1.08883;
  function f(t) {
    return t > 216 / 24389 ? Math.cbrt(t) : (24389 / 27 * t + 16) / 116;
  }
  return [116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z))];
}

// As cores nomeadas já em Lab, calculadas uma vez na primeira consulta.
var namedLab = null;

function ensureNamedLab() {
  if (namedLab !== null)
    return;
  namedLab = NAMED.map(function (entry) {
    return toLab(toRgb(entry[1]));
  });
}

// "steel blue" vira "Steel blue": só a primeira letra maiúscula.
function capitalize(text) {
  return text.charAt(0).toUpperCase() + text.substring(1);
}

// O nome da cor mais próxima entre as nomeadas do CSS, pela distância no espaço CIELAB (a diferença simples de 1976,
// a distância euclidiana entre os dois pontos). Em empate fica a primeira da lista. "" se o HEX for inválido.
function nameOf(hex) {
  var rgb = toRgb(hex);
  if (rgb === null)
    return "";
  ensureNamedLab();
  var lab = toLab(rgb);
  var best = 0;
  var bestDistance = Infinity;
  for (var i = 0; i < namedLab.length; i++) {
    var dl = lab[0] - namedLab[i][0];
    var da = lab[1] - namedLab[i][1];
    var db = lab[2] - namedLab[i][2];
    var distance = dl * dl + da * da + db * db;
    if (distance < bestDistance) {
      bestDistance = distance;
      best = i;
    }
  }
  return capitalize(NAMED[best][0]);
}

// Tudo o que a página mostra de uma cor: { hex, rgb, hsl, name }; null se o HEX for inválido.
function describe(hex) {
  var f = formats(hex);
  if (f === null)
    return null;
  f.name = nameOf(f.hex);
  return f;
}

// A origem sob o nome: "Picked just now" para a cor que entrou agora, senão a data e a hora em que foi pega (já
// formatadas por quem chama, no formato curto do locale); depois, " · " e o aplicativo, quando se sabe qual.
function originText(entry, fresh, dateText) {
  var when = fresh ? "Picked just now" : String(dateText || "");
  var app = entry && typeof entry.app === "string" ? entry.app.trim() : "";
  if (when === "")
    return app;
  return app !== "" ? when + " · " + app : when;
}

// O histórico guardado: lista de { hex, pickedAt, app }, a mais nova primeiro. Arquivo vazio, ilegível ou que
// não seja uma lista vale como lista vazia; a entrada malformada (sem HEX válido, ou sem uma data que eu entenda)
// é descartada, e as demais seguem. Repetido fica só o mais novo, e o corte é em `max` (12).
function parseHistory(text, max) {
  var limit = max === undefined ? MAX_HISTORY : max;
  var data;
  try {
    data = JSON.parse(text);
  } catch (error) {
    return [];
  }
  if (!Array.isArray(data))
    return [];
  var list = [];
  var seen = {};
  for (var i = 0; i < data.length && list.length < limit; i++) {
    var item = data[i];
    if (item === null || typeof item !== "object")
      continue;
    var hex = normalizeHex(item.hex);
    if (hex === "" || typeof item.pickedAt !== "string" || isNaN(Date.parse(item.pickedAt)))
      continue;
    if (seen[hex])
      continue;
    seen[hex] = true;
    list.push({ hex: hex, pickedAt: item.pickedAt, app: typeof item.app === "string" ? item.app : "" });
  }
  return list;
}

function serializeHistory(list) {
  return JSON.stringify(list.map(function (item) {
    return { hex: item.hex, pickedAt: item.pickedAt, app: item.app };
  }), null, 2) + "\n";
}

// A lista com `entry` na frente: se a cor já estava, sai de onde estava (pegar de novo leva a cor para a frente), e
// o corte é em `max`. Não mexe na lista recebida.
function pushHistory(list, entry, max) {
  var limit = max === undefined ? MAX_HISTORY : max;
  var out = [entry];
  for (var i = 0; i < list.length; i++) {
    if (list[i].hex !== entry.hex)
      out.push(list[i]);
  }
  return out.slice(0, limit);
}
