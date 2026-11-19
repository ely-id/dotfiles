# 05 · Wi-Fi

**Nova?** não (refino; as páginas extras que faltavam na 1ª referência já estão no design)  
**Board:** `13:13604`  
**PNG:** `referencias/armitage/04-paineis-wifi-bluetooth-chiba.png`  
**QML da Pond:** `wifi/Panel.qml`, `Networks.qml`, `NetworkRow.qml`, `Join.qml`, `AddNetwork.qml`, `Details.qml`, `Connection.qml`, `State.qml`, `SelectField.qml`, `EnterpriseFields.qml`, `FormViewport.qml`, `SecurityMenu.qml`, `SignalIcon.qml` (spec §3.14–3.15)  
**Pilha:** `CardStack.qml`, `CardLayer.qml`, `PanelCloseButton.qml` (as medidas ficam nos tokens `cardStack*` do `Theme.qml`; o `PanelStyle.qml` herdado da origem saiu na `F6-T17`)

## Pilha (vale também para Bluetooth e Som)

- Cartão da frente: **316** de largura, raio 16, vidro Armitage.
- Carta de trás (quando há página empilhada): **284** de largura, deslocada **16 px** para a direita, em `(16, 0)` da pilha (aparecem **32 px** acima da frente), raio **16**, mesmo vidro e mesmas sombras da frente. O conteúdo fica na escala original, cortado em 284, a **50%** de opacidade e com **blur 8**, inclusive no trecho que aparece acima da frente. Conferi em `prelude2.js` (`stack`) e no print `04-paineis-wifi-bluetooth-chiba.png`; a origem usava topo a 16, raio 14,38, conteúdo reduzido a 284/316 e blur só sob a frente (2026-11-15, S07).
- A base da carta de trás fica rente à base da frente. No Figma ela aparece abaixo da frente com a altura natural da página, mas parece artefato do gerador; **A CONFIRMAR** em P-40.
- Botão fechar 40×40 pendurado em `(296, folga − 20)`. Com página empilhada, o X vira “voltar”. Folga do verso = 32; sem verso = 22 (`prelude2.js` `stack`).
- Abrir: escala 0,9→1 em 220 ms, origem no canto inferior esquerdo, InOutCubic.
- Trocar página: 350 ms, curva `[0.19, 1, 0.22, 1]`. Fechar: 200 ms, mesma curva.

## Lista — 316×306

- Título Geist Serif 20 em (20,16), caixa 200×32. Chave em (242,18).
- Divisor y 60, largura 276, x 20.
- Linhas 300×44 raio 12 a partir de y 64, x 8 (passo 44).
- Rede conectada: fundo `accentSubtle`, botão “Desconectar” 100×32 à direita.
- Rodapé “Adicionar rede”: ícone `plus` 20 + texto 15 `muted`. Hover `hover`. Divisor de 1 px em y 248 (x 20, 276 de largura) e linha 300×44 em y 254, medidos no print de referência (2026-11-15, S07).
- “Desconectar” da rede conectada: botão pequeno 100×32 r8 em (192,6) da linha, `control` + `border`.

## Entrar (senha) — frente 228

- Título “Entrar em «…»” (20,16). Rótulo “Senha” 15 em (20,72). Campo senha em (20,100). Primário “Conectar” em (20,160). O botão fica sempre visível e **desativado** (opacidade 0,4) até haver senha; a origem escondia o botão e animava a altura de 167 para 226. Decisão minha na S07, para a altura ficar fixa em 228 como na ficha; não está no Figma.

## Adicionar rede — frente 436

- SSID (campo em foco), Segurança (seletor 276×44 raio 12 com chevron), Senha, caixa “Rede oculta” em (20,328) + rótulo em (48,328).
- “Conectar” primário **desativado** até dar para conectar (20,368).

## Detalhes — frente 424

- Título = nome da rede; ícone wifi `accentText` à direita.
- Linhas de 48 com divisor de 1 px (passo 49), a primeira em y 64; rótulo 15 Medium à esquerda, valor 13 `muted` à direita, margem de 20 nos dois lados. Linhas: Velocidade, IPv4, Banda, Gateway, DNS, Interface.
- Rodapé: “Esquecer” perigo 146×40 r10 em (8,368) e “Desconectar” secundário em (162,368), isto é, 56 acima da base (y = altura − 56). Ícone wifi 20×20 em (276,22).

## Status — 112

- “Conectando…” com 3 pontos `accent` (opacidade 1 / 0,6 / 0,3), ou “Conectado” `successText` + check, ou “Senha incorreta” `dangerText` + alerta. Título Serif 20 centrado (caixa 276×32 em y 54). Os três pontos são 8×8 com espaço 4, e o ícone `circle-check` / `circle-alert` é 20×20, todos centrados em y 34 (medido no print).
- Fecha sozinho 1,5 s (`1500 ms`) depois de conectar. É o tempo que a Pond já define em `wifi/Panel.qml:46` (`420 ms` nas outras ações). Confirmado em 2026-11-15 (P-09).

## Rede cabeada

- Quando há cabo conectado, o botão da barra e a linha da lista de redes usam o ícone Lucide `cable`, no lugar de `ethernet.svg` e `ethernet-no-internet.svg` da origem. Definido em 2026-11-15 (P-39).
- O SVG `cable` (Lucide, ISC) entrou em `wintermute-shell/icons/` na S07, com o traço `#F2F3F5` como os outros ícones (desde a `F4-T25` todos são brancos, `#FFFFFF`, e a cor vem da peça: ficha 00). Ele vale com ou sem internet: o Lucide não tem uma variante “sem internet” e a origem trocava de arquivo, então o estado de cabo sem internet deixou de ter ícone próprio (a barra continua mostrando as taxas e o estado de conexão).

## Dados

Use SSID e IPs fictícios, como nas prévias (Wintermute-5G, Casa_Lima, 192.168.0.42). Nunca dados reais da minha rede nos prints de documentação.
