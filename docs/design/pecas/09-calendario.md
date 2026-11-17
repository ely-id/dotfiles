# 09 · Calendário

**Nova?** não (refino de grade)  
**Board:** `13:14610`  
**PNG:** `referencias/armitage/05-popups-cartoes-osds-chiba.png`  
**QML da Pond:** `calendar/Window.qml`, `calendar/Card.qml` (spec §3.4); abre pelo cartão do relógio (`Clock.qml`)

## Medidas — 264×296, raio 16

- Título “Novembro de 2026” (mês corrente) em (16,16) caixa 160×24, 13 Medium (medi no print: a altura das letras é de 13).
- Três botões 24×24 raio 6 em y 16, x 176 / 204 / 232: voltar para hoje (`rotate-ccw`), mês anterior (`chevron-up`), mês seguinte (`chevron-down`), com ícone de 16. Os três ficam sempre visíveis, como na prévia; a origem escondia o de voltar para hoje no mês corrente. Hover `hover`.
- Cabeçalho da semana: **segunda a domingo** (`S T Q Q S S D`), 11 `muted`, células 32 de largura a cada **36**, origem (8,48).
- Células do dia: **32×32** raio 8, passo 36 (a Pond usava 33,14 — fora da grade; este é o refino). Origem da grade (8,72). Número 13 Medium. A grade tem sempre 6 linhas, então o painel fica com 296 de altura.
- Hoje: fundo `accent`, número `onAccent`.
- Hover: fundo `pressed`.
- Dias de outro mês: `muted` a 50% de opacidade.
- Faixa da semana atual: 248×32 raio 8, fundo `hover`, atrás das células (na prévia, y 144).

## Comportamento a herdar

- Semana começa na segunda (já era a intenção; o Figma confirma).
- ~~Locale pt-BR para nomes e abreviações.~~ Desde a `F4-T16` (2026-11-17, decisão 0012) o calendário segue o locale do sistema (`Qt.locale()`): o título é o nome do mês com a primeira letra em maiúscula, um espaço e o ano ("November 2026"; em português, "Novembro 2026", sem o "de"), as iniciais do cabeçalho saem do locale (M T W T F S S; em português, S T Q Q S S D) e o leitor de tela lê a data por extenso do locale. A semana continua começando na segunda, e a grade não muda. O relógio da barra não segue o locale: o dia do chip ("fri") e o do recolhido ("FR") ficam em inglês, porque a abreviação de duas letras é desenho.
