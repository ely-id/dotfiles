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

- ~~Política de retenção (quantos itens, quanto tempo).~~ Respondida na P-17 (2026-11-19): 50 itens, só na sessão, sem gravar em disco; os itens que o gerenciador de senhas marca como sigilosos não entram. O **teto de memória das imagens** continua em aberto: a `F6-T16` implementou uma proposta (texto até 1 MB, PNG até 16 MB, imagens guardadas somando até 64 MB; ver “O serviço”, abaixo) e a pendência que pede a minha confirmação não trava nada.
- ~~Onde fica “Limpar tudo” na UI.~~ Respondida na P-17: “Clear history” fica no menu de ações (Ctrl+K). Feito na `F6-T16`: o Ctrl+K desta página abre o menu de ações do launcher, com Copy, Pin ou Unpin, Delete e Clear history.
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

- **Abrir e sair:** o chip “Clipboard” do launcher abre a página, com o campo de busca em foco e o primeiro item selecionado (o primeiro fixado, se houver). Esc e Backspace com o campo vazio voltam ao launcher, como no seletor de emoji. O Super+V, que abre o histórico de qualquer lugar, é da `F6-T16` (ver “O serviço”); o rodapé do vazio diz “Close Esc”, como o board.
- **Seleção:** ↑ e ↓ andam uma linha e atravessam de uma seção à outra, parando nas pontas. A lista rola quando passa de 335 de altura (até 50 itens), com a roda do mouse e com o mesmo padrão do launcher, e a linha selecionada fica sempre à vista; na primeira linha de uma seção o rótulo vem junto. O clique seleciona; o duplo clique e o Enter copiam. A seleção segue o item pelo `id` quando a lista muda: fixar o item o muda de seção e ele continua selecionado; apagar passa a seleção ao vizinho (a linha de baixo, ou a de cima se era a última).
- **Enter:** devolve o item à área de transferência e fecha o launcher (P-80). Colo com Ctrl+V.
- **Ctrl+P:** fixa o item, ou solta se já estava fixo. Com o item selecionado fixado, “Pin” vira “Unpin” no rodapé (composição, A-05).
- **Del:** apaga o item. Com texto na busca e o cursor no meio dele, o Del apaga o caractere, como em qualquer campo; só apaga o item com a busca vazia ou o cursor no fim.
- **Busca:** filtra por título, texto, URL, título do link, cor e nome do aplicativo de origem, sem diferenciar maiúsculas. Com busca, a divisão em “Pinned” e “Today” some e o rótulo vira “N results” (“1 result” no singular). A seleção volta à primeira linha a cada texto novo.
- **Seções:** “Pinned” (o fixado mais recente primeiro) e “Today” (o resto, do mais novo para o mais antigo). O rótulo “Today” vale para todos os itens não fixados, mesmo os que entraram de véspera, porque o histórico é só da sessão.
- **Sem resultado** (sem board, composição, A-05): o mesmo bloco do vazio, com o ícone `search-x` e o título e a dica do launcher para a busca digitada (“Nothing found for “texto””, “Check the spelling or try another search.”); rodapé só com “Close Esc”.
- **Serviço:** a peça lê `service.items` (do mais novo para o mais antigo, cada item `{ id, kind, title, text, source, time, pinned, pinnedTime, image: { url, width, height, format, bytes }, color, linkTitle }`), `service.now` (o relógio do tempo relativo) e chama `copy(item)`, `togglePin(item)` e `remove(item)`. O serviço de verdade (`clipboard/State.qml`) existia vazio, com essa superfície, até a `F6-T16`, que o encheu (ver “O serviço”); `demo/ClipboardService.qml` é o fictício e `demo/ClipboardSpecimen.qml` a vitrine.
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

## O serviço: como funciona (`F6-T16`)

Enchi o `clipboard/State.qml`, que até a `F6-T05` era vazio. A peça não mudou: ela continua lendo `items`, `now`, `copy`, `togglePin` e `remove`, e ganhou `clear` e `expect` (o fictício, `demo/ClipboardService.qml`, tem os mesmos).

### Como escuto

