pragma Singleton

import QtQuick
import ".."
import "Save.js" as Save
import QtCore
import Quickshell

// O estado do aviso "Screenshot saved" (ficha 17, F6-T03). A janela (SavedToastWindow.qml, uma por tela) lê `visible` e `outputName`, e a
// peça (SavedToast.qml) lê `displayPath`. Quem avisa é quem acabou de salvar: a pílula de ações da seleção (CaptureState.saveSelection),
// a prévia da barra (State.save) e o editor de anotação (AnnotateState.save), todos por `CaptureState.notifySaved`.
//
// Também é daqui que sai o destino do arquivo salvo, porque os três "salvar" gravam no mesmo lugar e com o mesmo nome: `dir` é a pasta
// de imagens do sistema mais `Screenshots` (P-15, a mesma em que o Niri salva as capturas dele, para tudo ficar junto) e `nextPath()` dá o
// caminho de um arquivo novo, no padrão de nome do Niri (Save.js). O formato é sempre PNG (P-16).
//
// O aviso some sozinho em `captureSavedDuration`. Um salvar novo durante o aviso troca o caminho e recomeça o tempo. Depois de sumir o
// caminho continua guardado, só para a animação de saída ainda ter o que mostrar.
Singleton {
  id: root

  property bool visible: false
  // O caminho completo do arquivo salvo, o mesmo com a pasta pessoal trocada por `~` (o que o aviso mostra) e o monitor do aviso.
  property string path: ""
  property string outputName: ""
  readonly property string displayPath: Save.displayPath(path, home)

  // A pasta pessoal e a pasta das capturas salvas. `dir` é uma propriedade comum para o teste trocar por uma pasta temporária.
  readonly property string home: localPath(StandardPaths.writableLocation(StandardPaths.HomeLocation))
  property string dir: {
    const pictures = localPath(StandardPaths.writableLocation(StandardPaths.PicturesLocation));
    return (pictures !== "" ? pictures : home + "/Pictures").replace(/\/+$/, "") + "/Screenshots";
  }

  // O relógio do nome do arquivo e os nomes que esta sessão já deu, para o mesmo segundo não repetir. O teste troca `clock`.
  property var clock: () => new Date()
  property var usedNames: []

  function localPath(url) {
    return decodeURIComponent(url.toString().replace(/^file:\/\//, ""));
  }

  // O caminho de um arquivo novo na pasta das capturas salvas. Reserva o nome: o próximo pedido, mesmo no mesmo segundo, recebe outro.
  function nextPath() {
    const name = Save.fileName(clock(), usedNames);
    usedNames = usedNames.concat([name]);
    return dir + "/" + name;
  }

  // Mostra o aviso para o arquivo `savedPath` no monitor `output` (sem nome, o primeiro). Já estando à mostra, só troca o caminho e recomeça o tempo.
  function show(savedPath, output) {
    path = savedPath;
    outputName = output || Quickshell.screens[0]?.name || "";
    visible = true;
    hideTimer.restart();
  }

  function dismiss() {
    hideTimer.stop();
    visible = false;
  }

  Timer {
    id: hideTimer
    interval: Theme.captureSavedDuration
    onTriggered: root.dismiss()
  }
}
