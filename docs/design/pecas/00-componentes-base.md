# 00 · Componentes base e vidro

**Nova?** não (refino dos primitivos da Pond)  
**Boards:** biblioteca `13:11217` · base `13:11463`  
**PNG:** `referencias/armitage/01-biblioteca-componentes.png`, `02-componentes-base.png`  
**QML da Pond:** `ActionButton.qml`, `IconButton.qml`, `Toggle.qml`, `Slider.qml`, `Field.qml`, `Card.qml`, `PanelBackground.qml`, `PanelBorder.qml`, `GradientFill.qml`, `Shadow.qml`, `PanelCloseButton.qml`, `HoverAnimation.qml`, `wifi/CheckBox.qml`, `settings/Field.qml` (spec §3.19, §2.3)

Os componentes são reutilizáveis. Todas as peças das fases seguintes instanciam estes. Grade de 4 px. Ícones Lucide 16 (botão 32) ou 20 (botão 40), no centro geométrico: padding = (tamanho − ícone) / 2.

## Vidro

Fonte: `tokens.json` → `glass` e `armitage-shell/figma/prelude2.js` (`GLASSF`, `RIM`, `GFX`, `glow`, `glass`).

- Degradê vertical: `#0D0E11` 94% (topo) → `#16171A` 92% (pos 0,55) → `#2A2C31` 92% (base).
- Borda (rim) 1 px inside: branco 20% em cima → 6% no meio → 16% embaixo.
- Brilho interno: inner shadow x 0, y 1, blur 0, branco 8%.
- Brilho do acento na base: elipse na cor `accent` a 10% de opacidade, layer blur 40, largura 120% do cartão, altura = min(50% da altura, 80), centrada na borda de baixo (`x = −10% da largura`, `y = h − gh/2`). Efetivo sobre o texto ≤ 8%.
- Blur de fundo 40 (estimativa; no niri é background-effect).
- Sombras: `0,2 blur 6 α 0,30` + `0,12 blur 32 α 0,45`. Substitui as 5 camadas de `PanelStyle.qml`.
- Hover do **cartão de vidro**: soma `cardHover` (branco 4%, `#FFFFFF0A`).
- Hover de **controle** (botão, linha): `hover` (branco 6%, `#FFFFFF0F`).
- Pressionado: `pressed` (branco 10%).
- Raios de superfície: cartão 16, painel 16, pop-up 20, modal 32, launcher 24.

Tipos de amostra na biblioteca: Cartão 156×64 r16 · Painel 316×160 r16 · Pop-up 280×120 r20 · Modal 580×200 r32.

## Botão ícone

- Tamanhos: 32 (raio 10, ícone 16) e 40 (raio 12, ícone 20).
- Estados: Repouso (sem fundo) · Hover (`hover`) · Pressionado (`pressed`) · Selecionado (fundo `accent`, ícone `onAccent`) · Desativado (opacidade 0,4).

## Botão fechar (pendurado)

- 40×40, raio 12, ícone `x` 20 no centro (10,10).
- Superfície de vidro + rim no repouso; hover = fundo `accent`, ícone `onAccent`.
- Nos painéis fica em `(296, folga − 20)` sobre um cartão de 316 (`prelude2.js` `stack`).

## Botão de texto

| Tipo | Tamanho | Raio | Fundo | Texto |
|---|---|---|---|---|
| Primário | 276×48 | 24 | `accent` / hover `accentHover` | `onAccent` 15 Medium, centro |
| Secundário | 146×40 | 10 | `control` + borda `border` / hover `pressed` | `text` 13 |
| Perigo | 146×40 | 10 | igual secundário | `dangerText` 13 |

Desativado: opacidade 0,4.

Há também `smallBtn` nas fichas de painel: largura variável, altura padrão 32 raio 8, ou 40 raio 10 quando a ficha pede.

## Chave (toggle)

- 54×28, raio 14. Botão 22×22, y 3; desligada em x 3, ligada em x 29.
- Ligada: fundo `accent` (hover `accentHover`), botão `onAccent`.
- Desligada: fundo `track` + borda `border` (hover soma `hover`), botão `muted`.
- Motion herdado: 200 ms, curva `[0.77, 0, 0.175, 1]` (`Toggle.qml:18-24`).

## Slider