- Dois processos de vida longa, donos do `State.qml`: `wl-paste --type text --watch python3 clipboard/watch.py text` e `wl-paste --type image/png --watch python3 clipboard/watch.py image`. O `wl-paste --watch` chama o `watch.py` uma vez por mudança, com o conteúdo na entrada padrão e a variável `CLIPBOARD_STATE` (`data`, `nil`, `clear` ou `sensitive`). O `watch.py` escreve **uma linha de JSON por item** e o QML a lê com um `SplitParser` e a entrega a `ingest(event)`, que é pública para o teste entregar eventos sem o `wl-paste`.
- **Só começam quando a shell de verdade pede**: o `shell.qml` chama `Clipboard.State.start()` no `Component.onCompleted`. Importar o singleton (a vitrine, a bancada, o launcher) não liga processo nenhum, e a bancada não ganha aviso novo.
- Sem o protocolo de controle de dados do compositor (como no GNOME e na tela de teste) ou sem o `wl-paste`, o histórico fica vazio e sai **uma** linha de aviso no log, sem tentar de novo em laço: o processo que sai em menos de 3 s não é reiniciado; o que cai depois de ter rodado é reiniciado até 3 vezes, 2 s depois, e então avisa e para. Esses números são limites de falha, não de desenho.
- Só PNG nesta versão. JPEG e outros formatos de imagem não entram.

### O que não entra

- O que o gerenciador de senhas marca como sigiloso (P-17): `CLIPBOARD_STATE=sensitive`, e, como segunda barreira para versões do `wl-clipboard` sem o `sensitive`, o `x-kde-passwordManagerHint` na lista de tipos (`wl-paste --list-types`). Nesses casos o `watch.py` nem lê a entrada padrão: o conteúdo não vai para a memória, para o disco nem para o log. Se ele não consegue perguntar os tipos, também não guarda (na dúvida, trato como sigiloso).
- Área de transferência vazia ou limpa (`nil`, `clear`), texto vazio ou só de espaços, texto que não é UTF-8, texto acima do teto, PNG inválido ou acima do teto. Do PNG confiro a assinatura, o cabeçalho (IHDR) e o **fim do arquivo**: os últimos 12 bytes têm de ser o chunk IEND. PNG cortado no meio, sem o IEND ou com lixo depois dele não entra: nada é gravado e nada é escrito. Não descomprimo a imagem nem confiro o CRC dos outros chunks.
- Uma seleção que oferece `image/png` e nenhum texto simples (o “copiar imagem” de um navegador oferece também o HTML dela) é só imagem: o texto dela não vira um segundo item de marcação.

### O limite de 50 e o teto de memória

- No máximo **50 itens não fixados** (P-17). Os fixados não contam e não saem; soltar um fixado que passa dos 50 tira o não fixado mais antigo, e se os 50 já estavam cheios esse pode ser o próprio item que acabei de soltar (quando ele é o não fixado mais antigo). O mesmo conteúdo de novo (texto igual, ou imagem com o mesmo hash) não duplica: o que já existe sobe para o topo com a hora nova, mantendo o fixado, a hora de fixar e a origem.
- **Teto de memória: é a proposta da `F6-T16`, não decisão minha ainda** (a P-17 não fechou o teto das imagens). Três propriedades com nome no `State.qml`: `maxTextBytes` = 1 MB (texto acima disso não entra), `maxImageBytes` = 16 MB (PNG acima disso não entra) e `maxImagesTotalBytes` = 64 MB (a soma das imagens guardadas, fixadas incluídas; passando disso saem primeiro as imagens não fixadas mais antigas, e se só sobram fixadas a imagem nova que não cabe não entra). Quando um item sai, o arquivo da imagem sai junto, e só se o caminho está direto dentro da pasta do histórico.

### Onde ficam as imagens e o texto

- O histórico vive só na sessão e some ao sair ou reiniciar, **sem gravar em disco**: nada é lido nem gravado entre uma sessão e outra. O texto fica só na memória da shell. Cada PNG fica em `$XDG_RUNTIME_DIR/wintermute-shell/clipboard/<hash>.png` (SHA-256), com permissão só do dono (arquivo 0600, pasta 0700). Essa pasta é da sessão: está em memória e some no logout.
- **A pasta é limpa quando a shell começa.** Reiniciar a shell apaga a lista, e os PNGs que ficaram na pasta não teriam nenhum item apontando para eles; por isso o `Clipboard.State.start()` roda `python3 clipboard/watch.py sweep --dir <pasta>` e só depois liga as duas escutas (se a limpeza falha, ou passa de 3 s, as escutas ligam do mesmo jeito). Então **reiniciar a shell também apaga as imagens** do histórico. A limpeza apaga só arquivo regular direto dentro da pasta, de nome `<64 dígitos hexadecimais>.png` (e o temporário `<hash>.png.tmp-<pid>` de uma gravação interrompida): não segue link simbólico, não desce em subpasta, não apaga a pasta, e pasta que não existe não é erro. A bancada não chama o `start()`, então não limpa nada.
- O mesmo PNG de novo dá o mesmo hash e não cria outro arquivo.

