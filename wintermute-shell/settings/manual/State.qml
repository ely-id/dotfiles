pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Lista de atalhos do Manual (ficha 13; P-11 e P-52). A fonte é o shortcuts.json, o mesmo arquivo de
// onde o keybinds.py gera as binds do Niri: cada atalho tem a tecla do Niri (`bind`), a descrição
// (`label`, em inglês) e a ação. Aqui eu só derivo o que o Manual mostra, uma linha `{ keys, label }`
// por atalho, na ordem do arquivo. Pulo as seções (o Figma não desenha rótulo de grupo) e os itens com
// `"manual": false`. Uma linha que junta várias binds (a roda, Super+1 a 9) traz `keys` escrito à mão.
Singleton {
  id: root
  property var rows: []

  // Do nome que o Niri usa para o que se lê no Manual. Letra vira maiúscula; Return, Tab, Space, Up,
  // Down, Left, Right, números, F1.. e os modificadores Ctrl, Shift e Alt ficam como estão.
  readonly property var keyNames: ({
    "Mod": "Super",
    "Grave": "`",
    "Escape": "Esc",
    "Delete": "Del",
    "Slash": "/",
    "BracketLeft": "[",
    "BracketRight": "]",
    "Minus": "-",
    "Equal": "=",
    "WheelScrollLeft": "Wheel left",
    "WheelScrollRight": "Wheel right"
  })

  function keysFor(bind) {
    return bind.split("+").map(k => {
      if (root.keyNames[k] !== undefined) return root.keyNames[k];
      return k.length === 1 ? k.toUpperCase() : k;
    });
  }

  function rowsFrom(list) {
    const out = [];
    for (const item of list) {
      if (item.section !== undefined || item.manual === false) continue;
      out.push({ keys: item.keys !== undefined ? item.keys : root.keysFor(item.bind), label: item.label });
    }
    return out;
  }

  FileView {
    path: Quickshell.shellDir + "/settings/manual/shortcuts.json"
    blockLoading: true
    onLoaded: {
      try { root.rows = root.rowsFrom(JSON.parse(text())); }
      catch (e) { console.warn("Manual: could not read shortcuts.json", e); }
    }
  }
}
