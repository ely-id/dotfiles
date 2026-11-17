import QtQuick
import "../settings/appearance/Places.js" as Places

// Estado fictício do seletor de papel de parede para a vitrine e os prints da F4 (ficha 13). Mesma
// superfície que o seletor lê em settings/appearance/State.qml: `wallpapers`, `wallpaperMode`,
// `wallpaperPath`, `error`, `busy` e as três ações. As imagens são as três incluídas no repositório
// (wallpaper/included/), com o título e o autor de wallpaper/catalog.json. Nada aqui chama processo,
// nem lê ~/Pictures: a ação "Choose an image" não faz nada.
// Os papéis de parede por lugar (F4-T24, P-67) têm a mesma superfície do serviço real: `followScheme`,
// `perDisplay`, `places`, `choosingPlace`, `choosingName`, `markedMode`, `markedPath`, `connectors`,
// `placeRows`, `wallpaperFor()`, as ações das chaves e da escolha de um lugar e o sinal `placeSaved`. A
// lógica é a mesma do serviço real (settings/appearance/Places.js), para os dois não divergirem. Os
// conectores fictícios são os de demo/DisplayService.qml; nenhum nome vem da máquina.
// `extras` acrescenta ao fim de `wallpapers` essa quantidade de imagens acrescentadas e numeradas (P-59),
// como o control.py as devolve: `number` de 1 em diante, título e autor vazios. Reaproveito as três
// incluídas em rodízio; o `path` é fictício (/demo/backgrounds/...) e o `url` leva um sufixo de consulta,
// para cada uma ser distinta e a seleção funcionar. Nenhuma é lida do disco além das incluídas.
QtObject {
  id: root

  function included(file) { return Qt.resolvedUrl("../wallpaper/included/" + file); }

  property string wallpaperMode: "dynamic"
  property string wallpaperPath: ""
  property string error: ""
  property bool busy: false
  // O marcado na grade tem o `url` da imagem; o serviço real o lê do arquivo.
  readonly property string wallpaperUrl: {
    const found = wallpapers.find(entry => !entry.dynamic && entry.path === wallpaperPath);
    return wallpaperMode === "custom" && found ? found.url.toString() : "";
  }
  property bool followScheme: false
  property bool perDisplay: false
  // Escolhas de cada lugar, como o wallpaper.json as guarda: chave -> {mode, path, url}.
  property var places: ({})
  property string choosingPlace: ""
  // O modo dos aplicativos ("dark" ou "light"), que escolhe Light ou Dark quando a chave do modo está ligada.
  property string appsScheme: "dark"
  property var connectors: Places.sortConnectors(["DP-1", "eDP-1"])
  signal placeSaved(string key)
  readonly property var grid: ({ mode: wallpaperMode, path: wallpaperPath, url: wallpaperUrl })
  readonly property var marked: Places.resolve(grid, places, choosingPlace)
  readonly property string markedMode: marked.mode
  readonly property string markedPath: marked.path
  readonly property string choosingName: Places.nameOf(choosingPlace)
  readonly property var placeRows: Places.rows(followScheme, perDisplay, connectors, places, grid)
  property int extras: 0
  readonly property var wallpapers: base.concat(Array.from({length: extras}, (unused, i) => {
    const file = ["chiba", "freeside", "sprawl"][i % 3] + "-1920x1080.png";
    return { path: "/demo/backgrounds/" + file.replace(".png", "-" + (i + 1) + ".png"),
             url: included(file) + "?extra=" + (i + 1), number: i + 1, title: "", subtitle: "" };
  }))
  readonly property var base: [
    { dynamic: true, title: "Dynamic" },
    { path: included("chiba-1920x1080.png").toString().replace("file://", ""), url: included("chiba-1920x1080.png"),
      title: "Chiba", subtitle: "Armitage palette" },
    { path: included("freeside-1920x1080.png").toString().replace("file://", ""), url: included("freeside-1920x1080.png"),
      title: "Freeside", subtitle: "Armitage palette" },
    { path: included("sprawl-1920x1080.png").toString().replace("file://", ""), url: included("sprawl-1920x1080.png"),
      title: "Sprawl", subtitle: "Armitage palette" }
  ]

  function pickWallpaper() {}
  // Com um lugar em escolha a escolha vai para o lugar, como no serviço real; sem, para o marcado na grade.
  function selectDynamic() {
    if (choosingPlace) savePlace({ mode: "dynamic", path: "", url: "" });
    else { wallpaperMode = "dynamic"; wallpaperPath = ""; }
  }
  function selectWallpaper(path) {
    if (choosingPlace) savePlace(entryOfPath(path));
    else { wallpaperMode = "custom"; wallpaperPath = path; }
  }
  function savePlace(entry) {
    const key = choosingPlace;
    places = Object.assign({}, places, { [key]: entry });
    placeSaved(key);
  }
  function setFollowScheme(on) { followScheme = on; }
  function setPerDisplay(on) { perDisplay = on; }
  function beginPlace(key) { if (Places.validKey(key)) choosingPlace = key; }
  function cancelPlace() { choosingPlace = ""; }
  // O papel de parede que vale numa tela, para o shell.qml (o serviço real devolve o mesmo).
  function wallpaperFor(connector) {
    return Places.forScreen(followScheme, perDisplay, places, grid, connector, appsScheme);
  }
  // Só para o espécime: a entrada de `places` de uma imagem pelo caminho, ou do "Dynamic".
  function entryOfPath(path) {
    const found = wallpapers.find(entry => !entry.dynamic && entry.path === path);
    return found ? { mode: "custom", path: found.path, url: found.url.toString() } : { mode: "dynamic", path: "", url: "" };
  }
  // Só para o espécime: a entrada de um lugar pelo mesmo nome que `selected` aceita ("dynamic", "chiba", "01").
  function entryOf(name) {
    return name === "dynamic" ? { mode: "dynamic", path: "", url: "" } : entryOfPath(pathOf(name));
  }
  // Só para o espécime: o caminho da imagem pelo título em minúsculas ("chiba") ou pelo número de duas
  // casas de uma acrescentada ("01").
  function pathOf(name) {
    const found = wallpapers.find(entry => !entry.dynamic
        && (entry.number ? (entry.number < 10 ? "0" : "") + entry.number === name : entry.title.toLowerCase() === name));
    return found ? found.path : "";
  }
}