- Trilho 276×12, y 10 dentro de uma caixa 276×32, raio 6, fundo `track`.
- Preenchimento `accent`, raio 5.
- Alça 26 (repouso/hover) ou 20 (arrastando), `knob`; no hover, anel `accentRing` 4 px outside; arrastando = `accentHover`.
- Bolha de valor no hover: 28×22, raio 6, fundo `knob`, texto Geist Mono 11 `onAccent`, acima da alça (y −28).
- Mudo: trilho só com borda `borderStrong`, preenchimento 2 px de altura em `muted`, ícone `volume-x` 16 na alça.

## Campo

- 276×44, raio 12. Fundo `control` (hover `pressed`).
- Borda `border` 1 px; foco ou erro: 1,5 px `accent` ou `dangerText`.
- Texto 13, padding x 16; vazio/foco usa `muted`, preenchido usa `text`.
- Cursor de foco: 2×20 raio 1, `accent`, em (16,12).
- Senha / erro: botão olho 28×28 raio 8 em (240,8), ícone `eye` 16.

## Caixa, rádio, seletor

- Caixa 20×20 raio 6; desmarcada `control` + borda `borderStrong` 1,5; marcada fundo `accent` + check 16 `onAccent`.
- Rádio 16×16; marcado fundo `accent` + miolo 6×6 `onAccent` em (5,5).
- Seletor segmentado 168×40 raio 12, borda `border`. Marcador 80×32 raio 8 em x 4 ou 84, y 4, fundo `accentSubtle`. Opção ativa `text`, inativa `muted`.

## Linhas

- Lista (painéis): 300×44 raio 12. Ícone 20 em (12,12); título em x 40; detalhe 11 à direita; ícone final 16 em (272,14). Estados: vazio · `hover` · `pressed` · selecionada `accentSubtle` (detalhe em `accentText`).
- Ajuste: 520×52 raio 12, fundo `control` (hover `pressed`). Título Geist 15 Regular. Valor 13 `muted` à direita. Tipo Chave (toggle em x 446, y 12), Valor, ou Seta (`chevron-right` 16 em 484,18).

## Organizador (peças soltas)

Ver ficha `02-organizador.md`. Resumo na biblioteca:

- Pílula 14×20 raio 7. Repouso/hover: fundo `raised` + borda `borderStrong`; ativa: `accent` + número `onAccent`; arrastando: `accentHover` + 3 pontos. Número Geist Mono 11.
- Janela: 40 px (aberta) ou 32 px (recolhida e **Recolhida focada**). Ícone 16 no centro. Foco/levantada: traço `accent` 1,5. Recolhida focada = 32 px + anel `accent` (componente `13:11395`).
- Botão + : 40×40, traço tracejado `[4,4]` `borderStrong`; hover preenche `pressed`.
- Alvo de soltar: 40×40, `accentSubtle` + `accentRing`.
- Ponto vazio: ponto 4×4 `dot` no centro de 40×40.
- Indicador de agente 16: Trabalhando `hourglass` `accentText` · Atenção `circle-alert` `attentionText` · Não lido `sprout` `warning` · Lido `circle-check` `successText`.

## Chip, etiqueta, tecla, bloco de app

- Chip: altura 36, padding 12/14, espaço 8, raio 10, ícone 16 + rótulo 13. Repouso `control`+`border`; hover `pressed`; selecionado `accentSubtle`+`accentRing`.
- Etiqueta: altura 20, padding 8, raio 10, texto 11. Tipos: Acento (`accentSubtle`/`accentText`), Neutra (`control`/`muted`), Sucesso / Perigo (texto `successText` / `dangerText`).
- Tecla: altura 20, padding horizontal 6, raio 6, Geist Mono 11 `muted`, fundo `control` + `border`.
- Bloco de app: 28 raio 8 ícone 16, ou 48 raio 14 ícone 20. Foco: traço `accentRing` 1,5.

## Tipografia (deste board)

- Corpo 13 Medium Geist; rótulo 15; legenda 11; títulos de seção no board 20 Serif (não entram na shell).
- Letter-spacing 0.

## A CONFIRMAR

- Valor exato do blur no niri (`Theme.glassBlur` 40 é estimativa do Figma).
- Nome real dos cortes da família Geist no sistema (Medium / SemiBold / Regular). Se o pacote variable só expuser outros nomes, pergunte antes de substituir.
