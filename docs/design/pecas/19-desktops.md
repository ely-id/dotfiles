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
- **Anel de foco do niri.** Pond: 2 px cinza `#8a8a8a99` / `#50505055` (`spec` §5). Figma: anel `accent` 2 px na janela focada. É uma mudança visual aprovada no desktop do Armitage, mas mexe em `config/niri/`. Só altero o config do niri depois de confirmar esta mudança (ver pendência no painel do projeto).
