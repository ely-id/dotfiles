# 15 · Seletor de cor

**Nova?** **sim** (dentro do launcher, ficha 14)  
**Onde encaixar:** `shell/launcher/` (subpágina ou modo do launcher)  
**Board:** `13:17120`  
**PNG:** `referencias/armitage/07-launcher-ferramentas-chiba.png`

## Estado “pegando a cor”

- Tela do desktop visível. Lupa **112×112** raio 56, traço `knob` 2 px outside, sombra, conteúdo em grade 7×7 de pixels **16×16**. Pixel central marcado com traço `knob` 2.
- Valor sob o cursor, 112×28 raio 14, logo abaixo da lupa: amostra 12×12 + hex Geist Mono 11 (exemplo `#3FA9D9`, cor fictícia).
- Dica em pílula de vidro raio 20: Clique = pegar · Setas = mover 1 px · Esc = cancelar.

## Estado resultado — launcher 640×476

- Cabeçalho com voltar 32 + título “Seletor de cor” 17 Regular.
- Amostra 96×96 raio 16 em (20,76), borda `border`.
- Nome Serif 24; origem 13 Regular `muted`; botão “Pegar outra”.
- Três linhas de formato 600×44 raio 12, fundo `control`: rótulo Mono 11 `muted` (HEX / RGB / HSL) + valor Mono 13. Ao copiar: check `successText` + “Copiado” por **1,5 s**, botão ícone vira Selecionado.
- Histórico: as **12** últimas, swatches 32×32 raio 8 a cada 40 px, y 364. Hover mostra o valor numa dica (na prévia, a dica foi corrigida para x 32, y 328).
- Rodapé: Copiar HEX ↵ · Pegar outra P.

## Conferido no Figma (2026-11-17, `F5-T08`, board `13:17120`)

Li os dois estados pelo `get_design_context`: "pegando a cor" `13:17430` (560×340) e o resultado `13:17499` (640×476). As coordenadas são do quadro de cada um.

### Resultado: launcher de 640×476

- O mesmo vidro do launcher (640, raio 24), com o brilho do acento colado ao rodapé.
- **Cabeçalho:** botão ícone de 32 (raio 10, sem fundo no repouso) em (12,12), com a seta para a esquerda de 16; título "Seletor de cor" em Geist Regular 17 `text`, numa caixa de 400×24 em (52,16); divisor `border` em y 56.
- **Amostra:** 96×96 em (20,76), raio 16, a cor, com borda `border` de 1.
- **Nome:** Geist Serif Regular 24 `text`, numa caixa de 300×32 em (136,84). No board, "Azul céu".
- **Origem:** Geist Regular 13 `muted`, numa caixa de 300×20 em (136,116). No board, "Pego agora · Firefox".
- **"Pegar outra":** botão de 120×32 em (136,140), raio 8, `control` com borda `border`, texto Geist Medium 13 `text` centrado (o secundário pequeno da ficha 00, com 120 de largura).
- **Três linhas de formato:** 600×44 em x 20 e y 188, 236 e 284 (passo 48), raio 12, `control`, sem borda. Rótulo (HEX, RGB, HSL) em Geist Mono Medium 11 `muted`, numa caixa de 56×44 em x 16; valor em Geist Mono Medium 13 `text`, numa caixa de 360×44 em x 72; botão ícone de 32 em (560,6), com o `copy` de 16.
  - Valores do board: `#3FA9D9`, `rgb(63, 169, 217)` e `hsl(199, 68%, 55%)`.
  - Linha copiada: o `check` de 16 em `successText` em (456,14), "Copiado" em Geist Medium 13 `successText` numa caixa de 80×44 em x 476, e o botão no estado selecionado (fundo `accent`, com o `check`).
