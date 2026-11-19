// Testes da lógica dos papéis de parede por lugar: wintermute-shell/settings/appearance/Places.js (qual chave vale para uma tela e um
// modo, o nome do lugar, as linhas do cartão Customize e o papel de parede que vale em cada lugar). Os casos saem da ficha 13, seção
// "Cartão Customize: papel de parede por modo e por monitor" (F4-T24, ajuste A-05, P-67) e do comentário de abertura da biblioteca: as
// chaves `light`, `dark`, `display:<conector>` e `display:<conector>:light|dark`; "lugar sem entrada usa o marcado na grade e não herda
// de outro lugar"; "com as duas chaves desligadas vale exatamente o marcado na grade"; "com a chave dos monitores uma linha por
// monitor ligado (a embutida primeiro) e, dentro de cada um, Light antes de Dark"; "dynamic vale em qualquer lugar". Os conectores
// são nomes de exemplo.
// A ordem dos conectores é a do Python (`settings/display/control.py`), "por ponto de código": as letras maiúsculas vêm antes das minúsculas.
//   .agents/scripts/testar.sh places
.import "apoio.js" as T
.import "settings/appearance/Places.js" as P

const test = T.test, equal = T.equal, check = T.check;

// O espaço antes do ponto do nome do lugar não quebra (ficha 13: "como no '1 · Built-in' da página Tela"): U+00A0, o ponto do meio U+00B7 e um espaço.
const DOT = " · ";

// ---- a chave de um lugar ----

test("chaves válidas: light, dark, display:<conector> e display:<conector>:light|dark", () => {
  ["light", "dark", "display:eDP-1", "display:HDMI-A-1", "display:DP-2:light", "display:eDP-1:dark", "display:DP-1.2", "display:X_y+z-9"].forEach((key) => {
    check(P.validKey(key), "deveria valer: " + key);
  });
  check(P.validKey("display:" + "a".repeat(64)), "64 caracteres no conector vale");
  check(P.validKey("display:" + "a".repeat(64) + ":dark"), "64 com o modo");
});

test("chaves inválidas: maiúsculas, modo desconhecido, conector vazio, longo demais ou fora do conjunto, e o que não é texto", () => {
  ["Light", "DARK", "auto", "", "display", "display:", "display::dark", "display:eDP-1:", "display:eDP-1:auto", "display:eDP-1:dark:light",
    "display:a b", "display:a/b", "display:a:b:c", "light:dark", "xdisplay:eDP-1", "display:eDP-1\n", " light"].forEach((key) => {
    check(!P.validKey(key), "não deveria valer: " + JSON.stringify(key));
  });
  check(!P.validKey("display:" + "a".repeat(65)), "65 caracteres no conector não vale");
  [null, undefined, 5, true, {}, ["light"]].forEach((value) => check(!P.validKey(value), "não é texto: " + JSON.stringify(value)));
});

// ---- tela embutida e ordem dos monitores ----

test("a tela embutida é eDP, LVDS, DSI ou DPI seguido de hífen, e vem primeiro na ordem dos monitores", () => {
  ["eDP-1", "eDP-2", "LVDS-1", "DSI-1", "DPI-1"].forEach((name) => check(P.isBuiltin(name), "embutida: " + name));
  ["HDMI-A-1", "DP-1", "DVI-D-1", "VGA-1", "eDP", "eDP1", "XeDP-1", "Virtual-1", ""].forEach((name) => check(!P.isBuiltin(name), "externa: " + JSON.stringify(name)));
  equal(P.sortConnectors(["HDMI-A-1", "DP-2", "eDP-1", "DP-1"]), ["eDP-1", "DP-1", "DP-2", "HDMI-A-1"]);
  equal(P.sortConnectors(["HDMI-A-2", "HDMI-A-1", "DP-1"]), ["DP-1", "HDMI-A-1", "HDMI-A-2"], "sem embutida");
  equal(P.sortConnectors(["DP-10", "DP-2", "DP-1"]), ["DP-1", "DP-10", "DP-2"], "por texto, e não por número");
  equal(P.sortConnectors(["dp-1", "DP-1"]), ["DP-1", "dp-1"], "ponto de código: maiúscula antes de minúscula");
  equal(P.sortConnectors(["HDMI-A-1", "eDP-1", "LVDS-1"]), ["LVDS-1", "eDP-1", "HDMI-A-1"], "duas embutidas, entre si por ponto de código");
});