### Como classifico

A conta é pura, no `Clipboard.js`. `kind`: `color` se o texto inteiro é uma cor num dos três formatos que o seletor de cor copia (`#RRGGBB`, `rgb(r, g, b)` e `hsl(h, s%, l%)`; o HEX sem o `#` não conta, porque “facade” é uma palavra); `link` se é uma linha só com `http://`, `https://` ou `www.`; `email` se é uma linha só com um endereço; `command` se o aplicativo de origem é um terminal (a categoria `TerminalEmulator` da entrada `.desktop` dele; quem diz isso é o serviço, e a conta recebe um booleano); senão `text`. Nessa ordem: uma URL copiada do terminal é `link`. Imagem é `image`.

`title`: a primeira linha não vazia do texto, sem espaços nas pontas; no link, a URL; na cor, o texto; na imagem, `Screenshot HH:MM` quando veio da captura da shell e `Image HH:MM` nos outros casos (hora local de quando chegou). `color` é a cor em `#RRGGBB` para a amostra (o `hsl` do seletor é arredondado em inteiros, então a amostra dele pode diferir em um ou dois níveis do HEX original). `linkTitle` fica vazio: a prévia cai no nome do servidor. Dois cortes de robustez, que não aparecem na tela: o título guardado tem no máximo 256 caracteres (a linha corta com reticências bem antes, e um texto de 1 MB numa linha só travaria o `Text`), e a prévia mede só os 2000 primeiros caracteres do texto (a caixa de 296×176 mostra umas poucas linhas).

### De onde vem a origem (e o limite dela)

A área de transferência do Wayland **não diz quem copiou**. Uso a janela em foco no instante em que o item chega: o `appId` pelo `NiriMsg.focusedWindow()` e o nome pela entrada `.desktop` (`DesktopEntries.heuristicLookup`), como a captura já faz. **Pode errar**: um aplicativo que copia em segundo plano, ou uma cópia que chega depois de eu trocar de janela, leva o nome da janela que está em foco. Sem janela, a origem fica vazia e os metadados mostram “Unknown”. O nome e a categoria vêm da entrada `.desktop`, que o Quickshell leva um ou dois segundos para ler na primeira vez; por isso o `start()` já pede a leitura, e o primeiro item da sessão não cai no `appId` cru (por exemplo `com.mitchellh.ghostty`), que é o que aparece quando o aplicativo não tem entrada.

Quando quem copia é a própria shell, ela avisa antes com `expect(nome)`, que vale para o próximo item que chegar em até 1 s e só para ele: o seletor de cor avisa “Color picker”, a captura e o editor de anotação (que passam pelo mesmo `deliverFile`) avisam “Screenshot”, e as outras cópias do launcher (emoji, cálculo, caminho de arquivo) avisam “Launcher”. O recopiar do próprio histórico não avisa e cai na regra do item que já existe: a origem não muda. Como o que repete mantém a origem, uma cópia repetida de outro aplicativo também não a troca.

### As ações

- `copy(item)`: o texto vai por `wl-copy -- texto`, como o launcher faz; acima de 100000 bytes (o sistema aceita 131072 por argumento) ou com um byte nulo, pela entrada padrão do `wl-copy`. A imagem vai pelo `screenshot/clipboard.py copy-file`. A cópia gera uma mudança na área de transferência, e o item que já existe sobe: não duplica.
- `togglePin(item)` guarda o `pinnedTime`; `remove(item)` apaga o arquivo da imagem; `clear()` tira todos os **não fixados** (os fixados são o que escolhi guardar). Nenhuma das três esvazia a área de transferência do sistema.

### O menu Ctrl+K (composição, A-05)

