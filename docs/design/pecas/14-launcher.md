# 14 · Launcher

**Nova?** **sim** — a Pond não tem launcher próprio; o “+” abria o Vicinae (`PlusButton.qml`, spec §4.8).  
**Onde encaixar:** pasta nova `shell/launcher/` (janela, busca, resultados, cálculo). Abrir a partir de `minimap/PlusButton.qml`, de um atalho (Manual: Super+Espaço) e, se fizer sentido, de `Shortcuts.qml` / `config/niri/cfg/keybinds.kdl`.  
**Board:** `13:17120`  
**PNG:** `referencias/armitage/07-launcher-ferramentas-chiba.png`

Inspiração visual: Raycast, simples. Vidro Armitage, sempre escuro.

## Medidas comuns

- Largura **640**, raio **24**.
- Cabeçalho de busca altura **56**: ícone 20 em (18,18) (ou botão voltar 32 em (12,12) nas subpáginas); texto Geist Regular **17**, line-height 24, em x 52, y 16; cursor 1×24 `accentText`.
- Divisor y 56, largura 640.
- Seção: rótulo 11 `muted` em (20, y), altura 24.
- Resultado: linha 624×44 raio 12, x 8. Tile de app 28 raio 8 em (8,8). Título 13 Medium + detalhe 13 Regular (na selecionada o detalhe usa `text`, senão `muted`). Tipo 11 à direita. Selecionada: `accentSubtle` + tecla ↵.
- Rodapé **44**: ícone 16 + nome da ferramenta 11 `muted` à esquerda; ações (rótulo 11 + teclas) à direita, separadas por divisor 1×16.
- Placeholder da busca: `muted`. Sugestão fantasma (completar palavra): `muted` a 70%; Tab aceita.
- Tag de contexto (“No workspace 3”): altura 24 raio 12, `accentSubtle`+`accentRing`, texto 11 `accentText`, à direita do cabeçalho.

## Estados (aceite)

1. **Vazio** — altura 352. Recentes (3 apps) + seção Ferramentas com chips: Seletor de cor, Emoji, Captura de tela, Área de transf. Rodapé: Abrir ↵ · Ações Ctrl+K.
2. **Aberto pelo “+”** — o mesmo vazio, com a tag “No workspace N”. O app escolhido abre **nesse** workspace.
3. **Digitando** — altura 260. Fantasma completa a palavra. “Melhor resultado” no topo. Atualiza a cada tecla.
4. **Resultados agrupados** — altura 496. Grupos fixos nesta ordem: Aplicativos, Arquivos, Ajustes, Comandos. ↑↓ navegam, ↵ abre. Comandos perigosos (Desligar) usam ícone `dangerText`.
5. **Cálculo** — altura 360. Ícone `calculator` no cabeçalho. Cartão 624×128 raio 16: expressão Serif 28 `muted` | círculo “igual” | resultado Serif 40. Vírgula decimal **pt-BR**. ↵ copia o resultado; ações Copiar / Colar (Ctrl+↵). Também “Em hexadecimal”.
6. **Sem resultado** — altura 332. Ícone de busca vazia 48, título 15 centrado, dica `muted`, ações “Buscar na web” e “Buscar nos arquivos”.

## Comportamento

- Não reabrir o Vicinae.
- Esc fecha.
- Véu do desktop atrás: preto 20% (ficha 19).
- Posição no desktop de 1440×900 da prévia: launcher em (400, 160) — “terço de cima, centrado”. Em monitores reais, centre horizontalmente e ancore nessa proporção vertical; se a regra exata de multi-monitor faltar, **pergunte**.

## Conferido no Figma (2026-11-17, `F5-T01`, board `13:17120`)

Li os seis estados pelo `get_design_context`: vazio `13:17130`, aberto pelo "+" `13:17179`, digitando `13:17230`, resultados agrupados `13:17275`, cálculo `13:17343` e sem resultado `13:17387`. As coordenadas abaixo são do quadro do launcher (640 de largura, borda de 1 incluída).