- **Histórico:** rótulo "Histórico" em Geist Medium 11 `muted`, numa caixa de 400×24 em (20,336); 12 amostras de 32×32, raio 8, borda `border` de 1, em y 364, a partir de x 20, uma a cada 40. A amostra sob o ponteiro tem a borda `knob` de 2.
- **Dica do valor:** pílula de vidro de 88×28, raio 8, 4 abaixo da amostra (y 400) e centrada nela (no board, em x 32 sob a segunda amostra), com o HEX em Geist Mono Medium 11 `text`.
- **Rodapé:** divisor em y 432; ícone `pipette` de 16 a 80% em (16,446); "Seletor de cor" em Geist Medium 11 `muted`; ações "Copiar HEX ↵" (em `text`) e "Pegar outra P" (em `muted`), com o divisor de 1×16 entre elas.
- Nota do board, palavra por palavra: "HEX/RGB/HSL copiáveis (o copiado mostra check verde por 1,5 s). Histórico guarda as 12 últimas cores; hover mostra o valor."

### Pegando a cor: a tela à vista

- **Lupa:** 112×112 em círculo (raio 56), fundo preto, traço `knob` de 2, sombra do vidro; dentro, a grade de 7×7 pixels de 16×16, sem folga; o pixel central (coluna 3, linha 3, em (48,48) da lupa) só com o traço `knob` de 2.
- **Valor sob o cursor:** pílula de vidro de 112×28, raio 14, 12 abaixo da lupa e alinhada a ela (lupa em (288,72), pílula em (288,196)); amostra redonda de 12 em (8,8) e o HEX em Geist Mono Medium 11 `text`, centrado numa caixa de 80×28 a partir de x 24.
- **Dicas:** pílula de vidro de 376×40, raio 20, centrada na largura e a 16 da base no quadro de 560×340 (em (92,284)); dentro, a partir de (16,10), com 8 entre os itens: tecla "Clique", "pegar", tecla "Setas", "mover 1 px", tecla "Esc", "cancelar"; teclas no componente Tecla, textos em Geist Medium 11 `muted`.
- O fundo e a janela do board são só cenário.
- Nota do board, palavra por palavra: "Lupa 112 com pixels de 16 (7 × 7) e o pixel central marcado; valor sob o cursor logo abaixo. Setas movem 1 px."

## Textos em inglês (decisão 0012)

| Board | Shell |
|---|---|
| Seletor de cor | Color picker |
| Pego agora · Firefox | Picked just now · Firefox |
| Pegar outra | Pick another |
| Copiado | Copied |
| Histórico | History |
| Copiar HEX · Pegar outra | Copy HEX · Pick another |
| Clique · pegar · Setas · mover 1 px · Esc · cancelar | Click · pick · Arrows · move 1 px · Esc · cancel |

## Como funciona (`F5-T08`, propostas da P-75 e da P-76, que não travam)

- **Nome da cor** (P-75): o da cor mais próxima entre as cores nomeadas do CSS (a lista pública do W3C), em inglês e com espaços, comparando no espaço Lab. A lista (139 nomes, sem os repetidos `grey`, `aqua` e `fuchsia`) está em `launcher/Colors.js`. Para o `#3FA9D9` do board dá "Deep sky blue"; o "Azul céu" de lá é só texto de exemplo.
- **Fluxo** (P-76): o chip "Color picker" abre o resultado com a cor mais recente; sem nenhuma cor guardada, vai direto para a lupa (`F5-T12`). "Pick another", pelo botão ou pela tecla P, abre a lupa. Enter copia o HEX. Esc ou o botão voltar retornam ao launcher; um segundo Esc fecha.
- **Origem:** "Picked just now" para a cor que acabei de pegar; para as do histórico, a data e a hora no formato do sistema; depois, " · " e o aplicativo em foco quando peguei, se eu souber.
- **Formatos:** HEX em maiúsculas, `rgb(63, 169, 217)` e `hsl(199, 67%, 55%)`, com inteiros arredondados. O board escreve `68%` na saturação de `#3FA9D9`, mas a conta do HSL dá 66,96% (154/230): é um deslize do texto de exemplo, e a shell mostra o valor calculado.
- **Copiar:** o botão da linha copia aquele formato; a linha mostra o `check` e "Copied" por 1,5 s e o botão fica selecionado nesse tempo.
- **Histórico:** as 12 últimas, a mais nova primeiro, sem repetir (pegar de novo uma cor leva-a para a frente), em `~/.local/state/wintermute-shell/colors.json`. Clicar numa amostra a põe como a cor mostrada. Não se mistura com a área de transferência.
- **Dica do valor:** nas amostras das pontas, a pílula não sai dos 20 de margem do launcher.
- **Teclado:** Enter copia o HEX, P pede outra cor, Esc e Backspace voltam ao launcher. As amostras do histórico e os botões de copiar são do ponteiro.
- **Arquivos:** `launcher/ColorPage.qml`, `ColorFormatRow.qml`, `ColorHistory.qml` e `Colors.js`; tokens `launcherColor*`, `fontLauncherColorName` (24) e `launcherCopiedDuration` (1500) no `Theme.qml`.

