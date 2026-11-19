pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import ".."
import "Search.js" as Search

// Busca de arquivos por nome do launcher (ficha 14, grupo Files; P-12). Sem índice nem serviço: a cada mudança do
// texto, depois de um atraso de `Theme.controlDuration`, rodo o `fd` com o texto como trecho fixo nas pastas
// principais da pasta pessoal e guardo a lista que ele devolveu. Uma busca nova mata a anterior. A `Search.js` monta
// as linhas e o `State.qml` as mistura com as outras fontes.
//
// O binário, as pastas e os limites são propriedades, para o teste apontar para uma pasta temporária e para um `fd`
// de mentira. A "Search files" da F5-T11 vai reaproveitar isto com outras pastas e mais resultados.
//
//   text       o que buscar; abaixo de `minChars` não busco nada e a lista fica vazia
//   output     a saída crua do `fd` da última busca concluída (caminhos absolutos separados por NUL)
//   searching  há uma busca pendente (no atraso ou no `fd`) para o texto atual
//   available  o `fd` existe; se não existir, aviso uma vez no log e o grupo Files fica de fora
Scope {
  id: root

  property string binary: "fd"
  // As pastas do usuário que o Qt conhece (Desktop, Documents, Downloads, Music, Pictures e Videos). Sem nome de pasta
  // escrito aqui: quem diz onde elas ficam é o xdg-user-dirs, pelo StandardPaths.
  property var directories: defaultDirectories()
  property int minChars: Search.FILES_MIN_CHARS
  property int maxResults: Search.FILES_MAX_RESULTS
  // Atraso entre a última tecla e a busca: o tempo de controle que a shell já usa, sem tempo novo.
  property int delay: Theme.controlDuration
  property string text: ""

  property string output: ""
  // O texto a que `output` responde, para quem quiser conferir.
  property string outputText: ""
  readonly property bool searching: pending
  // Atualizado a cada busca (o PATH pode mudar enquanto a shell roda).
  property bool available: true

  property bool pending: false
  property bool warned: false
  // Número da busca em andamento: a resposta de uma busca que já foi trocada não vale.
  property int generation: 0
  property var current: null

  // As pastas padrão do usuário que existem no mapa do Qt, sem a própria pasta pessoal (se o xdg-user-dirs não
  // configurou uma delas, o Qt devolve a pasta pessoal, e buscar nela inteira não é o que quero) e sem repetir.
  function defaultDirectories() {
    const home = Search.localPath(StandardPaths.writableLocation(StandardPaths.HomeLocation));
    const kinds = [StandardPaths.DesktopLocation, StandardPaths.DocumentsLocation, StandardPaths.DownloadLocation,
        StandardPaths.MusicLocation, StandardPaths.PicturesLocation, StandardPaths.MoviesLocation];
    const found = [];
    kinds.forEach(kind => {
      StandardPaths.standardLocations(kind).forEach(url => {
        const path = Search.localPath(url);
        if (path !== "" && path !== home && found.indexOf(path) < 0)
          found.push(path);
      });
    });
    return found;
  }

  onTextChanged: schedule()

  // Texto novo: mata a busca anterior e, se o texto é grande o bastante, espera o atraso para começar a nova.
  function schedule() {
    kill();
    const wanted = String(text).trim();
    if (wanted.length < minChars) {
      debounce.stop();
      pending = false;
      if (output !== "") {
        output = "";
        outputText = "";
      }
      return;
    }
    pending = true;
    debounce.restart();
  }

  function kill() {
    generation += 1;
    if (current) {
      current.running = false;
      current = null;
    }
  }

  function start() {
    const wanted = String(text).trim();
    if (wanted.length < minChars) {
      pending = false;
      return;
    }
    available = String(StandardPaths.findExecutable(binary)) !== "";
    if (!available) {
      if (!warned) {
        warned = true;
        console.warn("launcher: não achei o `" + binary + "`; a busca de arquivos fica desligada");
      }
      finish("", wanted);
      return;
    }
    if (!directories || directories.length === 0) {
      finish("", wanted);
      return;
    }
    current = runner.createObject(root, {
      command: Search.fdCommand(binary, wanted, directories, maxResults),
      searchGeneration: generation,
      searchedText: wanted
    });
  }

  function finish(result, wanted) {
    output = result;
    outputText = wanted;
    pending = false;
  }

  Timer {
    id: debounce
    interval: root.delay
    onTriggered: root.start()
  }

  Component {
    id: runner
    Process {
      id: search
      required property int searchGeneration
      required property string searchedText
      property string payload: ""
      running: true
      stdout: StdioCollector {
        onStreamFinished: search.payload = text
      }
      stderr: StdioCollector {}
      onExited: {
        // Só a busca atual conta; uma que foi morta ou trocada no caminho só se limpa.
        if (search.searchGeneration === root.generation) {
          root.current = null;
          root.finish(search.payload, search.searchedText);
        }
        search.destroy();
      }
    }
  }
}