test("a ordem dos monitores: lista vazia, um só, e a lista de entrada fica como estava", () => {
  equal(P.sortConnectors([]), []);
  equal(P.sortConnectors(["DP-1"]), ["DP-1"]);
  const input = ["HDMI-A-1", "eDP-1"];
  P.sortConnectors(input);
  equal(input, ["HDMI-A-1", "eDP-1"], "não mexe na lista que recebeu");
});

// ---- chave por tela e modo, e o nome do lugar ----

test("keyFor: cada combinação das duas chaves", () => {
  equal(P.keyFor(true, true, "eDP-1", "dark"), "display:eDP-1:dark", "as duas ligadas");
  equal(P.keyFor(true, true, "eDP-1", "light"), "display:eDP-1:light");
  equal(P.keyFor(false, true, "eDP-1", "dark"), "display:eDP-1", "só a dos monitores: o modo não conta");
  equal(P.keyFor(true, false, "eDP-1", "dark"), "dark", "só a do modo: o monitor não conta");
  equal(P.keyFor(true, false, "eDP-1", "light"), "light");
  equal(P.keyFor(false, false, "eDP-1", "dark"), "", "nenhuma: vale o da grade");
  equal(P.keyFor(true, false, "eDP-1", undefined), "light");
  equal(P.keyFor(true, true, "DP-1", "auto"), "display:DP-1:light");
  [[true, true], [false, true], [true, false]].forEach((flags) => {
    ["light", "dark"].forEach((scheme) => check(P.validKey(P.keyFor(flags[0], flags[1], "HDMI-A-1", scheme)), "chave válida"));
  });
});

test("nameOf: o nome do lugar, o mesmo na linha do cartão e no título do seletor", () => {
  equal(P.nameOf("light"), "Light");
  equal(P.nameOf("dark"), "Dark");
  equal(P.nameOf("display:HDMI-A-1"), "HDMI-A-1");
  equal(P.nameOf("display:eDP-1:dark"), "eDP-1" + DOT + "Dark");
  equal(P.nameOf("display:eDP-1:light"), "eDP-1" + DOT + "Light");
});

test("nameOf: chave inválida não tem nome, e o ponto não quebra a linha", () => {
  equal(P.nameOf("Light"), "");
  equal(P.nameOf("display:"), "");
  equal(P.nameOf(undefined), "");
  equal(P.nameOf(null), "");
  check(P.nameOf("display:eDP-1:dark").indexOf("eDP-1 ") < 0, "não é um espaço comum antes do ponto");
  check(P.nameOf("display:eDP-1:dark").indexOf(" ") === 5, "o espaço que não quebra vem logo depois do conector");
});

test("schemeLabel: Dark só para dark, e o resto é Light", () => {
  equal(P.schemeLabel("dark"), "Dark");
  equal(P.schemeLabel("light"), "Light");
  equal(P.schemeLabel(undefined), "Light");
  equal(P.schemeLabel("DARK"), "Light");
});

// ---- a entrada guardada de um lugar ----

test("entryOf: dynamic não leva caminho nem url, mesmo que o arquivo traga", () => {
  equal(P.entryOf({ light: { mode: "dynamic" } }, "light"), { mode: "dynamic", path: "", url: "" });
  equal(P.entryOf({ light: { mode: "dynamic", path: "/x/a.png", url: "file:///x/a.png" } }, "light"), { mode: "dynamic", path: "", url: "" });
});

