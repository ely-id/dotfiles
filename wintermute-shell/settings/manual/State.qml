pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Lista de atalhos do Manual (ficha 13; P-11 e P-52). Mora em shortcuts.json, um atalho por linha, na
// ordem em que aparece: Wintermute, aplicativos, janelas, workspaces, layout e sistema. Cada item tem
// `keys` (as teclas, na ordem em que se aperta) e `label` (o que o atalho faz, em inglês).
Singleton {
  id: root
  property var rows: []

  FileView {
    path: Quickshell.shellDir + "/settings/manual/shortcuts.json"
    blockLoading: true
    onLoaded: {
      try { root.rows = JSON.parse(text()); }
      catch (e) { console.warn("Manual: could not read shortcuts.json", e); }
    }
  }
}
