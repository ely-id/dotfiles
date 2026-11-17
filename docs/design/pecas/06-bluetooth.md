# 06 · Bluetooth

**Nova?** não (refino; páginas Próximos e Pareamento entram neste design)  
**Board:** `13:13604`  
**PNG:** `referencias/armitage/04-paineis-wifi-bluetooth-chiba.png`  
**QML da Pond:** `bluetooth/Panel.qml`, `Devices.qml`, `DeviceRow.qml`, `Row.qml`, `Nearby.qml`, `Pairing.qml`, `Details.qml`, `State.qml`, `StatusAnimation.qml` (spec §3.17)

Pilha igual à ficha 05 (316 / 284 / fechar pendurado).

## Lista — 316×306

- Ícone bluetooth 20 em (20,22) + título Serif 20 em (48,16) + chave em (242,18).
- Linha de dispositivo 300×44 raio 12: ícone 20, nome, bateria opcional 11 (na selecionada a bateria usa `text`, senão `muted`), botão info 32×32 raio 8, rádio de conexão à direita (x 272, y 14). Medido no print: a linha conectada usa `accentSubtle`; o texto da bateria termina em x 216 e o botão de info fica em (224,6), sempre visível (a origem só mostrava no hover); a bateria aparece em qualquer dispositivo que a informe, conectado ou não (2026-11-15, S07).
- “Conectando”: dois pontos `accent` 6×6 com espaço 4 no lugar do rádio, em (272,19); um aceso e o outro a 30%, trocando a cada **750 ms** (o tempo que a Pond usava; os pontos agora são desenhados em QML, em `bluetooth/ConnectingDots.qml`).
- Rodapé: divisor em y 248 e linha 300×44 em y 254, como no Wi-Fi, com o ícone `bluetooth-searching`.
- Rodapé: “Procurar dispositivos próximos” 15 `muted`.

## Próximos — frente 236

- Título “Dispositivos próximos” + ícone `bluetooth-searching` 20 `accentText` em (276,22). Legenda “Procurando…” 11 `muted` em (20,72). Linhas a partir de y 96. Lista de não pareados. A altura é 236 com até 3 dispositivos e cresce até 316 com mais (escolha minha na S07, para a lista não ficar curta demais; a ficha só mostra 3).

## Pareamento — frente 236

- Instrução 13 Regular `muted`, caixa 276 em (20,72), quebra de linha permitida (é o único texto corrido deste painel). O código fica em (20,119), caixa 276×40.
- Código em Geist Serif **32** `accentText`, centrado (exemplo “482 913”). (A Pond usava Onest 28 na cor accent — agora Serif 32 em `accentText`, nunca acento puro.)
- “Cancelar” 146×40 r10 em (8,184); “Parear” primário em (162,184), também 146×40 r10 (`ActionButton` com `compact: true`). Quando é preciso digitar PIN ou senha, o campo fica em (20,100) e a altura continua 236.

## Desligado — 156

- Mesmo cabeçalho com a chave off + texto centrado `muted`: “O Bluetooth está desligado.” Sem rodapé; o texto fica com o centro em y 104.
- **Rádio bloqueado pelo `rfkill`** (`F4-T13`, 2026-11-17). É o mesmo desenho do desligado, com a frase "Bluetooth is blocked. Turn it on to unblock it." no lugar. Ligar a chave roda `rfkill unblock bluetooth` e só então liga o adaptador; a chave fica ocupada do começo ao fim. Se o comando falha, a mensagem de erro (em `dangerText`, onde as mensagens do Bluetooth já aparecem) diz o motivo: "Could not unblock Bluetooth: …". Se o comando passa e o adaptador continua bloqueado depois de 3 s, que é o caso de bloqueio de hardware: "Bluetooth is still blocked. Check the hardware switch or airplane mode.". Os 3 s são espera de processo, não medida de desenho.
