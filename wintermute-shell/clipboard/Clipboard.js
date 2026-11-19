.pragma library

// A conta do histórico da área de transferência (ficha 18), sem QML: filtrar, separar em seções, o tempo relativo, o texto de
// tamanho, o nome do servidor de uma URL e a posição de cada rótulo e de cada linha. Fica aqui para eu poder testar sem abrir a shell.
//
// Um item do histórico é { id, kind, title, text, source, time, pinned, pinnedTime, image: { url, width, height, format, bytes },
// color, linkTitle }. `kind` é "command", "image", "link", "text", "email" ou "color". `time` e `pinnedTime` são em milissegundos
// desde a época, e o relógio (`now`) vem do serviço, para o espécime poder fixá-lo.

var MINUTE = 60 * 1000;
var HOUR = 60 * MINUTE;
var DAY = 24 * HOUR;

// O ícone da linha por tipo (os arquivos de icons/). A cor não tem ícone: no lugar do bloco vai a amostra.
var ICONS = {
  command: "terminal",
  image: "image",
  link: "link",
  text: "file-text",
  email: "mail"
};

function iconFor(kind) {
  return ICONS[kind] || ICONS.text;
}

// Quanto faz que o item entrou: "now" (menos de um minuto), "2 min", "1 h" (menos de 24 horas), "yesterday" (de 24 a 48 horas) e "3 days".
// Conto pelo tempo corrido, e não pela virada do dia, para a conta não depender do fuso. Com `withAgo` a forma é a dos metadados:
// "just now", "2 min ago", "1 h ago", "yesterday" e "3 days ago".
function relativeTime(now, time, withAgo) {
  var elapsed = Math.max(0, Number(now) - Number(time));
  if (elapsed < MINUTE)
    return withAgo ? "just now" : "now";
  var text;
  if (elapsed < HOUR)
    text = Math.floor(elapsed / MINUTE) + " min";
  else if (elapsed < DAY)
    text = Math.floor(elapsed / HOUR) + " h";
  else if (elapsed < 2 * DAY)
    return "yesterday";
  else
    text = Math.floor(elapsed / DAY) + " days";
  return withAgo ? text + " ago" : text;
}

// "412 KB", "1.3 MB" ou "900 B". Base 1024; só o MB leva casa decimal, e o ".0" cai ("2 MB").
function byteText(bytes) {
  var n = Math.max(0, Number(bytes) || 0);
  if (n < 1024)
    return n + " B";
  if (n < 1024 * 1024)
    return Math.round(n / 1024) + " KB";
  var mb = Math.round(n / (1024 * 1024) * 10) / 10;
  return (mb === Math.floor(mb) ? String(mb) : mb.toFixed(1)) + " MB";
}

// O número de linhas do texto: uma quebra no fim não abre linha nova.
function lineCount(text) {
  var value = String(text || "").replace(/\r\n/g, "\n").replace(/\n$/, "");
  return value === "" ? 0 : value.split("\n").length;
}

function plural(count, one, many) {
  return count + " " + (count === 1 ? one : many);
}

// O texto de tamanho dos metadados. Imagem: "1920 × 1080 · PNG · 412 KB". Texto: "3 lines · 84 characters", e com uma linha só,
// "15 characters" (não digo "1 line"). Link não tem tamanho, e quem chama não pede.
function sizeText(item) {
  if (!item)
    return "";
  if (item.kind === "image") {
    var image = item.image || {};
    return image.width + " × " + image.height + " · " + image.format + " · " + byteText(image.bytes);
  }
  var text = String(item.text || "");
  var characters = plural(text.length, "character", "characters");
  var lines = lineCount(text);
  return lines > 1 ? lines + " lines · " + characters : characters;
}

