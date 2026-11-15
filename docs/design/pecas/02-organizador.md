# 02 · Organizador de workspaces (12 estados)

**Nova?** não (refino + troca do “+”)  
**Board:** `13:12277` · variante `Janela do workspace / Estado=Recolhida focada` `13:11395`  
**PNG:** `referencias/armitage/03-barra-organizador-chiba.png`, `10-recolhido-corrigido.png`  
**QML da Pond:** `minimap/Map.qml`, `WindowIcon.qml`, `PlusButton.qml`, `TerminalIndicator.qml`, `DragSession.qml`, `NiriMsg.qml` (spec §4, sobretudo §4.2 `NiriMsg.qml:380-507`, §4.3–4.8)

Peça central. Cada workspace é uma **linha**; cada janela é um **círculo com o ícone do app**, na ordem das colunas do niri. Não há miniaturas nem tooltips.

## Medidas — aberto (cartão 156)

Fonte: `g2.src.js` `orgCard` e a nota do board: *linha 40, passo 50, círculo 40 ícone 16, slots a cada 48, fundo ativo 146×50 r10 em x 5, pílula 14×20 na borda (x −7)*.

- Padding 10 (= (156 − 3×40 − 2×8) / 2). Altura do cartão = `50 × max(linhas, 3) + 10`.
- Círculo 40, gap 8, passo horizontal 48. Passo vertical 50 (40+10).
- Fundo do ativo: 146×50, raio 10, em (5, y−5), `accentSubtle` + traço `accentRing`.
- Hover da linha: mesmo retângulo, fundo `hover`.
- Alvo de arraste na linha: mesmo retângulo, `accentSubtle`.
- Linha levantada (reordenar): mesmo retângulo, `raised` + `borderStrong` + sombra.
- Pílula 14×20 raio 7. No hover do cartão aparece na borda, metade para fora (x −7 do cartão; no palco do Figma a pílula está em x 1 e o cartão em x 8).
- Mínimo 3 linhas (vazios de preenchimento com 3 pontos).
- No máximo 3 janelas visíveis por linha (carrossel 136 px, 220 ms, a focada permanece à vista).

## Medidas — recolhido (cartão 48)

Fonte: `g2.src.js` `orgCollapsed` + correção documentada em `armitage-shell/status.md`.

- Número do workspace em Geist Mono Regular 13, caixa 40×20 no topo da linha (y+6), ativo/hover em `text`, senão `muted`. Prefixo visual “01”, “02”…
- Workspace **ativo**: empilha as janelas em círculos de **32 px**, passo 40 (`workspaceCollapsedControlPitch`), começando em y+37, x 8 (centro da coluna de 48: (48−32)/2 = 8).
- **FIX:** a janela focada no recolhido usa a variante **Recolhida focada** (`13:11395`): **32 px** (não 40) + anel `accent`. O erro original era usar o círculo de 40, que ficava 4 px à direita e maior. Conferir em `10-recolhido-corrigido.png`.
- Workspaces inativos: até 4 pontos 4×4, passo 6, centrados; cor `muted` (token `dot` / `muted` conforme a referência).
- Fundo do ativo: `pressed`; hover: `hover`; raio 12; x 4, largura 40.
- Divisor 16×1 `border` entre linhas (x 16).
- Sem arraste no modo recolhido.

## Pílula — estados

| Estado | Fundo | Conteúdo |
|---|---|---|
| Repouso | `raised` + `borderStrong` | número Mono 11 `text` |
| Hover (puxador) | idem | 3 pontos `text` (arraste vertical) |
| Ativa | `accent` | número `onAccent` |
| Arrastando | `accentHover` + sombra | 3 pontos `onAccent` |

## Janela (círculo) — estados

| Estado | Tamanho | Traço / fundo |
|---|---|---|
| Repouso | 40 | borda `border` 1 |
| Hover | 40 | fundo `pressed`, sem traço |
| Foco | 40 | traço `accent` 1,5 |
| Levantada | 40 | fundo `raised` + `accent` 1,5 + sombra |
| Recolhida | 32 | borda `border` |
| **Recolhida focada** | **32** | anel `accent` |

## Os 12 estados (aceite um a um)

1. **Aberto, em repouso.** Pílulas escondidas. Ativo com fundo de acento 18% e janela focada com anel.
2. **Mouse sobre a linha 1.** Cartão + `cardHover`; pílulas aparecem; “+” no slot depois da última janela (abre o **launcher**, não o Vicinae).
3. **Hover no círculo e no +.** Círculo em hover perde o contorno e ganha fundo 10%; “+” preenche.
4. **Hover na pílula.** Número vira puxador de 3 pontos; arraste vertical reordena.
5. **Mais de 3 janelas.** Carrossel; só 3 visíveis; 220 ms; focada à vista.
6. **Workspace ativo vazio.** 1º slot vira círculo `accentSubtle`+`accentRing` com “+”: clicar abre o launcher **já nesse workspace**.
7. **Arrastando uma janela.** Círculo levantado segue o cursor; alvo abre espaço (110 ms); a janela já se move no niri (prévia ao vivo a cada 32 ms, spec §4.6). Esc devolve.
8. **Reordenando workspaces.** A linha inteira segue o cursor; as do caminho deslizam ±50 px (110 ms). Solta = `MoveWorkspaceToIndex`.
9. **Recolhido.** Números Mono 13; ativo empilha 32 px; inativos até 4 pontos.
10. **Recolhido, mouse numa linha inativa.** Acende o número e o fundo 6%. Sem arraste.
11. **Terminais com agente.** No lugar do ícone: Trabalhando (`accentText`), Atenção (`attentionText`), Não lido (`warning`), Lido (`successText`). Detecção pelo título continua a da Pond (`NiriMsg.qml:314-325` — o próprio código chama de hack), mas passa a reconhecer também o Ghostty: a origem só olha janelas com app-id `kitty`, e o meu terminal é o Ghostty (decidido em 2026-11-14, P-30). O app-id do Ghostty e o formato dos títulos são conferidos na sessão do Niri antes de implementar.
12. **Monitor sem janelas.** Substitui o 12º estado “Unthemed” da Pond. Só a linha de criação ativa, “+” visível; duas linhas de pontos completam o mínimo de 3.

## Comportamento a herdar (não redesenhar a lógica)

- Dados e comandos: `NiriMsg._recompute` (`NiriMsg.qml:380-507`). Quais linhas aparecem: ocupadas + ativo + exatamente um vazio de criação (`:409-456`). Numeração por monitor (`:485-490`). Ordem das janelas (`:371-378`).
- Sidebar de cada monitor só mostra as linhas daquele monitor (`Map.qml:135-137`).
- Janelas flutuantes entram na lista (spec §4.8).
- O “+” e o auto-abrir **deixam de depender do Vicinae**.

## Decisões confirmadas

- **P-05 (2026-11-15, S06):** os indicadores de terminais com agente usam os 4 ícones Lucide do Figma (`hourglass` em `accentText` para Trabalhando, `circle-alert` em `attentionText` para Atenção, `sprout` em `warning` para Não lido e `circle-check` em `successText` para Lido), em vez dos 4 loaders SVG da Pond.
