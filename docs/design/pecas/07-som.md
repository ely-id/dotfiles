# 07 · Som

**Nova?** não (refino)  
**Board:** `13:14610`  
**PNG:** `referencias/armitage/05-popups-cartoes-osds-chiba.png`  
**QML da Pond:** `audio/Panel.qml`, `Devices.qml`, `DeviceRow.qml`, `State.qml` (spec §3.16, `PanelStyle.qml` `audioRowHeight` 40)

## Medidas

- Painel 316 × (114 + 40 por dispositivo). Nas prévias, 3 dispositivos → **236** de altura.
- Abas “Saída” / “Entrada” em Geist Serif 20, y 16: Saída em (20,16) caixa 64×32; Entrada em (92,16) caixa 96×32. Aba ativa `text`, inativa `muted`. Clique troca a lista.
- Slider 276 em (20,56). Divisor em y 100.
- Linha de dispositivo: 300×**40** raio 12, x 8. Ícone 16 em (12,12), nome, rádio em (272,12). Hover `hover`.

## Comportamento a herdar

- Dispositivo selecionado = rádio marcado. Hover no slider (aba Entrada na prévia) mostra a bolha de valor (ficha 00).
- Lista de sinks/sources do PipeWire / o que a Pond já usa (`audio/State.qml`).
