# 18 · Histórico da área de transferência

**Nova?** **sim** (a Pond não tem histórico)  
**Onde encaixar:** pasta nova `shell/clipboard/`, aberta pelo launcher (chip “Clipboard”) e pelo atalho Super+V (Manual, `F6-T16`). Precisa conviver com o clipboard do sistema e **obrigatoriamente** copiar/colar entre apps Wayland e XWayland (Steam, umu/Battle.net, apps GNOME, Ghostty).  
**Board:** `13:19344`  
**PNG:** `referencias/armitage/08-screenshot-clipboard-chiba.png`

## Medidas — mesma casca do launcher 640×436, raio 24

- Cabeçalho com ícone `clipboard` + busca (“Buscar no histórico”), Geist 17.
- Coluna esquerda 280, divisor vertical em x 280 (de y 57 até o rodapé).
- Linha de item **264×52** raio 12, x 8: tile 28 ou amostra de cor 28 raio 8 em (8,12); título 13 com reticências em (44,8); meta 11 centrada em y 35 (esta ficha dizia “em (44,28)”; no Figma ela é centrada em y 35) — na selecionada a meta usa `text`, senão `muted`. Fixado: ícone `pin` `accentText` à direita.
- Prévia à direita: 328×208 raio 12 em (296,72). Texto em Geist Mono 12, line-height 20. Imagem: no board ela preenche a caixa (miniatura cortada); na shell aparece inteira, sem deformar (composição, A-05). Link: ícone + título 15 + URL Mono 11 `muted`.
- Metadados abaixo: rótulo 11 `muted` + valor 11 à direita (Origem, Copiado, Tamanho / Fixado).
- Rodapé: Colar ↵ · Fixar Ctrl+P · Apagar Del. Na shell o primeiro é “Copy ↵” (P-80: o Enter devolve o item à área de transferência e eu colo com Ctrl+V).

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

- ~~Política de retenção (quantos itens, quanto tempo).~~ Respondida na P-17 (2026-11-19): 50 itens, só na sessão, sem gravar em disco; os itens que o gerenciador de senhas marca como sigilosos não entram. O **teto de memória das imagens** continua em aberto: a `F6-T16` implementa uma proposta e a anota numa pendência que não trava.
- ~~Onde fica “Limpar tudo” na UI.~~ Respondida na P-17: “Clear history” fica no menu de ações (Ctrl+K). O menu e a ação são da `F6-T16`; esta página ainda não tem o Ctrl+K.
- ~~Se cores copiadas pelo seletor (ficha 15) entram automaticamente neste histórico.~~ Respondida na P-17: entram, com a origem “Color picker”.
- ~~O que o Enter faz.~~ Respondida na P-80: devolve o item à área de transferência e fecha o launcher.

## Conferido no Figma e como funciona (`F6-T05`, board `13:19344`)

Li os cinco estados pelo `get_design_context`: texto (`13:19621`), imagem (`13:19678`), busca (`13:19746`), fixados (`13:19790`) e vazio (`13:19846`). As coordenadas abaixo são do quadro de 640×436, com a borda de 1 já somada (o Figma dá as de dentro a partir da borda). A peça mora dentro do launcher, como as páginas do seletor de cor e do emoji (`service.page === "clipboard"`, aberta pelo chip “Clipboard”), então o vidro, o cabeçalho, o divisor em y 56, o rodapé, o bloco de 28, o rótulo de seção e as teclas são os tokens do launcher; o que é só desta página é o token `clipboard*` no `Theme.qml`, com o nó no comentário.

### Medidas

