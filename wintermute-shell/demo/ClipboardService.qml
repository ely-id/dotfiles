import QtQuick

// O serviço fictício do histórico da área de transferência para a vitrine e a bancada (decisão 0011): a mesma superfície de
// clipboard/State.qml (`items`, `now`, `copy`, `togglePin` e `remove`), sem escutar a área de transferência de verdade e sem guardar nada.
// Os dados são inventados: nenhum texto, endereço ou aplicativo veio da máquina, e a imagem é um desenho meu. O relógio (`now`) é fixo,
// para os "2 min" e o "yesterday" dos prints não mudarem com a hora em que o espécime abre.
// `scenario` escolhe os itens:
//   "text", "image", "search" e "no-results"  os cinco itens do board do texto (um comando, uma captura, um link, um e-mail e uma cor)
//   "pinned"                                  quatro itens, dois deles fixados (o comando e o e-mail)
//   "empty"                                   nenhum item
//   "many"                                    cinquenta itens (o teto da sessão), para a rolagem
// `togglePin` e `remove` mudam `items` de verdade, para a página reagir como reage ao serviço real; `copy` só conta. O teste de
// comportamento lê o que foi pedido em `lastCopied`, `lastPinned` e `lastRemoved`.
QtObject {
  id: root

  property string scenario: "text"

  readonly property real now: Date.UTC(2026, 10, 19, 14, 40, 0)
  readonly property real minute: 60 * 1000
  readonly property real hour: 60 * minute
  readonly property real day: 24 * hour

  // Um desenho inventado, no formato 16:9 da captura de 1920×1080: uma janela escura com um gráfico de barras e um disco.
  readonly property string drawing:
      "<svg xmlns='http://www.w3.org/2000/svg' width='640' height='360' viewBox='0 0 640 360'>"
      + "<defs><linearGradient id='g' x1='0' y1='0' x2='1' y2='1'>"
      + "<stop offset='0' stop-color='#1E2A4A'/><stop offset='1' stop-color='#4B3A6B'/></linearGradient></defs>"
      + "<rect width='640' height='360' fill='url(#g)'/>"
      + "<rect x='24' y='24' width='592' height='36' rx='8' fill='#0D0E11' fill-opacity='0.55'/>"
      + "<rect x='24' y='80' width='360' height='256' rx='12' fill='#0D0E11' fill-opacity='0.45'/>"
      + "<rect x='56' y='236' width='44' height='72' rx='4' fill='#7FD1E8'/>"
      + "<rect x='120' y='188' width='44' height='120' rx='4' fill='#E8A87C'/>"
      + "<rect x='184' y='212' width='44' height='96' rx='4' fill='#9BE0A8'/>"
      + "<rect x='248' y='148' width='44' height='160' rx='4' fill='#F2B8D0'/>"
      + "<rect x='312' y='116' width='44' height='192' rx='4' fill='#C7B6F2'/>"
      + "<circle cx='502' cy='168' r='82' fill='#0D0E11' fill-opacity='0.45'/>"
      + "<circle cx='502' cy='168' r='56' fill='none' stroke='#7FD1E8' stroke-width='18'/>"
      + "</svg>"
  readonly property string drawingUrl: "data:image/svg+xml;utf8," + encodeURIComponent(drawing)

  function make(id, kind, fields) {
    return Object.assign({
      id: id,
      kind: kind,
      title: "",
      text: "",
      source: "",
      time: now,
      pinned: false,
      pinnedTime: 0,
      image: null,
      color: "",
      linkTitle: ""
    }, fields);
  }

  readonly property var command: make("c1", "command", {
    title: "git clone https://example.org/case/sprawl-tools",
    text: "git clone https://example.org/case/sprawl-tools\ncd sprawl-tools\n./run.sh",
    source: "Ghostty",
    time: now - 2 * minute
  })
  readonly property var capture: make("c2", "image", {
    title: "Screenshot 14:32",
    source: "Screenshot",
    time: now - 12 * minute,
    image: { url: drawingUrl, width: 1920, height: 1080, format: "PNG", bytes: 412 * 1024 }
  })
  readonly property var link: make("c3", "link", {
    // Como no board: a linha mostra a URL, e a prévia mostra o título da página.
    title: "https://www.example.org/design/a1B2c3D4e5F6g7H8i9J0k1L2m3N4",
    linkTitle: "Sprawl design board",
    text: "https://www.example.org/design/a1B2c3D4e5F6g7H8i9J0k1L2m3N4",
    source: "Firefox",
    time: now - hour
  })
  readonly property var email: make("c4", "email", {
    title: "case@example.org",
    text: "case@example.org",
    source: "Firefox",
    time: now - 30 * hour
  })
  readonly property var swatch: make("c5", "color", {
    title: "#3FA9D9",
    text: "#3FA9D9",
    color: "#3FA9D9",
    source: "Color picker",
    time: now - 3 * day
  })

  // Cinquenta itens: uma mistura dos tipos, do mais novo para o mais antigo, com títulos que variam de tamanho.
  readonly property var many: {
    const kinds = ["command", "text", "link", "email", "color", "image"];
    const list = [];
    for (let i = 0; i < 50; ++i) {
      const kind = kinds[i % kinds.length];
      const n = i + 1;
      const time = now - (i + 1) * 7 * minute;
      if (kind === "command")
        list.push(make("m" + n, kind, { title: "make test-" + n, text: "make test-" + n + "\nmake install", source: "Ghostty", time: time }));
      else if (kind === "link")
        list.push(make("m" + n, kind, { title: "https://www.example.org/page/" + n, linkTitle: "Page " + n, text: "https://www.example.org/page/" + n, source: "Firefox", time: time }));
      else if (kind === "email")
        list.push(make("m" + n, kind, { title: "user" + n + "@example.org", text: "user" + n + "@example.org", source: "Firefox", time: time }));
      else if (kind === "color")
        list.push(make("m" + n, kind, { title: "#3FA9D9", text: "#3FA9D9", color: "#3FA9D9", source: "Color picker", time: time }));
      else if (kind === "image")
        list.push(make("m" + n, kind, { title: "Screenshot 14:" + (10 + (i % 50)), source: "Screenshot", time: time,
            image: { url: drawingUrl, width: 1920, height: 1080, format: "PNG", bytes: (300 + n) * 1024 } }));
      else
        list.push(make("m" + n, kind, { title: "Note " + n + ": a longer line of text that has to be cut with an ellipsis", text: "Note " + n + "\nsecond line", source: "Editor", time: time }));
    }
    return list;
  }

  // O fixado entra com o `pinnedTime` depois do instante em que foi copiado.
  function pinnedOf(item, minutesAgo) {
    return Object.assign({}, item, { pinned: true, pinnedTime: now - minutesAgo * minute });
  }

  readonly property var scenarioItems: scenario === "empty" ? []
      : scenario === "many" ? many
      : scenario === "pinned" ? [pinnedOf(command, 1), capture, pinnedOf(email, 12), swatch]
      : [command, capture, link, email, swatch]

  property var items: scenarioItems

  // Para o teste de comportamento: o que foi pedido por último, e quantas vezes.
  property var lastCopied: null
  property int copies: 0
  property var lastPinned: null
  property int pins: 0
  property var lastRemoved: null
  property int removals: 0

  function copy(item) {
    lastCopied = item;
    copies += 1;
  }

  function togglePin(item) {
    lastPinned = item;
    pins += 1;
    items = items.map(entry => entry.id !== item.id ? entry
        : Object.assign({}, entry, { pinned: !entry.pinned, pinnedTime: entry.pinned ? 0 : now }));
  }

  function remove(item) {
    lastRemoved = item;
    removals += 1;
    items = items.filter(entry => entry.id !== item.id);
  }
}