- **Superfície:** 640 de largura, raio 24, o vidro da ficha 00 no tipo launcher (degradê #0D0E11 94% → #16171A 92% aos 55% → #2A2C31 92%, borda branca 20%, sombras 0 12 32 preto 45% e 0 2 6 preto 30%, brilho interno de 1 px branco 8%). O brilho do acento é uma elipse de 768×80 em (−64, altura − 40), colada ao rodapé. Só a altura muda entre os estados.
- **Cabeçalho (0 a 56):** ícone `search` de 20 em (18,18); texto e cursor em (52,16), altura 24: Geist Regular 17 com linha de 24, `text` quando digitado e `muted` no placeholder; cursor de 1×24 em `accentText`, com 1 de folga do texto. A sugestão fantasma vem depois do cursor, em `muted` a 70%. Divisor `border` de 640×1 em y 56.
- **Rótulo de seção:** caixa de 400×24 em x 20, Geist Medium 11 `muted`, centrado na vertical. O primeiro em y 64; os seguintes, 8 abaixo da última linha do grupo anterior (176 → 184, 296 → 304, 372 → 380).
- **Linha de resultado:** 624×44 em x 8, raio 12, a primeira logo abaixo do rótulo (y 88), uma a cada 44. Fundo: nenhum no repouso, `hover` (branco 6%) sob o ponteiro, `accentSubtle` na selecionada.
  - Bloco de 28×28, raio 8, `control`, em (8,8), com o ícone de 16 em (6,6).
  - Título Geist Medium 13 `text` e detalhe Geist Regular 13, lado a lado em (48,12), linha de 20, com 8 entre eles. O detalhe é `text` na selecionada e `muted` nas outras.
  - Tipo: Geist Medium 11, alinhado à direita numa caixa de 140×44 que termina em x 576; `text` na selecionada e `muted` nas outras.
  - Tecla ↵ (componente Tecla da ficha 00) em (584,12), só na selecionada.
  - Comando perigoso ("Desligar agora"): o ícone do bloco em `dangerText`; o bloco continua `control`.
- **Rodapé (44):** divisor `border` de 640×1; ícone do modo de 16 a 80% em (16, divisor + 14); nome do modo Geist Medium 11 `muted` numa caixa de 240×44 em x 40; ações numa faixa de 344×20 em (280, divisor + 12), alinhadas à direita (terminam em x 624), com 8 entre os itens: texto Geist Medium 11 (`text` na ação principal, `muted` na segunda), teclas e um divisor `border` de 1×16 entre as duas ações.
- **Folga antes do rodapé:** o board se contradiz. Em "Resultados agrupados" e "Sem resultado" a última linha termina 4 px antes do divisor; em "Digitando" e "Cálculo" ela passa 4 px por baixo dele. Implemento 4 px de folga sempre (proposta da P-68, que não trava): "Digitando" com três linhas fica com 268, e não 260, e "Cálculo" com 368, e não 360.
- **Vazio (352):** "Recentes" em y 64, três linhas (88, 132, 176); "Ferramentas" em y 228; quatro chips (componente Chip da ficha 00: altura 36, raio 10, ícone 16 e rótulo Geist Medium 13) em y 256, a partir de x 20, com 8 entre eles; divisor do rodapé em 308, 16 abaixo dos chips. Ícones dos chips: `pipette`, `smile`, `scan` e `clipboard`.
- **Aberto pelo "+" (352):** o vazio com a etiqueta de contexto de 24 de altura, raio 12, `accentSubtle` com borda `accentRing` de 1 e texto Geist Medium 11 `accentText` centrado, em y 16, terminando em x 620 (112 de largura com "No workspace 3").
- **Digitando (260 no board):** "ter" + cursor + "minal" fantasma; seção "Melhor resultado" com três linhas de tipos diferentes (Aplicativo, Ajuste, Arquivo).
- **Resultados agrupados (496):** seções Aplicativos (y 64), Arquivos (184), Ajustes (304) e Comandos (380); divisor do rodapé em 452.
- **Cálculo (360 no board):** ícone `calculator` no cabeçalho e no rodapé; seção "Calculadora"; cartão de 624×128 em (8,88), raio 16, `cardHover` com borda `border`; dentro dele, a expressão em Geist Serif 28 `muted` numa caixa de 260×48 em (24,28) e a legenda "Expressão" (Geist Medium 11 `muted`) em (24,80), caixa de 260×20; o círculo "igual" de 32, `control`, em (296,36), com o `equal` de 16; o resultado em Geist Serif 40 `text` em (340,28) e a legenda "Resultado" em (340,80); tudo centrado nas caixas. Linhas "Copiar resultado" (com o valor no detalhe) e "Em hexadecimal" (`0x1CC`) em y 232 e 276, 16 abaixo do cartão, tipo "Ação". A busca mostra a expressão crua (`128*3,5+12`) e o cartão a mostra formatada (`128 × 3,5 + 12`). Rodapé: "Calculadora", "Copiar ↵" e "Colar Ctrl ↵".
- **Sem resultado (332):** círculo de 48, `control`, em (296,80), com o `search-x` de 20; título Geist Medium 15 `text` centrado numa caixa de 640×24 em y 136 ("Nada encontrado para “xyzzy”", com aspas curvas); dica Geist Regular 13 `muted` centrada numa caixa de 640×20 em y 160; duas linhas de ação em y 196 e 240, sem rótulo de seção, com a busca entre aspas no detalhe e tipo "Ação"; divisor do rodapé em 288.
- As notas do board, palavra por palavra: "Mesmo launcher, com o contexto “No workspace 3”: o app escolhido abre nesse workspace (substitui o Vicinae)."; "Sugestão fantasma completa a palavra (Tab aceita). Resultados atualizam a cada tecla."; "Grupos fixos: Aplicativos, Arquivos, Ajustes, Comandos. ↑↓ navegam, ↵ abre. Comandos perigosos com ícone em tom de perigo."; "Expressões viram resultado na hora; ↵ copia. Vírgula decimal (pt-BR)."; "Sugere buscar na web ou nos arquivos."

## Cálculo: como funciona (`F5-T03`, propostas da P-70 e da P-71)

- **Quando a busca vira cálculo:** quando o texto inteiro é uma expressão com pelo menos uma operação entre dois valores. Um número sozinho (`42`, `-5`) não é; expressão incompleta (`2+`), divisão por zero e texto comum também não, e a busca segue normal. Enquanto é cálculo, o launcher inteiro é o cálculo: nenhum outro resultado aparece, e não há sugestão fantasma.
- **Operações:** `+`, `-`, `*`, `/` e parênteses, com o sinal na frente de um valor (`2*-3`). Também aceito `×`, `÷` e `−`, os símbolos que o cartão mostra. A análise é minha (`launcher/Calculator.js`), sem `eval`: o texto vem do teclado e nunca vira código.
- **Números:** a expressão aceita vírgula e ponto como separador decimal, sem separador de milhar. O resultado sai com o separador do locale do sistema (`Qt.locale()`: ponto nesta máquina, pela decisão 0012; a ficha e o board dizem vírgula pt-BR, e isso é a P-70), com até 10 casas decimais, sem zeros no fim. Resultado de módulo a partir de 10²¹ não vira cálculo.
- **Cartão:** a expressão aparece formatada, com um espaço de cada lado do operador e `×`, `÷` e `−` no lugar de `*`, `/` e `-`; o que não cabe na caixa de 260 é cortado com reticências, e o valor inteiro fica na linha "Copy result".
- **Linhas de ação:** "Copy result" (a selecionada ao entrar no modo) e, só quando o resultado é inteiro e não negativo, "In hexadecimal" (`0x1CC`). Enter ou clique copia o texto da linha (o resultado como aparece, ou o hexadecimal) e fecha o launcher. A cópia é o `wl-copy`, com o texto como argumento.
- **Altura:** 368 com as duas linhas (o board tem 360: P-68) e 324 só com "Copy result".
- **Rodapé:** ícone `calculator`, "Calculator" e uma ação só, "Copy ↵". O "Colar Ctrl ↵" do board ficou de fora: escrever na janela que estava em foco pede uma ferramenta que a shell não traz (P-71).
- **Tokens:** `fontLauncherExpression` (28) e `fontLauncherResult` (40), em Geist Serif, e os `launcherCalc*` do `Theme.qml`, com o nó do Figma no comentário.

## Vazio e sem resultado: como funcionam (`F5-T04`, proposta da P-72)

- **Qual estado aparece:** uma expressão vira cálculo; com a busca vazia (ou só com espaços), o vazio; com texto que o serviço não acha em seção nenhuma, o sem resultado; no resto, a lista.
- **Vazio:** "Recent" com as linhas que o serviço entrega (sem recentes, a seção não aparece) e "Tools" com os quatro chips. O rótulo "Tools" segue a regra dos rótulos (8 abaixo da última linha, ou em y 64 sem recentes); os chips ficam 4 abaixo dele e o divisor do rodapé 16 abaixo dos chips. Com três recentes dá os 352 do board; sem recentes, 188 (chips em y 92, divisor em 144).
- **Chips pelo teclado** (P-72, que não trava): ↓ depois da última linha de "Recent", ou direto quando não há recentes, entra no primeiro chip; ← e → andam entre os chips e param nas pontas; ↑ volta para a linha de onde entrei; Enter abre a ferramenta. O chip com o foco usa o estado selecionado do componente Chip (`accentSubtle` com `accentRing`), e enquanto ele tem o foco nenhuma linha fica selecionada. Com texto na busca, ← e → são do campo de texto. Digitar tira o foco do chip.
- **O que os chips abrem:** nada ainda. O seletor de cor é a `F5-T08`, o emoji a `F5-T09`, e a captura e a área de transferência são da F6. Até lá o clique só fica registrado no log, e o launcher continua aberto.
- **Sem resultado:** o círculo, o título com a busca entre aspas curvas (cortado com reticências numa caixa de 600, 20 de cada lado) e a dica. As duas linhas de ação vêm do serviço, 16 abaixo da dica, sem rótulo, com 4 de folga até o rodapé (332, como no board). **O serviço de verdade ainda não as oferece**, porque o que elas fazem é a P-73: nesse caso o divisor do rodapé fica 16 abaixo da dica, em 196, e o launcher tem 240. A conta é a mesma folga de 16 que o board deixa entre os chips e o rodapé.
- Enquanto a `F5-T02` não trouxer a fonte de resultados, o launcher de verdade mostra só "Tools" com a busca vazia e "Nothing found" para qualquer texto que não seja cálculo.

## Textos em inglês (decisão 0012)

A ficha e o board estão em português; a shell mostra o equivalente em inglês. Escolhi assim:

| Board | Shell |
|---|---|
| Buscar apps, arquivos e comandos | Search apps, files and commands |
| Recentes · Ferramentas · Melhor resultado | Recent · Tools · Best match |
| Aplicativos · Arquivos · Ajustes · Comandos | Apps · Files · Settings · Commands |
| Aplicativo · Arquivo · Ajuste · Comando · Ação | App · File · Setting · Command · Action |
| Seletor de cor · Emoji · Captura de tela · Área de transf. | Color picker · Emoji · Screenshot · Clipboard |
| Launcher · Abrir · Ações | Launcher · Open · Actions |
| Calculadora · Copiar · Colar · Expressão · Resultado | Calculator · Copy · Paste · Expression · Result |
| Copiar resultado · Em hexadecimal | Copy result · In hexadecimal |
| No workspace 3 | On workspace 3 |
| Nada encontrado para “xyzzy” | Nothing found for “xyzzy” |
| Confira a digitação ou tente outra busca. | Check the spelling or try another search. |
| Buscar na web · Buscar nos arquivos | Search the web · Search files |

## Escolhas minhas, onde a ficha e o Figma não decidem

- **Atalho:** a ficha fala em Super+Espaço; pela P-11 (2026-11-15) o launcher é o Super+E, e o Super+Espaço troca o layout do teclado.
- **Número do cálculo:** a ficha e o board dizem vírgula decimal pt-BR; a decisão 0012, que é minha e mais nova, diz que datas e números seguem o locale do sistema. Vale a decisão (P-70, que não trava).
- **Monitor, animação e clique fora** (P-69, que não trava; padrão dos Ajustes): pelo atalho o launcher abre no monitor em foco e pelo "+" no monitor daquele organizador; fica centrado na largura, com o topo a 160/900 da altura da tela, arredondado para pixel inteiro; aparece e some com a opacidade e a escala de 0,96 a 1 em 180 ms (`settingsCloseDuration`), como os modais dos Ajustes; clicar no véu fecha, como Esc.
- **Véu:** preto a 20% na tela inteira (ficha 19), token `launcherScrim`.
- **Hover e seleção** são coisas separadas, como o board desenha em "Resultados agrupados": o ponteiro dá o fundo `hover`, as setas movem a selecionada (`accentSubtle`), e o clique abre a linha clicada.
- Passando da altura que cabe na tela, a lista rola entre o cabeçalho e o rodapé, que ficam fixos.

## A CONFIRMAR

- Fontes da busca (apps, arquivos, ajustes, comandos): o Figma não escolhe o backend. Sugestão: desktop entries + local files + páginas dos Ajustes + sessão (desligar etc.). Confirme antes de amarrar um indexador pesado.
- Ctrl+K (“Ações”) aparece no rodapé, mas o menu de ações não tem board próprio. **A CONFIRMAR NO FIGMA (node 13:17120)** o conteúdo desse menu, ou implemente um menu mínimo e pergunte.