- **Cabeçalho:** o ícone `clipboard` de 20 em (18,18) em `text`; campo em (52,16), altura 24, Geist Regular 17; texto digitado em `text`, o marcador “Search history” em `muted`; cursor de 1×24 em `accentText`. Divisor `border` em y 56. É o `SearchField` do launcher com outro ícone e outro marcador.
- **Rodapé (y 392):** o divisor `border` de 1; o ícone `clipboard` de 16 em (16,406) a 80%; “Clipboard” em Geist Medium 11 `muted`, em x 40; as ações terminando em x 624, numa fila de 20 em y 404, com 8 entre os itens: “Copy” (`text`) + `↵`, divisor de 1×16, “Pin” (`muted`) + `Ctrl` `P`, divisor, “Delete” (`muted`) + `Del`. Teclas: o `KeyCap` da shell.
- **Divisor vertical:** `border` de 1 em x 280, de y 57 a 392 (335). Não existe no vazio.
- **Rótulo de seção:** Geist Medium 11 `muted`, em x 20, caixa de 24; o primeiro em y 60 a 84 (centro em y 72). “Today”, “Pinned” e “N results”. A segunda seção começa com o rótulo 4 abaixo da última linha da primeira (no board dos fixados, linhas em 84 e 136, “Today” em 192 a 216, linhas em 216 e 268).
- **Linha:** 264×52, raio 12 (`radiusRow`), em x 8, empilhadas sem folga (84, 136, 188, 240, 292). Selecionada: `accentSubtle`; sob o ponteiro: `hover`; normal: sem fundo. Bloco de 28×28 em (8,12), raio 8, `control`, com o ícone de 16 em (6,6) em `text`; o item de cor tem no lugar uma amostra de 28 na cor dele, com borda `border` de 1. Título: Geist Medium 13 `text`, caixa de 212×20 em (44,8), uma linha, reticências; a linha fixada tem a caixa de 184. Meta: Geist Medium 11, caixa de 212 em x 44, **centrada em y 35**, em `text` na selecionada e em `muted` nas outras. Fixado: `pin` de 16 em (236,18), em `accentText`.
- **Ícone por tipo:** `command` → `terminal`; `image` → `image`; `link` → `link`; `text` → `file-text`; `email` → `mail`; `color` → a amostra.
- **Prévia:** caixa de 328×208 em (296,72), raio 12, borda `border` de 1, fundo `cardHover`. Texto (`text`, `command`, `email`, `color`): Geist Mono Medium 12, linha de 20, `text`, numa caixa de 296×176 em (16,16) de dentro, que quebra linha e corta o que passar. Link: bloco de 40×40 em (16,16), raio 10 (`radiusChip`), `accentSubtle`, com o `globe` de 20 em (10,10) em `accentText`; título Geist Medium 15 `text`, caixa de 296×24 em (16,68), uma linha, reticências; URL em Geist Mono Medium 11, linha de 16, `muted`, em (16,96), 296 de largura, quebrando linha.
- **Metadados:** linhas de 24 centradas em y 308, 332 e 356; o rótulo em Geist Medium 11 `muted` em x 296 (caixa de 120) e o valor em Geist Medium 11 `text`, alinhado à direita, terminando em x 624 (caixa de 208). Texto e imagem: Source, Copied, Size. Fixado: Source, Pinned, Size. Link: só Source e Copied.
- **Vazio:** sem lista, sem divisor vertical, sem prévia. Círculo de 48 (`control`, raio 24) em (296,120), com o `clipboard` de 20 em (14,14) em `text`; título Geist Medium 15 `text`, caixa de 24 centrada em y 196; dica em Geist Regular 13, linha de 20, `muted`, centrada, de 400 de largura, em duas linhas a partir de y 212. Rodapé: só “Close” + `Esc`.
- **Corrigido na ficha:** a meta da linha é centrada em y 35, e não “em (44,28)”; o rodapé do board diz “Colar”, e a shell diz “Copy”.

### Como funciona

