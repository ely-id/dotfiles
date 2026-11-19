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

- **Uma janela por tela,** em camada de sobreposição, com o quadro congelado do monitor no fundo (tirado quando a captura abre; desde a `F6-T13` são dois, um sem o cursor e um com) e a peça por cima, no padrão da lupa do seletor de cor. O teclado é exclusivo no monitor em que o ponteiro está, e é nele que aparecem a mira, as coordenadas, a dica e a barra. Onde não há captura de tela (GNOME, tela de teste), a janela desiste em 2 s e deixa um aviso no log.
- **Abrir:** o IPC `screenshot` (`open`, `close`, `toggle`) e o chip "Screenshot" do launcher, que espera o launcher sumir antes de capturar o quadro, para ele não sair na imagem. Abrir a captura fecha o launcher, os Ajustes e a lupa, e o contrário. Desde a `F6-T13`, o Super+Shift+1 abre a captura da shell; o Super+Shift+2 e o 3 continuam com a captura do Niri (ver "Capturar e copiar").
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
- **As quatro ações:** capturar e copiar funcionam desde a `F6-T13` (ver "Capturar e copiar"), e anotar desde a `F6-T14` (ver "Editor de anotação"); salvar (`F6-T03`) ainda só avisa no log.

## Modo janela e modo tela: conferido no Figma e como funcionam (`F6-T12`)

Li o estado "Modo janela" (`13:19441`): o escurecimento (`13:19457`), o anel (`13:19458`) e a pílula (`13:19459`). **O modo tela não tem board:** é composição minha (ajuste A-05), com os mesmos valores.

- **Modo janela:** a tela inteira escurecida a 45%, sem mira, sem coordenadas e sem dica, com o ponteiro normal. A janela sob o ponteiro ganha o **anel** de 2 px no acento, raio 14, todo por fora dela (para a janela de 320×300 em (360,56), o anel tem 324×304 em (358,54)). Como no board, a janela destacada não fica mais clara que o resto: só o anel a marca.
- **A pílula:** o vidro pequeno das outras pílulas da captura (24 de altura, raio 8, Geist Mono Medium 11 `text`), com `Nome · 320 × 300`: o nome do aplicativo e o tamanho da janela em pixels do monitor. Fica alinhada à esquerda da janela e termina 8 acima do anel; sem lugar acima, vai para dentro, a 8 do canto de cima à esquerda; não sai do monitor, e um nome comprido é cortado com reticências para ela não passar da largura da janela. O recuo de cada lado é 13: (152 − 126) / 2, com os 152 do board e os 126 que `Firefox · 320 × 300` avança (19 caracteres em Geist Mono Medium 11). Aqui a medida é o avanço do texto, e não a largura do desenho das outras duas pílulas: com o desenho, a pílula mudaria 1 px conforme a primeira letra do nome.
- **O nome** é o `Name` da entrada `.desktop` da janela, achada pelo `appId`; sem entrada, o título da janela; sem título, o `appId`; sem nada, "Window".
- **Quais janelas:** as do workspace ativo do monitor, na foto tirada quando a captura abre, porque a imagem está congelada. Quando duas se sobrepõem, vale a de cima: as flutuantes antes das lado a lado, e, entre flutuantes, a mais nova.
- **De onde vem a posição:** do `layout` que o Niri informa de cada janela. A conta, que mora num lugar só (`screenshot/Windows.js`, `place`): posição = `tile_pos_in_workspace_view` + `window_offset_in_tile`; tamanho = `window_size`. Janela sem posição fica de fora. **Esta conta nunca rodou com janelas de verdade**: a origem da "vista do workspace" e se as janelas lado a lado trazem posição só dá para conferir na sessão do Niri. Ao abrir, a captura escreve no log quantas janelas achou e quantas têm posição.
- **Escolher:** clicar na janela destacada, ou Enter, escolhe a janela; sem janela sob o ponteiro, o clique não faz nada.
- **Modo tela:** o monitor do ponteiro fica sem escurecimento (é a imagem que vai ser capturada), com o anel de 2 no acento por dentro da borda, sem raio, e a pílula com o nome e o tamanho do monitor (`eDP-1 · 1920 × 1080`) a 8 do canto de cima à esquerda. Os outros monitores ficam escurecidos a 45%. Clicar em qualquer ponto, ou Enter, escolhe o monitor.
- **As duas escolhas** tiram a imagem desde a `F6-T13` (ver "Capturar e copiar").

## Capturar e copiar: como funciona (`F6-T13`, decisão 0017)

Nada muda no desenho. O que muda é que as escolhas passam a produzir uma imagem.

