# 08 · Bateria

**Nova?** não (refino)  
**Board:** `13:14610`  
**PNG:** `referencias/armitage/05-popups-cartoes-osds-chiba.png`  
**QML da Pond:** `battery/Window.qml`, `Card.qml`, `Notification.qml`, `ProfileSelector.qml`, `PowerProfileButton.qml`, `Indicator.qml`, `State.qml` (spec §3.18)

## Pop-up — 280×232, raio 20

- “Bateria” 13 `muted` em (20,16). À direita: ícone + “Carregando” `successText` (ou o estado atual).
- Percentual Geist Serif **40** em (20,40) caixa 120×48 (Pond era Gramercy 39).
- “18 W” e tempo restante (`1 h 20 min para encher`) 13 `muted` alinhados à direita.
- Trilho 240×20 raio 6 em (20,100), fundo `track`; carga `success` quando carregando, senão `text` / `danger` se baixa — herdar a lógica, usar tokens.
- “Perfil de energia” `muted` em (20,128).
- Três botões 76×40 raio 8 em x 20 / 102 / 184, y 156: ícone 16 centrado. Selecionado: `accentSubtle` + `accentRing`. Repouso: `control` + `border`.
- Rótulos 11 centrados em y 200, largura 76: Economia, Equilibrado, Desempenho. O selecionado usa `text`; os outros `muted`.

Ícones nas prévias do pop-up: `leaf`, `gauge`, `rocket`.

## Alerta de bateria baixa

- 176×40 raio 12. Só com a barra **recolhida**, no rodapé. Ícone `battery-low` `dangerText`, texto “Bateria em 9%” `dangerText`, botão fechar 24×24.

## A CONFIRMAR

- Na tela inicial dos Ajustes (ficha 13) o terceiro perfil foi desenhado com ícone `zap`, não `rocket`. Qual dos dois fica? Não misture; pergunte se for implementar os dois lugares antes da resposta.
