.pragma library

// Busca do launcher (ficha 14; pendência P-78). Biblioteca pura: recebe listas simples e devolve listas simples,
// sem tocar em Quickshell nem em arquivo. O serviço de verdade (State.qml) entrega as fontes (apps, arquivos, ajustes
// e comandos) e esta biblioteca casa, ordena, decide entre "Best match" e os grupos, calcula a sugestão fantasma e
// monta as linhas de arquivo a partir da saída do `fd`. Os testes exercitam estas funções com listas fictícias.
//
// Uma linha tem o formato que o Panel.qml lê ({ title, detail, kind, icon, iconSource, danger }) e mais dois
// campos que só esta biblioteca e o State usam:
//   secondary  textos de segunda importância em que a busca também casa (app: genericName e keywords; ajuste: o
//              nome da página mãe). Casar só ali vale a nota mais baixa.
//   target     o alvo da linha: { type: "app", id, entry } | { type: "file", path, directory } |
//              { type: "setting", page } | { type: "command", action } e, nas linhas de ação do "sem resultado",
//              { type: "web-search", text } | { type: "file-search", text }. É o que `activate` despacha e o que o
//              menu de ações lê.

// ---- Limites (a minha proposta da P-78: o board não decide estas regras) ----
// Até este total de resultados, uma seção só, "Best match"; com mais, os grupos.
var BEST_MATCH_MAX = 3;
// Linhas por grupo.
var GROUP_MAX = 5;
// Quantos ids de app o arquivo de recentes guarda, e quantos o estado vazio mostra.
var RECENTS_KEPT = 10;
var RECENTS_SHOWN = 3;
// A busca de arquivos só roda com este mínimo de caracteres, e o `fd` para neste número de resultados.
var FILES_MIN_CHARS = 2;
var FILES_MAX_RESULTS = 50;
// A busca profunda ("Search files" do estado sem resultado, F5-T11) vale com 1 caractere, pede até 200 candidatos ao `fd`
// e mostra 20 linhas. Os três números são a proposta da P-78: a P-73 só diz que a busca é "mais funda" que a normal.
var DEEP_FILES_MIN_CHARS = 1;
var DEEP_FILES_MAX_RESULTS = 200;
var DEEP_FILES_SHOWN = 20;
// O que o `fd` ganha a mais na busca profunda: as ocultas entram, e o conteúdo dos repositórios (`.git`) fica de fora,
// senão ele afoga o resto. O `.gitignore` continua valendo, que é o padrão do `fd`.
var DEEP_FILES_OPTIONS = ["--hidden", "--exclude", ".git"];
// O buscador de "Search the web" é o Google (P-73, 2026-11-18: "acho que seria melhor"). O texto, codificado, entra no fim.
var WEB_SEARCH_URL = "https://www.google.com/search?q=";

// Os grupos, na ordem fixa do board. `key` é a chave da fonte em `sources`.
var GROUPS = [
  { key: "apps", label: "Apps" },
  { key: "files", label: "Files" },
  { key: "settings", label: "Settings" },
  { key: "commands", label: "Commands" }
];

// Notas do casamento, da maior para a menor.
var SCORE_PREFIX = 4;       // o texto é prefixo do título
var SCORE_WORD_PREFIX = 3;  // o texto é prefixo de uma palavra do título
var SCORE_SUBSTRING = 2;    // o texto é um trecho do título
var SCORE_SECONDARY = 1;    // o texto só aparece num campo secundário

// ---- Casar e ordenar ----

// Minúsculas e sem acento: "Café" e "cafe" ficam iguais. U+0300 a U+036F é a faixa dos acentos soltos que o NFD separa.
function normalize(text) {
  return String(text === undefined || text === null ? "" : text)
      .normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}

// Início de palavra: o começo do texto ou o que vem depois de um separador.
var SEPARATORS = " \t-_.,:;()[]{}/\\|&+@#'\"`›·";

function isWordStart(text, index) {
  return index === 0 || SEPARATORS.indexOf(text.charAt(index - 1)) >= 0;
}

// Nota de um título para o texto buscado, os dois já normalizados. 0 não casa.
function titleScore(needle, title) {
  const first = title.indexOf(needle);
  if (first < 0)
    return 0;
  if (first === 0)
    return SCORE_PREFIX;
  for (let at = first; at >= 0; at = title.indexOf(needle, at + 1)) {
    if (isWordStart(title, at))
      return SCORE_WORD_PREFIX;
  }
  return SCORE_SUBSTRING;
}

