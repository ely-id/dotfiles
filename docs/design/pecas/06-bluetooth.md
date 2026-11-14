# 06 · Bluetooth

**Nova?** não (refino; páginas Próximos e Pareamento entram neste design)  
**Board:** `13:13604`  
**PNG:** `referencias/armitage/04-paineis-wifi-bluetooth-chiba.png`  
**QML da Pond:** `bluetooth/Panel.qml`, `Devices.qml`, `DeviceRow.qml`, `Row.qml`, `Nearby.qml`, `Pairing.qml`, `Details.qml`, `State.qml`, `StatusAnimation.qml` (spec §3.17)

Pilha igual à ficha 05 (316 / 284 / fechar pendurado).

## Lista — 316×306

- Ícone bluetooth 20 em (20,22) + título Serif 20 em (48,16) + chave em (242,18).
- Linha de dispositivo 300×44 raio 12: ícone 20, nome, bateria opcional 11 (na selecionada a bateria usa `text`, senão `muted`), botão info 32×32 raio 8, rádio de conexão à direita (x 272, y 14).
- “Conectando”: dois pontos `accent` no lugar do rádio; a Pond pisca a cada **750 ms** — herdar (`StatusAnimation.qml`).
- Rodapé: “Procurar dispositivos próximos” 15 `muted`.

## Próximos — frente 236

- Título “Dispositivos próximos” + ícone searching `accentText`. Seção “Procurando…” 11 `muted`. Lista de não pareados.

## Pareamento — frente 236

- Instrução 13 Regular `muted`, caixa 276, quebra de linha permitida (é o único texto corrido deste painel).
- Código em Geist Serif **32** `accentText`, centrado (exemplo “482 913”). (A Pond usava Onest 28 na cor accent — agora Serif 32 em `accentText`, nunca acento puro.)
- “Cancelar” 146×40 r10 em (8,184); “Parear” primário em (162,184).

## Desligado — 156

- Mesmo cabeçalho com a chave off + texto centrado `muted`: “O Bluetooth está desligado.”
