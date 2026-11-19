import QtQuick
import "../screenshot" as Screenshot

// O serviço fictício do editor de anotação (decisão 0011, ficha 17, estado 5): a mesma superfície de screenshot/AnnotateState.qml
// (`imageSource`, `document`, `saving`, `copy`, `save`, `close`, `registerExporter`, `unregisterExporter`), sem janela, sem arquivo e sem
// área de transferência. O documento é o mesmo AnnotateDocument.qml do estado de verdade, então a ferramenta, a cor, as marcas, o
// desfazer e o recorte funcionam como na shell. "Copy", "Save" e fechar só contam, porque a vitrine não grava, não copia nem fecha nada.
QtObject {
  id: root

  property string imageSource: ""
  property bool saving: false

  readonly property QtObject document: Screenshot.AnnotateDocument { id: doc }
  // As marcas que o documento já tem quando a imagem carrega, a ferramenta e a cor de abertura: o espécime os põe.
  property alias initialMarks: doc.initialMarks
  property alias tool: doc.tool
  property alias colorIndex: doc.colorIndex

  // Quem exporta, como no estado de verdade; o teste de exportação o usa para gravar o PNG.
  property var exporter: null

  // Quantas vezes pediram cada coisa (para o teste de comportamento).
  property int copyCount: 0
  property int saveCount: 0
  property int closeCount: 0

  function registerExporter(item) { exporter = item; }
  function unregisterExporter(item) { if (exporter === item) exporter = null; }

  function copy() { ++copyCount; }
  function save() { ++saveCount; }
  function close() { ++closeCount; }
}
