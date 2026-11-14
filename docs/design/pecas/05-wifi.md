# 05 · Wi-Fi

**Nova?** não (refino; as páginas extras que faltavam na 1ª referência já estão no design)  
**Board:** `13:13604`  
**PNG:** `referencias/armitage/04-paineis-wifi-bluetooth-chiba.png`  
**QML da Pond:** `wifi/Panel.qml`, `Networks.qml`, `NetworkRow.qml`, `Join.qml`, `AddNetwork.qml`, `Details.qml`, `Connection.qml`, `State.qml`, `SelectField.qml`, `EnterpriseFields.qml`, `FormViewport.qml`, `SecurityMenu.qml`, `SignalIcon.qml` (spec §3.14–3.15)  
**Pilha:** `CardStack.qml`, `CardLayer.qml`, `PanelCloseButton.qml`, `PanelStyle.qml`

## Pilha (vale também para Bluetooth e Som)

- Cartão da frente: **316** de largura, raio 16, vidro Armitage.
- Carta de trás (quando há página empilhada): **284** de largura, deslocada **16 px**, conteúdo a 50% com blur 8.
- Botão fechar 40×40 pendurado em `(296, folga − 20)`. Com página empilhada, o X vira “voltar”. Folga do verso = 32; sem verso = 22 (`prelude2.js` `stack`).
- Abrir: escala 0,9→1 em 220 ms, origem no canto inferior esquerdo, InOutCubic.
- Trocar página: 350 ms, curva `[0.19, 1, 0.22, 1]`. Fechar: 200 ms, mesma curva.

## Lista — 316×306

- Título Geist Serif 20 em (20,16), caixa 200×32. Chave em (242,18).
- Divisor y 60, largura 276, x 20.
- Linhas 300×44 raio 12 a partir de y 64, x 8 (passo 44).
- Rede conectada: fundo `accentSubtle`, botão “Desconectar” 100×32 à direita.
- Rodapé “Adicionar rede”: ícone `plus` 20 + texto 15 `muted`. Hover `hover`.

## Entrar (senha) — frente 228

- Título “Entrar em «…»” (20,16). Rótulo “Senha” 15 em (20,72). Campo senha em (20,100). Primário “Conectar” em (20,160).

## Adicionar rede — frente 436

- SSID (campo em foco), Segurança (seletor 276×44 raio 12 com chevron), Senha, caixa “Rede oculta” em (20,328) + rótulo em (48,328).
- “Conectar” primário **desativado** até dar para conectar (20,368).

## Detalhes — frente 424

- Título = nome da rede; ícone wifi `accentText` à direita.
- Linhas 48 (rótulo 15 à esquerda, valor `muted` à direita) com divisor: Velocidade, IPv4, Banda, Gateway, DNS, Interface.
- Rodapé: “Esquecer” perigo 146×40 r10 em (8,368) e “Desconectar” secundário em (162,368).

## Status — 112

- “Conectando…” com 3 pontos `accent` (opacidade 1 / 0,6 / 0,3), ou “Conectado” `successText` + check, ou “Senha incorreta” `dangerText` + alerta. Título Serif 20 centrado.
- Fecha sozinho 1,5 s depois de conectar (comportamento da Pond — herdar o tempo do código; se não existir, **A CONFIRMAR**, não inventar outro).

## Dados

Use SSID e IPs fictícios, como nas prévias (Wintermute-5G, Casa_Lima, 192.168.0.42). Nunca dados reais da minha rede nos prints de documentação.