Sem board: é o menu de ações que o launcher já tem (`page === "actions"`, `launcher/Actions.js`), aberto da página do histórico. Cabeçalho com o botão de voltar e o título do item selecionado (“Clipboard” sem item); linhas **Copy**, **Pin** ou **Unpin**, **Delete** e **Clear history** (ícones `copy`, `pin`, `x` e `trash-2`; “Clear history” é a linha de perigo). “Clear history” **só aparece quando há item não fixado para tirar**: com tudo fixado o menu mostra só Copy, Unpin e Delete. Sem item selecionado (a busca não achou nada) só sobra “Clear history”, e sem o que limpar o Ctrl+K não abre. “Clear history” pede a mesma confirmação dos comandos perigosos de sessão: o primeiro Enter arma (“Press ↵ again to confirm”), o segundo limpa e volta à página, que mostra o vazio se não sobrou nada; mudar de linha desarma. Esc, Backspace e o botão de voltar voltam à página do histórico, com a busca e a seleção de antes. O Ctrl+K não está no rodapé da página, porque o board não o tem.

### Super+V

`settings/manual/shortcuts.json` ganhou `{ "bind": "Mod+V", "label": "Clipboard history", "ipc": "launcher clipboard", "overlay": true }` na seção Wintermute, e o `keybinds.py` gera a bind. O alvo `launcher` do IPC ganhou `clipboard()`: abre o launcher direto na página do histórico, no monitor em foco, e com ela já aberta (ou o menu dela) fecha. **Aberta assim o Esc fecha o launcher de vez** e o Backspace no campo vazio não volta à busca, porque não há busca por baixo; aberta pelo chip, continuam voltando à busca, como antes. Aplicar a bind no Niri é da sessão ao vivo: o `keybinds.kdl` de `~/.config/niri/cfg/` é gerado de novo por `keybinds.py generate --output ... --apply`.

### O que nunca rodou de verdade

Testei o `watch.py` com entrada e variáveis fabricadas, o serviço pelo `ingest` e pelos ganchos, a cadeia inteira (`wl-paste` de mentira, `watch.py`, `ingest`) e a página no launcher de verdade. O que só existe no Niri, com o monitor e o teclado de verdade:

- o `wl-paste --watch` contra um compositor com o protocolo de controle de dados (a tela de teste não tem, e o `wl-paste` sai logo, como esperado);
- o que ele faz com a seleção que já existe quando a shell começa (entra como um item novo, com a janela em foco como origem, que pode errar);
- uma cópia de verdade de texto e de imagem (Ctrl+C num aplicativo Wayland), e o `copy` devolvendo o item e colando com Ctrl+V (a tela de teste não tem teclado, e o `wl-copy` recusa); o caminho da entrada padrão do `wl-copy` para texto grande foi testado só contra um `cat`;
- o `x-kde-passwordManagerHint` de um gerenciador de senhas de verdade;
- a origem pela janela em foco, no Niri, e se o Niri mantém a janela em foco enquanto o launcher tem o teclado;
- o teclado de verdade (Ctrl+K, Ctrl+P, Del, Esc) na página, o Super+V aplicado e o menu com o desfoque;
- XWayland (Steam, umu), que é da `F6-T06`.

### Textos em inglês (`F6-T16`)

| Onde | Texto |
|---|---|
| Menu Ctrl+K | Copy · Pin · Unpin · Delete · Clear history |
| Confirmação | Press ↵ again to confirm |
| Título do menu sem item | Clipboard |
| Título da imagem | Screenshot HH:MM · Image HH:MM |
| Manual | Clipboard history (Super+V) |

## Wayland e XWayland: o que o serviço precisa e o roteiro do teste (`F6-T06`)

O aceite da fase pede copiar e colar entre aplicativos Wayland e XWayland, nos dois sentidos, com o histórico mostrando os dois. O teste só existe na sessão do Niri; aqui fica o que conferi e o roteiro.

### O que conferi nesta máquina (2026-11-19)