test("entryOf: custom precisa de um caminho; a url que falta ou não é texto vira vazia", () => {
  equal(P.entryOf({ dark: { mode: "custom", path: "/x/a.png", url: "file:///x/a.png" } }, "dark"), { mode: "custom", path: "/x/a.png", url: "file:///x/a.png" });
  equal(P.entryOf({ dark: { mode: "custom", path: "/x/a.png" } }, "dark"), { mode: "custom", path: "/x/a.png", url: "" }, "sem url");
  equal(P.entryOf({ dark: { mode: "custom", path: "/x/a.png", url: 7 } }, "dark"), { mode: "custom", path: "/x/a.png", url: "" }, "url que não é texto");
  equal(P.entryOf({ dark: { mode: "custom", path: "" } }, "dark"), null, "caminho vazio");
  equal(P.entryOf({ dark: { mode: "custom" } }, "dark"), null, "sem caminho");
  equal(P.entryOf({ dark: { mode: "custom", path: 3 } }, "dark"), null, "caminho que não é texto");
});

test("entryOf: modo desconhecido, entrada que não é objeto, lugar ausente ou chave inválida valem null", () => {
  equal(P.entryOf({ light: { mode: "static", path: "/x" } }, "light"), null, "modo desconhecido");
  equal(P.entryOf({ light: "dynamic" }, "light"), null, "texto no lugar do objeto");
  equal(P.entryOf({ light: 5 }, "light"), null);
  equal(P.entryOf({ light: null }, "light"), null);
  equal(P.entryOf({}, "light"), null, "sem escolha");
  equal(P.entryOf({ dark: { mode: "dynamic" } }, "light"), null, "outro lugar");
  equal(P.entryOf(null, "light"), null);
  equal(P.entryOf(undefined, "light"), null);
  equal(P.entryOf({ "display:": { mode: "dynamic" } }, "display:"), null, "chave inválida, mesmo que esteja lá");
  equal(P.entryOf({ light: { mode: "dynamic" } }, ""), null, "chave vazia");
});

test("cleanPlaces guarda só as entradas bem formadas, com as chaves do formato", () => {
  const raw = {
    "light": { mode: "dynamic", extra: "some" },
    "dark": { mode: "custom", path: "/x/b.png", url: "file:///x/b.png" },
    "display:eDP-1": { mode: "custom", path: "" },
    "display:DP-1:dark": { mode: "dynamic" },
    "display:DP-1:auto": { mode: "dynamic" },
    "Light": { mode: "dynamic" },
    "display:HDMI-A-1": "dynamic",
    "display:HDMI-A-2": null
  };
  equal(P.cleanPlaces(raw), {
    "light": { mode: "dynamic", path: "", url: "" },
    "dark": { mode: "custom", path: "/x/b.png", url: "file:///x/b.png" },
    "display:DP-1:dark": { mode: "dynamic", path: "", url: "" }
  });
  // o que não é um dicionário vira um dicionário vazio
  equal(P.cleanPlaces(null), {});
  equal(P.cleanPlaces(undefined), {});
  equal(P.cleanPlaces("light"), {});
  equal(P.cleanPlaces(5), {});
  equal(P.cleanPlaces([{ mode: "dynamic" }]), {}, "uma lista tem chaves '0', '1', que não são lugares");
  equal(P.cleanPlaces({}), {});
});

// ---- o que vale em cada lugar ----

const GRID_IMAGE = { mode: "custom", path: "/grid/sky.png", url: "file:///grid/sky.png" };
const GRID_DYNAMIC = { mode: "dynamic", path: "", url: "" };

test("resolve: a escolha do lugar ganha da grade, e o resultado diz que foi escolha", () => {
  const places = { dark: { mode: "custom", path: "/x/night.png", url: "file:///x/night.png" } };
  equal(P.resolve(GRID_IMAGE, places, "dark"), { mode: "custom", path: "/x/night.png", url: "file:///x/night.png", chosen: true });
  equal(P.resolve(GRID_IMAGE, { light: { mode: "dynamic" } }, "light"), { mode: "dynamic", path: "", url: "", chosen: true }, "dynamic vale em qualquer lugar");
});

