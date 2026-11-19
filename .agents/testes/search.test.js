// Testes da busca do launcher: wintermute-shell/launcher/Search.js. Os casos saem da ficha 14, seção "Busca: como funciona" (F5-T02,
// P-12 e P-78), "Ações do sem resultado" (F5-T11, P-73) e "Textos em inglês" (decisão 0012).
//   .agents/scripts/testar.sh search
.import "apoio.js" as T
.import "launcher/Search.js" as S

const test = T.test, equal = T.equal, check = T.check;

// Linhas fictícias. Só o que a busca lê: título, campos secundários e alvo.
const row = (title, extra) => Object.assign({ title: title, detail: "", kind: "App", secondary: [], target: { type: "app", id: title.toLowerCase() } }, extra || {});
const titles = (rows) => rows.map((r) => r.title);
const rankTitles = (query, rows, recents) => S.rank(query, rows, recents || []).map((entry) => entry.row.title);

// ---- casar ----

test("sem diferença de maiúsculas nem de acentos: 'cafe' acha 'Café'", () => {
  const rows = [row("Café Noir"), row("Terminal")];
  equal(rankTitles("cafe", rows), ["Café Noir"]);
  equal(rankTitles("CAFÉ", rows), ["Café Noir"]);
  equal(rankTitles("café", [row("Cafe Noir")]), ["Cafe Noir"], "e ao contrário");
  equal(S.normalize("ÀÉÎÕÜ Ç"), "aeiou c");
  equal(S.normalize(null), "");
});

test("só trecho contínuo, sem busca aproximada", () => {
  equal(rankTitles("frx", [row("Firefox")]), []);
  equal(rankTitles("fiefox", [row("Firefox")]), []);
  equal(rankTitles("fire", [row("Firefox")]), ["Firefox"]);
});

test("texto vazio, ou só com espaços, não casa com nada", () => {
  equal(rankTitles("", [row("Firefox")]), []);
  equal(rankTitles("   ", [row("Firefox")]), []);
});

test("o espaço nas pontas do texto não conta", () => {
  equal(rankTitles("  fire ", [row("Firefox")]), ["Firefox"]);
});

test("a ordem: prefixo do título, prefixo de uma palavra, trecho, campo secundário", () => {
  const rows = [
    row("Campfire"),                                  // trecho do título
    row("Browser", { secondary: ["fire"] }),          // só num campo secundário
    row("Mozilla Fire Tool"),                         // prefixo de uma palavra
    row("Terminal"),                                  // não casa
    row("Firefox")                                    // prefixo do título
  ];
  equal(rankTitles("fire", rows), ["Firefox", "Mozilla Fire Tool", "Campfire", "Browser"]);
});

test("o prefixo de uma palavra vale depois de qualquer separador", () => {
  const scores = (title) => S.rank("fire", [row(title)], [])[0].score;
  equal(scores("Firefox"), S.SCORE_PREFIX);
  equal(scores("Mozilla-Fire"), S.SCORE_WORD_PREFIX);
  equal(scores("My_fire"), S.SCORE_WORD_PREFIX);
  equal(scores("Settings › Fire"), S.SCORE_WORD_PREFIX);
  equal(scores("Campfire"), S.SCORE_SUBSTRING);
  equal(S.SCORE_PREFIX > S.SCORE_WORD_PREFIX && S.SCORE_WORD_PREFIX > S.SCORE_SUBSTRING && S.SCORE_SUBSTRING > S.SCORE_SECONDARY, true);
});

test("o campo secundário: o GenericName e as Keywords do app, e a página mãe do ajuste", () => {
  const firefox = S.appRow({ id: "firefox", name: "Firefox", genericName: "Web Browser", keywords: ["internet", "www"] });
  equal(S.rank("browser", [firefox], []).map((e) => e.score), [S.SCORE_SECONDARY]);
  equal(S.rank("internet", [firefox], []).map((e) => e.score), [S.SCORE_SECONDARY]);
  const wallpaper = S.settingRows(["wallpaper"])[0];
  equal(S.rank("appearance", [wallpaper], []).map((e) => e.score), [S.SCORE_SECONDARY]);
});

