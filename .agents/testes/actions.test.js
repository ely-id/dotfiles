// Testes do menu "Actions" do launcher: wintermute-shell/launcher/Actions.js. Os casos saem da ficha 14, seção "Menu de ações: como
// funciona" (F5-T05, P-13) e, para o histórico da área de transferência, da ficha 18, seção "O menu Ctrl+K" (F6-T16).
//   .agents/scripts/testar.sh actions
.import "apoio.js" as T
.import "launcher/Actions.js" as A

const test = T.test, equal = T.equal, check = T.check;

// Linhas fictícias, no formato que o Search.js entrega.
const appTarget = { type: "app", id: "firefox" };
const appRow = { title: "Firefox", kind: "App", target: appTarget };
const fileTarget = { type: "file", path: "/home/u/Documents/notes.txt", directory: false };
const fileRow = { title: "notes.txt", kind: "File", target: fileTarget };
const settingTarget = { type: "setting", page: "wallpaper" };
const settingRow = { title: "Wallpaper", kind: "Setting", target: settingTarget };
const lockTarget = { type: "command", action: "lock" };
const lockRow = { title: "Lock screen", kind: "Command", danger: false, target: lockTarget };
const rebootTarget = { type: "command", action: "reboot" };
const rebootRow = { title: "Restart", kind: "Command", danger: true, target: rebootTarget };

const summary = (list) => list.map((a) => [a.title, a.icon]);

// ---- que tipo de item tem menu ----

test("o tipo do item: app, arquivo, ajuste, comando, cálculo e histórico", () => {
  equal(A.itemType(appRow), "app");
  equal(A.itemType(fileRow), "file");
  equal(A.itemType(settingRow), "setting");
  equal(A.itemType(lockRow), "command");
  equal(A.itemType({ title: "Copy result", copy: "460" }), "calc");
  equal(A.itemType({ title: "x", clipboard: { unpinned: 0 } }), "clipboard");
  equal(A.itemType(null), "");
  equal(A.itemType(undefined), "");
});

// ---- as ações de cada tipo (a tabela da P-13) ----

test("app: Open e Open on workspace…", () => {
  equal(summary(A.rowsFor(appRow, [])), [["Open", "arrow-up-right"], ["Open on workspace…", "layout-grid"]]);
});

test("app: Open leva o alvo da linha, e Open on workspace… troca a lista pela dos workspaces", () => {
  const list = A.rowsFor(appRow, []);
  equal(list[0].target, appTarget);
  equal(list[1].act, "workspaces");
});

test("app: 'Remove from recent' só aparece para app que está nos recentes", () => {
  equal(A.rowsFor(appRow, ["outro"]).length, 2);
  equal(A.rowsFor(appRow, undefined).length, 2);
  const list = A.rowsFor(appRow, ["outro", "firefox"]);
  equal(summary(list), [["Open", "arrow-up-right"], ["Open on workspace…", "layout-grid"], ["Remove from recent", "trash-2"]]);
  equal(list[2].act, "remove-recent");
});

test("arquivo: Open, Show in folder e Copy path, com o caminho absoluto para copiar", () => {
  const list = A.rowsFor(fileRow, []);
  equal(summary(list), [["Open", "arrow-up-right"], ["Show in folder", "folder"], ["Copy path", "copy"]]);
  equal(list[0].target, fileTarget);
  equal(list[1].act, "show-folder");
  equal(list[2].copy, "/home/u/Documents/notes.txt");
});

test("ajuste: só Open", () => {
  const list = A.rowsFor(settingRow, []);
  equal(summary(list), [["Open", "arrow-up-right"]]);
  equal(list[0].target, settingTarget);
});

test("comando: Run, com o ícone play, e o perigoso fica perigoso", () => {
  const safe = A.rowsFor(lockRow, []);
  equal(summary(safe), [["Run", "play"]]);
  equal(safe[0].target, lockTarget);
  equal(safe[0].danger, false);
  equal(A.rowsFor(rebootRow, [])[0].danger, true, "Restart pede a confirmação dos dois Enters");
  equal(A.rowsFor(rebootRow, [])[0].target, rebootTarget);
});

test("cálculo: Copy result e, só quando há hexadecimal, Copy hexadecimal", () => {
  const calcRow = { title: "Copy result", copy: "460" };
  const withHex = A.rowsFor(calcRow, [], { result: "460", hex: "0x1CC" });
  equal(summary(withHex), [["Copy result", "copy"], ["Copy hexadecimal", "hash"]]);
  equal(withHex.map((a) => a.copy), ["460", "0x1CC"]);
  const without = A.rowsFor(calcRow, [], { result: "2,5", hex: "" });
  equal(summary(without), [["Copy result", "copy"]]);
  equal(without[0].copy, "2,5");
});

test("cálculo sem o cálculo do estado não tem ação", () => {
  equal(A.rowsFor({ title: "Copy result", copy: "460" }, [], null), []);
});

test("as linhas do 'Nothing found' não têm menu: Ctrl+K nelas não faz nada", () => {
  equal(A.rowsFor({ title: "Search the web", kind: "Action", target: { type: "web-search", text: "xyzzy" } }, []), []);
  equal(A.rowsFor({ title: "Search files", kind: "Action", target: { type: "file-search", text: "xyzzy" } }, []), []);
  equal(A.rowsFor(null, []), []);
  equal(A.rowsFor({ title: "sem alvo" }, []), []);
});

