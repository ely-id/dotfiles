# 17 · Captura de tela

**Nova?** a **UI de captura e a anotação são novas**. A Pond só tem a prévia pós-captura: `fonte/screenshot/Preview.qml`, `State.qml` (spec §3.13).  
**Onde encaixar:** evoluir `fonte/screenshot/` (não jogar a prévia fora) e uma janela de captura em tela cheia. Atalho do Manual: Print. Chip no launcher (ficha 14).  
**Board:** `13:19344` (e desktop `13:20899`)  
**PNG:** `referencias/armitage/08-screenshot-clipboard-chiba.png`, `09-desktop-sprawl-captura.png`

## Regra de ouro

**Sempre começa do zero.** Abrir a captura não restaura a área, janela ou atraso anteriores. O atraso visível na barra inicia em **0 s**. Teste obrigatório: abrir, selecionar, fechar (Esc), abrir de novo — sem retângulo residual.

## Barra de modos — 496×56 raio 16, embaixo

- Modos 88×40 raio 10: Área (`crop`), Janela (`app-window`), Tela (`monitor`). Selecionado: `accentSubtle`+`accentRing`.
- Atraso (ícone relógio + “0 s”).
- Botão “mostrar cursor” 40. Fechar 40. Divisores 1×24.

## Estado 1 — Início (modo área)

- Sem seleção. Tela escurece 30%. Mira em cruz (linhas brancas 60%) com pílula de coordenadas Geist Mono 11 (ex. `420, 236`).
- Dica: “Arraste para selecionar” · Espaço muda o modo · Esc.

## Estado 2 — Selecionando uma área

- Fora da seleção escurece **45%**. Borda `accent` 1 px, **8 alças** 8×8 raio 2 (`knob` + traço `accent`).
- Pílula de tamanho Mono 11 acima (ex. `320 × 200`).
- Ações logo abaixo da seleção, pílula 208×48 raio 14: copiar, salvar, anotar (botões 32) + “Capturar” primário 84×32.

## Estado 3 — Modo janela

- Escurece 45%. Hover destaca a janela com anel `accent` 2 px (raio 14 ao redor de uma janela de raio 12). Pílula com nome e tamanho. Clique captura só ela.

## Estado 4 — Prévia pós-captura (evoluir a da Pond)

- **156×112** raio 12, acima dos controles da barra, borda `borderStrong`, some em **6 s**. Dá para arrastar para outro app (herdar se a Pond já faz).
- Hover: véu preto 50% + 4 botões redondos 32 (copiar, salvar, anotar, fechar). Fundo do botão `#0D0E11` 70%; hover branco 20%.
- Barra recolhida: prévia **48×48** raio 12, acima dos controles.

## Aviso de salvo

- Toast 280×64 raio 16: check, “Captura salva”, caminho 11 `muted` com reticências. O caminho da prévia (`~/Imagens/Capturas/14-32.png`) é exemplo.

## Estado 5 — Anotação simples — editor 720×480 raio 24

- Ferramentas 32: lápis, marca-texto, retângulo (selecionado na prévia), seta, texto, recorte. Cinco cores: `attentionText`, `warning`, `accentText`, `successText`, `text` (amostra 16 no círculo 32; selecionada com anel `text` 2). Desfazer. “Copiar” secundário + “Salvar” primário.
- Área da captura 688×408 raio 12 abaixo da barra (y 56).

## Conferido no Figma (2026-11-19, `F6-T01`, board `13:19344`)

Li o estado "Início (modo área)" (`13:19354`) pelo `get_design_context`. O quadro do board é uma tela de 720×450; as medidas abaixo são relativas ao monitor.

