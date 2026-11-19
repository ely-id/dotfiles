import QtQuick
import Quickshell.Io
import "Emoji.js" as Emoji

// O inventário do seletor de emoji (ficha 16): lê o emoji/emoji.json, que o build.py gera, só quando a página abre pela
// primeira vez. O arquivo tem uns 300 KB e 1914 emojis; não vale pagar a leitura toda vez que a shell sobe. É o mesmo
// objeto no State.qml e no serviço fictício da vitrine, porque o inventário não é dado da máquina.
QtObject {
  id: root

  // De onde ler; o teste aponta para outro arquivo.
  property url source: Qt.resolvedUrl("emoji/emoji.json")
  // O resultado de Emoji.parse, ou null até a primeira leitura (e se o arquivo não presta).
  property var data: null
  // Quanto a última leitura levou, em milissegundos, para eu medir; -1 antes dela.
  property int loadMillis: -1

  readonly property FileView file: FileView {
    blockLoading: true
    printErrors: false
  }

  // Lê o arquivo se ainda não leu. Devolve se há inventário.
  function ensure() {
    if (data)
      return true;
    const started = Date.now();
    file.path = String(source).replace(/^file:\/\//, "");
    file.waitForJob();
    let text = "";
    try {
      text = file.text();
    } catch (error) {
      text = "";
    }
    const parsed = Emoji.parse(text);
    if (!parsed) {
      console.warn("launcher: não consegui ler o inventário de emoji em", file.path);
      return false;
    }
    data = parsed;
    loadMillis = Date.now() - started;
    return true;
  }
}
