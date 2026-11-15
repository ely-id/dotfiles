# 08 · Bateria

**Nova?** não (refino)  
**Board:** `13:14610`  
**PNG:** `referencias/armitage/05-popups-cartoes-osds-chiba.png`  
**QML da Pond:** `battery/Window.qml`, `Card.qml`, `Notification.qml`, `ProfileSelector.qml`, `PowerProfileButton.qml`, `Indicator.qml`, `State.qml` (spec §3.18)

## Pop-up — 280×232, raio 20

- “Bateria” 13 `muted` em (20,16). À direita: ícone + “Carregando” `successText` (ou o estado atual).
- Percentual Geist Serif **40** em (20,40) caixa 120×48 (Pond era Gramercy 39). Estado à direita do título: ícone `zap` 16 + “Carregando” 13 Medium em `successText` (“Carregada” quando está ligada na tomada e cheia).
- “18 W” e tempo restante (`1 h 20 min para encher`) 13 `muted` alinhados à direita, em y 46 e y 67 (medidos no print). Descarregando, o tempo vira “2 h 5 min restantes” e a potência some se for zero.
- Trilho 240×20 raio 6 em (20,100), fundo `track`; carga `success` quando carregando, senão `text` / `danger` se baixa — herdar a lógica, usar tokens.
- “Perfil de energia” `muted` em (20,128).
- Três botões 76×40 raio 8 em x 20 / 102 / 184, y 156: ícone 16 centrado. Selecionado: `accentSubtle` + `accentRing`. Repouso: `control` + `border`.
- Rótulos 11 centrados em y 200, largura 76: Economia, Equilibrado, Desempenho. O selecionado usa `text` em DemiBold (no print ele aparece mais pesado); os outros `muted` em Medium.
- O botão selecionado leva `accentSubtle` com borda `accentRing` de 1 px; os outros, `control` com borda `border`. Os ícones ficam todos em branco.

Ícones nas prévias do pop-up: `leaf`, `gauge`, `rocket`. **Vale `zap` no terceiro botão**, igual à tela inicial dos Ajustes (P-07, 2026-11-15).

## Alerta de bateria baixa

- 176×40 raio 12, vidro Armitage. Só com a barra **recolhida**, no rodapé. Ícone `battery-low` 16 `dangerText` em (12,12), texto “Bateria em 9%” `dangerText` em x 36, botão fechar 24×24 r6 em (144,8). Sempre em `dangerText`: a origem mudava a cor por nível (amarelo, laranja, vermelho), mas o Figma só desenha o caso de 9% e eu mantive uma cor só, escolha minha na S07.

## A CONFIRMAR

- ~~Na tela inicial dos Ajustes (ficha 13) o terceiro perfil foi desenhado com ícone `zap`, não `rocket`. Qual dos dois fica?~~ Definido em 2026-11-15 (P-07): `zap` nos dois lugares, no pop-up da bateria e nos Ajustes.