test("toda ação tem o tipo Action, detalhe vazio e ícone", () => {
  const all = [].concat(
    A.rowsFor(appRow, ["firefox"]), A.rowsFor(fileRow, []), A.rowsFor(settingRow, []), A.rowsFor(rebootRow, []),
    A.rowsFor({ copy: "1" }, [], { result: "1", hex: "0x1" }),
    A.rowsFor({ clipboard: { item: { pinned: false }, unpinned: 2 } }, []));
  check(all.length > 10);
  all.forEach((a) => {
    equal([a.kind, a.detail], ["Action", ""], a.title);
    check(a.icon !== "", a.title + " sem ícone");
  });
});

// ---- o cabeçalho da página ----

test("o título da página é o nome do item, ou a expressão formatada no cálculo", () => {
  equal(A.itemTitle(appRow, null), "Firefox");
  equal(A.itemTitle(fileRow, null), "notes.txt");
  equal(A.itemTitle({ title: "Copy result", copy: "460" }, { expression: "128 × 3,5 + 12", result: "460" }), "128 × 3,5 + 12");
  equal(A.itemTitle(null, null), "");
  equal(A.itemTitle({}, null), "");
});

// ---- mostrar na pasta ----

test("a pasta de um arquivo é o caminho sem o último componente", () => {
  equal(A.parentDirectory("/home/u/Documents/notes.txt"), "/home/u/Documents");
  equal(A.parentDirectory("/home/u/dir with space/a b.txt"), "/home/u/dir with space");
  equal(A.parentDirectory("/notes.txt"), "/", "um item direto na raiz fica em /");
  equal(A.parentDirectory(""), "/");
  equal(A.parentDirectory(undefined), "/");
});

// ---- Open on workspace… ----

const entries = [
  { outputName: "eDP-1", workspaceId: 10, sidebarWorkspaceNumber: 1, sidebarRowOrdinal: 0 },
  { outputName: "HDMI-A-1", workspaceId: 20, sidebarWorkspaceNumber: 1, sidebarRowOrdinal: 0 },
  { outputName: "eDP-1", workspaceId: 11, sidebarWorkspaceNumber: 2, sidebarRowOrdinal: 1 },
  { outputName: "eDP-1", workspaceId: 12, sidebarWorkspaceNumber: 0, sidebarRowOrdinal: 2 }   // a linha de criação, ainda sem número
];

test("a segunda camada: um 'Workspace N' por workspace do monitor, na ordem do organizador", () => {
  const rows = A.workspaceRows(entries, "eDP-1");
  equal(rows.map((r) => r.title), ["Workspace 1", "Workspace 2", "Workspace 3"]);
  equal(rows.map((r) => r.act), ["pick-workspace", "pick-workspace", "pick-workspace"]);
  equal(rows.map((r) => r.workspaceId), [10, 11, 12]);
  rows.forEach((r) => equal([r.kind, r.icon], ["Action", "layout-grid"]));
});

test("a linha de criação sem número usa a posição dela, como a etiqueta 'On workspace N'", () => {
  const rows = A.workspaceRows([{ outputName: "A", workspaceId: 5, sidebarWorkspaceNumber: 0, sidebarRowOrdinal: 0 }], "A");
  equal(rows.map((r) => r.title), ["Workspace 1"]);
  equal(A.workspaceNumber({ sidebarWorkspaceNumber: 4, sidebarRowOrdinal: 9 }), 4, "o número do organizador vence");
  equal(A.workspaceNumber({ sidebarRowOrdinal: 3 }), 4);
  equal(A.workspaceNumber({}), 1);
});

test("só os workspaces do monitor do launcher", () => {
  equal(A.workspaceRows(entries, "HDMI-A-1").map((r) => r.workspaceId), [20]);
  equal(A.workspaceRows(entries, "DP-9"), []);
  equal(A.workspaceRows(undefined, "eDP-1"), []);
});

// ---- o histórico da área de transferência (ficha 18) ----

test("histórico com item não fixado: Copy, Pin, Delete e Clear history", () => {
  const list = A.rowsFor({ title: "x", clipboard: { item: { pinned: false }, unpinned: 3 } }, []);
  equal(summary(list), [["Copy", "copy"], ["Pin", "pin"], ["Delete", "x"], ["Clear history", "trash-2"]]);
  equal(list.map((a) => a.act), ["clipboard-copy", "clipboard-pin", "clipboard-delete", "clipboard-clear"]);
});

test("histórico: com o item fixado, Pin vira Unpin", () => {
  const list = A.rowsFor({ title: "x", clipboard: { item: { pinned: true }, unpinned: 3 } }, []);
  equal(list.map((a) => a.title), ["Copy", "Unpin", "Delete", "Clear history"]);
});

test("histórico: Clear history é a linha de perigo, e só ela", () => {
  const list = A.rowsFor({ title: "x", clipboard: { item: { pinned: false }, unpinned: 1 } }, []);
  equal(list.map((a) => a.danger), [false, false, false, true]);
});

test("histórico: Clear history só aparece quando há item não fixado para tirar", () => {
  const list = A.rowsFor({ title: "x", clipboard: { item: { pinned: true }, unpinned: 0 } }, []);
  equal(list.map((a) => a.title), ["Copy", "Unpin", "Delete"], "com tudo fixado");
});

test("histórico sem item selecionado (a busca não achou nada): só Clear history, e sem o que limpar o menu fica vazio", () => {
  equal(A.rowsFor({ title: "Clipboard", clipboard: { unpinned: 2 } }, []).map((a) => a.title), ["Clear history"]);
  equal(A.rowsFor({ title: "Clipboard", clipboard: { unpinned: 0 } }, []), []);
  equal(A.rowsFor({ title: "Clipboard", clipboard: {} }, []), []);
});
