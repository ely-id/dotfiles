# 07 · Som

**Nova?** não (refino)  
**Board:** `13:14610`  
**PNG:** `referencias/armitage/05-popups-cartoes-osds-chiba.png`  
**QML da Pond:** `audio/Panel.qml`, `Devices.qml`, `DeviceRow.qml`, `State.qml` (spec §3.16, `PanelStyle.qml` `audioRowHeight` 40)

## Medidas

- Painel 316 × (116 + 40 por dispositivo). Nas prévias, 3 dispositivos → **236** de altura. A conta antiga, 114 + 40 por dispositivo, dava 234 e não batia com os 236 da prévia: no print a primeira linha começa em y 108 e sobram 8 embaixo, então vale 116 (2026-11-15, S07).
- Abas “Saída” / “Entrada” em Geist Serif 20, y 16: Saída em (20,16) caixa 64×32; Entrada em (92,16) caixa 96×32. Aba ativa `text`, inativa `muted`. Clique troca a lista.
- Slider 276 em (20,56), com o valor dentro da alça. Divisor em y 100 (x 20, 276 de largura). Linhas a partir de y 108.
- Linha de dispositivo: 300×**40** raio 12, x 8. Ícone 16 em (12,12), nome 13 Medium em x 40, rádio em (272,12). Hover `hover`. Ícone por tipo: alto-falante, fones ou monitor (HDMI e afins) na saída; microfone ou fones na entrada, escolhidos por `device.form-factor`, `device.icon-name` e pelo nome do dispositivo.

## Comportamento a herdar

- Dispositivo selecionado = rádio marcado. Hover no slider (aba Entrada na prévia) mostra a bolha de valor (ficha 00).
- Lista de sinks/sources do PipeWire / o que a Pond já usa (`audio/State.qml`).