// O nome do servidor de uma URL ("https://www.example.org/a?b" vira "www.example.org"): sem esquema, sem usuário, sem porta e
// sem caminho. Sem esquema reconhecível, o que vier antes da primeira barra. Texto que não é URL volta como está.
function hostOf(url) {
  var text = String(url || "").trim();
  if (text === "")
    return "";
  var match = /^[a-z][a-z0-9+.-]*:\/\/([^/?#]*)/i.exec(text);
  var authority = match ? match[1] : text.split(/[/?#]/)[0];
  authority = authority.replace(/^.*@/, "");
  authority = authority.replace(/:\d*$/, "");
  return authority;
}

// O título da linha: o que o serviço deu; sem ele, o título do link ou o servidor dele, ou a primeira linha do texto.
function titleOf(item) {
  if (!item)
    return "";
  if (item.title)
    return String(item.title);
  if (item.kind === "link")
    return linkTitleOf(item);
  var text = String(item.text || "");
  return text.split(/\r?\n/)[0];
}

// O título do link na prévia: `linkTitle` do item; sem ele, o nome do servidor da URL.
function linkTitleOf(item) {
  if (!item)
    return "";
  return item.linkTitle ? String(item.linkTitle) : hostOf(item.text);
}

// O texto que a prévia mostra: o `color` do item de cor (o hex), senão o texto.
function previewText(item) {
  if (!item)
    return "";
  return String(item.text !== undefined && item.text !== "" ? item.text : (item.color || ""));
}

// A meta da linha: "Ghostty · 2 min", "PNG · 1920 × 1080" para a imagem e "Pinned" para o item fixado.
function metaOf(item, now) {
  if (item.pinned)
    return "Pinned";
  if (item.kind === "image") {
    var image = item.image || {};
    return image.format + " · " + image.width + " × " + image.height;
  }
  return (item.source || "Unknown") + " · " + relativeTime(now, item.time, false);
}

// Os metadados abaixo da prévia: { label, value }. Texto e imagem: Source, Copied e Size; fixado, "Pinned" no lugar de "Copied"
// (quanto faz que fixei); link: só Source e Copied.
function metadata(item, now) {
  if (!item)
    return [];
  var rows = [{ label: "Source", value: item.source || "Unknown" }];
  if (item.pinned)
    rows.push({ label: "Pinned", value: relativeTime(now, item.pinnedTime !== undefined ? item.pinnedTime : item.time, true) });
  else
    rows.push({ label: "Copied", value: relativeTime(now, item.time, true) });
  if (item.kind !== "link")
    rows.push({ label: "Size", value: sizeText(item) });
  return rows;
}

// O que a busca olha: o título, o texto (a URL, no link), o título do link, a cor e o nome do aplicativo de origem.
function haystack(item) {
  return [titleOf(item), item.text, item.linkTitle, item.color, item.source].filter(function (part) {
    return part !== undefined && part !== null && String(part) !== "";
  }).join("\n").toLowerCase();
}

// Filtra pelo texto digitado, sem diferenciar maiúsculas. Busca vazia (ou só espaço) devolve a lista como veio.
function filter(items, query) {
  var needle = String(query || "").trim().toLowerCase();
  var list = items || [];
  if (needle === "")
    return list.slice();
  return list.filter(function (item) {
    return haystack(item).indexOf(needle) >= 0;
  });
}

// As seções: sem busca, "Pinned" (o fixado mais recente primeiro) e "Today" (o resto, na ordem do serviço, do mais novo para o
// mais antigo); com busca, uma seção só, "N results" ("1 result"), sem a divisão. Seção sem item não existe, e sem nada o resultado é [].
function sections(items, query) {
  var list = items || [];
  if (String(query || "").trim() !== "") {
    var found = filter(list, query);
    return found.length === 0 ? [] : [{ label: plural(found.length, "result", "results"), items: found }];
  }
  var pinned = list.filter(function (item) { return item.pinned; }).map(function (item, order) {
    return { item: item, order: order };
  });
  pinned.sort(function (a, b) {
    var diff = Number(b.item.pinnedTime || 0) - Number(a.item.pinnedTime || 0);
    return diff !== 0 ? diff : a.order - b.order;
  });
  var rest = list.filter(function (item) { return !item.pinned; });
  var result = [];
  if (pinned.length > 0)
    result.push({ label: "Pinned", items: pinned.map(function (entry) { return entry.item; }) });
  if (rest.length > 0)
    result.push({ label: "Today", items: rest });
  return result;
}

// A posição de cada rótulo e de cada linha no quadro da página (y), e a altura do conteúdo. `m` traz { firstLabelY, labelHeight,
// rowHeight, labelGap, endGap }: o primeiro rótulo em `firstLabelY`, as linhas logo abaixo dele sem folga, o rótulo seguinte
// `labelGap` abaixo da última linha da seção anterior. Cada linha leva o `labelY` da própria seção, para a rolagem mostrar o rótulo
// junto quando a linha é a primeira dela.
function layout(sectionList, m) {
  var labels = [];
  var rows = [];
  var y = m.firstLabelY;
  var lastEnd = y;
  (sectionList || []).forEach(function (section) {
    var labelY = y;
    labels.push({ text: section.label, y: labelY });
    y += m.labelHeight;
    section.items.forEach(function (item, i) {
      rows.push({ item: item, y: y, first: i === 0, labelY: labelY });
      y += m.rowHeight;
    });
    lastEnd = y;
    y += m.labelGap;
  });
  return { labels: labels, rows: rows, height: lastEnd + m.endGap };
}

// Onde a linha selecionada fica depois de a lista mudar: a mesma pelo `id` (o item mudou de seção ao ser fixado), senão o vizinho
// (o índice de antes, que agora é a linha de baixo, ou a última se era a última), ou -1 sem linha nenhuma.
function reselect(rows, id, previousIndex) {
  if (!rows || rows.length === 0)
    return -1;
  for (var i = 0; i < rows.length; ++i) {
    if (id !== undefined && id !== null && rows[i].item.id === id)
      return i;
  }
  return Math.max(0, Math.min(rows.length - 1, previousIndex));
}