// Nota de uma linha: a do título e, se o título não casa, o piso dos campos secundários. `needle` normalizado.
function rowScore(needle, row) {
  if (needle === "")
    return 0;
  const byTitle = titleScore(needle, normalize(row.title));
  if (byTitle > 0)
    return byTitle;
  const secondary = row.secondary || [];
  for (let i = 0; i < secondary.length; ++i) {
    if (normalize(secondary[i]).indexOf(needle) >= 0)
      return SCORE_SECONDARY;
  }
  return 0;
}

// Posição do app nos recentes (0 é o mais novo), ou -1 se a linha não é um app recente.
function recentRank(row, recentIds) {
  const target = row.target;
  return target && target.type === "app" ? (recentIds || []).indexOf(target.id) : -1;
}

// Ordem das entradas { row, score, rank, group, index }: nota maior primeiro; no empate, app recente na frente
// (o mais novo primeiro); depois ordem alfabética do título; e, se ainda empatar, a ordem em que vieram.
function compareEntries(a, b) {
  if (a.score !== b.score)
    return b.score - a.score;
  const aRecent = a.rank >= 0;
  const bRecent = b.rank >= 0;
  if (aRecent !== bRecent)
    return aRecent ? -1 : 1;
  if (aRecent && a.rank !== b.rank)
    return a.rank - b.rank;
  const aTitle = normalize(a.row.title);
  const bTitle = normalize(b.row.title);
  if (aTitle !== bTitle)
    return aTitle < bTitle ? -1 : 1;
  if (a.group !== b.group)
    return a.group - b.group;
  return a.index - b.index;
}

// As linhas que casam com o texto, ordenadas. Devolve entradas { row, score, rank, group, index }.
function rank(query, rows, recentIds, group) {
  const needle = normalize(String(query).trim());
  const found = [];
  (rows || []).forEach((row, index) => {
    const score = rowScore(needle, row);
    if (score > 0)
      found.push({ row: row, score: score, rank: recentRank(row, recentIds), group: group || 0, index: index });
  });
  found.sort(compareEntries);
  return found;
}

// As seções para um texto. `sources` tem as listas de linhas por chave (`apps`, `files`, `settings`, `commands`);
// chave ausente vale lista vazia. Com até BEST_MATCH_MAX resultados no total, uma seção "Best match" com os tipos
// misturados; com mais, os grupos nesta ordem, cada um com até GROUP_MAX linhas e sem grupo vazio.
function buildSections(query, sources, recentIds) {
  const perGroup = GROUPS.map((group, i) => rank(query, (sources || {})[group.key], recentIds, i));
  const total = perGroup.reduce((sum, list) => sum + list.length, 0);
  if (total === 0)
    return [];
  if (total <= BEST_MATCH_MAX) {
    const all = [].concat.apply([], perGroup);
    all.sort(compareEntries);
    return [{ label: "Best match", rows: all.map(entry => entry.row) }];
  }
  const sections = [];
  GROUPS.forEach((group, i) => {
    if (perGroup[i].length > 0)
      sections.push({ label: group.label, rows: perGroup[i].slice(0, GROUP_MAX).map(entry => entry.row) });
  });
  return sections;
}

function countRows(sections) {
  return (sections || []).reduce((sum, section) => sum + (section.rows || []).length, 0);
}

// ---- Sugestão fantasma ----

// O resto do título da primeira linha, quando o texto (sem espaço no fim, com pelo menos 1 caractere) é prefixo
// dele, sem diferença de maiúsculas nem de acentos. Senão, vazio.
function ghost(query, sections) {
  const text = String(query);
  const first = (sections && sections.length > 0 && sections[0].rows && sections[0].rows.length > 0)
      ? sections[0].rows[0] : null;
  if (!first || text.length < 1 || /\s$/.test(text))
    return "";
  // NFC para que o corte por posição caia num caractere inteiro mesmo se o título vier com acento solto.
  const title = String(first.title).normalize("NFC");
  if (title.length <= text.length)
    return "";
  if (normalize(title.substring(0, text.length)) !== normalize(text))
    return "";
  return title.substring(text.length);
}

// ---- Recentes ----

// Lê o arquivo de recentes: uma lista JSON de ids. Ausente, estragado ou fora do formato vale como lista vazia.
function parseRecents(text, max) {
  let data = null;
  try {
    data = JSON.parse(String(text || ""));
  } catch (error) {
    return [];
  }
  if (!Array.isArray(data))
    return [];
  const ids = [];
  data.forEach(id => {
    if (typeof id === "string" && id !== "" && ids.indexOf(id) < 0)
      ids.push(id);
  });
  return ids.slice(0, max || RECENTS_KEPT);
}

function serializeRecents(ids) {
  return JSON.stringify(ids, null, 2) + "\n";
}

