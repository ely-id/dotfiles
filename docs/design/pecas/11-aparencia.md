# 11 · Aparência

**Nova?** não (os 5 temas da Pond viram as 3 variações)  
**Board:** `13:14610`  
**PNG:** `referencias/armitage/05-popups-cartoes-osds-chiba.png`  
**QML da Pond:** `settings/appearance/Panel.qml`, `ThemeButton.qml`, `Accordion.qml`, `State.qml`, `settings/Modal.qml` (spec §3.21)

## Modal — 580×456, raio 32 (palco 600×476 com o X pendurado)

- X = voltar, 40×40 em (560, 7) no palco (isto é, `w − 20`, y 7 — `lib45.js` `MODAL`).
- Título “Aparência” Geist Serif 32 em (30,20), caixa 400×44.
- Rótulo “Variação” `muted` em (30,64).
- Três discos de 88×88 raio 44, com amostra de acento 40×40 no centro e, se selecionado, check 24×24 fundo `accent` no canto. Anel `accentRing` 2 px quando selecionado; senão borda 1 `border`.
- Nomes embaixo, 13 Medium: Chiba, Freeside, Sprawl. Selecionado `text`, os outros `muted`.
  - Amostras: Chiba `#52C2F6`, Freeside `#7F89E1`, Sprawl `#F4A846`.
- Escolher um disco chama `Theme.setName(...)` e persiste em `~/.config/wintermute-shell/theme.json` (caminho confirmado em 2026-11-14).
- Accordion 520×52 raio 12, fundo `control`, x 30: “Papel de parede”, “Brilho da tela”, “Tela”. Título 15 Regular, valor `muted` à direita, chevron. Abertura 240 ms InOutCubic.

O papel de parede em si está na ficha 13 (seletor). “Brilho” e “Tela” navegam para as páginas já existentes.
