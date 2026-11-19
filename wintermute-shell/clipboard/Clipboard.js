.pragma library
.import "../launcher/Colors.js" as Colors

// A conta do histórico da área de transferência (ficha 18), sem QML: filtrar, separar em seções, o tempo relativo, o texto de
// tamanho, o nome do servidor de uma URL e a posição de cada rótulo e de cada linha (F6-T05); e, da F6-T16, classificar o que foi
// copiado, guardar, fixar, apagar e cortar a lista nos tetos. Fica aqui para eu poder testar sem abrir a shell.
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

// O texto que a prévia mostra: o `color` do item de cor (o hex), senão o texto. Com o serviço de verdade o texto pode ter 1 MB, e a caixa
// da prévia mostra umas poucas linhas; corto em `PREVIEW_MAX` caracteres para o Text não ter de medir o resto (não aparece nada a menos).
function previewText(item) {
  if (!item)
    return "";
  return cut(String(item.text !== undefined && item.text !== "" ? item.text : (item.color || "")), PREVIEW_MAX);
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

// ---- O serviço (F6-T16) ----
// As funções abaixo não mexem em nada que receberam: devolvem listas e itens novos, para o `items` do serviço ser sempre uma lista
// nova e a página reagir.

// Limites de robustez, não de desenho: o título que o serviço dá a um item (a linha corta com reticências bem antes) e o texto que a
// prévia mede. Um texto de 1 MB numa linha só travaria o Text da linha e o da prévia.
var TITLE_MAX = 256;
var PREVIEW_MAX = 2000;

// Os primeiros `max` caracteres, sem deixar meio par de substituição na ponta.
function cut(text, max) {
  var value = String(text);
  if (value.length <= max)
    return value;
  var end = max;
  var last = value.charCodeAt(end - 1);
  if (last >= 0xD800 && last <= 0xDBFF)
    end -= 1;
  return value.substring(0, end);
}

// Quantos bytes o texto tem em UTF-8 (o teto de texto é em bytes, como o `watch.py` confere).
function utf8Length(text) {
  var value = String(text === undefined || text === null ? "" : text);
  var bytes = 0;
  for (var i = 0; i < value.length; ++i) {
    var code = value.charCodeAt(i);
    if (code < 0x80) {
      bytes += 1;
    } else if (code < 0x800) {
      bytes += 2;
    } else if (code >= 0xD800 && code <= 0xDBFF && i + 1 < value.length
        && value.charCodeAt(i + 1) >= 0xDC00 && value.charCodeAt(i + 1) <= 0xDFFF) {
      bytes += 4;
      ++i;
    } else {
      bytes += 3;
    }
  }
  return bytes;
}

// A primeira linha não vazia do texto, sem espaços nas pontas. Texto sem linha nenhuma volta "".
function firstLine(text) {
  var lines = String(text || "").split(/\r\n|\r|\n/);
  for (var i = 0; i < lines.length; ++i) {
    var line = lines[i].trim();
    if (line !== "")
      return line;
  }
  return "";
}

// Hue em graus (0 a 360), saturação e luminosidade em porcentagem, para [r, g, b] de 0 a 255, arredondado.
function hslToRgb(h, s, l) {
  var sat = s / 100;
  var light = l / 100;
  var hue = (((h % 360) + 360) % 360) / 60;
  var chroma = (1 - Math.abs(2 * light - 1)) * sat;
  var x = chroma * (1 - Math.abs(hue % 2 - 1));
  var rgb = hue < 1 ? [chroma, x, 0] : hue < 2 ? [x, chroma, 0] : hue < 3 ? [0, chroma, x]
      : hue < 4 ? [0, x, chroma] : hue < 5 ? [x, 0, chroma] : [chroma, 0, x];
  var m = light - chroma / 2;
  return rgb.map(function (channel) { return Math.round((channel + m) * 255); });
}

function hexOf(rgb) {
  return "#" + rgb.map(function (channel) {
    var part = channel.toString(16).toUpperCase();
    return part.length < 2 ? "0" + part : part;
  }).join("");
}

// A cor que o texto inteiro é, em "#RRGGBB" maiúsculo, ou "". Os formatos são os que o seletor de cor copia (launcher/Colors.js):
// "#3FA9D9", "rgb(63, 169, 217)" e "hsl(198, 68%, 53%)". O HEX sem o "#" não conta: "facade" ou "decade" são palavras.
function parseColor(text) {
  var value = String(text || "").trim();
  if (value.charAt(0) === "#")
    return Colors.normalizeHex(value);
  var number = "(\\d{1,3}(?:\\.\\d+)?)";
  var rgb = new RegExp("^rgb\\(\\s*" + number + "\\s*,\\s*" + number + "\\s*,\\s*" + number + "\\s*\\)$", "i").exec(value);
  if (rgb) {
    var channels = [Number(rgb[1]), Number(rgb[2]), Number(rgb[3])];
    if (channels.some(function (channel) { return channel > 255; }))
      return "";
    return hexOf(channels.map(Math.round));
  }
  var hsl = new RegExp("^hsl\\(\\s*" + number + "\\s*,\\s*" + number + "%\\s*,\\s*" + number + "%\\s*\\)$", "i").exec(value);
  if (hsl) {
    var h = Number(hsl[1]);
    var s = Number(hsl[2]);
    var l = Number(hsl[3]);
    if (h > 360 || s > 100 || l > 100)
      return "";
    return hexOf(hslToRgb(h, s, l));
  }
  return "";
}

// Uma linha só com http://, https:// ou www. e mais alguma coisa, sem espaço no meio.
function isLink(text) {
  return /^(?:https?:\/\/|www\.)\S+$/i.test(String(text || "").trim());
}

// Uma linha só com um endereço de e-mail.
function isEmail(text) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(text || "").trim());
}