// O id vai para a frente, sem repetir, e a lista é cortada em `max`.
function pushRecent(ids, id, max) {
  return [id].concat((ids || []).filter(other => other !== id)).slice(0, max || RECENTS_KEPT);
}

// O id sai da lista ("Remove from recent"); os outros ficam na mesma ordem.
function dropRecent(ids, id) {
  return (ids || []).filter(other => other !== id);
}

// Os apps do estado vazio: os `shown` primeiros ids que ainda existem como app instalado. `appsById` mapeia id para linha.
function recentRows(ids, appsById, shown) {
  const rows = [];
  (ids || []).forEach(id => {
    if (rows.length < (shown || RECENTS_SHOWN) && appsById && appsById[id])
      rows.push(appsById[id]);
  });
  return rows;
}

// ---- Apps ----

// Linha de app a partir de uma entrada de .desktop (a do Quickshell, ou uma fictícia com os mesmos campos).
function appRow(entry) {
  const secondary = [];
  if (entry.genericName)
    secondary.push(entry.genericName);
  Array.from(entry.keywords || []).forEach(word => {
    if (word)
      secondary.push(word);
  });
  return {
    title: entry.name,
    detail: entry.genericName || "",
    kind: "App",
    iconSource: entry.icon || "",
    secondary: secondary,
    target: { type: "app", id: entry.id, entry: entry }
  };
}

// As linhas de todos os apps que aparecem em menu (sem `noDisplay`), e o mapa id → linha.
function appRows(entries) {
  const rows = [];
  const byId = {};
  Array.from(entries || []).forEach(entry => {
    if (!entry || entry.noDisplay || !entry.name)
      return;
    const row = appRow(entry);
    rows.push(row);
    byId[entry.id] = row;
  });
  return { rows: rows, byId: byId };
}

// ---- Ajustes ----

// As páginas dos Ajustes (Settings.State.pages), com o título que o painel usa, o ícone, e a página mãe de onde ela
// abre. O título é o `title:` do painel: wallpaper, customize, arrange e manual vêm de settings/appearance/
// WallpaperPicker.qml e WallpaperCustomize.qml, display/Arrange.qml e da legenda "Manual" do botão da informação
// (o painel do Manual não tem título). Abrir é Settings.State.open(monitor, página).
var SETTING_PAGES = {
  appearance: { title: "Appearance", icon: "palette", parent: "" },
  wallpaper: { title: "Wallpaper", icon: "image", parent: "appearance" },
  customize: { title: "Customize", icon: "image", parent: "wallpaper" },
  display: { title: "Display", icon: "monitor", parent: "appearance" },
  arrange: { title: "Arrange displays", icon: "monitor", parent: "display" },
  system: { title: "System", icon: "settings", parent: "" },
  mouse: { title: "Mouse & touchpad", icon: "mouse", parent: "system" },
  lock: { title: "Lock & sleep", icon: "lock", parent: "system" },
  keyboard: { title: "Keyboard language", icon: "keyboard", parent: "system" },
  information: { title: "Information", icon: "info", parent: "" },
  manual: { title: "Manual", icon: "book-open", parent: "information" }
};

// Uma linha por página de `pages`; página que não está na tabela fica de fora.
function settingRows(pages) {
  const rows = [];
  Array.from(pages || []).forEach(page => {
    const info = SETTING_PAGES[page];
    if (!info)
      return;
    const parent = info.parent !== "" ? SETTING_PAGES[info.parent].title : "";
    rows.push({
      title: info.title,
      detail: parent !== "" ? "Settings › " + parent : "Settings",
      kind: "Setting",
      icon: info.icon,
      secondary: parent !== "" ? [parent] : [],
      target: { type: "setting", page: page }
    });
  });
  return rows;
}

// ---- Comandos de sessão ----

// Os nomes e os ícones dos quatro primeiros são os da tela inicial dos Ajustes (settings/Home.qml). O "Log out" usa
// o `arrow-up-right`, porque o conjunto de ícones não tem o `log-out`. `danger` pede a confirmação antes de rodar.
var COMMANDS = [
  { action: "lock", title: "Lock screen", icon: "lock", danger: false },
  { action: "suspend", title: "Sleep", icon: "moon", danger: false },
  { action: "reboot", title: "Restart", icon: "rotate-ccw", danger: true },
  { action: "shutdown", title: "Power off", icon: "power", danger: true },
  { action: "logout", title: "Log out", icon: "arrow-up-right", danger: true }
];

function commandRows() {
  return COMMANDS.map(command => ({
    title: command.title,
    detail: "Session",
    kind: "Command",
    icon: command.icon,
    danger: command.danger,
    secondary: [],
    target: { type: "command", action: command.action }
  }));
}

