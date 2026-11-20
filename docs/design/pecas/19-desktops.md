# 19 · Desktops completos

**Nova?** não (composição das peças)  
**Board:** `13:20899`  
**PNG:**
- `09-desktop-chiba-aberta.png`
- `09-desktop-chiba-recolhida.png`
- `09-desktop-freeside-aberta.png`
- `09-desktop-freeside-launcher.png`
- `09-desktop-freeside-recolhida.png`
- `09-desktop-sprawl-aberta.png`
- `09-desktop-sprawl-recolhida.png`
- `09-desktop-sprawl-captura.png`

As peças são as mesmas dos boards 2 e 5a/5b, montadas num desktop **1440×900**. Serve de aceite final da fase 6.

## Quatro estados, nas três variações

1. **Barra aberta (10 + 156).** Janelas do niri começam depois da barra. Na composição do Figma, a primeira janela está em **x 188**. Janela focada com anel de **acento 2 px**, raio 12; a coluna seguinte pode sair da tela (niri).
2. **Barra recolhida (10 + 48).** Recolher (o botão, ou Super+` pela lista de atalhos da shell; a origem usava Super+B) devolve 108 px às janelas, em 300 ms. No Figma a primeira janela está em **x 80**.
3. **Launcher aberto** (Super+Espaço ou “+”; pela P-11, de 2026-11-15, o atalho é o Super+E, e o Super+Espaço troca o layout do teclado). Véu preto **20%** sobre o desktop; launcher em (400, 160) no frame 1440×900.
4. **Captura em andamento.** Seleção começando do zero; barra de modos embaixo; ações ao lado da seleção. Exemplo da composição: seleção 640×400 em (560, 180).

## Véu à esquerda

Faixa de degradê preto 40%→0 atrás da barra, para contraste (`g6.src.js` `VEIL`, largura 656 no frame 1440). A Pond usava 40%→0 em 788/1728 da largura (`spec` §3.27). São razões parecidas, não idênticas (656,7 contra 656 num desktop de 1440). Desde a `F6-T09` o papel de parede (`wallpaper/desktop/Content.qml`) usa a do Figma, `656 / 1440`.

## Janelas de app nas prévias

São genéricas (Ghostty, Firefox, Arquivos). Não é para clonar o conteúdo; é para conferir gaps, raios (12), anel de foco e a reserva da sidebar.

## Conferência fora do Niri (`F6-T09`)

O desktop de verdade só existe na sessão do Niri: as janelas, a zona da barra e o anel de foco são do compositor. Fora dele, o que dá para conferir é a composição das peças da shell. Para isso existe o espécime `demo/DesktopSpecimen.qml`, um palco de 1440×900 com quatro estados (`open`, `collapsed`, `launcher`, `capture`), que a bancada grava nas três variações com `--margem 0`.

**O que é peça de verdade no espécime:** o papel de parede com o véu, os cartões da barra (relógio, organizador, mídia, notificações e controles de baixo, nos modos de prévia), o launcher e a captura. **O que é dado de exemplo:** as duas janelas de aplicativo (`demo/SampleWindow.qml`), o anel de foco e a seleção da captura.

Medidas do board (`13:20899`, variação Chiba) que o espécime reproduz:

| O quê | Board | Nó |
|---|---|---|
| Janelas, barra aberta | "Firefox" em (188,12) com 744×876; "Ghostty" em (948,12) com 480×876 | `13:20908`, `13:20917` |
| Janelas, barra recolhida | "Firefox" em (80,12) com 808×876; "Ghostty" em (904,12) com 524×876 | `13:20987`, `13:20996` |
| Dentro da janela | barra de título de 40; imagem em (24,64), com a largura da janela menos 48 e 368 de altura; cinco linhas de 10 em y 464, 488, 512, 536 e 560 | `13:20909` a `13:20916` |
| Pilha da barra | em (10,10), com 156 ou 48 de largura e 880 de altura; os controles terminam em y 890 | `13:20936`, `13:21015` |
| Launcher | véu de 20% nos 1440×900; vidro de 640×496 em (400,160) | `13:21139`, `13:21140` |
| Captura | seleção de 640×400 em (560,180); pílula de tamanho de 88×24 em (560,148); pílula de ações de 208×48 em (992,588); barra de modos de 496×56 em (472,812) | `13:21289`, `13:21298`, `13:21300`, `13:21306` |
| Véu da barra | preto de 40% a 0, de x 0 a 656 | `13:21209` |

No espécime os nomes das janelas são "Browser" e "Terminal", sem texto dentro, porque dado de exemplo não leva nome de aplicativo nem saída de terminal.

**O que bate com o board,** medido nos prints das três variações: a pilha da barra em (10,10) com 156 e 48, e os controles terminando em y 890; as janelas em x 188 e 948 (aberta) e em x 80 e 904 (recolhida), de y 12 a 888, terminando em x 1428; o véu da barra, linear de 40% a 0 em 656; o véu de 20% do launcher e o vidro de 640×496 em (400,160); e, na captura, a seleção, a borda, as oito alças, a pílula de tamanho em (560,148) e a pílula de ações em (992,588), com o escurecimento de 45% por fora, inclusive sobre a barra.

**O que não bate, e fica como está:**

- **A barra de modos da captura** fica em y 820 (a 24 da base, como no board da captura, ficha 17) e o board do desktop a põe em y 812 (a 32). É a P-90.
- **O anel de foco** fica por fora da janela, de x 186 a 934 e de y 10 a 890 com a barra aberta, que é como o `focus-ring` do Niri desenha. O board o põe por dentro do quadro da janela (188 a 190). Também é a P-90.
- **O papel de parede.** O board tem um fundo desenhado, azul-escuro. O espécime usa o céu da shell fixo em 13 de novembro de 2026, 14:32, que é claro e acinzentado; isso muda o tom do vidro dos cartões. Na sessão do Niri o fundo é o papel de parede que eu escolher.
- **O organizador** lê o Niri, e fora dele não tem workspaces: aberto, aparece como um cartão vazio de 156×160 (a altura do board); recolhido, some, e os cartões de baixo sobem 266 px em relação ao board. O espécime não inventa workspaces, para não escrever no estado de verdade.
- **Os dados de prévia dos cartões** são os que a barra já usa com `demoCards`, e não os do board: a bateria em 76% (o board mostra cerca de 72%), os ícones de notificação `hash`, `mail` e `terminal` (o board tem `mail`, calendário e download), e o primeiro botão dos controles mostra o glifo de sem rede, porque fora da shell não há rede para ler.
- **As janelas de exemplo** têm o corpo 5 níveis mais claro que as do board (`#1B1D22` contra `#16181D`) e a barra de título 6 níveis mais clara (`#24262C` contra `#1E2026`), porque usam o desenho que o espécime da captura já tinha. Também não têm o título ("Firefox", "Ghostty") nem a saída de terminal que o board desenha. Não são peça da shell.
- **O hover** da terceira linha do launcher, que o board mostra, não está no print.
- **O vidro do launcher** sai bem mais escuro que o do board: na média de cada faixa, 10 contra 19 no topo, 14 contra 37 no meio e 19 contra 48 no rodapé (de 255). Não vem desta tarefa: o print avulso do launcher da F5 já saía assim contra o board `07-launcher-ferramentas-chiba.png`. A bancada não tem o desfoque do compositor, que é o que clareia o vidro com o que está atrás; se ao vivo ele continuar mais escuro que o board, a diferença é da peça, e vira ajuste no QA da F5.
- **O idioma:** a shell é em inglês (decisão 0012) e as referências, em português.

**O que só se confere ao vivo:** os quatro desktops com janelas de verdade, que são o critério de aceite da fase. O roteiro está no handoff da F6.

## A CONFIRMAR

- **Exclusive zone vs recuo do Figma.** Resolvido na P-18 e na P-88 (opção A, o Figma). Pond: `exclusiveZone = 10 + 156` ou `10 + 48`, e o gap do niri é **10** (`config/niri/shell/layout.kdl:3`). Figma: janelas em 188 / 80. Fico com o Figma: zona de 176 e 68, 12 nas bordas e 16 entre colunas. Como funciona, na seção "Zona da barra e folga das janelas (`F6-T07`)", logo abaixo.
- **Anel de foco do niri.** Resolvido na P-19 ("ok"). Pond: 2 px cinza `#8a8a8a99` / `#50505055` (`spec` §5). Figma: anel `accent` 2 px na janela focada. Fico com o do Figma: o anel usa o acento da variação, e a shell reescreve a cor na configuração do Niri quando a variação muda, num arquivo só dela marcado `wintermute` (P-35). Como funciona, na seção "Anel de foco: como funciona (`F6-T08`)", logo abaixo.

## Zona da barra e folga das janelas (`F6-T07`)

Medi no board dos desktops (`13:20899`, quadros `13:20907`, barra aberta, e `13:20986`, recolhida), num desktop de 1440×900:

| O quê | Valor | De onde sai |
|---|---|---|
| Quadro da barra, aberta | **176** | 10 + 156 + 10: a margem, o cartão e a margem de novo |
| Quadro da barra, recolhida | **68** | 10 + 48 + 10 |
| Primeira janela, barra aberta | **x 188** | 176 + 12 |
| Primeira janela, barra recolhida | **x 80** | 68 + 12 |
| Topo e base das janelas | **y 12**, altura 876 em 900 | 12 em cima e 12 embaixo |
| Entre uma coluna e a outra | **16** | a primeira janela tem 744 a partir de 188 (termina em 932); a seguinte começa em 948 |

- **A zona é da shell.** A janela da barra (`Sidebar.qml`) reserva no Niri `sidebarOuterMargin + cartão + sidebarOuterMargin`: 176 aberta e 68 recolhida. A origem reservava só `10 + cartão` (166 e 58). Os 168 e 60 que a P-18 registrou deixaram de valer na P-88, porque não davam o x 188 do board.
- **A folga é do Niri.** O Niri tem um `gaps` só, que vale entre as colunas e nas bordas. Para ter 16 entre colunas e 12 nas bordas, o `gaps 16` fica como já está no meu `layout.kdl` e um `struts` negativo tira das bordas o que sobra: 12 − 16 = **−4**, nos quatro lados. A conta fecha: 176 − 4 + 16 = 188; 68 − 4 + 16 = 80; 0 − 4 + 16 = 12 no topo, na base e na direita. A documentação do Niri aceita `struts` negativos e descreve esse uso ("Configuration: Layout", `struts`: emular folga de dentro e de fora).
- **Onde os `struts` moram.** No arquivo da shell, o `wintermute.kdl` da seção seguinte, junto do anel de foco: é o que a shell precisa do Niri para o desktop sair como no board, fica marcado `[wintermute]` (P-35) e some quando eu tiro o `include`. O `gaps` não vai para lá: a P-88 diz "`gaps 16` como já está", e ele continua no meu `layout.kdl`. Pela documentação do Niri ("Configuration: Include", "Merging"), o `layout` de um arquivo incluído depois é mesclado campo a campo com o anterior, e o `struts` é das poucas seções que não se mesclam: o bloco de quem vem depois substitui o anterior inteiro. Por isso o `struts {}` vazio do meu `layout.kdl` dá lugar aos −4, e o `gaps 16` continua.
- **Um depende do outro.** Os −4 só dão 12 nas bordas com o `gaps` em 16. Se eu mudar o `gaps` no `layout.kdl`, a borda muda junto (`gaps` − 4). A F8 recolhe os dois arquivos.
- **A animação de recolher** (os 108 px devolvidos às janelas) é do Niri, que move as janelas quando a zona muda; a shell só troca a zona.
- **O que nunca rodou de verdade.** A zona só existe com a barra numa sessão do Niri, e os `struts` só valem com o `include`. Vejo ao vivo: a primeira janela em x 188 com a barra aberta e em x 80 recolhida; 12 no topo, na base e na direita; 16 entre duas colunas; uma janela em tela cheia e uma maximizada sem sobra nem corte; e o `gaps` do meu `layout.kdl` continuando a valer.

## Anel de foco: como funciona (`F6-T08`)

O anel de foco das janelas é do Niri, não da shell, então a shell só escreve a cor dele. Escrevo num arquivo que é só da shell, `~/.config/niri/cfg/wintermute.kdl` (o caminho respeita `XDG_CONFIG_HOME`), e nunca edito os outros arquivos da minha configuração. O arquivo começa com um comentário `[wintermute]` que diz que é gerado e por quem, e tem só isto (os comentários de dentro ficaram de fora deste exemplo):

```kdl
layout {
    focus-ring {
        width 2
        active-color "#52C2F6"
    }
    struts {
        left -4
        right -4
        top -4
        bottom -4
    }
}
window-rule {
    geometry-corner-radius 12
    clip-to-geometry true
}
```

- **De onde vêm os valores.** A largura 2 é o anel de acento de 2 px do estado 1 desta ficha. O raio 12 é o das janelas ("raios (12)" na seção das janelas de app e, na ficha 17, o anel de 14 da captura em volta de uma janela de 12). A cor é `Theme.accent` da variação em uso, em `#RRGGBB` maiúsculo: `#52C2F6` (Chiba), `#7F89E1` (Freeside) ou `#F4A846` (Sprawl). Não defino a cor do anel inativo: o Niri tem um `inactive-color` próprio para o anel, e eu deixo o padrão dele. Com mais de um monitor, a janela ativa do monitor que não está com o foco usa essa cor padrão, e isso eu vejo ao vivo. Os `struts` de −4 são a folga das bordas, da seção anterior (`F6-T07`); o `gaps` não entra no arquivo.
- **Quem escreve e quando.** O `settings/appearance/niri_theme.py` (`generate --accent "#RRGGBB" [--output ARQUIVO]`, e `check`, que só mostra o que escreveria) valida a cor (exatamente `#` e seis dígitos hexadecimais ASCII, sem espaço nem quebra de linha antes ou depois; qualquer outra coisa dá erro e nada é escrito), passa o texto pelo `niri validate -c` num arquivo temporário (sem o `niri` no `PATH`, escreve e avisa que não validou), troca o arquivo de forma atômica (quando o caminho é um link simbólico, escreve no alvo e o link continua link; um link quebrado vira arquivo novo no alvo; um laço de links simbólicos, no arquivo ou numa pasta do caminho, é erro, nada é escrito e os links ficam como estavam, pela P-89) e não reescreve quando o conteúdo já é o mesmo, para o Niri não recarregar à toa. Ele se recusa a escrever num arquivo que já existe (no alvo, se for link) sem o marcador `[wintermute]` na primeira linha, para nunca passar por cima de um arquivo meu. O `settings/appearance/NiriTheme.qml` chama o script: uma vez quando a shell de verdade começa (o `shell.qml` chama `start()`; a vitrine e a bancada não chamam e não tocam na configuração do Niri) e toda vez que o acento muda. Ele espera a primeira leitura do `theme.json` para não escrever o acento padrão antes da minha escolha chegar. Se o script falha, sai uma linha de aviso no log e a shell segue.
- **O que eu faço à mão, uma vez.** O Niri observa todos os arquivos incluídos e recarrega sozinho quando um muda, mas só inclui o que o `config.kdl` pede. A linha `include "./cfg/wintermute.kdl"` vai no fim do `config.kdl`, depois do `rules.kdl`, para o raio 12 vencer o 20 de lá (as regras de janela entram na posição do `include`). A shell não escreve nessa linha. Sem ela o arquivo existe e não tem efeito.
- **Como desfazer.** Tiro o `include` do `config.kdl` e apago o `wintermute.kdl`. A shell o recria quando abrir de novo, mas sem o `include` ele não vale de nada.
- **O que nunca rodou de verdade.** Testei o script e a chamada da shell contra pastas temporárias, e o `niri validate` aceita o `config.kdl` que inclui cópias do meu `layout.kdl` e do meu `rules.kdl` e depois o `wintermute.kdl`. Nunca rodou contra a minha sessão do Niri: o `include` real, o recarregamento automático, o anel desenhado no acento certo e o raio 12 vencendo o 20 só se veem ao vivo, no QA, trocando a variação nos Ajustes.