test("no empate, o app que abri há menos tempo vem antes, e depois a ordem alfabética", () => {
  const rows = [row("Gimp", { target: { type: "app", id: "gimp" } }), row("Geany", { target: { type: "app", id: "geany" } }), row("Gedit", { target: { type: "app", id: "gedit" } })];
  equal(rankTitles("g", rows), ["Geany", "Gedit", "Gimp"], "sem recentes: alfabética");
  equal(rankTitles("g", rows, ["gedit", "gimp"]), ["Gedit", "Gimp", "Geany"], "recentes primeiro, o mais novo na frente");
  equal(rankTitles("g", rows, ["gimp"]), ["Gimp", "Geany", "Gedit"]);
});

test("a nota do casamento ganha de ser recente", () => {
  const rows = [row("Campfire", { target: { type: "app", id: "campfire" } }), row("Firefox", { target: { type: "app", id: "firefox" } })];
  equal(rankTitles("fire", rows, ["campfire"]), ["Firefox", "Campfire"]);
});

// ---- "Best match" ou grupos ----

test("com até 3 resultados no total, uma seção só, 'Best match', com os tipos misturados", () => {
  const sections = S.buildSections("mon", {
    apps: [row("Monitor Tool")],                                                          // prefixo
    files: [row("Salmon.txt", { kind: "File", target: { type: "file", path: "/x/Salmon.txt" } })],   // trecho
    settings: [row("Second Monitor", { kind: "Setting", target: { type: "setting", page: "x" } })],  // prefixo de palavra
    commands: [row("Power off", { kind: "Command", target: { type: "command", action: "shutdown" } })]   // não casa
  }, []);
  equal(sections.length, 1);
  equal(sections[0].label, "Best match");
  equal(titles(sections[0].rows), ["Monitor Tool", "Second Monitor", "Salmon.txt"]);
  equal(sections[0].rows.map((r) => r.kind), ["App", "Setting", "File"]);
});

test("com 4 ou mais, os grupos fixos Apps, Files, Settings e Commands, e o grupo vazio não aparece", () => {
  const sections = S.buildSections("a", {
    commands: [row("Alarm", { kind: "Command" })],
    files: [row("Atlas.txt", { kind: "File" })],
    apps: [row("Alpha"), row("Beta")]
  }, []);
  equal(sections.map((s) => s.label), ["Apps", "Files", "Commands"]);
  equal(titles(sections[0].rows), ["Alpha", "Beta"]);
});

test("os quatro grupos saem na ordem do board, não na das chaves de quem chama", () => {
  const sections = S.buildSections("e", {
    commands: [row("Eject")],
    settings: [row("Energy")],
    files: [row("Eagle.png")],
    apps: [row("Editor")]
  }, []);
  equal(sections.map((s) => s.label), ["Apps", "Files", "Settings", "Commands"]);
});

test("o limite entre as duas formas: 3 resultados é Best match, 4 são grupos", () => {
  const three = S.buildSections("a", { apps: [row("A1"), row("A2"), row("A3")] }, []);
  equal(three.map((s) => s.label), ["Best match"]);
  const four = S.buildSections("a", { apps: [row("A1"), row("A2"), row("A3"), row("A4")] }, []);
  equal(four.map((s) => s.label), ["Apps"]);
  equal(S.BEST_MATCH_MAX, 3);
});