// Identifica a linha para a confirmação do comando perigoso: o primeiro Enter arma, o segundo, na mesma linha, roda.
function rowKey(row) {
  const target = row ? row.target : null;
  return target && target.type === "command" ? "command:" + target.action : "";
}

// ---- Linhas de ação do "sem resultado" ----

// O endereço da busca na web para um texto. O `encodeURIComponent` falha com uma ponta solta de UTF-16 (meio par de
// substituição); se o texto trouxer uma, tiro esses caracteres e codifico o resto.
function webSearchUrl(text) {
  let encoded = "";
  try {
    encoded = encodeURIComponent(String(text));
  } catch (error) {
    encoded = encodeURIComponent(String(text).replace(/[\ud800-\udfff]/g, ""));
  }
  return WEB_SEARCH_URL + encoded;
}

// As linhas de ação do "Nothing found" (P-73): "Search the web" e, se `offerFiles`, "Search files", com o texto entre aspas
// curvas no detalhe. `text` já vem sem espaços nas pontas. Cada linha carrega o alvo para o `activate` despachar.
function fallbackRows(text, offerFiles) {
  const detail = "“" + text + "”";
  const rows = [{ title: "Search the web", detail: detail, kind: "Action", icon: "globe",
      target: { type: "web-search", text: text } }];
  if (offerFiles) {
    rows.push({ title: "Search files", detail: detail, kind: "Action", icon: "folder",
        target: { type: "file-search", text: text } });
  }
  return rows;
}

// ---- Arquivos ----

// O caminho local de uma URL "file://" (o que o StandardPaths devolve); o que já é caminho passa como está.
function localPath(url) {
  const text = String(url === undefined || url === null ? "" : url);
  if (text.indexOf("file://") !== 0)
    return text;
  try {
    return decodeURIComponent(text.substring("file://".length));
  } catch (error) {
    return text.substring("file://".length);
  }
}

// A linha de comando do `fd`: o texto como trecho fixo, sem maiúsculas, arquivos, pastas e links, sem as ocultas
// (o padrão do `fd`), com caminhos absolutos separados por NUL. O texto vai depois de `--`, como argumento, nunca por
// shell; as pastas vêm depois dele. `options` são as opções a mais (a busca profunda passa DEEP_FILES_OPTIONS); sem
// elas o comando é o da busca normal.
function fdCommand(binary, text, directories, maxResults, options) {
  return [binary || "fd", "--fixed-strings", "--ignore-case", "--type", "file", "--type", "directory",
      "--type", "symlink", "--max-results", String(maxResults || FILES_MAX_RESULTS), "--absolute-path", "--print0"]
      .concat(options || [], ["--", String(text)], directories || []);
}

// A busca profunda mostra uma seção só, "Files", com os arquivos que casam ordenados pela nota de sempre, até
// DEEP_FILES_SHOWN. Mesmo com poucos resultados não vira "Best match", e as outras fontes não entram.
function deepSections(query, fileRows) {
  const found = rank(query, fileRows, [], 0).slice(0, DEEP_FILES_SHOWN);
  return found.length === 0 ? [] : [{ label: "Files", rows: found.map(entry => entry.row) }];
}

var IMAGE_EXTENSIONS = ["png", "jpg", "jpeg", "gif", "webp", "bmp", "svg", "avif", "tif", "tiff", "heic", "ico"];

function fileIcon(name, directory) {
  if (directory)
    return "folder";
  const dot = name.lastIndexOf(".");
  const extension = dot > 0 ? name.substring(dot + 1).toLowerCase() : "";
  return IMAGE_EXTENSIONS.indexOf(extension) >= 0 ? "image" : "file-text";
}

// A pasta com a pasta pessoal escrita como "~".
function tildePath(directory, home) {
  if (!home || home === "/")
    return directory;
  if (directory === home)
    return "~";
  return directory.indexOf(home + "/") === 0 ? "~" + directory.substring(home.length) : directory;
}

// As linhas de arquivo a partir da saída do `fd` (caminhos absolutos separados por NUL; a pasta termina em "/").
function fileRows(output, home) {
  const rows = [];
  String(output || "").split("\0").forEach(raw => {
    if (raw === "")
      return;
    const directory = raw.length > 1 && raw.charAt(raw.length - 1) === "/";
    const path = directory ? raw.substring(0, raw.length - 1) : raw;
    const slash = path.lastIndexOf("/");
    const name = path.substring(slash + 1);
    if (name === "")
      return;
    rows.push({
      title: name,
      detail: tildePath(slash <= 0 ? "/" : path.substring(0, slash), home),
      kind: "File",
      icon: fileIcon(name, directory),
      secondary: [],
      target: { type: "file", path: path, directory: directory }
    });
  });
  return rows;
}
