# 16 · Seletor de emoji

**Nova?** **sim** (dentro do launcher, ficha 14)  
**Onde encaixar:** `shell/launcher/`  
**Board:** `13:17120`  
**PNG:** `referencias/armitage/07-launcher-ferramentas-chiba.png`

## Medidas — launcher 640×436

- Cabeçalho com voltar + busca (“Buscar emoji”), Geist 17.
- Abas 36×36 raio 10 a cada 44 px, origem (20,64). Aba ativa: fundo `accentSubtle`, ícone `accentText`. Com busca, as abas ficam a 50% e nenhuma selecionada.
- Divisor y 108.
- Células **48×48** raio 12, passo **52**, origem x 36. Emoji 28, centrado.
- Hover: `hover`. Selecionada: `accentSubtle` + `accentRing`.
- Seções: “Recentes” (11 emojis na prévia) e categoria (grade 3×11 na prévia de Rostos e pessoas).
- Rodapé 44: prévia 20 + nome 11 à esquerda; ações Copiar ↵ · Tons de pele Ctrl+T.

## Estados

1. Grade (recentes + categorias).
2. Busca por nome em **português e inglês** (prévia: “gato”).
3. Tons de pele: segurar o clique ou Ctrl+T abre uma faixa 320×56 com os 6 tons; o escolhido vira o padrão.

## Fonte

No Figma usou-se Noto Color Emoji, mas a exportação saiu **monocromática**. No sistema real os emojis devem aparecer **coloridos**. Família sugerida: Noto Color Emoji (OFL) ou a fonte colorida do sistema.

## Conferido no Figma (2026-11-18, `F5-T09`, board `13:17120`)

Li a grade (`13:17552`) e a busca (`13:17675`) pelo `get_design_context`. As coordenadas são do quadro do launcher, de 640×436, com a borda de 1 incluída.

- **Cabeçalho (0 a 56):** botão de voltar de 32 em (12,12), com o `chevron-left`; campo em (52,16), altura 24, Geist Regular 17, com o placeholder em `muted` e o cursor de 1×24 em `accentText`. Divisor `border` em y 56.
- **Abas:** seis quadros de 36×36, raio 10, em y 64 e x 20, 64, 108, 152, 196 e 240, com o ícone de 16 em (10,10): `clock`, `smile`, `leaf`, `gamepad-2`, `globe` e `hash`. A ativa tem fundo `accentSubtle` e o ícone em `accentText`; as outras, o ícone `text` a 80%. Com texto na busca, as seis ficam a 50% e nenhuma é a ativa. Divisor `border` em y 108.
- **Rótulo de seção:** Geist Medium 11 `muted`, caixa de 400×24 em x 20; o primeiro em y 116 e os seguintes 8 abaixo da última fileira (188 → 196).
- **Células:** 48×48, raio 12, 11 por fileira, de x 36 a x 556, com passo de 52 nas duas direções; a primeira fileira logo abaixo do rótulo (140; depois 220, 272 e 324 na segunda seção). Emoji de 28 centrado. Hover com o fundo `hover`; selecionada com `accentSubtle` e borda `accentRing` de 1.
- **Rodapé (392 a 436):** divisor `border` em y 392; a prévia do emoji em 20, centrada numa caixa de 32×44 em x 12; o nome em Geist Medium 11 `text`, numa caixa de 220×44 em x 48; as ações à direita, terminando em x 624.
- **Busca:** o primeiro rótulo é "Resultados para “gato” (6)" e o segundo, "Relacionados".
- O board escreve os emojis com a "Noto Emoji", que é a versão de traço; na shell é a Noto Color Emoji.

## Como funciona (`F5-T09`, P-14 e proposta da P-79)

A P-14 (2026-11-18) escolheu o inventário e a fonte. O que o board não decide é a minha proposta da P-79, que não trava.