// O que o texto copiado é: { kind, title, color }. `fromTerminal` diz que o aplicativo de origem é um terminal (quem sabe é o
// serviço, pela entrada .desktop). A ordem é a da ficha: cor, link, e-mail, comando, texto. O título é a primeira linha não vazia;
// no link, a URL; na cor, o texto. `color` só existe no item de cor.
function classify(text, fromTerminal) {
  var trimmed = String(text || "").trim();
  var color = parseColor(trimmed);
  if (color !== "")
    return { kind: "color", title: trimmed, color: color };
  if (isLink(trimmed))
    return { kind: "link", title: cut(trimmed, TITLE_MAX), color: "" };
  if (isEmail(trimmed))
    return { kind: "email", title: cut(trimmed, TITLE_MAX), color: "" };
  return { kind: fromTerminal ? "command" : "text", title: cut(firstLine(text), TITLE_MAX), color: "" };
}

function twoDigits(n) {
  return (n < 10 ? "0" : "") + n;
}

// "Screenshot 14:32" para a imagem que veio da captura da shell, "Image 14:32" para as outras, na hora local em que ela chegou.
function imageTitle(fromScreenshot, time) {
  var when = new Date(Number(time));
  return (fromScreenshot ? "Screenshot " : "Image ") + twoDigits(when.getHours()) + ":" + twoDigits(when.getMinutes());
}

// O arquivo é um PNG que o `watch.py` gravou dentro de `dir` (`<hash>.png`, direto na pasta)? É a única coisa que o serviço apaga.
function isOwnFile(dir, path) {
  var base = String(dir || "");
  var file = String(path || "");
  if (base === "" || base.charAt(0) !== "/" || file.indexOf(base + "/") !== 0)
    return false;
  return /^[0-9a-f]{8,128}\.png$/.test(file.substring(base.length + 1));
}

// O mesmo conteúdo: texto igual, ou imagem com o mesmo hash.
function sameContent(a, b) {
  if (a.kind === "image" || b.kind === "image")
    return a.kind === b.kind && !!a.image && !!b.image && a.image.hash === b.image.hash;
  return a.text === b.text;
}

// O item novo entra no topo; se o conteúdo já estava, o que estava sobe com `time` novo e mantém o id, o fixado e a origem.
// Devolve { items, item, duplicate }.
function push(items, entry) {
  var list = items || [];
  for (var i = 0; i < list.length; ++i) {
    if (sameContent(list[i], entry)) {
      var risen = Object.assign({}, list[i], { time: entry.time });
      return { items: [risen].concat(list.slice(0, i), list.slice(i + 1)), item: risen, duplicate: true };
    }
  }
  return { items: [entry].concat(list), item: entry, duplicate: false };
}

// A soma dos bytes das imagens guardadas (as fixadas contam).
function imageBytes(items) {
  return (items || []).reduce(function (sum, item) {
    return sum + (item.kind === "image" && item.image ? Number(item.image.bytes) || 0 : 0);
  }, 0);
}

// Corta a lista nos tetos: no máximo `maxItems` itens não fixados (saem os mais antigos), e as imagens somando no máximo
// `maxImageBytes` (saem primeiro as imagens não fixadas mais antigas). Os fixados nunca saem. Devolve { items, dropped }, com
// `dropped` na ordem em que saíram.
function trim(items, maxItems, maxImageBytes) {
  var list = (items || []).slice();
  var dropped = [];
  function dropLast(predicate) {
    for (var i = list.length - 1; i >= 0; --i) {
      if (predicate(list[i])) {
        dropped.push(list[i]);
        list.splice(i, 1);
        return true;
      }
    }
    return false;
  }
  function unpinned(item) {
    return !item.pinned;
  }
  while (list.filter(unpinned).length > maxItems && dropLast(unpinned)) {
  }
  while (imageBytes(list) > maxImageBytes
      && dropLast(function (item) { return !item.pinned && item.kind === "image"; })) {
  }
  return { items: list, dropped: dropped };
}

// Fixa o item (`pinnedTime` = `time`), ou solta (`pinnedTime` 0). Id que não existe deixa a lista como está.
function togglePin(items, id, time) {
  return (items || []).map(function (item) {
    if (item.id !== id)
      return item;
    return Object.assign({}, item, { pinned: !item.pinned, pinnedTime: item.pinned ? 0 : time });
  });
}

// Tira o item da lista. Devolve { items, removed } (`removed` é null se o id não existia).
function remove(items, id) {
  var removed = null;
  var kept = (items || []).filter(function (item) {
    if (item.id === id) {
      removed = item;
      return false;
    }
    return true;
  });
  return { items: kept, removed: removed };
}

// "Clear history": tira todos os não fixados. Devolve { items, removed }.
function clearUnpinned(items) {
  var removed = [];
  var kept = (items || []).filter(function (item) {
    if (item.pinned)
      return true;
    removed.push(item);
    return false;
  });
  return { items: kept, removed: removed };
}
