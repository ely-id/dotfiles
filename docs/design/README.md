# Design — Armitage

Esta pasta é a fonte da verdade visual da Wintermute Shell em formato de texto. A regra que vale para todo o projeto: **nenhum valor é inventado**. Cor, medida, raio, tempo e tipografia saem daqui. Quando um valor falta, eu pergunto e registro a pendência; não estimo.

## O que tem aqui

| Caminho | Conteúdo |
|---|---|
| `tokens/tokens.json` | Paleta, vidro, tipografia e os contrastes medidos das três variações |
| `tokens/Theme.qml` | O mesmo conjunto como singleton QML, pronto para a shell ler |
| `pecas/` | Uma ficha por peça ou grupo: medidas, estados, comportamento e pendências |

Na fase F0, o `Theme.qml` passa a morar em `wintermute-shell/` e este diretório mantém só o `tokens.json` como registro do que foi aprovado.

## Regras fixas do visual

- A shell é sempre escura. Os aplicativos continuam podendo alternar claro e escuro.
- Três variações (Chiba, Freeside, Sprawl) que mudam **apenas** o acento. Os neutros e o layout são idênticos.
- Texto secundário é `#C2C4C7`. Texto ou ícone colorido usa `accentText`, `dangerText`, `successText` ou `attentionText`. O acento puro só aparece em fundos e detalhes. Texto sobre acento é `onAccent` (`#0D0E11`).
- Títulos em Geist Serif, corpo em Geist, números em Geist Mono. Espaçamento entre letras em zero.
- Grade de 4 px. Nenhuma posição fracionada. Ícone sempre no centro geométrico do botão.
- Ícones de interface: Lucide.

## Fichas por fase

| Fase | Fichas |
|---|---|
| F1 | `00-componentes-base` |
| F2 | `01-barra-lateral`, `02-organizador`, `03-controles`, `04-cartoes` |
| F3 | `05-wifi`, `06-bluetooth`, `07-som`, `08-bateria`, `09-calendario`, `10-notificacoes-toast-osds`, `11-aparencia`, `12-idlefade` |
| F4 | `13-ajustes` |
| F5 | `14-launcher`, `15-color-picker`, `16-emoji` |
| F6 | `17-screenshot`, `18-clipboard`, `19-desktops` |

## Figma

Arquivo: [Wintermute Shell](https://www.figma.com/design/NNTSBuWuiTGYpvlEVFXKLU/Wintermute-Shell?node-id=3-1257)

| Board | node-id | Fase |
|---|---|---|
| Página Wintermute Shell · Armitage | `3:1257` | todas |
| Prévia das 3 variações | `13:9418` | F0 |
| Ícones Lucide (16 e 20) | `13:10065`, `13:10641` | F0 |
| Biblioteca de componentes | `13:11217` | F1 |
| 1 · Componentes base | `13:11463` | F1 |
| 2 · Barra lateral + organizador | `13:12277` | F2 |
| Variante Janela do workspace / Recolhida focada (32 px) | `13:11395` | F2 |
| 3a · Painéis Wi-Fi e Bluetooth | `13:13604` | F3 |
| 3b · Pop-ups, cartões e OSDs | `13:14610` | F3 |
| 4 · Ajustes | `13:15787` | F4 |
| 5a · Launcher, seletor de cor e emoji | `13:17120` | F5 |
| 5b · Captura de tela e área de transferência | `13:19344` | F6 |
| 6 · Desktops completos | `13:20899` | F6 |
| Página Pond · referência (shell original) | `0:1` | consulta |

O Figma é consulta visual. Quando ele e uma ficha divergirem, registro a divergência como pendência e pergunto; não escolho sozinho.

## Imagens de referência

As PNGs de aceite não estão no repositório ([decisão 0005](../decisoes/0005-referencias-fora-do-git.md)). Nas fichas, um caminho como `referencias/armitage/03-barra-organizador-chiba.png` se resolve em:

```
~/Projects/referencias/dotfiles-estudo/pacote-entrega-original/referencias/armitage/
~/Projects/referencias/dotfiles-estudo/pacote-entrega-original/referencias/pond/
```

Quem não tiver essa pasta exporta o board correspondente direto do Figma, pelos node-ids da tabela acima.

## Como ler as citações de origem nas fichas

As fichas foram escritas antes de este repositório existir e citam materiais pelos nomes que tinham na origem. A correspondência é esta:

| Citação na ficha | O que é | Onde consultar hoje |
|---|---|---|
| "QML da Pond", `shell/...`, `minimap/...`, `Arquivo.qml:linha` | Arquivo do código de origem da shell | `~/Projects/referencias/dotfiles-estudo/pond-interface/shell/` |
| `fonte/...` | Raiz do código de origem | `~/Projects/referencias/dotfiles-estudo/pond-interface/` |
| `config/niri/...` | Configuração de exemplo do Niri na origem | `~/Projects/referencias/dotfiles-estudo/pond-interface/config/niri/` |
| `spec` §N, `spec-pond-shell.md` | Especificação de comportamento da shell de origem | **Não recebi este arquivo.** Até ele aparecer, a fonte é o próprio código de origem |
| `g2.src.js`, `g6.src.js`, `armitage-shell/figma/...` | Scripts que geraram os boards no Figma | **Não recebi.** O valor citado na ficha é o que vale; o board do Figma serve de conferência |
| `armitage-shell/status.md` | Registro da correção do organizador recolhido | **Não recebi.** A correção está descrita na ficha `02-organizador` e no board `13:11395` |

As referências de linha (`NiriMsg.qml:380-507`) apontam para a versão do código de origem que existia quando as fichas foram escritas. No clone de estudo as linhas podem ter se deslocado: procuro pelo nome da função ou do bloco, não pelo número.

## Pendências de design

Cada ficha termina com uma seção *A CONFIRMAR*. Todas estão consolidadas, com identificador e fase, em `PENDENCIAS.md` no painel do projeto. Uma pendência só sai da lista quando eu respondo, e a resposta é copiada para a ficha.
