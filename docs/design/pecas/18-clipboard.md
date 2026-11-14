# 18 · Histórico da área de transferência

**Nova?** **sim** (a Pond não tem histórico)  
**Onde encaixar:** pasta nova `shell/clipboard/`, aberta pelo launcher (chip “Área de transf.”) e pelo atalho Super+V (Manual). Precisa conviver com o clipboard do sistema e **obrigatoriamente** copiar/colar entre apps Wayland e XWayland (Steam, umu/Battle.net, apps GNOME, Ghostty).  
**Board:** `13:19344`  
**PNG:** `referencias/armitage/08-screenshot-clipboard-chiba.png`

## Medidas — mesma casca do launcher 640×436, raio 24

- Cabeçalho com ícone `clipboard` + busca (“Buscar no histórico”), Geist 17.
- Coluna esquerda 280, divisor vertical em x 280 (de y 57 até o rodapé).
- Linha de item **264×52** raio 12, x 8: tile 28 ou amostra de cor 28 raio 8 em (8,12); título 13 com reticências em (44,8); meta 11 em (44,28) — na selecionada a meta usa `text`, senão `muted`. Fixado: ícone `pin` `accentText` à direita.
- Prévia à direita: 328×208 raio 12 em (296,72). Texto em Geist Mono 12, line-height 20. Imagem em miniatura. Link: ícone + título 15 + URL Mono 11 `muted`.
- Metadados abaixo: rótulo 11 `muted` + valor 11 à direita (Origem, Copiado, Tamanho / Fixado).
- Rodapé: Colar ↵ · Fixar Ctrl+P · Apagar Del.

## Estados (aceite)

1. **Texto** — lista “Hoje” + prévia do texto + metadados. Tipos de item na prévia: comando de terminal, captura (imagem), link, nota, cor do seletor.
2. **Imagem** — miniatura e tamanho (ex. 1920×1080 · PNG · 412 KB).
3. **Busca** — filtra por texto, link, app de origem (prévia: “figma”, 2 resultados).
4. **Fixados** — seção no topo, não expiram (Ctrl+P). Depois, “Hoje”.
5. **Vazio** — ícone 48, “Nada copiado ainda”, dica Regular 13 line-height 20 mencionando Super+V. Rodapé só com Esc.

## Comportamento

- ↵ cola no app focado (Wayland ou XWayland).
- Esc fecha.
- “Limpar tudo” (se existir — **não tem botão no board**, só o estado vazio “também depois de Limpar tudo” na legenda) deve ser perguntado antes de inventar a entrada de UI.

## A CONFIRMAR

- Política de retenção (quantos itens, quanto tempo, teto de memória para imagens). O Figma mostra uma lista do “hoje” e diz que fixados não expiram, mas não define o restante.
- Onde fica “Limpar tudo” na UI.
- Se cores copiadas pelo seletor (ficha 15) entram automaticamente neste histórico (a prévia sugere que sim: item `#3FA9D9`).
