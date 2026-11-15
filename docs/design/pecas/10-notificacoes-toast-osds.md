# 10 · Notificações, toast e OSDs

**Nova?** não (refino)  
**Board:** `13:14610`  
**PNG:** `referencias/armitage/05-popups-cartoes-osds-chiba.png`  
**QML da Pond:** `notifications/CenterWindow.qml`, `Card.qml`, `ToastWindow.qml`, `SidebarCard.qml`, `CloseButton.qml`, `Style.qml`, `State.qml` (spec §3.6–3.8, §3.10–3.11); `KeyboardFeedback.qml`, `BrightnessFeedback.qml`, `BottomControls.qml` (OSDs, hold 1200 ms)

Motion das notificações: 180 ms.

## Central — 280 de largura, raio 16 (prévia 316 de altura com 3 itens)

- Cabeçalho altura 60: “N notificações” Geist Serif 20 em (16,16); “Limpar tudo” 13 Medium `muted` à direita (`text` no hover).
- Divisor y 60, largura total 280. Os divisores entre itens têm 16 de margem (x 16, 248 de largura) e ocupam 1 px a mais na altura do item.
- Item: padding 16; ícone 16 em (16,16); **nome do app 13 `muted` em x 40 e hora 11 `muted` à direita** (a ficha dizia 11 para os dois, mas no print o nome do app tem a altura de 13 e a hora de 11); corpo 13 Medium, line-height 16, largura 248, y 40. O nome do app vem de `appName`, e o corpo junta resumo e texto (`Elo: o mercado chega às 18h…`).
- Altura do item = 40 + linhas×16 + 16 (mais 1 px de divisor, menos no último). Até 3 linhas.
- Respiro de 22 px embaixo da lista, medido no print (60 + 73 + 89 + 72 + 22 = 316 com 3 itens).
- Hover do item: fundo `hover` raio 10 (inset 4) e botão fechar 24×24 raio 6 (`pressed`) em (largura − 40, 13). A hora recua 32 para dar lugar ao X.

## Toast (barra recolhida) — 288×88, raio 16

- Mesma anatomia de um item (ícone, app `muted`, hora, corpo), sem lista, com 288 de largura (o corpo fica com 256). Aparece quando a barra está recolhida.

## Chegando no cartão da barra — 156×156

- O cartão de notificações cresce de 48 para 156 em **300 ms** e mostra uma prévia 140×104 raio 12, fundo `control` + `border`, a partir de (8,44). Na prévia: sem ícone de app, padding 12, nome do app e hora 11 `muted` em y 12, corpo 13 Medium em y 36, altura 36 + linhas×16 + 20 (3 linhas = 104).

## OSDs

- Brilho e volume: **156×36** raio 16. Ícone 16 em (12,10) + **10** pontos 6×6 a cada 10 px, começando em x 42, y 15. Acasos acesos = `text`; apagados = `dot`.
- Teclado: **156×76** raio 12. Duas linhas (layout atual com rádio marcado, o outro `muted`). Abre com Mod+K na Pond (`KeyboardFeedback.qml`) — herdar o atalho, salvo se eu definir um bind novo.
- Ficam visíveis **1200 ms** depois do último evento.

## A CONFIRMAR

- Nada bloqueante. Se o número de níveis reais de brilho/volume não for 10, pergunte se a barra de 10 pontos deve mapear (arredondar) ou mudar o desenho.