- **Inventário:** o Emoji 17.0 do Unicode com os nomes e as palavras-chave do CLDR 48, em inglês e em português. São 1.914 emojis: os `fully-qualified`, sem o grupo de componentes e sem as variações de tom de pele. `launcher/emoji/build.py` gera o `launcher/emoji/emoji.json` (cerca de 305 KB) a partir das fontes oficiais, que não entram no repositório; o cabeçalho do script diz de onde elas vêm. A licença do Unicode acompanha os dados (`launcher/emoji/LICENSE-unicode.txt`). O arquivo só é lido quando a página abre pela primeira vez.
- **Fonte:** Noto Color Emoji (token `emojiFontFamily`), instalada pela F10. A versão instalada nesta máquina tem desenho para os 1.914.
- **Seções e abas:** a grade é uma lista só, que rola entre y 109 e y 392, com 20 de folga depois da última fileira. As seções, na ordem das abas: "Recent" (aba `clock`); "Smileys & emotion" e "People & body" (`smile`); "Animals & nature" e "Food & drink" (`leaf`); "Activities" e "Objects" (`gamepad-2`); "Travel & places" e "Flags" (`globe`); "Symbols" (`hash`). São os nove grupos do Unicode; o board só tem seis abas, então cada aba leva à primeira seção dela. A aba ativa é a da seção que está no topo. Clicar numa aba rola até a seção e seleciona a primeira célula dela; Tab e Shift+Tab fazem o mesmo com a aba seguinte e a anterior. O hover da aba, que não tem desenho, usa o fundo `hover` das células.
- **Recentes:** os últimos 11 emojis que copiei (uma fileira, como no board), o mais novo primeiro, sem repetir, em `$XDG_STATE_HOME/wintermute-shell/emoji-recents.json`. Sem recentes, a seção não aparece, a aba `clock` fica a 50% e não responde, e a lista começa em "Smileys & emotion".
- **Seleção e prévia:** há sempre uma célula selecionada, a primeira ao abrir e a cada mudança da busca. ← e → andam uma célula e passam para a fileira vizinha nas pontas; ↑ e ↓ andam uma fileira e mantêm a coluna, atravessando as seções; a lista rola junto. O rodapé mostra o emoji sob o ponteiro e, sem ponteiro, o selecionado, com o nome em inglês (decisão 0012) e a primeira letra maiúscula. No board a primeira célula aparece só com o fundo de hover; na shell ela é a selecionada.
- **Copiar:** Enter copia o selecionado e o clique copia o clicado, com o `wl-copy`; o emoji entra nos recentes e o launcher fecha. O rodapé tem só `Copy ↵`.
- **Busca:** em português e em inglês, sem diferença de maiúsculas nem de acentos, e só no começo de palavra (com trecho no meio da palavra, "cat" traria o abacate, por causa de "avocado"). "Results for “texto” (N)" traz os que casam no nome, primeiro os que começam pelo texto; "Related" traz os que só casam nas palavras-chave. Seção vazia não aparece. Sem resultado nenhum, o bloco "Nothing found" do launcher ocupa o lugar da grade, em y 132: os mesmos 24 que ele tem do divisor do cabeçalho no launcher (80 − 56), contados do divisor das abas.
- **Sair:** Esc, Backspace com o campo vazio e o botão de voltar retornam ao launcher.
- **Altura:** sempre 436, como no board.
- **Tons de pele:** ficam de fora na primeira versão (P-14). Não há Ctrl+T nem faixa de tons, e os emojis de pessoa aparecem no amarelo padrão.

## Textos em inglês (decisão 0012)

| Board | Shell |
|---|---|
| Buscar emoji | Search emoji |
| Recentes · Rostos e pessoas | Recent · Smileys & emotion (e os outros grupos, com o nome do Unicode) |
| Resultados para “gato” (6) · Relacionados | Results for “gato” (12) · Related |
| Copiar · Tons de pele | Copy (os tons de pele ficam de fora) |
| Mão acenando | Waving hand |

## A CONFIRMAR

- ~~Lista completa de categorias e o inventário de emojis.~~ Respondida na P-14 (2026-11-18): o inventário do Unicode com os nomes do CLDR. Está em "Como funciona".
- ~~Família no CachyOS.~~ Respondida na P-14: Noto Color Emoji, instalada pela F10 (`noto-fonts-emoji`).