- **De onde sai a imagem:** do quadro congelado que a janela mostra, recortado em pixels do quadro (decisão 0017). A área é o retângulo da seleção; a janela é o retângulo dela, cortado no que cabe no monitor, com os cantos arredondados saindo com o que estava atrás; a tela é o quadro inteiro. O PNG tem os pixels do recorte: a seleção de 320×200 num monitor de escala 2 dá 640×400, o mesmo número que a pílula de tamanho mostra.
- **Mostrar o cursor:** a captura tira dois quadros por monitor ao abrir, um sem o cursor e um com; o botão da barra troca o que fica à mostra, e a imagem sai do que está à mostra.
- **"Capture"** (o botão e o Enter, no modo Area), a janela escolhida e o monitor escolhido: gravam o PNG, copiam para a área de transferência, entregam à prévia da barra e fecham a captura, nessa ordem.
- **O botão de copiar** da pílula de ações: grava, copia e fecha, sem a prévia.
- **Anotar** abre o editor com o recorte, desde a `F6-T14`. **Salvar** ainda só avisa no log, com a janela aberta.
- **Arquivo temporário:** `$XDG_RUNTIME_DIR/wintermute-shell/capture-….png`. Cada captura apaga o arquivo da anterior. Se gravar falhar, fica um aviso no log, a captura fecha e nada é copiado.
- **Copiar** é o `wl-copy --type image/png`, pela ação `copy-file` do `screenshot/clipboard.py`.
- **Atalhos:** o Super+Shift+1 ("Screenshot a region") abre a captura da shell. O Super+Shift+2 (tela) e o Super+Shift+3 (janela) continuam com as ações do Niri, que capturam na hora e sem interface; a imagem delas chega à prévia pelo evento do Niri. No Niri isso só vale depois de eu aplicar o `keybinds.kdl` gerado.
- **Limites conhecidos:** num monitor com escala fracionária, o PNG pode sair com 1 px a mais ou a menos; o recorte da janela herda a conta da posição, que só dá para conferir na sessão do Niri.
- **Nunca rodou de verdade:** a captura do quadro não existe fora do Niri. O recorte foi testado sobre imagens fictícias de pixels conhecidos, e a cópia com um `wl-copy` de mentira.

## Prévia na barra: conferido no Figma e como funciona (`F6-T04`)

Li os três estados da prévia: em repouso (`13:19531`), em hover (`13:19557`) e com a barra recolhida (`13:19592`). A peça é a `screenshot/Preview.qml` que veio da origem, redesenhada.

- **Repouso, barra aberta:** a miniatura de 156×112, raio 12, com a borda `borderStrong` de 1 por cima da imagem e a sombra do vidro; fica 6 acima dos controles. Sem véu em repouso.
- **Hover:** véu preto a 50% e quatro botões redondos de 32 (raio 16), em y 40 e x 8, 44, 80 e 116: copiar (`copy`), salvar (`save`), anotar (`pencil`) e fechar (`x`). Cada botão tem o fundo `#0D0E11` a 70%, a borda `borderStrong` de 1 e o ícone de 16 em `text`; sob o ponteiro, o fundo é o `text` a 20%.
- **Barra recolhida:** 48×48, raio 12, borda `borderStrong`, sem sombra, 6 acima do controle recolhido. O board não desenha o hover recolhido; compus (ajuste A-05) com o véu e um botão só, o de copiar, centrado, porque é o que cabe.
- **Some em 6 s** (`capturePreviewDuration`), e não nos 30 s da origem. Com o ponteiro em cima o tempo para, e recomeça do zero quando o ponteiro sai; uma captura nova também recomeça. Durante um arraste ele já parava.
- **Copiar:** o botão chama o `wl-copy` e mostra o `check` em `successText` por 1,5 s (`launcherCopiedDuration`), o mesmo sinal do launcher ao copiar uma cor. A etiqueta "Copy’d" roxa da origem saiu. O sinal só aparece com o ponteiro em cima, porque os botões só existem no hover.
- **Fechar** apaga a prévia. **Anotar** abre o editor com a imagem da prévia, desde a `F6-T14`. **Salvar** ainda só avisa no log (`F6-T03`).
- **O clique na miniatura recolhida** não copia mais: quem copia é o botão.
- **Arrastar** para outro aplicativo continua desligado até a `F6-T15`.
- Os botões aparecem e somem em `hoverDuration` (120 ms).
- **Diferença para o board:** o anel de 1 px de cada botão redondo se mistura com a imagem escurecida, e não com o fundo do botão, então sai um pouco mais claro que no Figma e varia com a imagem. Deixei assim; vejo ao vivo se incomoda.
- A peça lê `service` (decisão 0011), com `demo/ScreenshotService.qml` e `demo/ScreenshotPreviewSpecimen.qml`, que usam um desenho inventado.

## Editor de anotação: conferido no Figma e como funciona (`F6-T14`)

Li o editor (`13:19481`) pelo `get_design_context`. As coordenadas são do quadro de 720×480.