- O Niri é o 26.04 e o `xwayland-satellite` está instalado. Desde a 25.08 o Niri sobe o `xwayland-satellite` sozinho quando ele existe, sem linha nenhuma na configuração (a minha não tem). É ele que roda os aplicativos X11 (Steam, o Battle.net pelo umu-launcher) e que faz a ponte da área de transferência: o que um aplicativo X11 copia aparece como uma seleção comum do Wayland, e o que um aplicativo Wayland copia fica disponível para os X11.
- **O serviço do histórico não precisa de nada a mais.** Ele escuta a seleção do Wayland pelo `wl-paste --watch`, então o que vem de um aplicativo X11 chega pelo mesmo caminho. O que ele devolve com o Enter vai pelo `wl-copy`, e a ponte entrega aos X11.
- Os nomes de tipo do X11 já são tratados: o `wl-paste --type text` aceita `UTF8_STRING`, `STRING` e `TEXT` como texto, e o `watch.py` conta `UTF8_STRING` e `STRING` como texto simples na hora de separar uma cópia de imagem de uma cópia de texto. Isto eu li no código e na documentação do `wl-clipboard`; quem confirma é o passo 2 do roteiro.
- A origem de um item copiado num aplicativo X11 é a janela em foco, como nos outros: o Niri vê a janela do X11 com o `app_id` que o `xwayland-satellite` informa (a classe da janela), e o nome sai da entrada `.desktop` quando ela existe.

### O que pode dar errado, e onde olhar

- **Ponte parada.** Se nada passa de um lado para o outro, confiro se o `xwayland-satellite` está rodando (`pgrep -a xwayland-satellite`) e o que ele diz no diário (`journalctl --user -b | grep -i satellite`).
- **O aplicativo de origem fechou.** No Wayland quem copiou é quem serve o conteúdo: fechado o aplicativo, a área de transferência esvazia. O histórico guarda uma cópia, então o Super+V e o Enter devolvem o item.
- **Seleção primária.** O histórico só escuta a área de transferência (Ctrl+C), e não a seleção primária (o texto só selecionado com o mouse).
- **Imagem que não é PNG.** Um aplicativo X11 que só oferece a imagem em outro formato não entra no histórico (só PNG nesta versão), mas o colar direto entre os dois aplicativos não depende do histórico.

### Roteiro (sessão do Niri, com a shell aberta e o Super+V aplicado)

Uso um aplicativo Wayland (Ghostty ou Firefox) e um X11 (Steam, ou o Battle.net pelo umu-launcher). A Steam e o Battle.net são X11; na dúvida sobre outra janela, o `xlsclients` (se estiver instalado) lista as que passam pelo `xwayland-satellite`.

1. **Wayland para X11.** Copio uma linha no Ghostty e colo num campo de texto da Steam (a busca da loja ou o chat). Esperado: o texto colado é o mesmo.
2. **X11 para Wayland.** Copio um texto na Steam (o nome de um jogo, um trecho de uma página) e colo no Ghostty. Esperado: o texto colado é o mesmo, com os acentos.
3. **O histórico mostra os dois.** Super+V. Esperado: os dois itens no topo, cada um com o aplicativo certo em "Source" (a Steam pode aparecer pelo nome da classe da janela, se não houver entrada `.desktop` com o mesmo nome).
4. **Do histórico para o X11.** No Super+V escolho o item mais antigo, Enter, e Ctrl+V na Steam. Esperado: cola o item escolhido, e ele sobe para o topo do histórico sem duplicar.
5. **Do histórico para o Wayland.** O mesmo, colando no Firefox.
6. **Aplicativos GNOME.** Repito o 1 e o 2 entre um aplicativo GNOME (Arquivos ou o Editor de texto, que são Wayland) e a Steam.
7. **Battle.net pelo umu-launcher.** Copio um texto no cliente (o nome de usuário na tela de conta, por exemplo) e colo no Ghostty; copio no Ghostty e colo no campo de busca do cliente.
8. **Origem fechada.** Copio um texto num aplicativo X11, fecho o aplicativo, e colo no Ghostty. Esperado: pode não colar nada (é o comportamento do Wayland). Depois, Super+V, Enter no item e Ctrl+V: cola.
9. **Imagem.** Copio uma imagem no Firefox ("Copiar imagem") e colo num aplicativo que aceite imagem. No Super+V: um item só, de imagem, com a prévia.
10. **Teclado e gestos.** Com o histórico aberto, digito na busca um texto com acentos pelo `us altgr-intl` (AltGr+vírgula para "ç", AltGr+e para "é"). Fecho, e confiro que os gestos de três dedos do touchpad do Niri continuam trocando de workspace e de coluna.

**FAIL** da fase: o colar só funciona entre aplicativos Wayland (os passos 1, 2, 4 ou 7 falham), ou o teclado ou os gestos mudam com a shell aberta.
