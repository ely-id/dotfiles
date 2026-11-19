pragma Singleton

import QtQuick
import ".."
import "." as Screenshot
import Quickshell

// O estado do editor de anotação da captura de tela (ficha 17, estado 5, F6-T14). A janela (AnnotateWindow.qml, uma por tela) lê
// `opened` e `outputName`; a peça (Annotate.qml) lê `imageSource` e o `document` e chama `close`, `copy` e `save`. Quem abre o editor é a
// captura (`CaptureState.annotateSelection`, com o arquivo do recorte) e a prévia da barra (`State.annotate`, com a imagem que ela mostra).
//
// A imagem é uma URL: `file://` do PNG temporário da captura, ou o `data:` que a prévia guarda (a prévia não guarda o caminho, e o
// arquivo dela pode já ter sido apagado pela captura seguinte). A peça carrega a imagem e diz o tamanho dela ao `document`
// (AnnotateDocument.qml), que guarda a ferramenta, a cor, as marcas e o histórico.
//
// Sempre do zero, como a captura: `open()` devolve o documento ao lápis, à primeira cor e a nenhuma marca, e nada é guardado entre uma
// abertura e outra.
//
// "Copy" grava a imagem com as marcas num PNG temporário novo (a peça desenha e exporta: `registerExporter`), na mesma pasta e do mesmo
// jeito da captura (decisão 0017: o CaptureState dá a pasta, o nome, a cópia para a área de transferência e a entrega à prévia), copia,
// mostra na prévia da barra e fecha o editor. "Save" ainda não tem destino (F6-T03).
Singleton {
  id: root

  property bool opened: false
  property string outputName: ""
  property string imageSource: ""
  // Gravando o PNG de "Copy". Um número que cada fechamento troca faz um pedido que ficou para trás não copiar nem mostrar nada.
  property bool saving: false
  property int saveToken: 0

  readonly property alias document: doc

  // Quem exporta: a peça (Annotate.qml) se registra aqui. `exporter.exportTo(path, done)` grava o PNG em `path` e chama `done(true)` ou `done(false)`.
  property var exporter: null

  AnnotateDocument { id: doc }

  // Abre o editor com a imagem `source` (uma URL) no monitor `output`. Fecha o que já estava aberto nele: começa do zero.
  function open(source, output) {
    if (!source)
      return;
    saving = false;
    ++saveToken;
    doc.reset();
    imageSource = source;
    outputName = output || Quickshell.screens[0]?.name || "";
    opened = true;
  }

  // Abre com um PNG em arquivo (o recorte da captura). O caminho vira URL por partes, para um caractere como `#` não cortar o nome.
  function openFile(path, output) {
    if (!path)
      return;
    open("file://" + path.split("/").map(encodeURIComponent).join("/"), output);
  }

  // Esc, ou depois de copiar. A imagem e as marcas ficam até a próxima abertura: a janela some com uma animação e o desenho não
  // pode sumir antes dela.
  function close() {
    saving = false;
    ++saveToken;
    opened = false;
  }

  function registerExporter(item) {
    exporter = item;
  }

  function unregisterExporter(item) {
    if (exporter === item)
      exporter = null;
  }

  // "Save" tem o desenho do board, mas ainda não tem para onde ir (a pasta e o formato são a P-15 e a P-16, F6-T03). O editor continua aberto.
  function save() {
    console.log("screenshot: salvar a anotação ainda não tem destino (F6-T03); nada foi feito");
  }

  // "Copy": grava, copia, mostra na prévia e fecha, nessa ordem. Se gravar falhar, fica um aviso no log e o editor continua aberto,
  // porque aqui o trabalho é o desenho e eu não quero perdê-lo.
  function copy() {
    if (!opened || saving || !doc.ready || !exporter)
      return;
    saving = true;
    const token = ++saveToken;
    const capture = Screenshot.CaptureState;
    const dir = capture.captureDir();
    capture.makeDir(dir, made => {
      if (token !== saveToken)
        return;
      if (!made) {
        finishCopy(token, false, "");
        return;
      }
      const path = capture.nextFile(dir);
      exporter.exportTo(path, ok => finishCopy(token, ok, path));
    });
  }

  function finishCopy(token, ok, path) {
    const capture = Screenshot.CaptureState;
    if (token !== saveToken) {
      // Fechei o editor enquanto ele gravava: o arquivo ficou pronto e sem uso. Apago, para não sobrar na pasta.
      if (ok && path !== "")
        capture.exec(["rm", "-f", "--", path]);
      return;
    }
    saving = false;
    if (!ok) {
      console.warn("screenshot: não consegui gravar a imagem anotada; nada foi copiado nem mostrado. O editor continua aberto.");
      return;
    }
    capture.deliverFile(path, outputName, true);
    close();
  }
}
