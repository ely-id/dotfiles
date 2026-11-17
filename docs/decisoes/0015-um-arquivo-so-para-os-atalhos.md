# 0015 — Um arquivo só para os atalhos: o Manual e as binds do Niri saem da mesma lista

- **Data:** 2026-11-17
- **Estado:** Aceita

## Contexto

Desde a `F4-T05` eu tinha duas listas de atalhos. Uma é a do Manual da shell, em `wintermute-shell/settings/manual/shortcuts.json`, com as teclas e a descrição de cada atalho. A outra é a que vale de verdade: o `keybinds.kdl` da minha configuração do Niri. Cada mudança precisava ser feita nas duas, à mão, e a `F4-T05` já tinha deixado as duas divergindo: o Manual mostrava as binds da P-11 (Super+\` para a barra, Super+E para o launcher, Super+Escape para os Ajustes) antes de elas existirem no Niri.

Na ficha 13 eu tinha escrito que posso trocar os binds depois e que por isso eles ficam num único arquivo. Faltava decidir qual arquivo e como ele chega ao Niri. As opções eram:

1. O `keybinds.kdl` como fonte, e o Manual lendo o KDL.
2. O `shortcuts.json` como fonte, com um script que gera o KDL.
3. Só as binds da shell num arquivo, e o resto continuando no meu `keybinds.kdl`.

## Decisão

A fonte é o `wintermute-shell/settings/manual/shortcuts.json`. Cada atalho tem a tecla como o Niri escreve (`bind`), a descrição em inglês (`label`) e uma ação: `niri` (ação do compositor), `spawn` (um programa), `sh` (um comando de shell) ou `ipc` (uma chamada ao IPC da shell).

- O Manual deriva as teclas que mostra a partir do `bind` (`Mod` vira Super, `Grave` vira \`, e assim por diante), em `settings/manual/State.qml`.
- `wintermute-shell/settings/manual/keybinds.py generate` escreve o bloco `binds { }` inteiro do Niri, e `check` confere a lista: bind repetida, item sem ação, campo desconhecido.
- A lista é completa: entram também as teclas de mídia e de brilho, com `"manual": false`, que as deixa fora do Manual.
- Um atalho cuja ação só existe numa fase futura leva `"waits"` com a fase, e sai comentado no KDL. É o caso do launcher (F5) e do bloqueio (F7). Não dou nome ao alvo de IPC antes de a peça existir.
- O título da lista de atalhos do Niri (`hotkey-overlay-title`) só sai nas binds marcadas com `"overlay": true`: as que já tinham título no meu arquivo e as da P-11 que abrem uma peça da shell. Nas outras o Niri usa a descrição dele. O campo só vale em atalho simples (uma linha que junta várias binds não o aceita) e o `check` o recusa junto com `"manual": false`, porque o título é o `label` que o Manual mostra.
- O comando de IPC leva a pasta da shell, que o gerador recebe em `--shell` ou tira do lugar onde o script mora. Nenhum caminho pessoal fica escrito no repositório.
- Escrever dentro de `~/.config` pede `--apply`, que guarda uma cópia do arquivo antes e só aplica se o `niri validate` aceitar.

## Motivo

**O JSON, e não o KDL,** porque o Manual já lia o JSON, e ler KDL dentro do QML pediria um interpretador só para isso. O JSON também deixa separar o que o KDL mistura: a tecla, a descrição e a ação viram campos, e o `check` consegue recusar um campo escrito errado, que no Niri sumiria em silêncio.

**A lista completa, e não só as binds da shell,** porque o Manual lista todos os atalhos, inclusive os do compositor. Com meia lista eu continuaria tendo dois lugares para manter.

**Gerar o bloco inteiro,** porque juntar um trecho gerado com um arquivo editado à mão é onde as duas listas voltariam a divergir. O arquivo gerado diz no cabeçalho que não se edita.

**`waits` em vez de um comando provisório,** porque a regra do projeto é não inventar: o nome do alvo de IPC do launcher é decisão da F5.

## Consequências

- Para mudar um atalho, edito o `shortcuts.json` e gero de novo. O `keybinds.kdl` deixa de ser editado à mão.
- A escrita no `~/.config/niri/cfg/keybinds.kdl` desta máquina fica para a sessão ao vivo (ajuste A-03), com `generate --output ... --apply`. Até lá o Manual e o Niri continuam divergindo nas binds da P-11.
- As linhas comentadas que o meu `keybinds.kdl` guarda (atalhos da shell anterior, valores antigos de volume) não passam para o arquivo gerado. A cópia `.bak` que o `--apply` deixa ao lado guarda o arquivo antigo.
- A F5 e a F7 trocam o `waits` do launcher e do bloqueio pela ação, e a F6 troca as capturas do Niri pelas da shell, tudo nesse arquivo.
- A F8, que recolhe a configuração do Niri para `niri/`, não copia o `keybinds.kdl`: ele é gerado. O instalador da F10 roda o gerador com a pasta em que a shell foi instalada.
- A tabela que traduz o nome da tecla do Niri para o que o Manual mostra mora no `State.qml`. Uma tecla nova fora da tabela aparece no Manual com o nome do Niri.
