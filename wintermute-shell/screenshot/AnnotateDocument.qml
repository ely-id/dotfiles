import QtQuick
import ".."
import "Annotate.js" as Ann

// O documento do editor de anotação (ficha 17, F6-T14): a ferramenta, a cor, e a imagem com as marcas e o histórico (o `state` do
// Annotate.js, imutável). O estado de verdade (AnnotateState.qml) e o fictício da vitrine (demo/AnnotateService.qml) usam este mesmo
// objeto, para a peça se comportar igual nos dois e eu não escrever a conta duas vezes. As contas são do Annotate.js; aqui só moram
// as propriedades que o QML observa.
//
// Sempre do zero: `reset()` volta ao lápis, à primeira cor e a nenhuma imagem; o documento só passa a existir (`ready`) quando a peça
// diz o tamanho da imagem carregada (`begin`), porque quem sabe o tamanho é o `Image`.
QtObject {
  id: root

  // As ferramentas, na ordem da barra: lápis, marca-texto, retângulo, seta, texto e recorte.
  readonly property var tools: ["pencil", "highlighter", "rectangle", "arrow", "text", "crop"]
  property string tool: "pencil"
  property int colorIndex: 0
  readonly property color color: Theme.captureAnnotateColors[colorIndex]

  // O documento do Annotate.js, ou null enquanto a imagem não carregou.
  property var state: null
  readonly property bool ready: state !== null
  readonly property bool canUndo: state !== null && Ann.canUndo(state)
  // Cada `reset()` troca este número: a peça zera o que é só dela (o texto em andamento, o recorte) quando ele muda.
  property int generation: 0
  // Marcas já presentes quando a imagem carrega. Só a vitrine usa, para montar o estado do board.
  property var initialMarks: []

  function reset() {
    tool = "pencil";
    colorIndex = 0;
    state = null;
    ++generation;
  }

  // A imagem carregou com `width` × `height` pixels: começa o documento, sem marcas (ou com as `initialMarks`).
  function begin(width, height) {
    if (!(width > 0) || !(height > 0))
      return;
    let next = Ann.create(width, height);
    for (const mark of initialMarks)
      next = Ann.addMark(next, mark);
    state = next;
  }

  function setTool(name) {
    if (tools.indexOf(name) >= 0)
      tool = name;
  }

  function setColor(index) {
    if (index >= 0 && index < Theme.captureAnnotateColors.length)
      colorIndex = index;
  }

  function addMark(mark) {
    if (state && mark)
      state = Ann.addMark(state, mark);
  }

  function undo() {
    if (canUndo)
      state = Ann.undo(state);
  }

  // Recorta a imagem em `rect` (pixels da imagem de agora). O Annotate.js decide o que sobra das marcas.
  function applyCrop(rect) {
    if (state)
      state = Ann.crop(state, rect);
  }
}
