import QtQuick

// Estado fictício do seletor de papel de parede para a vitrine e os prints da F4 (ficha 13). Mesma
// superfície que o seletor lê em settings/appearance/State.qml: `wallpapers`, `wallpaperMode`,
// `wallpaperPath`, `error`, `busy` e as três ações. As imagens são as três incluídas no repositório
// (wallpaper/included/), com o título e o autor de wallpaper/catalog.json. Nada aqui chama processo,
// nem lê ~/Pictures: a ação "Choose an image" não faz nada.
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
  function selectDynamic() { wallpaperMode = "dynamic"; wallpaperPath = ""; }
  function selectWallpaper(path) { wallpaperMode = "custom"; wallpaperPath = path; }
  // Só para o espécime: o caminho da imagem pelo título em minúsculas ("chiba") ou pelo número de duas
  // casas de uma acrescentada ("01").
  function pathOf(name) {
    const found = wallpapers.find(entry => !entry.dynamic
        && (entry.number ? (entry.number < 10 ? "0" : "") + entry.number === name : entry.title.toLowerCase() === name));
    return found ? found.path : "";
  }
}
