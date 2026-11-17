import QtQuick

// Estado fictício do seletor de papel de parede para a vitrine e os prints da F4 (ficha 13). Mesma
// superfície que o seletor lê em settings/appearance/State.qml: `wallpapers`, `wallpaperMode`,
// `wallpaperPath`, `error`, `busy` e as três ações. As imagens são as três incluídas no repositório
// (wallpaper/included/), com o título e o autor de wallpaper/catalog.json. Nada aqui chama processo,
// nem lê ~/Pictures: a ação "Choose an image" não faz nada.
QtObject {
  id: root

  function included(file) { return Qt.resolvedUrl("../wallpaper/included/" + file); }

  property string wallpaperMode: "dynamic"
  property string wallpaperPath: ""
  property string error: ""
  property bool busy: false
  readonly property var wallpapers: [
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
  // Só para o espécime: o caminho da imagem pelo título, em minúsculas ("chiba").
  function pathOf(name) {
    const found = wallpapers.find(entry => !entry.dynamic && entry.title.toLowerCase() === name);
    return found ? found.path : "";
  }
}