- **Vidro:** 720×480, raio 24, o vidro do launcher, sem o brilho do acento.
- **Ferramentas:** seis botões de ícone de 32 em y 12 e x 12, 48, 84, 120, 156 e 192: lápis (`pencil`), marca-texto (`highlighter`), retângulo (`square`), seta (`arrow-up-right`), texto (`type`) e recorte (`crop`). A selecionada tem o fundo `accent` e o ícone em `onAccent`.
- **Divisores** `border` de 1×16 em (236,20) e (436,20).
- **Cores:** cinco caixas de 32 em x 248, 284, 320, 356 e 392, cada uma com um círculo de 16 na cor: `attentionText`, `warning`, `accentText`, `successText` e `text`. A escolhida tem o anel `text` de 2 no círculo de 32.
- **Desfazer:** botão de ícone de 32 em (448,12), `undo-2`.
- **"Copy":** 88×32 em (524,12), o botão de texto secundário pequeno. **"Save":** 88×32 em (620,12), o primário pequeno.
- **Área da imagem:** 688×408 em (16,56), raio 12, com borda `border` de 1.
- **As marcas de exemplo do board:** o contorno do retângulo e a haste da seta têm 3 de espessura; o retângulo tem raio 8; a faixa do marca-texto tem 20 de espessura, a 35%, com raio 2; a haste também tem raio 2; a ponta da seta é um glifo de 20; o texto é Geist SemiBold 17.

O board desenha um estado só. O comportamento é composição minha (ajuste A-05), sem valor novo:

- **Janela:** em camada de sobreposição, no monitor da captura, centrada nos dois eixos, sobre o véu do launcher, com o teclado exclusivo. Abrir o editor fecha o launcher, os Ajustes e a captura, e o contrário.
- **Abrir:** o botão do lápis da pílula de ações da seleção grava o recorte, fecha a captura e abre o editor com ele, sem copiar nem mostrar a prévia; o botão do lápis da prévia abre o editor com a imagem dela e fecha a prévia.
- **A imagem** cabe inteira na área, sem deformar, centrada. Menor que a área, aparece no tamanho natural, que é um pixel da imagem para um pixel do monitor: num monitor com escala, a captura aparece do tamanho que tinha na tela.
- **Lápis:** traço livre de 3, pontas redondas; um clique sem arrastar vira um ponto. **Marca-texto:** faixa reta de 20, do aperto ao soltar, na cor a 35%. **Retângulo:** contorno de 3, raio 8, do canto onde apertei ao canto onde soltei. **Seta:** haste de 3 e o `chevron-right` de 20 na ponta, girado na direção dela. Arrastar menos de 4 não cria marca-texto, retângulo nem seta.
- **Texto:** um clique põe o cursor; Enter confirma, Esc cancela só o texto; clicar em outro ponto confirma e começa outro; texto vazio não vira marca.
- **Recorte:** arrasto um retângulo, com a borda e o escurecimento da seleção de área, sem as alças; Enter aplica e Esc cancela. Aplicado, a imagem passa a ser só aquele pedaço, e as marcas que ficaram fora somem com ele. Trocar de ferramenta abandona o recorte em andamento. Um recorte com menos de 8 num eixo é descartado, como na seleção de área.
- **Cor:** vale para as próximas marcas; as que já existem não mudam.
- **Desfazer** (o botão e Ctrl+Z): tira a última marca ou desfaz o último recorte, um por vez. Com um texto em andamento, cancela o texto. Sem nada para desfazer, o botão fica desativado.
- **O que eu vejo é o que sai:** as marcas ficam guardadas em pixels da imagem, e o mesmo desenho serve para a tela e para o arquivo. As espessuras valem na tela; numa imagem reduzida para caber, o traço do arquivo é proporcionalmente mais grosso (numa imagem de 1600×1000, o contorno de 3 sai com 7 px).
- **"Copy":** grava a imagem com as marcas num PNG temporário, copia, entrega à prévia da barra e fecha. Com um texto em andamento, confirma o texto antes. Se gravar falhar, o editor continua aberto.
- **"Save"** ainda só avisa no log (`F6-T03`).
- **Fechar:** Esc, quando não há texto nem recorte em andamento, fecha e descarta as marcas. Clicar no véu **não** fecha, para um clique errado não jogar o desenho fora.
- **Sempre do zero:** cada abertura começa com o lápis, a primeira cor e nenhuma marca.
- **Fora desta versão:** mover, redimensionar ou apagar uma marca já feita; refazer; escolher espessura e fonte.

## Textos em inglês (decisão 0012)

| Board | Shell |
|---|---|
| Arraste para selecionar · Espaço · muda o modo · Esc | Drag to select · Space · switches mode · Esc |
| Área · Janela · Tela | Area · Window · Screen |
| Capturar | Capture |
| Copiar · Salvar (editor) | Copy · Save |
| Olhe aqui (exemplo) | Look here |

## A CONFIRMAR

- Pasta padrão de salvar (a prévia usa `~/Imagens/Capturas/`).
- Formato (PNG) e se o atraso tem lista de valores no Figma — a barra mostra “0 s”, mas a UI do seletor de atraso **não tem board próprio**. **A CONFIRMAR NO FIGMA (node 13:19344)** os tempos oferecidos, ou pergunte.
