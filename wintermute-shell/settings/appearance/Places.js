.pragma library

// Lógica pura dos papéis de parede por lugar (F4-T24, P-67): qual chave vale para uma tela e um modo, quais
// linhas o cartão Customize mostra, em que ordem ficam os monitores e qual papel de parede vale em cada
// lugar. Mora num arquivo só, usado por settings/appearance/State.qml e por demo/AppearanceService.qml,
// para o serviço real e o fictício não divergirem. Não lê nada fora dos argumentos.
//
// Um lugar tem uma chave: "light" ou "dark" (só a chave do modo ligada), "display:<conector>" (só a dos
// monitores) e "display:<conector>:light" ou ":dark" (as duas). O mesmo formato que wallpaper/control.py
// valida. O "papel de parede marcado na grade" é o `grid`: {mode, path, url}, o que existe desde antes.

var KEY_PATTERN = /^(light|dark|display:[A-Za-z0-9._+-]{1,64}(:(light|dark))?)$/;
var BUILTIN_PATTERN = /^(eDP|LVDS|DSI|DPI)-/;
var SCHEMES = ["light", "dark"];

function validKey(key) {
  return typeof key === "string" && KEY_PATTERN.test(key);
}

// Tela embutida: a mesma regra de settings/display/control.py.
function isBuiltin(connector) {
  return BUILTIN_PATTERN.test(connector);
}

// A embutida primeiro, depois pelo nome do conector (a ordem do Python, por ponto de código).
function sortConnectors(names) {
  return names.slice().sort(function (a, b) {
    var left = isBuiltin(a) ? 0 : 1, right = isBuiltin(b) ? 0 : 1;
    if (left !== right) return left - right;
    return a < b ? -1 : a > b ? 1 : 0;
  });
}

function schemeLabel(scheme) {
  return scheme === "dark" ? "Dark" : "Light";
}

// A chave que vale para uma tela e um modo; "" quando as duas chaves estão desligadas (vale o da grade).
function keyFor(followScheme, perDisplay, connector, scheme) {
  var mode = scheme === "dark" ? "dark" : "light";
  if (followScheme && perDisplay) return "display:" + connector + ":" + mode;
  if (perDisplay) return "display:" + connector;
  if (followScheme) return mode;
  return "";
}

// O nome do lugar, o mesmo na linha do cartão e no título do seletor. O espaço antes do ponto não quebra,
// como no "1 · Built-in" da página Tela.
function nameOf(key) {
  if (!validKey(key)) return "";
  var parts = key.split(":");
  if (parts[0] === "light" || parts[0] === "dark") return schemeLabel(parts[0]);
  if (parts.length === 2) return parts[1];
  return parts[1] + " · " + schemeLabel(parts[2]);
}

// A entrada guardada de um lugar, ou null quando não há ou está malformada.
function entryOf(places, key) {
  var entry = places && validKey(key) ? places[key] : null;
  if (!entry || typeof entry !== "object") return null;
  if (entry.mode === "dynamic") return { mode: "dynamic", path: "", url: "" };
  if (entry.mode === "custom" && typeof entry.path === "string" && entry.path !== "")
    return { mode: "custom", path: entry.path, url: typeof entry.url === "string" ? entry.url : "" };
  return null;
}

// O que sobra de `places` lido do arquivo: só as entradas bem formadas.
function cleanPlaces(raw) {
  var clean = {};
  if (!raw || typeof raw !== "object") return clean;
  Object.keys(raw).forEach(function (key) {
    var entry = entryOf(raw, key);
    if (entry) clean[key] = entry;
  });
  return clean;
}

// O papel de parede que vale num lugar: a escolha dele ou, sem escolha, o marcado na grade (ponto 6 da
// P-67: não herda de outro lugar). `chosen` diz qual dos dois valeu.
function resolve(grid, places, key) {
  var entry = key === "" ? null : entryOf(places, key);
  if (entry) return { mode: entry.mode, path: entry.path, url: entry.url, chosen: true };
  return { mode: grid.mode, path: grid.path, url: grid.url, chosen: false };
}

// O que uma janela de papel de parede recebe para uma tela e um modo: se é imagem e qual url. Com as duas
// chaves desligadas devolve exatamente o marcado na grade, como o shell.qml passava antes.
function forScreen(followScheme, perDisplay, places, grid, connector, scheme) {
  var found = resolve(grid, places, keyFor(followScheme, perDisplay, connector, scheme));
  return { custom: found.mode === "custom", url: found.url };
}

// As linhas de lugar do cartão, na ordem: com a chave dos monitores uma por monitor ligado (a embutida
// primeiro) e, dentro de cada um, Light antes de Dark quando a do modo também está ligada. Cada linha
// leva o que vale no lugar para a miniatura: `dynamic` e `url`.
function rows(followScheme, perDisplay, connectors, places, grid) {
  var keys = [];
  if (perDisplay) {
    sortConnectors(connectors).forEach(function (connector) {
      if (followScheme) SCHEMES.forEach(function (scheme) { keys.push("display:" + connector + ":" + scheme); });
      else keys.push("display:" + connector);
    });
  } else if (followScheme) {
    keys = SCHEMES.slice();
  }
  return keys.map(function (key) {
    var found = resolve(grid, places, key);
    return { key: key, name: nameOf(key), dynamic: found.mode === "dynamic", url: found.url };
  });
}