test("resolve: lugar sem escolha usa o marcado na grade, e o dynamic da grade também", () => {
  equal(P.resolve(GRID_IMAGE, {}, "dark"), { mode: "custom", path: "/grid/sky.png", url: "file:///grid/sky.png", chosen: false });
  equal(P.resolve(GRID_DYNAMIC, {}, "display:DP-1"), { mode: "dynamic", path: "", url: "", chosen: false });
  equal(P.resolve(GRID_IMAGE, null, "dark").chosen, false, "sem dicionário de lugares");
  equal(P.resolve(GRID_IMAGE, { dark: { mode: "custom", path: "" } }, "dark").chosen, false, "entrada estragada vale como lugar sem escolha");
  equal(P.resolve(GRID_IMAGE, { dark: "oops" }, "dark").path, "/grid/sky.png");
});

test("resolve: um lugar não herda de outro (ponto 6 da P-67), nem a chave vazia olha os lugares", () => {
  const places = {
    "light": { mode: "custom", path: "/x/l.png", url: "u" },
    "display:DP-1": { mode: "custom", path: "/x/d.png", url: "u" },
    "display:DP-1:light": { mode: "dynamic" }
  };
  equal(P.resolve(GRID_IMAGE, places, "display:DP-1:dark").chosen, false, "nem do modo, nem do monitor");
  equal(P.resolve(GRID_IMAGE, places, "display:DP-1:dark").path, "/grid/sky.png");
  equal(P.resolve(GRID_IMAGE, places, "display:HDMI-A-1:light").path, "/grid/sky.png", "outro monitor");
  equal(P.resolve(GRID_IMAGE, places, "").path, "/grid/sky.png", "chave vazia: as duas chaves desligadas");
  equal(P.resolve(GRID_IMAGE, places, "").chosen, false);
});

test("forScreen com as duas chaves desligadas devolve exatamente o marcado na grade, mesmo havendo lugares guardados", () => {
  const places = { dark: { mode: "dynamic" }, "display:DP-1": { mode: "dynamic" }, "display:DP-1:dark": { mode: "dynamic" } };
  equal(P.forScreen(false, false, places, GRID_IMAGE, "DP-1", "dark"), { custom: true, url: "file:///grid/sky.png" });
  equal(P.forScreen(false, false, places, GRID_DYNAMIC, "DP-1", "dark"), { custom: false, url: "" }, "grade em Dynamic: sem imagem");
});

test("forScreen: o modo, o monitor ou os dois, conforme as chaves", () => {
  const places = {
    "light": { mode: "custom", path: "/x/light.png", url: "file:///x/light.png" },
    "dark": { mode: "custom", path: "/x/dark.png", url: "file:///x/dark.png" },
    "display:DP-1": { mode: "custom", path: "/x/mon.png", url: "file:///x/mon.png" },
    "display:DP-1:dark": { mode: "custom", path: "/x/mon-dark.png", url: "file:///x/mon-dark.png" }
  };
  equal(P.forScreen(true, false, places, GRID_IMAGE, "DP-1", "dark").url, "file:///x/dark.png", "só o modo");
  equal(P.forScreen(true, false, places, GRID_IMAGE, "DP-1", "light").url, "file:///x/light.png");
  equal(P.forScreen(false, true, places, GRID_IMAGE, "DP-1", "dark").url, "file:///x/mon.png", "só o monitor: o modo não conta");
  equal(P.forScreen(true, true, places, GRID_IMAGE, "DP-1", "dark").url, "file:///x/mon-dark.png", "os dois");
  equal(P.forScreen(true, true, places, GRID_IMAGE, "DP-1", "light").url, "file:///grid/sky.png", "o lugar display:DP-1:light não tem escolha: usa a grade, e não o modo");
  equal(P.forScreen(false, true, places, GRID_IMAGE, "HDMI-A-1", "dark").url, "file:///grid/sky.png", "monitor sem escolha");
  equal(P.forScreen(true, false, { dark: { mode: "dynamic" } }, GRID_IMAGE, "DP-1", "dark"), { custom: false, url: "" }, "um lugar em Dynamic não leva imagem, e ganha de uma imagem na grade");
});

// ---- as linhas do cartão Customize ----

