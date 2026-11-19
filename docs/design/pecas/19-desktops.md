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

- **Exclusive zone vs recuo do Figma.** Pond: `exclusiveZone = 10 + 156` ou `10 + 48`, e o gap do niri é **10** (`config/niri/shell/layout.kdl:3`). Figma: janelas em 188 / 80, o que bate com (10+156 ou 10+48) + 10 + gap **12**. Não mude o gap nem a zona sozinho: pergunte se a folga fica 10 (Pond) ou 12 (Figma), e se a zona permanece 166/58.
- **Anel de foco do niri.** Resolvido na P-19 ("ok"). Pond: 2 px cinza `#8a8a8a99` / `#50505055` (`spec` §5). Figma: anel `accent` 2 px na janela focada. Fico com o do Figma: o anel usa o acento da variação, e a shell reescreve a cor na configuração do Niri quando a variação muda, num arquivo só dela marcado `wintermute` (P-35). Como funciona, na seção "Anel de foco: como funciona (`F6-T08`)", logo abaixo.

## Anel de foco: como funciona (`F6-T08`)

O anel de foco das janelas é do Niri, não da shell, então a shell só escreve a cor dele. Escrevo num arquivo que é só da shell, `~/.config/niri/cfg/wintermute.kdl` (o caminho respeita `XDG_CONFIG_HOME`), e nunca edito os outros arquivos da minha configuração. O arquivo começa com um comentário `[wintermute]` que diz que é gerado e por quem, e tem só isto:

```kdl
layout {
    focus-ring {
        width 2
        active-color "#52C2F6"
    }
}
window-rule {
    geometry-corner-radius 12
    clip-to-geometry true
}
```

- **De onde vêm os valores.** A largura 2 é o anel de acento de 2 px do estado 1 desta ficha. O raio 12 é o das janelas ("raios (12)" na seção das janelas de app e, na ficha 17, o anel de 14 da captura em volta de uma janela de 12). A cor é `Theme.accent` da variação em uso, em `#RRGGBB` maiúsculo: `#52C2F6` (Chiba), `#7F89E1` (Freeside) ou `#F4A846` (Sprawl). Não defino a cor do anel inativo: o Niri tem um `inactive-color` próprio para o anel, e eu deixo o padrão dele. Com mais de um monitor, a janela ativa do monitor que não está com o foco usa essa cor padrão, e isso eu vejo ao vivo. Não ponho `gaps` nem `struts`: a folga e a reserva da barra são da `F6-T07`.
- **Quem escreve e quando.** O `settings/appearance/niri_theme.py` (`generate --accent "#RRGGBB" [--output ARQUIVO]`, e `check`, que só mostra o que escreveria) valida a cor (exatamente `#` e seis dígitos hexadecimais ASCII, sem espaço nem quebra de linha antes ou depois; qualquer outra coisa dá erro e nada é escrito), passa o texto pelo `niri validate -c` num arquivo temporário (sem o `niri` no `PATH`, escreve e avisa que não validou), troca o arquivo de forma atômica (quando o caminho é um link simbólico, escreve no alvo e o link continua link; um link quebrado vira arquivo novo no alvo) e não reescreve quando o conteúdo já é o mesmo, para o Niri não recarregar à toa. Ele se recusa a escrever num arquivo que já existe (no alvo, se for link) sem o marcador `[wintermute]` na primeira linha, para nunca passar por cima de um arquivo meu. O `settings/appearance/NiriTheme.qml` chama o script: uma vez quando a shell de verdade começa (o `shell.qml` chama `start()`; a vitrine e a bancada não chamam e não tocam na configuração do Niri) e toda vez que o acento muda. Ele espera a primeira leitura do `theme.json` para não escrever o acento padrão antes da minha escolha chegar. Se o script falha, sai uma linha de aviso no log e a shell segue.
- **O que eu faço à mão, uma vez.** O Niri observa todos os arquivos incluídos e recarrega sozinho quando um muda, mas só inclui o que o `config.kdl` pede. A linha `include "./cfg/wintermute.kdl"` vai no fim do `config.kdl`, depois do `rules.kdl`, para o raio 12 vencer o 20 de lá (as regras de janela entram na posição do `include`). A shell não escreve nessa linha. Sem ela o arquivo existe e não tem efeito.
- **Como desfazer.** Tiro o `include` do `config.kdl` e apago o `wintermute.kdl`. A shell o recria quando abrir de novo, mas sem o `include` ele não vale de nada.
- **O que nunca rodou de verdade.** Testei o script e a chamada da shell contra pastas temporárias, e o `niri validate` aceita o `config.kdl` que inclui cópias do meu `layout.kdl` e do meu `rules.kdl` e depois o `wintermute.kdl`. Nunca rodou contra a minha sessão do Niri: o `include` real, o recarregamento automático, o anel desenhado no acento certo e o raio 12 vencendo o 20 só se veem ao vivo, no QA, trocando a variação nos Ajustes.
