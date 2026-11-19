pragma ComponentBehavior: Bound

import QtQuick

// Recorta um pedaço de qualquer `Item` e grava como PNG (ficha 17, F6-T13). Na shell o item é o quadro congelado do monitor
// (o `ScreencopyView` da CaptureWindow.qml); no teste é uma cena fictícia de pixels conhecidos. Por isso a peça recebe qualquer
// item e não sabe nada de captura de tela.
//
// O caminho técnico: uma `ShaderEffectSource` que mostra só o pedaço pedido (`sourceRect`) do item, numa textura do tamanho exato
// do recorte em pixels (`textureSize`), e um `grabToImage` dessa textura, com o `saveToFile` do resultado. Escolhi isto porque o
// `grabToImage` já é o que a lupa do seletor de cor usa no mesmo `ScreencopyView` (launcher/PixelReader.qml). O pedaço vem em pixels
// do quadro e vira o `sourceRect` em pixels lógicos do item pela razão quadro / item, a mesma da pílula de tamanho: a textura sai
// com uma amostra por pixel do quadro, sem reamostrar.
//
// O `grabToImage` entrega uma imagem de `round(tamanho pedido × devicePixelRatio da janela)` pixels, e o tamanho pedido é inteiro
// (medi com a escala do Qt em 1, 1,25, 1,5 e 2). Por isso eu peço o tamanho lógico que, vezes a escala, mais se aproxima do recorte
// (`fit`). Com escala inteira, e em qualquer escala onde a conta fecha, o PNG sai com exatamente os pixels do recorte; numa escala
// fracionária onde ela não fecha (1,5 e 61 pixels, por exemplo) o PNG sai com 1 pixel a mais ou a menos, e a textura esticada
// por esse pixel, sem suavizar.
Item {
  id: root

  // O item de onde sai a imagem.
  property Item source
  // O tamanho do quadro em pixels (o `sourceSize` do `ScreencopyView`). Com escala no monitor ele é maior que o item.
  property int frameWidth: 0
  property int frameHeight: 0

  // Pronto para recortar: o item existe, está numa janela e o quadro tem tamanho.
  readonly property bool ready: !!source && !!source.Window.window && source.width > 0 && source.height > 0
      && frameWidth > 0 && frameHeight > 0

  // Grava em `path` o retângulo `pixels` ({ x, y, width, height }, em pixels do quadro, já dentro dele) e chama `done(true)` ou
  // `done(false)` quando terminar. Só devolvo `false` por falha (sem item, sem janela, retângulo vazio, arquivo que não grava);
  // o aviso no log sai daqui.
  function save(pixels, path, done) {
    if (!ready || !pixels || pixels.width <= 0 || pixels.height <= 0 || !path) {
      console.warn("screenshot: o recorte não pôde começar (quadro não pronto ou retângulo vazio)");
      done(false);
      return;
    }
    const ratioX = frameWidth / source.width;
    const ratioY = frameHeight / source.height;
    const scale = source.Window.window.devicePixelRatio || 1;
    const cell = cellComponent.createObject(root, {
      src: source,
      area: Qt.rect(pixels.x / ratioX, pixels.y / ratioY, pixels.width / ratioX, pixels.height / ratioY),
      pixels: Qt.size(pixels.width, pixels.height),
      size: Qt.size(fit(pixels.width, scale), fit(pixels.height, scale))
    });
    // A célula acabou de nascer: espero o Qt Quick montá-la antes de pedir a imagem.
    Qt.callLater(() => root.grab(cell, path, done));
  }

  // O tamanho lógico inteiro que, vezes `scale` e arredondado, mais se aproxima de `pixels`. Entre o de baixo e o de cima vale o que
  // erra menos; no empate, o de baixo.
  function fit(pixels, scale) {
    const low = Math.max(1, Math.floor(pixels / scale));
    const high = low + 1;
    return Math.abs(Math.round(low * scale) - pixels) <= Math.abs(Math.round(high * scale) - pixels) ? low : high;
  }

  function grab(cell, path, done) {
    const started = cell.grabToImage(result => {
      const ok = result.saveToFile(path);
      if (!ok)
        console.warn("screenshot: não consegui gravar " + path);
      cell.destroy();
      done(ok);
    }, cell.size);
    if (!started) {
      console.warn("screenshot: o Qt não aceitou o pedido da imagem do recorte");
      cell.destroy();
      done(false);
    }
  }

  Component {
    id: cellComponent

    // Escondida: o `grabToImage` desenha o item mesmo invisível. `size` é o tamanho lógico pedido ao `grabToImage` (ver `fit`) e
    // `pixels` o do recorte, o da textura.
    Item {
      id: cell

      required property Item src
      required property rect area
      required property size pixels
      required property size size

      visible: false
      width: size.width
      height: size.height

      ShaderEffectSource {
        anchors.fill: parent
        sourceItem: cell.src
        sourceRect: cell.area
        textureSize: cell.pixels
        hideSource: false
        smooth: false
      }
    }
  }
}