test("rows: sem chave nenhuma não há linha, e só a chave do modo dá Light e Dark, qualquer que seja a lista de monitores", () => {
  equal(P.rows(false, false, ["eDP-1", "DP-1"], {}, GRID_IMAGE), []);
  const rows = P.rows(true, false, ["eDP-1", "DP-1"], {}, GRID_IMAGE);
  equal(rows.map((row) => row.key), ["light", "dark"]);
  equal(rows.map((row) => row.name), ["Light", "Dark"]);
  equal(P.rows(true, false, [], {}, GRID_IMAGE).map((row) => row.key), ["light", "dark"], "mesmo sem monitor");
});

test("rows: só a chave dos monitores dá uma linha por monitor, com a embutida primeiro", () => {
  const rows = P.rows(false, true, ["HDMI-A-1", "DP-1", "eDP-1"], {}, GRID_IMAGE);
  equal(rows.map((row) => row.key), ["display:eDP-1", "display:DP-1", "display:HDMI-A-1"]);
  equal(rows.map((row) => row.name), ["eDP-1", "DP-1", "HDMI-A-1"]);
});

test("rows: as duas chaves dão, por monitor, Light antes de Dark", () => {
  const rows = P.rows(true, true, ["DP-1", "eDP-1"], {}, GRID_IMAGE);
  equal(rows.map((row) => row.key), ["display:eDP-1:light", "display:eDP-1:dark", "display:DP-1:light", "display:DP-1:dark"]);
  equal(rows.map((row) => row.name), ["eDP-1" + DOT + "Light", "eDP-1" + DOT + "Dark", "DP-1" + DOT + "Light", "DP-1" + DOT + "Dark"]);
  rows.forEach((row) => check(P.validKey(row.key), "chave válida: " + row.key));
});

test("rows: a chave dos monitores sem monitor ligado não tem linha, e os lugares guardados ficam como estavam", () => {
  const places = { "display:DP-9": { mode: "dynamic" } };
  const copy = JSON.stringify(places);
  equal(P.rows(false, true, [], places, GRID_IMAGE), []);
  equal(P.rows(false, true, ["eDP-1"], places, GRID_IMAGE).map((row) => row.key), ["display:eDP-1"], "o monitor desligado some da lista");
  equal(JSON.stringify(places), copy, "e a escolha dele continua guardada");
});

test("rows: cada linha mostra o que vale no lugar, a escolha dele ou, sem escolha, o marcado na grade", () => {
  const places = {
    "display:eDP-1:dark": { mode: "dynamic" },
    "display:DP-1:dark": { mode: "custom", path: "/x/b.png", url: "file:///x/b.png" }
  };
  const rows = P.rows(true, true, ["eDP-1", "DP-1"], places, GRID_IMAGE);
  const byKey = {};
  rows.forEach((row) => { byKey[row.key] = row; });
  equal(byKey["display:eDP-1:dark"].dynamic, true, "Dynamic escolhido");
  equal(byKey["display:eDP-1:dark"].url, "", "Dynamic não tem url");
  equal(byKey["display:DP-1:dark"].dynamic, false);
  equal(byKey["display:DP-1:dark"].url, "file:///x/b.png", "a imagem escolhida");
  equal(byKey["display:eDP-1:light"].url, "file:///grid/sky.png", "sem escolha: o da grade");
  equal(byKey["display:eDP-1:light"].dynamic, false);
  equal(Object.keys(byKey["display:eDP-1:light"]).sort(), ["dynamic", "key", "name", "url"], "a linha leva só o que o cartão usa");
});

test("rows: sem escolha, uma grade em Dynamic aparece como Dynamic em todas as linhas, e a escolha de imagem num lugar ganha dela", () => {
  const same = P.rows(true, false, [], {}, GRID_DYNAMIC);
  equal(same.map((row) => row.dynamic), [true, true]);
  equal(same.map((row) => row.url), ["", ""]);
  const rows = P.rows(true, false, [], { light: { mode: "custom", path: "/x/a.png", url: "file:///x/a.png" } }, GRID_DYNAMIC);
  equal(rows[0], { key: "light", name: "Light", dynamic: false, url: "file:///x/a.png" });
  equal(rows[1].dynamic, true, "o Dark continua o da grade");
});
