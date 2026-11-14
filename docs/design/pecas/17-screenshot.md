# 17 · Captura de tela

**Nova?** a **UI de captura e a anotação são novas**. A Pond só tem a prévia pós-captura: `fonte/screenshot/Preview.qml`, `State.qml` (spec §3.13).  
**Onde encaixar:** evoluir `fonte/screenshot/` (não jogar a prévia fora) e uma janela de captura em tela cheia. Atalho do Manual: Print. Chip no launcher (ficha 14).  
**Board:** `13:19344` (e desktop `13:20899`)  
**PNG:** `referencias/armitage/08-screenshot-clipboard-chiba.png`, `09-desktop-sprawl-captura.png`

## Regra de ouro

**Sempre começa do zero.** Abrir a captura não restaura a área, janela ou atraso anteriores. O atraso visível na barra inicia em **0 s**. Teste obrigatório: abrir, selecionar, fechar (Esc), abrir de novo — sem retângulo residual.

## Barra de modos — 496×56 raio 16, embaixo

- Modos 88×40 raio 10: Área (`crop`), Janela (`app-window`), Tela (`monitor`). Selecionado: `accentSubtle`+`accentRing`.
- Atraso (ícone relógio + “0 s”).
- Botão “mostrar cursor” 40. Fechar 40. Divisores 1×24.

## Estado 1 — Início (modo área)

- Sem seleção. Tela escurece 30%. Mira em cruz (linhas brancas 60%) com pílula de coordenadas Geist Mono 11 (ex. `420, 236`).
- Dica: “Arraste para selecionar” · Espaço muda o modo · Esc.

## Estado 2 — Selecionando uma área

- Fora da seleção escurece **45%**. Borda `accent` 1 px, **8 alças** 8×8 raio 2 (`knob` + traço `accent`).
- Pílula de tamanho Mono 11 acima (ex. `320 × 200`).
- Ações logo abaixo da seleção, pílula 208×48 raio 14: copiar, salvar, anotar (botões 32) + “Capturar” primário 84×32.

## Estado 3 — Modo janela

- Escurece 45%. Hover destaca a janela com anel `accent` 2 px (raio 14 ao redor de uma janela de raio 12). Pílula com nome e tamanho. Clique captura só ela.

## Estado 4 — Prévia pós-captura (evoluir a da Pond)

- **156×112** raio 12, acima dos controles da barra, borda `borderStrong`, some em **6 s**. Dá para arrastar para outro app (herdar se a Pond já faz).
- Hover: véu preto 50% + 4 botões redondos 32 (copiar, salvar, anotar, fechar). Fundo do botão `#0D0E11` 70%; hover branco 20%.
- Barra recolhida: prévia **48×48** raio 12, acima dos controles.

## Aviso de salvo

- Toast 280×64 raio 16: check, “Captura salva”, caminho 11 `muted` com reticências. O caminho da prévia (`~/Imagens/Capturas/14-32.png`) é exemplo.

## Estado 5 — Anotação simples — editor 720×480 raio 24

- Ferramentas 32: lápis, marca-texto, retângulo (selecionado na prévia), seta, texto, recorte. Cinco cores: `attentionText`, `warning`, `accentText`, `successText`, `text` (amostra 16 no círculo 32; selecionada com anel `text` 2). Desfazer. “Copiar” secundário + “Salvar” primário.
- Área da captura 688×408 raio 12 abaixo da barra (y 56).

## A CONFIRMAR

- Pasta padrão de salvar (a prévia usa `~/Imagens/Capturas/`).
- Formato (PNG) e se o atraso tem lista de valores no Figma — a barra mostra “0 s”, mas a UI do seletor de atraso **não tem board próprio**. **A CONFIRMAR NO FIGMA (node 13:19344)** os tempos oferecidos, ou pergunte.
