# 07 · Som

**Nova?** não (refino)  
**Board:** `13:14610`  
**PNG:** `referencias/armitage/05-popups-cartoes-osds-chiba.png`  
**QML da Pond:** `audio/Panel.qml`, `Devices.qml`, `DeviceRow.qml`, `State.qml` (spec §3.16, `PanelStyle.qml` `audioRowHeight` 40)

## Medidas

- Painel 316 × (116 + 40 por dispositivo). Nas prévias, 3 dispositivos → **236** de altura. A conta antiga, 114 + 40 por dispositivo, dava 234 e não batia com os 236 da prévia: no print a primeira linha começa em y 108 e sobram 8 embaixo, então vale 116 (2026-11-15, S07).
- Abas em Geist Serif 20, y 16, altura 32. O Figma desenha “Saída” em (20,16) caixa 64×32 e “Entrada” em (92,16) caixa 96×32, em português. Aba ativa `text`, inativa `muted`. Clique troca a lista. Na shell as abas são "Output" e "Input" (decisão 0012), e a caixa de "Output" foi alargada (P-63, respondida em 2026-11-17: "Alarga"). Medi os textos em Geist Serif 20 Regular (`QFontMetricsF`, tinta pelo `tightBoundingRect`): "Saída" 52 px de tinta (avanço 51,39), "Output" 67 (66,89), "Entrada" 73 (72,70), "Input" 50 (49,05). Com "Saída" a folga entre o fim da tinta e a caixa de "Entrada" era 92 − (20 + 52) = 20; com "Output" na caixa de 64 caía para 5 (92 − (20 + 67)). A diferença de texto é 67 − 52 = 15. **Caixas finais na shell:** "Output" em (20,16) **79×32** (64 + 15); "Input" em (107,16) **96×32** (x = 92 + 15; a largura não muda). Folga depois: 107 − (20 + 67) = 20 px entre a tinta de "Output" e a caixa de "Input", e 8 px entre as duas caixas (107 − (20 + 79)). Os valores são fixos em `audio/Devices.qml`, sem medição em tempo de execução.
- Slider 276 em (20,56), com o valor dentro da alça. Divisor em y 100 (x 20, 276 de largura). Linhas a partir de y 108.
- Linha de dispositivo: 300×**40** raio 12, x 8. Ícone 16 em (12,12), nome 13 Medium em x 40, rádio em (272,12). Hover `hover`. Ícone por tipo: alto-falante, fones ou monitor (HDMI e afins) na saída; microfone ou fones na entrada, escolhidos por `device.form-factor`, `device.icon-name` e pelo nome do dispositivo.

## Comportamento a herdar

- Dispositivo selecionado = rádio marcado. Hover no slider (aba Entrada na prévia) mostra a bolha de valor (ficha 00).
- Lista de sinks/sources do PipeWire / o que a Pond já usa (`audio/State.qml`).