test("cada grupo mostra no máximo 5 linhas, as de maior nota", () => {
  const apps = [];
  for (let i = 1; i <= 7; ++i)
    apps.push(row("Item " + i));            // prefixo
  apps.push(row("Zed item"));               // prefixo de palavra: nota menor, fica de fora do corte
  const sections = S.buildSections("item", { apps: apps, commands: [row("Item command", { kind: "Command" })] }, []);
  equal(S.GROUP_MAX, 5);
  equal(sections[0].label, "Apps");
  equal(titles(sections[0].rows), ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"], "os de prefixo, por ordem alfabética");
  equal(sections[1].rows.length, 1);
});

test("sem resultado nenhum, a lista de seções é vazia (é aí que o 'Nothing found' entra)", () => {
  equal(S.buildSections("xyzzy", { apps: [row("Firefox")] }, []), []);
  equal(S.buildSections("fire", {}, []), []);
  equal(S.buildSections("fire", undefined, []), []);
  equal(S.buildSections("", { apps: [row("Firefox")] }, []), []);
});

test("countRows soma as linhas das seções", () => {
  equal(S.countRows([{ rows: [1, 2] }, { rows: [3] }]), 3);
  equal(S.countRows([]), 0);
  equal(S.countRows(undefined), 0);
});

// ---- sugestão fantasma ----

const sectionsOf = (title) => [{ label: "Best match", rows: [{ title: title }] }];

test("a sugestão fantasma é o resto do título da primeira linha", () => {
  equal(S.ghost("ter", sectionsOf("Terminal")), "minal");   // o exemplo do board: "ter" + "minal"
  equal(S.ghost("t", sectionsOf("Terminal")), "erminal");
});

test("a sugestão não diferencia maiúsculas nem acentos, e devolve o resto como o título escreve", () => {
  equal(S.ghost("TER", sectionsOf("Terminal")), "minal");
  equal(S.ghost("caf", sectionsOf("Café")), "é");
  equal(S.ghost("cafe", sectionsOf("Café Noir")), " Noir");
  equal(S.ghost("caf", sectionsOf("Café")), "é", "o acento solto também");
});

test("sem sugestão quando o texto não é prefixo do título, mesmo casando no meio", () => {
  equal(S.ghost("fox", sectionsOf("Firefox")), "");
  equal(S.ghost("fire", sectionsOf("Mozilla Firefox")), "");
});

test("sem sugestão com o título inteiro já digitado, ou com texto maior que ele", () => {
  equal(S.ghost("terminal", sectionsOf("Terminal")), "");
  equal(S.ghost("terminals", sectionsOf("Terminal")), "");
});

test("sem sugestão com o texto vazio, com espaço no fim ou sem resultado", () => {
  equal(S.ghost("", sectionsOf("Terminal")), "");
  equal(S.ghost("ter ", sectionsOf("Terminal")), "");
  equal(S.ghost("ter", []), "");
  equal(S.ghost("ter", [{ label: "Apps", rows: [] }]), "");
  equal(S.ghost("ter", undefined), "");
});

test("sem sugestão com espaço no fim, mesmo quando o título tem o espaço ali (só a regra do espaço explica o vazio)", () => {
  // A ficha 14: o fantasma só vale "sem espaço no fim". "visual " é prefixo de "Visual Notes" (7 caracteres iguais, o sétimo é o espaço), então
  // sem a conferência do espaço o resto seria "Notes". O caso de "ter " contra "Terminal" não pega isso: "Terminal" não tem espaço na posição 3.
  equal(S.ghost("visual ", sectionsOf("Visual Notes")), "");
  equal(S.ghost("visual", sectionsOf("Visual Notes")), " Notes", "sem o espaço o fantasma aparece, com o espaço que o título tem");
  equal(S.ghost("visual\t", sectionsOf("Visual\tNotes")), "", "tabulação no fim também é espaço");
});

test("a sugestão vem só da primeira linha da primeira seção", () => {
  const sections = [{ label: "Apps", rows: [{ title: "Terminal" }, { title: "Terra" }] }, { label: "Files", rows: [{ title: "Tertiary.txt" }] }];
  equal(S.ghost("ter", sections), "minal");
});

// ---- recentes ----

test("os recentes: lista de ids, e arquivo ausente ou estragado vale lista vazia", () => {
  equal(S.parseRecents('["a","b"]'), ["a", "b"]);
  equal(S.parseRecents(""), []);
  equal(S.parseRecents(undefined), []);
  equal(S.parseRecents("não é JSON"), []);
  equal(S.parseRecents('{"a":1}'), []);
  equal(S.parseRecents("null"), []);
});

test("os recentes: sem repetir, só texto não vazio, e até 10", () => {
  equal(S.parseRecents('["a","b","a",3,"",null,"c"]'), ["a", "b", "c"]);
  const many = [];
  for (let i = 0; i < 14; ++i)
    many.push("app" + i);
  equal(S.RECENTS_KEPT, 10);
  equal(S.parseRecents(JSON.stringify(many)).length, 10);
  equal(S.parseRecents(JSON.stringify(many), 4), ["app0", "app1", "app2", "app3"]);
});

test("abrir um app o põe na frente, sem repetir, e a lista corta em 10", () => {
  equal(S.pushRecent(["a", "b", "c"], "b"), ["b", "a", "c"]);
  equal(S.pushRecent(["a", "b"], "z"), ["z", "a", "b"]);
  equal(S.pushRecent(undefined, "z"), ["z"]);
  const ten = ["a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9"];
  const out = S.pushRecent(ten, "novo");
  equal(out.length, 10);
  equal([out[0], out[9]], ["novo", "a8"], "o mais antigo saiu");
  equal(ten.length, 10, "a lista de quem chamou não muda");
  equal(ten[0], "a0");
});

test("'Remove from recent' tira o id e deixa os outros na mesma ordem", () => {
  equal(S.dropRecent(["a", "b", "c"], "b"), ["a", "c"]);
  equal(S.dropRecent(["a", "b"], "x"), ["a", "b"]);
  equal(S.dropRecent(undefined, "x"), []);
});

test("o arquivo dos recentes: JSON com recuo de 2 e quebra de linha no fim", () => {
  equal(S.serializeRecents(["a", "b"]), '[\n  "a",\n  "b"\n]\n');
  equal(S.parseRecents(S.serializeRecents(["a", "b"])), ["a", "b"]);
});

test("o estado vazio mostra os 3 primeiros recentes que ainda estão instalados", () => {
  const byId = { a: row("A"), b: row("B"), c: row("C"), d: row("D"), x: row("X") };
  equal(S.RECENTS_SHOWN, 3);
  equal(titles(S.recentRows(["a", "b", "c", "d"], byId)), ["A", "B", "C"]);
  equal(titles(S.recentRows(["gone", "a", "removido", "b", "c", "d"], byId)), ["A", "B", "C"], "o que sumiu é pulado");
  equal(titles(S.recentRows(["a"], byId)), ["A"]);
  equal(S.recentRows([], byId), []);
  equal(S.recentRows(["a"], undefined), []);
});

// ---- apps ----

test("a linha de app: título é o nome, detalhe é o GenericName, ícone é o do aplicativo", () => {
  const entry = { id: "firefox", name: "Firefox", genericName: "Web Browser", keywords: ["internet", "www"], icon: "firefox" };
  const r = S.appRow(entry);
  equal([r.title, r.detail, r.kind, r.iconSource], ["Firefox", "Web Browser", "App", "firefox"]);
  equal(r.secondary, ["Web Browser", "internet", "www"]);
  equal([r.target.type, r.target.id], ["app", "firefox"]);
  const bare = S.appRow({ id: "x", name: "X" });
  equal([bare.detail, bare.iconSource, bare.secondary], ["", "", []]);
});

test("só entram os apps que aparecem em menu, e há o mapa de id para linha", () => {
  const out = S.appRows([
    { id: "a", name: "A" },
    { id: "hidden", name: "Hidden", noDisplay: true },
    { id: "noname" },
    null,
    { id: "b", name: "B" }
  ]);
  equal(titles(out.rows), ["A", "B"]);
  equal(Object.keys(out.byId).sort(), ["a", "b"]);
  equal(out.byId.a, out.rows[0]);
  equal(S.appRows(undefined).rows, []);
});

// ---- ajustes ----

test("as 11 páginas dos Ajustes, com o detalhe 'Settings' nas de topo e 'Settings › mãe' nas outras", () => {
  const all = ["appearance", "wallpaper", "customize", "display", "arrange", "system", "mouse", "lock", "keyboard", "information", "manual"];
  const rows = S.settingRows(all);
  equal(rows.length, 11);
  const byTitle = {};
  rows.forEach((r) => { byTitle[r.title] = r.detail; });
  equal(byTitle, {
    "Appearance": "Settings",
    "Wallpaper": "Settings › Appearance",
    "Customize": "Settings › Wallpaper",
    "Display": "Settings › Appearance",
    "Arrange displays": "Settings › Display",
    "System": "Settings",
    "Mouse & touchpad": "Settings › System",
    "Lock & sleep": "Settings › System",
    "Keyboard language": "Settings › System",
    "Information": "Settings",
    "Manual": "Settings › Information"
  });
});

test("a linha de ajuste leva a página no alvo e o nome da mãe como campo secundário", () => {
  const wallpaper = S.settingRows(["wallpaper"])[0];
  equal(wallpaper.kind, "Setting");
  equal(wallpaper.target, { type: "setting", page: "wallpaper" });
  equal(wallpaper.secondary, ["Appearance"]);
  equal(S.settingRows(["appearance"])[0].secondary, [], "a de topo não tem mãe");
});

test("página que não está na tabela fica de fora", () => {
  equal(titles(S.settingRows(["appearance", "nope", "system"])), ["Appearance", "System"]);
  equal(S.settingRows(undefined), []);
});

// ---- comandos de sessão ----

test("os cinco comandos, com o detalhe Session, na ordem da ficha", () => {
  const rows = S.commandRows();
  equal(titles(rows), ["Lock screen", "Sleep", "Restart", "Power off", "Log out"]);
  rows.forEach((r) => equal([r.detail, r.kind, r.target.type], ["Session", "Command", "command"], r.title));
});

test("Restart, Power off e Log out são perigosos; Lock screen e Sleep rodam no primeiro Enter", () => {
  const danger = {};
  S.commandRows().forEach((r) => { danger[r.title] = r.danger; });
  equal(danger, { "Lock screen": false, "Sleep": false, "Restart": true, "Power off": true, "Log out": true });
});

test("os quatro primeiros usam o nome, o ícone e a ação da tela inicial dos Ajustes, e o Log out o log-out do Lucide", () => {
  const rows = S.commandRows();
  // conferido à mão em settings/Home.qml (linhas 50 a 57): lock/Lock screen/lock, suspend/Sleep/moon, reboot/Restart/rotate-ccw, shutdown/Power off/power
  equal(rows.slice(0, 4).map((r) => [r.target.action, r.title, r.icon]), [
    ["lock", "Lock screen", "lock"], ["suspend", "Sleep", "moon"], ["reboot", "Restart", "rotate-ccw"], ["shutdown", "Power off", "power"]
  ]);
  equal(rows[4].icon, "log-out");
  rows.forEach((r) => check(r.icon !== "" && r.target.action !== "", r.title));
  const actions = rows.map((r) => r.target.action);
  equal(actions.filter((a, i) => actions.indexOf(a) !== i), [], "ações repetidas");
});

test("a chave da confirmação identifica a linha do comando perigoso", () => {
  const rows = S.commandRows();
  equal(S.rowKey(rows[2]), "command:" + rows[2].target.action);
  check(S.rowKey(rows[2]) !== S.rowKey(rows[3]), "uma linha não confirma a outra");
  equal(S.rowKey(row("Firefox")), "");
  equal(S.rowKey(null), "");
  equal(S.rowKey({ act: "clipboard-clear" }), "clipboard:clear", "o Clear history do histórico confirma igual");
});

// ---- sem resultado ----

test("a busca na web abre o Google com o texto codificado", () => {
  equal(S.webSearchUrl("xyzzy"), "https://www.google.com/search?q=xyzzy");
  equal(S.webSearchUrl("café & co"), "https://www.google.com/search?q=caf%C3%A9%20%26%20co");
  equal(S.webSearchUrl("a+b=c?d#e"), "https://www.google.com/search?q=a%2Bb%3Dc%3Fd%23e");
});

test("a busca na web não quebra com meio par de substituição", () => {
  equal(S.webSearchUrl("a\ud800b"), "https://www.google.com/search?q=ab");
  equal(S.webSearchUrl("a😀b"), "https://www.google.com/search?q=a%F0%9F%98%80b", "o par inteiro vale");
});

test("as duas linhas do sem resultado, com a busca entre aspas curvas no detalhe e tipo Action", () => {
  equal(S.fallbackRows("xyzzy", true), [
    { title: "Search the web", detail: "“xyzzy”", kind: "Action", icon: "globe", target: { type: "web-search", text: "xyzzy" } },
    { title: "Search files", detail: "“xyzzy”", kind: "Action", icon: "folder", target: { type: "file-search", text: "xyzzy" } }
  ]);
});

test("sem o fd, só a busca na web", () => {
  equal(titles(S.fallbackRows("xyzzy", false)), ["Search the web"]);
});

// ---- arquivos ----

test("o caminho local de uma URL file://", () => {
  equal(S.localPath("file:///home/u/Documents"), "/home/u/Documents");
  equal(S.localPath("file:///home/u/My%20Docs"), "/home/u/My Docs");
  equal(S.localPath("/home/u/Documents"), "/home/u/Documents", "o que já é caminho passa como está");
  equal(S.localPath(undefined), "");
  equal(S.localPath(null), "");
});

test("a linha de comando do fd: trecho fixo depois de --, com as pastas no fim", () => {
  equal(S.fdCommand("fd", "caf", ["/a", "/b"]), [
    "fd", "--fixed-strings", "--ignore-case", "--type", "file", "--type", "directory", "--type", "symlink",
    "--max-results", "50", "--absolute-path", "--print0", "--", "caf", "/a", "/b"
  ]);
  equal(S.fdCommand(undefined, "x", []).slice(0, 1), ["fd"], "sem binário, fd");
});

test("o texto que começa com - não vira opção do fd", () => {
  const command = S.fdCommand("fd", "--hidden", ["/a"]);
  const dashes = command.indexOf("--");
  equal(command.slice(dashes), ["--", "--hidden", "/a"]);
  check(command.slice(0, dashes).indexOf("--hidden") < 0, "o texto não pode estar entre as opções");
});

test("a busca profunda pede 200, com --hidden e sem o .git, antes do --", () => {
  equal(S.DEEP_FILES_MAX_RESULTS, 200);
  const command = S.fdCommand("fd", "caf", ["/home/u"], S.DEEP_FILES_MAX_RESULTS, S.DEEP_FILES_OPTIONS);
  equal(command.slice(command.indexOf("--max-results"), command.indexOf("--max-results") + 2), ["--max-results", "200"]);
  const dashes = command.indexOf("--");
  const options = command.slice(0, dashes);
  check(options.indexOf("--hidden") >= 0, "--hidden");
  equal(options.slice(options.indexOf("--exclude"), options.indexOf("--exclude") + 2), ["--exclude", ".git"]);
  equal(command.slice(dashes), ["--", "caf", "/home/u"]);
});

test("os limites da busca de arquivos: 2 caracteres, 50 do fd; na profunda, 1 caractere e 20 linhas", () => {
  equal([S.FILES_MIN_CHARS, S.FILES_MAX_RESULTS], [2, 50]);
  equal([S.DEEP_FILES_MIN_CHARS, S.DEEP_FILES_MAX_RESULTS, S.DEEP_FILES_SHOWN], [1, 200, 20]);
});

test("as linhas de arquivo saem da saída do fd, com a pasta pessoal escrita ~", () => {
  const output = "/home/u/Documents/Café.txt\0/home/u/Pictures/foto.PNG\0/home/u/Projects/\0/etc/hosts\0";
  const rows = S.fileRows(output, "/home/u");
  equal(rows.length, 4);
  equal(rows[0], { title: "Café.txt", detail: "~/Documents", kind: "File", icon: "file-text", secondary: [], target: { type: "file", path: "/home/u/Documents/Café.txt", directory: false } });
  equal([rows[1].title, rows[1].detail, rows[1].icon], ["foto.PNG", "~/Pictures", "image"], "a extensão vale em qualquer caixa");
  equal([rows[2].title, rows[2].detail, rows[2].icon], ["Projects", "~", "folder"]);
  equal(rows[2].target, { type: "file", path: "/home/u/Projects", directory: true }, "o / do fim sai do caminho");
  equal([rows[3].title, rows[3].detail], ["hosts", "/etc"], "fora da pasta pessoal fica inteiro");
});

test("o ~ só vale para a pasta pessoal inteira, e não para outra que começa igual", () => {
  const rows = S.fileRows("/home/u2/a.txt\0/home/u/a.txt\0", "/home/u");
  equal(rows.map((r) => r.detail), ["/home/u2", "~"]);
  equal(S.fileRows("/home/u/a.txt\0", "")[0].detail, "/home/u", "sem pasta pessoal conhecida");
  equal(S.fileRows("/home/u/a.txt\0", "/")[0].detail, "/home/u");
});

test("arquivo direto na raiz tem a pasta /", () => {
  equal(S.fileRows("/swapfile\0", "/home/u")[0].detail, "/");
});

test("os ícones: pasta, imagem pela extensão e o resto como arquivo de texto", () => {
  const icon = (path) => S.fileRows(path + "\0", "/home/u")[0].icon;
  equal(icon("/home/u/a.png"), "image");
  equal(icon("/home/u/a.JPG"), "image");
  equal(icon("/home/u/a.webp"), "image");
  equal(icon("/home/u/a.svg"), "image");
  equal(icon("/home/u/a.txt"), "file-text");
  equal(icon("/home/u/a"), "file-text", "sem extensão");
  equal(icon("/home/u/.bashrc"), "file-text", "o ponto do começo não é extensão");
  equal(icon("/home/u/pasta.png/"), "folder", "pasta vence a extensão");
});

test("a saída do fd vazia, ou com separadores sobrando, não gera linha", () => {
  equal(S.fileRows("", "/home/u"), []);
  equal(S.fileRows(undefined, "/home/u"), []);
  equal(S.fileRows("\0\0/a/b.txt\0\0", "/home/u").length, 1);
});

test("a busca profunda mostra uma seção só, 'Files', mesmo com poucos resultados", () => {
  const files = [row("notes.txt", { kind: "File" }), row("a notes.md", { kind: "File" })];
  const sections = S.deepSections("notes", files);
  equal(sections.length, 1);
  equal(sections[0].label, "Files");
  equal(titles(sections[0].rows), ["notes.txt", "a notes.md"], "a ordem de sempre: começo do nome antes do começo de palavra");
});

test("a busca profunda mostra até 20 linhas, e sem resultado não há seção", () => {
  const files = [];
  for (let i = 10; i < 40; ++i)
    files.push(row("f" + i + ".txt", { kind: "File" }));
  const sections = S.deepSections("f", files);
  equal(sections[0].rows.length, 20);
  equal(sections[0].rows[0].title, "f10.txt", "no empate, pelo nome");
  equal(S.deepSections("zzz", files), []);
});
