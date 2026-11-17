pragma Singleton
import QtQuick
import Quickshell

// Fonte de imagem do ícone de um aplicativo, a partir do `Icon=` do .desktop.
// Esse campo pode ser um nome de tema ("firefox") ou um caminho absoluto
// ("/caminho/icone.svg"). O `Quickshell.iconPath()` só procura nas pastas de tema,
// então com um caminho absoluto ele não acha o arquivo e o Qt avisa de SVG
// inválido. Quando o valor começa com "/", a fonte é o próprio arquivo.
Singleton {
  function isFile(icon) {
    return String(icon || "").startsWith("/");
  }

  function path(icon, fallback) {
    const name = String(icon || "");
    return isFile(name) ? "file://" + name : Quickshell.iconPath(name, fallback);
  }
}