- **Abrir e sair:** o chip “Clipboard” do launcher abre a página, com o campo de busca em foco e o primeiro item selecionado (o primeiro fixado, se houver). Esc e Backspace com o campo vazio voltam ao launcher, como no seletor de emoji. O Super+V, que abre o histórico de qualquer lugar, é da `F6-T16`; o rodapé do vazio diz “Close Esc”, como o board.
- **Seleção:** ↑ e ↓ andam uma linha e atravessam de uma seção à outra, parando nas pontas. A lista rola quando passa de 335 de altura (até 50 itens), com a roda do mouse e com o mesmo padrão do launcher, e a linha selecionada fica sempre à vista; na primeira linha de uma seção o rótulo vem junto. O clique seleciona; o duplo clique e o Enter copiam. A seleção segue o item pelo `id` quando a lista muda: fixar o item o muda de seção e ele continua selecionado; apagar passa a seleção ao vizinho (a linha de baixo, ou a de cima se era a última).
- **Enter:** devolve o item à área de transferência e fecha o launcher (P-80). Colo com Ctrl+V.
- **Ctrl+P:** fixa o item, ou solta se já estava fixo. Com o item selecionado fixado, “Pin” vira “Unpin” no rodapé (composição, A-05).
- **Del:** apaga o item. Com texto na busca e o cursor no meio dele, o Del apaga o caractere, como em qualquer campo; só apaga o item com a busca vazia ou o cursor no fim.
- **Busca:** filtra por título, texto, URL, título do link, cor e nome do aplicativo de origem, sem diferenciar maiúsculas. Com busca, a divisão em “Pinned” e “Today” some e o rótulo vira “N results” (“1 result” no singular). A seleção volta à primeira linha a cada texto novo.
- **Seções:** “Pinned” (o fixado mais recente primeiro) e “Today” (o resto, do mais novo para o mais antigo). O rótulo “Today” vale para todos os itens não fixados, mesmo os que entraram de véspera, porque o histórico é só da sessão.
- **Sem resultado** (sem board, composição, A-05): o mesmo bloco do vazio, com o ícone `search-x` e o título e a dica do launcher para a busca digitada (“Nothing found for “texto””, “Check the spelling or try another search.”); rodapé só com “Close Esc”.
- **Serviço:** a peça lê `service.items` (do mais novo para o mais antigo, cada item `{ id, kind, title, text, source, time, pinned, pinnedTime, image: { url, width, height, format, bytes }, color, linkTitle }`), `service.now` (o relógio do tempo relativo) e chama `copy(item)`, `togglePin(item)` e `remove(item)`. O serviço de verdade (`clipboard/State.qml`) existe vazio, com essa superfície, até a `F6-T16`; `demo/ClipboardService.qml` é o fictício e `demo/ClipboardSpecimen.qml` a vitrine.
- **A conta pura** (filtrar, separar em seções, o tempo relativo, o texto de tamanho, o nome do servidor de uma URL e a posição de cada linha) mora em `clipboard/Clipboard.js`, sem QML.

### O que é composição (A-05) e o que escolhi

- **Imagem inteira na prévia:** no board a imagem preenche a caixa e corta; na shell ela aparece inteira, centrada, sem deformar e cortada no raio de 12, com a borda por cima. Quero ver a imagem que copiei, não um pedaço dela.
- **“Unpin”:** o rodapé do board só tem “Pin”; com o item fixado ele vira “Unpin”.
- **Sem resultado:** o bloco do vazio com o `search-x` (acima).
- **Tempo relativo:** conto pelo tempo corrido, e não pela virada do dia: menos de 1 minuto é “now” (“just now” nos metadados), depois “N min”, “N h” até 24 horas, “yesterday” de 24 a 48 horas e “N days”. Nos metadados acrescento “ago” (“2 min ago”, “1 h ago”, “3 days ago”); “yesterday” fica sem.
- **Tamanho:** `412 KB` (base 1024; acima de 1 MB, uma casa decimal, `1.3 MB`); texto de uma linha só diz `15 characters`, e de mais de uma, `3 lines · 84 characters`; imagem, `1920 × 1080 · PNG · 412 KB`. O item de cor conta os caracteres do código (`7 characters`).
- **Fixado nos metadados:** “Pinned” mostra há quanto tempo fixei o item, e não há quanto o copiei.
- **Origem:** o nome do aplicativo que o serviço informa; a captura da shell é “Screenshot” e o seletor de cor é “Color picker”. Sem origem, “Unknown”.
- **Título do link:** o `linkTitle` do item; sem ele, o nome do servidor da URL (o endereço sem esquema, usuário, porta e caminho).

### Textos em inglês (decisão 0012)

| Board | Shell |
|---|---|
| Buscar no histórico | Search history |
| Hoje · Fixados | Today · Pinned |
| 2 resultados | 2 results (1 result) |
| Colar ↵ | Copy ↵ (P-80) |
| Fixar Ctrl P · Apagar Del | Pin Ctrl P (Unpin) · Delete Del |
| Origem · Copiado · Tamanho · Fixado | Source · Copied · Size · Pinned |
| Nada copiado ainda | Nothing copied yet |
| Dica do vazio | What you copy (text or image) shows up here. / Super+V opens this history from anywhere. |
| Rodapé do vazio, só com Esc | Close Esc |

Os textos de exemplo do board (o endereço de repositório, o e-mail e o endereço do design) têm o meu usuário. Nos espécimes e nos prints uso dados inventados: `git clone https://example.org/case/sprawl-tools`, `case@example.org` e `https://www.example.org/design/…`.
