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
2. **Barra recolhida (10 + 48).** Recolher (Super+B ou o botão) devolve 108 px às janelas, em 300 ms. No Figma a primeira janela está em **x 80**.
3. **Launcher aberto** (Super+Espaço ou “+”; pela P-11, de 2026-11-15, o atalho é o Super+E, e o Super+Espaço troca o layout do teclado). Véu preto **20%** sobre o desktop; launcher em (400, 160) no frame 1440×900.
4. **Captura em andamento.** Seleção começando do zero; barra de modos embaixo; ações ao lado da seleção. Exemplo da composição: seleção 640×400 em (560, 180).

## Véu à esquerda

Faixa de degradê preto 40%→0 atrás da barra, para contraste (`g6.src.js` `VEIL`, largura 656 no frame 1440). A Pond usava 40%→0 em 788/1728 da largura (`spec` §3.27). São razões parecidas, não idênticas.

## Janelas de app nas prévias

São genéricas (Ghostty, Firefox, Arquivos). Não é para clonar o conteúdo; é para conferir gaps, raios (12), anel de foco e a reserva da sidebar.

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