- **Véu:** preto a 30% sobre a tela inteira.
- **Mira:** duas linhas de 1 px, branco a 60%, de ponta a ponta, cruzando no ponteiro.
- **Pílula de coordenadas** (`13:19373`): 24 de altura, raio 8, com o canto a (+8, +8) do ponteiro; o vidro pequeno (o degradê do vidro, borda branca a 20%); texto Geist Mono Medium 11 `text`, no formato `420, 236`. No board ela tem 72 de largura com esse texto.
- **Dica** (`13:19375`): vidro de 40 de altura e raio 20, centrado na largura, a 24 do topo; uma fila a 16 da esquerda, com 8 entre os itens: o texto em Geist Medium 11 `text`, a tecla, o texto em `muted`, a tecla.
- **Barra de modos** (`13:19381`): vidro de 496×56, raio 16, centrado na largura, a 24 da base. Dentro dela, tudo em y 8: três modos de 88×40, raio 10, em x 8, 100 e 192 (ícone de 16 em (14,12), rótulo Geist Medium 13 em x 36), o selecionado com `accentSubtle` e borda `accentRing` e o rótulo em `text`, os outros com o rótulo em `muted`; divisor `border` de 1×24 em (292,16); o atraso, de 72×40 em x 304, com o `clock` e "0 s" em `muted`; o botão de 40 do cursor (`mouse-pointer-2`) em x 380; outro divisor em (432,16); o botão de 40 de fechar (`x`) em x 444.
- O modo janela (`13:19441`) não tem a dica: só a barra.

## Janela de captura: como funciona (`F6-T01` e `F6-T02`)

- **Uma janela por tela,** em camada de sobreposição, com o quadro congelado do monitor no fundo (uma captura só, sem o cursor, tirada quando a captura abre) e a peça por cima, no padrão da lupa do seletor de cor. O teclado é exclusivo no monitor em que o ponteiro está, e é nele que aparecem a mira, as coordenadas, a dica e a barra. Onde não há captura de tela (GNOME, tela de teste), a janela desiste em 2 s e deixa um aviso no log.
- **Abrir:** o IPC `screenshot` (`open`, `close`, `toggle`) e o chip "Screenshot" do launcher, que espera o launcher sumir antes de capturar o quadro, para ele não sair na imagem. Abrir a captura fecha o launcher, os Ajustes e a lupa, e o contrário. As binds Super+Shift+1, 2 e 3 continuam chamando a captura do Niri até a `F6-T13`.
- **Sempre do zero:** toda abertura começa no modo Area, com "mostrar o cursor" desligado, o atraso em 0 s e nenhuma seleção. Nada é guardado entre uma abertura e outra, nem em arquivo.
- **Teclas:** Espaço troca o modo em ciclo (Area, Window, Screen); Esc fecha, sempre.
- **Ponteiro:** fica invisível sobre a área de captura, onde a mira faz o papel dele, e volta ao normal sobre a dica e a barra, onde a mira e as coordenadas somem.
- **Coordenadas:** em pixels do monitor, inclusive com escala. A largura da pílula é a do texto mais 9 de cada lado: (72 − 54) / 2, com os 54 que `420, 236` mede em Geist Mono Medium 11. Perto da borda direita ou de baixo, a pílula passa para o outro lado do ponteiro.
- **Dica:** a largura é a da fila mais 16 de cada lado (283 em inglês; o board tem 360 com o texto em português).
- **Atraso:** mostra "0 s" e não responde a clique: os valores são a P-16.
- **Hover dos modos não selecionados:** sem desenho no board; usa o fundo `hover` (ajuste A-05).
- **Diferenças para o board:** a sombra da pílula de coordenadas é a do vidro padrão (no board ela é 0,6 dessa: 27% e 18% em vez de 45% e 30%), e o vidro desenha o brilho interno de 1 px, que o nó não tem. Sobre o véu escuro as duas não aparecem no print; vejo ao vivo. O rótulo "Window" mede 49 e a caixa do board tem 48, então ele fica a 4 do anel do modo selecionado, e não a 8 como "Area".

## Seleção de área: conferido no Figma e como funciona (`F6-T11`)

Li o estado "Selecionando uma área" (`13:19401`) pelo `get_design_context`. No board a seleção tem 320×200 em (200,104), numa tela de 720×450.

