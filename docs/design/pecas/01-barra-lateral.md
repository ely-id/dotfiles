# 01 · Barra lateral

**Nova?** não (refino)  
**Board:** `13:12277`  
**PNG:** `referencias/armitage/03-barra-organizador-chiba.png`  
**QML da Pond:** `shell/Sidebar.qml` (spec §3.1, `Sidebar.qml:131-138`, `:141-192`, `:233-262`, `:37-67`, `:139`), `shell/Card.qml`

## Medidas

- Margem externa 10. Cartão aberto 156, recolhido 48. Espaço entre cartões 6. Raio 16.
- A janela da sidebar é transparente; só os cartões aparecem. Clique entre as pilhas atravessa para o desktop (`Sidebar.qml:116-121`).
- Pilha de cima, origem (10,10): Relógio → Organizador → Mídia → Notificações → (Instalações / OSD de teclado, quando existirem).
- Pilha de baixo, 10 px do fundo: Prévia de screenshot (fase 6) → OSD de brilho → Controles.
- Altura máxima do organizador = espaço que sobra, mínimo 64 (`Sidebar.qml:159-163`). Sem rolagem: se não couber, corta (spec §4.8).
- Recolher: botão do canto ou atalho (Manual: Super+B). `collapseProgress` em 300 ms (`Motion`). Largura 156→48 nos primeiros 56%; altura no restante (`Theme.collapseWidth` / `collapseHeight`).
- Painéis (Wi-Fi / som / Bluetooth): só um aberto. Troca espera 200 ms. Posição: `x = 10 + largura do cartão + 6`, 10 px do fundo.
- Namespace da layer: o da Pond é `pond-sidebar` — trocar para um nome Wintermute (proposta: `wintermute-sidebar`). **A CONFIRMAR o identifier** se isso afetar o niri.

## Exclusive zone

A Pond reserva `10 + 156` (aberta) ou `10 + 48` (recolhida) (`spec` §3.1). No Figma do desktop (ficha 19) as janelas começam em **x 188** (aberta) e **x 80** (recolhida), que equivale a (10+156 ou 10+48) + 10 + gap 12. Manter o `exclusiveZone` da Pond até confirmação; ver *A CONFIRMAR* em `19-desktops.md`.

## Cores e tipografia

- Cartões = vidro Armitage (não o preto 12% da Pond translúcida).
- Hover de cartão = `cardHover` (4%), 120 ms OutCubic.
- Textos: `text` / `muted` / acentos pelas fichas de cada cartão.

## Comportamento a herdar

- Teclado exclusivo só durante arraste no organizador (Esc cancela) e sob demanda com painel aberto (`Sidebar.qml:134-135`).
- IPC `sidebar toggle`.
- Fundo da layer transparente; wallpaper é layer própria.

## O que muda em relação à Pond

- Vidro, fontes, acento por variação.
- Relógio em Geist Serif 36 (era Advent Pro 39) e altura 76 (era 75) — grade de 4. Ver ficha 04.
