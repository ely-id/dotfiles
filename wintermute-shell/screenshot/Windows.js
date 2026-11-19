.pragma library

// A conta dos modos Window e Screen da captura de tela (ficha 17, F6-T12). Fica fora do QML para eu testar com dados
// fictícios, sem a peça nem o Niri. Tudo em pixels lógicos do monitor, com a origem no canto de cima à esquerda; um retângulo
// é { x, y, width, height }. Nenhum valor de desenho mora aqui: as folgas e as medidas da pílula chegam de quem chama, que as
// lê do Theme.qml.
//
// Uma janela chega como o NiriMsg.activeWorkspaceWindows a entrega: { id, appId, title, entryName, isFloating, layout }, com o
// `layout` cru do IPC do Niri e o `entryName` (o Name da entrada .desktop, ou "") que o estado da captura acrescenta.

// O retângulo da janela em pixels do monitor, ou null se o Niri não deu a posição dela. A CONTA DA POSIÇÃO ESTÁ AQUI e só aqui:
// a janela fica em `tile_pos_in_workspace_view + window_offset_in_tile` e tem o tamanho `window_size` (o do bloco menos as
// decorações do Niri: borda e anel de foco). A "vista do workspace" do Niri é a área do monitor, a mesma do `relative-to=
// "workspace-view"` dos degradês da configuração. PRECISA SER CONFERIDA NA SESSÃO DO NIRI: se o anel sair deslocado, é aqui
// que se ajusta (a origem da vista, ou o `window_offset_in_tile`). Arredondo a posição para a borda de 2 px do anel cair em
// pixel inteiro; o tamanho do Niri já é inteiro.
function place(layout) {
  if (!layout || !layout.tile_pos_in_workspace_view || !layout.window_offset_in_tile || !layout.window_size)
    return null;
  const pos = layout.tile_pos_in_workspace_view;
  const offset = layout.window_offset_in_tile;
  const size = layout.window_size;
  return {
    x: Math.round(pos[0] + offset[0]),
    y: Math.round(pos[1] + offset[1]),
    width: size[0],
    height: size[1]
  };
}

// O nome que a pílula mostra: o da entrada .desktop; sem ela, o título da janela; sem título, o appId. Sem nenhum dos três
// (não deveria acontecer) cai em "Window", para a pílula não ficar com o texto começando num ponto.
function label(window) {
  return window.entryName || window.title || window.appId || "Window";
}

// A ordem de cima para baixo: as flutuantes ficam acima das lado a lado. O Niri não diz qual flutuante está por cima da outra;
// uso o id maior (a mais nova) em cima, que é a que acabou de abrir.
function stack(rects) {
  return rects.slice().sort((a, b) => (b.floating - a.floating) || (b.id - a.id));
}

// Das janelas do workspace ativo para os retângulos, já de cima para baixo. As sem posição ficam de fora.
function rects(windows) {
  const list = [];
  for (const window of windows || []) {
    const rect = place(window.layout);
    if (rect)
      list.push({ id: window.id, x: rect.x, y: rect.y, width: rect.width, height: rect.height,
          floating: !!window.isFloating, name: label(window) });
  }
  return stack(list);
}

// A janela sob o ponto (x, y): a primeira de cima para baixo que o contém, ou null. `rects` já vem ordenada de cima para baixo
// (Windows.rects). A borda de baixo e a da direita ficam de fora, como em qualquer retângulo de pixels.
function windowAt(rects, x, y) {
  for (const rect of rects || []) {
    if (x >= rect.x && x < rect.x + rect.width && y >= rect.y && y < rect.y + rect.height)
      return rect;
  }
  return null;
}

// Onde cai a pílula (largura `w`, altura `h`) de um alvo `rect`: alinhada à esquerda dele e terminando `gap` acima do anel, que
// sai `ring` para fora do alvo (a janela: 2; o monitor tem o anel por dentro, ring 0). Sem lugar em cima vai para dentro do
// alvo, a `gap` do canto de cima à esquerda. Na horizontal não sai do monitor de largura `width`.
function pillPlace(rect, w, h, gap, ring, width) {
  let x = rect.x;
  let y = rect.y - ring - gap - h;
  let where = "above";
  if (y < 0) {
    x = rect.x + gap;
    y = rect.y + gap;
    where = "inside";
  }
  return { x: Math.max(0, Math.min(x, Math.max(0, width - w))), y: y, where: where };
}

// O tamanho em pixels do monitor: com escala o quadro tem mais pixels que a tela, e `ratioX` e `ratioY` são quadro / tela.
function pixelSize(rect, ratioX, ratioY) {
  return { width: Math.round(rect.width * (ratioX || 1)), height: Math.round(rect.height * (ratioY || 1)) };
}

// A parte fixa da pílula, depois do nome: " · 320 × 300" (ponto no meio U+00B7 e sinal de vezes U+00D7, com um espaço de cada
// lado). A peça corta o nome com reticências e deixa isto inteiro.
function pillSuffix(rect, ratioX, ratioY) {
  const size = pixelSize(rect, ratioX, ratioY);
  return " · " + size.width + " × " + size.height;
}

// O texto da pílula inteiro: "Nome · 320 × 300".
function pillText(name, rect, ratioX, ratioY) {
  return name + pillSuffix(rect, ratioX, ratioY);
}
