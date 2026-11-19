.pragma library
.import "Windows.js" as Win

// A conta do recorte da captura de tela (ficha 17, F6-T13): do retângulo que escolhi, em pixels lógicos do monitor, para o
// retângulo de pixels do quadro congelado que vira o PNG. Fica fora do QML para eu testar sem janela. Um retângulo é
// { x, y, width, height }. Nenhum valor de desenho mora aqui.
//
// Com escala no monitor o quadro tem mais pixels que a tela (`ratioX` e `ratioY` são quadro / tela, os mesmos que a pílula de
// tamanho usa), e o PNG sai com os pixels do quadro: uma seleção de 320×200 num monitor de escala 2 dá um PNG de 640×400.

function clamp(value, low, high) {
  return Math.max(low, Math.min(high, value));
}

// O recorte de `rect` (pixels lógicos) em pixels do quadro de `frameWidth` × `frameHeight`, ou null se não sobra nada dentro do
// monitor. Primeiro corto o retângulo no monitor, em pixels lógicos (`width` × `height`): uma janela que sai da tela entrega só
// a parte que se vê. Depois converto: a origem e o tamanho são arredondados cada um, e não as duas bordas, para a largura do
// PNG ser a que a pílula de tamanho mostra (Windows.pixelSize). No fim prendo ao quadro, para o arredondamento não passar dele.
function toPixels(rect, width, height, frameWidth, frameHeight) {
  if (!rect || !(frameWidth > 0) || !(frameHeight > 0) || !(width > 0) || !(height > 0))
    return null;
  const left = clamp(rect.x, 0, width);
  const top = clamp(rect.y, 0, height);
  const right = clamp(rect.x + rect.width, 0, width);
  const bottom = clamp(rect.y + rect.height, 0, height);
  if (right <= left || bottom <= top)
    return null;
  const ratioX = frameWidth / width;
  const ratioY = frameHeight / height;
  const x = clamp(Math.round(left * ratioX), 0, frameWidth - 1);
  const y = clamp(Math.round(top * ratioY), 0, frameHeight - 1);
  const w = clamp(Math.round((right - left) * ratioX), 1, frameWidth - x);
  const h = clamp(Math.round((bottom - top) * ratioY), 1, frameHeight - y);
  return { x: x, y: y, width: w, height: h };
}

// O monitor inteiro: o quadro todo.
function screenPixels(frameWidth, frameHeight) {
  if (!(frameWidth > 0) || !(frameHeight > 0))
    return null;
  return { x: 0, y: 0, width: frameWidth, height: frameHeight };
}

// O retângulo da janela `id` na foto das janelas (`snapshot`, { monitor: [ janela ] } como o CaptureState guarda) e o monitor
// dela: { output, rect } ou null se a janela não está em nenhuma, ou se não tem posição (a conta da posição é a do Windows.place).
function findWindow(snapshot, id) {
  for (const output of Object.keys(snapshot || {})) {
    for (const window of snapshot[output] || []) {
      if (window.id === id) {
        const rect = Win.place(window.layout);
        return rect ? { output: output, rect: rect } : null;
      }
    }
  }
  return null;
}
