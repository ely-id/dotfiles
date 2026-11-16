# 03 · Controles de baixo

**Nova?** não (refino)  
**Board:** `13:12277` (peças) e `13:14610` (hover que cresce para 80)  
**PNG:** `03-barra-organizador-chiba.png`, `05-popups-cartoes-osds-chiba.png`  
**QML da Pond:** `shell/BottomControls.qml` (spec §3.12)

## Aberto — 156×48

Quatro botões numa fileira, y 4, altura 40, ícone 16 no centro:

| Botão | x | largura | Cantos (TL, TR, BR, BL) | Ação |
|---|---|---|---|---|
| Wi-Fi | 4 | 38 | 12, 4, 4, 12 | abre o painel Wi-Fi (Bluetooth segue agrupado no fluxo da origem, sem 5º botão — P-06) |
| Som | 42 | 36 | 4, 4, 4, 4 | abre o painel de som |
| Ajustes | 78 | 36 | 4, 4, 4, 4 | abre os Ajustes |
| Recolher | 114 | 38 | 4, 12, 12, 4 | recolhe a barra |

Estados do botão: vazio · Hover `hover` · Selecionado fundo `accent` ícone `onAccent`.

## Recolhido — 48×168

Quatro botões 40×40 empilhados em x 4, y 4 / 44 / 84 / 124. Ícone 16 em (12,12). Cantos: topo 12,12,4,4; meio 4; base 4,4,12,12. O último ícone vira `panel-left-open`.

## Hover que cresce para 80 (aberto)

O cartão vai a 156×80 (300 ms / mediaReveal? a Pond cresce o cartão no hover — herdar o tempo de `BottomControls.qml`). Os quatro botões descem para y 36. Em cima:

- **Hover no Wi-Fi:** download e upload atuais, ícones 16 + texto 11 `muted`, divisor vertical. (Valores de exemplo nas prévias: 12 MB/s e 1,2 MB/s.)
- **Hover no Som:** slider compacto, trilho 132×8 raio 4 em (12,14), preenchimento `accent`, alça 16 `knob`. O percentual aparece em Geist Mono 11 à direita do slider, que encurta o trilho para caber (P-42, 2026-11-15: "Percentual em Geist Mono"). A largura do trilho e a cor do número são conferidas no Figma na `F4-T10`.

## Comportamento a herdar

- Só um de Wi-Fi / som / Bluetooth aberto (`Sidebar.qml:37-67`).
- OSD de volume aparece ao girar o volume (ficha 10).

## Decisões confirmadas

- **P-06 (2026-11-15, S06):** confirmado com 4 botões; o primeiro botão abre o Wi-Fi e o Bluetooth permanece agrupado como na origem, sem quinto botão.