- **Escurecimento:** preto a 45% nos quatro lados da seleção; dentro dela, a imagem limpa. Com seleção, o véu de 30% da tela inteira, a mira, as coordenadas e a dica somem; a barra de modos continua.
- **Borda:** 1 px, `accent`, por dentro do retângulo.
- **Alças:** oito quadrados de 8×8, raio 2, `knob` com borda `accent` de 1, centrados nos quatro cantos e no meio de cada borda.
- **Pílula de tamanho** (`13:19430`): o vidro pequeno da pílula de coordenadas, com 24 de altura e raio 8, alinhada à esquerda da seleção, 8 acima dela; texto Geist Mono Medium 11 `text`, no formato `320 × 200`, em pixels do monitor. A largura é a do texto mais 14 de cada lado: (88 − 60) / 2, com os 88 do board e os 60 que `320 × 200` mede.
- **Pílula de ações** (`13:19432`): vidro de 208×48, raio 14, alinhada à direita da seleção, 8 abaixo dela. Três botões de ícone de 32 em x 8, 44 e 80 (copiar, salvar e anotar: `copy`, `save` e `pencil`) e o botão "Capture" de 84×32 em x 116, o botão de texto primário pequeno da ficha 00 (raio 8, `accent`, texto 13 em `onAccent`).

O board desenha esse estado só. O resto é composição minha (ajuste A-05), sem valor novo:

- **Arrastar** sobre a área de captura cria a seleção, em qualquer direção, presa ao monitor em que começou. Enquanto arrasto (para criar, mover ou redimensionar) aparecem o escurecimento, a borda e a pílula de tamanho; ao soltar, também as alças e a pílula de ações.
- **Pequena demais:** soltar com menos de 8 num eixo (o tamanho de uma alça) não cria seleção, e um clique sem arrastar não faz nada. O mesmo mínimo vale ao redimensionar.
- **Mover e redimensionar:** arrastar por dentro move, sem sair do monitor; as alças dos cantos mexem nos dois eixos e as do meio num só; passando do lado oposto, a seleção vira. A área que responde ao arraste de cada alça é um quadrado de 16 centrado nela (o dobro do desenho), e encolhe numa seleção pequena, para o miolo continuar movível. Apertar por fora apaga a seleção e começa outra.
- **Ponteiro:** a seta de mover por dentro, a seta de redimensionar certa sobre cada alça, a cruz por fora, e a seta normal sobre a barra e a pílula de ações.
- **Onde as pílulas caem perto das bordas:** a de tamanho, sem lugar acima, vai para dentro da seleção, a 8 do canto de cima à esquerda. A de ações, se embaixo ela sair do monitor ou encostar na barra de modos, vai para cima da seleção; se em cima também não couber, ou cobrir a pílula de tamanho, vai para dentro, a 8 do canto de baixo à direita. Na horizontal, nenhuma sai do monitor. Num monitor estreito, a pílula de ações por dentro pode cair sobre a barra de modos; ela fica por cima, clicável.
- **Teclas:** Enter vale o "Capture"; Esc fecha a captura, com ou sem seleção; Espaço troca o modo e apaga a seleção.
- **Sempre do zero:** a seleção mora no estado da captura e é apagada ao abrir e ao fechar.
- **Vários monitores:** a seleção é uma só; começar outra num monitor apaga a anterior.
- **As quatro ações** ainda não fazem nada além de avisar no log: capturar e copiar são a `F6-T13`, salvar a `F6-T03` e anotar a `F6-T14`.

## Textos em inglês (decisão 0012)

| Board | Shell |
|---|---|
| Arraste para selecionar · Espaço · muda o modo · Esc | Drag to select · Space · switches mode · Esc |
| Área · Janela · Tela | Area · Window · Screen |
| Capturar | Capture |

## A CONFIRMAR

- Pasta padrão de salvar (a prévia usa `~/Imagens/Capturas/`).
- Formato (PNG) e se o atraso tem lista de valores no Figma — a barra mostra “0 s”, mas a UI do seletor de atraso **não tem board próprio**. **A CONFIRMAR NO FIGMA (node 13:19344)** os tempos oferecidos, ou pergunte.
