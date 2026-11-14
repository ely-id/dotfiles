# 09 · Calendário

**Nova?** não (refino de grade)  
**Board:** `13:14610`  
**PNG:** `referencias/armitage/05-popups-cartoes-osds-chiba.png`  
**QML da Pond:** `calendar/Window.qml`, `calendar/Card.qml` (spec §3.4); abre pelo cartão do relógio (`Clock.qml`)

## Medidas — 264×296, raio 16

- Título “Novembro de 2026” (mês corrente) em (16,16) caixa 160×24.
- Três botões 24×24 raio 6 em y 16, x 176 / 204 / 232: voltar para hoje (`rotate-ccw`), mês anterior, mês seguinte.
- Cabeçalho da semana: **segunda a domingo** (`S T Q Q S S D`), 11 `muted`, células 32 de largura a cada **36**, origem (8,48).
- Células do dia: **32×32** raio 8, passo 36 (a Pond usava 33,14 — fora da grade; este é o refino). Origem da grade (8,72).
- Hoje: fundo `accent`, número `onAccent`.
- Hover: fundo `pressed`.
- Dias de outro mês: `muted` a 50% de opacidade.
- Faixa da semana atual: 248×32 raio 8, fundo `hover`, atrás das células (na prévia, y 144).

## Comportamento a herdar

- Semana começa na segunda (já era a intenção; o Figma confirma).
- Locale pt-BR para nomes e abreviações.
