pragma ComponentBehavior: Bound

import QtQuick

// Lê pixels de qualquer `Item` (ficha 15, lupa do seletor de cor). O Qt Quick não deixa ler a cor de um pixel de um
// item na tela; o que dá para ler de forma síncrona é um `Canvas`. Então o caminho é: uma única captura do item para
// uma imagem (`grabToImage`), a imagem desenhada num `Canvas` e, daí, `getImageData` nos poucos pixels que a lupa
// mostra, a cada movimento, sem esperar nada. Escolhi isto porque funciona igual para o `ScreencopyView` da shell e
// para a cena fictícia do espécime, sem depender de nada do compositor. A captura do item é feita uma vez por
// `refresh()`: a tela fica congelada, então não preciso de outra.
//
// Eu desenho a imagem num `Image` e entrego o `Image` ao `drawImage`, e não a URL do `grabToImage` ao
// `Canvas.loadImage`: o `loadImage` não aceita o esquema `itemgrabber:` e o `imageLoaded` nunca vem.
//
// O tamanho do quadro é o da imagem que o Qt devolveu, em pixels de verdade. Peço ao `grabToImage` o tamanho
// `frameWidth`×`frameHeight` (para o `ScreencopyView` é o `sourceSize` da captura, que num monitor com escala vem
// maior que o item); a lupa mostra pixels do quadro, não pixels lógicos.
Item {
  id: root

  // O item de onde saem os pixels.
  property Item source
  // Tamanho pedido para o quadro, em pixels. Sem valor, vale o tamanho do item.
  property int frameWidth: source ? Math.round(source.width) : 0
  property int frameHeight: source ? Math.round(source.height) : 0
  // Só leio o item quando ele está pronto (o ScreencopyView ainda não tem imagem antes de `hasContent`).
  property bool sourceReady: true

  // Tamanho real do quadro lido, em pixels (0 antes de estar pronto).
  readonly property int pixelWidth: ready ? canvas.canvasSize.width : 0
  readonly property int pixelHeight: ready ? canvas.canvasSize.height : 0
  // Sobe a cada quadro novo pronto; quem lê pixels depende dele para reler.
  property int revision: 0
  readonly property bool ready: revision > 0
  // A captura do item falhou (sem janela, sem tamanho).
  property bool failed: false

  // Guarda o resultado do grabToImage: a URL dele só vale enquanto o objeto vive.
  property var _result: null

  function refresh() {
    failed = false;
    // Sem janela ainda (a vitrine de componentes cria os espécimes antes de a janela existir): espero, o
    // `onWindowChanged` abaixo chama de novo. Não é falha.
    if (source && !source.Window.window)
      return;
    if (!source || frameWidth <= 0 || frameHeight <= 0) {
      failed = true;
      return;
    }
    const started = source.grabToImage(result => {
      root._result = result;
      grabbed.source = result.url;
    }, Qt.size(frameWidth, frameHeight));
    if (!started)
      failed = true;
  }

  onSourceReadyChanged: {
    if (sourceReady)
      Qt.callLater(refresh);
  }
  Component.onCompleted: {
    if (sourceReady)
      Qt.callLater(refresh);
  }

  Connections {
    target: root.source
    // O `Window.window` do item só vale depois do sinal, por isso o `callLater`; o `refresh` confere a janela.
    function onWindowChanged() {
      if (root.sourceReady && !root.ready)
        Qt.callLater(root.refresh);
    }
  }

  Image {
    id: grabbed
    visible: false
    cache: false
    onStatusChanged: {
      if (status === Image.Ready) {
        canvas.canvasSize = Qt.size(implicitWidth, implicitHeight);
        canvas.width = implicitWidth;
        canvas.height = implicitHeight;
        canvas.requestPaint();
      } else if (status === Image.Error) {
        root.failed = true;
      }
    }
  }

  Canvas {
    id: canvas
    visible: false
    renderTarget: Canvas.Image
    renderStrategy: Canvas.Immediate
    onPaint: {
      if (grabbed.status !== Image.Ready)
        return;
      const ctx = getContext("2d");
      ctx.clearRect(0, 0, width, height);
      ctx.drawImage(grabbed, 0, 0);
      root.revision += 1;
    }
  }

  function _hex(value) {
    return (value < 16 ? "0" : "") + value.toString(16).toUpperCase();
  }

  // Os `cols`×`rows` pixels do quadro em volta de (px, py), em ordem de linha, como "#RRGGBB". O pixel de fora
  // do quadro vem como "". Antes de estar pronto, tudo vem "". O pixel do meio é o (px, py) quando `cols` e
  // `rows` são ímpares.
  function sample(px, py, cols, rows) {
    const out = new Array(cols * rows).fill("");
    if (!ready)
      return out;
    const w = pixelWidth;
    const h = pixelHeight;
    const x0 = px - Math.floor(cols / 2);
    const y0 = py - Math.floor(rows / 2);
    // Só peço ao canvas o trecho que existe; o resto fica vazio.
    const cx0 = Math.max(0, x0);
    const cy0 = Math.max(0, y0);
    const cx1 = Math.min(w, x0 + cols);
    const cy1 = Math.min(h, y0 + rows);
    if (cx1 <= cx0 || cy1 <= cy0)
      return out;
    const data = canvas.getContext("2d").getImageData(cx0, cy0, cx1 - cx0, cy1 - cy0).data;
    for (let y = cy0; y < cy1; y++) {
      for (let x = cx0; x < cx1; x++) {
        const i = ((y - cy0) * (cx1 - cx0) + (x - cx0)) * 4;
        out[(y - y0) * cols + (x - x0)] = "#" + _hex(data[i]) + _hex(data[i + 1]) + _hex(data[i + 2]);
      }
    }
    return out;
  }

  // A cor de um pixel do quadro, ou "" se ele não existe.
  function colorAt(px, py) {
    return sample(px, py, 1, 1)[0];
  }
}