## Pegando a cor: como funciona (`F5-T12`, proposta da P-77, que não trava)

- **Tela congelada:** ao pedir a cor, o launcher some e um quadro capturado de cada monitor fica na frente de tudo, para a cor não mudar enquanto escolho. A captura é a do próprio Quickshell (`ScreencopyView`), sem ferramenta de fora. Não desenho véu nenhum por cima: a tela parece a mesma.
- **Lupa:** centrada no ponteiro, que some; mostra os 7×7 pixels em volta dele, cada um com 16, e o do meio marcado. Vale em todos os monitores: aparece naquele em que o ponteiro está.
- **Valor:** a pílula fica 12 abaixo da lupa, alinhada a ela; quando não cabe embaixo, vai 12 acima.
- **Dicas:** a pílula fica centrada na largura do monitor em que o ponteiro está, a 16 da base, como no board.
- **Setas:** andam 1 px a partir de onde a lupa está; mexer o mouse volta a seguir o ponteiro.
- **Clique:** guarda a cor (com o aplicativo que estava em foco) e reabre o launcher na página de resultado.
- **Esc:** volta para onde eu estava, sem guardar: a página de resultado, se vim dela; senão o launcher.
- **Como a lupa lê os pixels:** uma captura só do quadro congelado vai para um `Canvas` (`launcher/PixelReader.qml`), e a cada movimento leio dali os 7×7 pixels em volta do ponto. O mesmo caminho serve para a tela de verdade e para a cena de teste. Os pixels são os do quadro: num monitor com escala, a seta anda 1 pixel do quadro, não 1 ponto lógico. O que cai fora da tela fica na cor de fundo da lupa (`launcherLoupeBackdrop`, o preto do board).
- **Nas bordas laterais** a pílula do valor não sai do monitor: deixa de ficar alinhada à lupa só ali, para o HEX continuar legível.
- **Antes de capturar** espero o launcher terminar de sumir (os 180 ms da animação mais 100 ms de folga, para ele não sair no quadro). Se o quadro não chega em 2 s (sem o protocolo de captura, como no GNOME), a lupa desiste, o launcher reabre onde estava e fica um aviso no log. Esses dois tempos são limites de funcionamento, não medidas de desenho, e moram no `launcher/LoupeState.qml`.
- **Aplicativo da origem:** o da última janela que esteve em foco antes de o launcher abrir, com o nome da entrada `.desktop`; vazio se eu não souber.
- **Arquivos:** `launcher/ColorLoupe.qml` (a peça), `PixelReader.qml`, `LoupeState.qml` e `LoupeWindow.qml` (uma janela por tela, com o `ScreencopyView`); tokens `launcherLoupe*` no `Theme.qml`.
- **Na bancada** não existe captura de tela: a lupa é conferida sobre uma cena fictícia, a do board (a janela com o degradê de `#12283E` a `#3FA9D9` a `#F4A846`). A captura de verdade só se vê no Niri.

## Comportamento

- ↵ no resultado copia HEX por padrão.
- O histórico é só de cores deste seletor (não misturar com o clipboard, ficha 18), a menos que se confirme o contrário.
