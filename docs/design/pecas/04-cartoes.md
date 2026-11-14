# 04 · Cartões da barra (relógio, mídia, notificações, instalações)

**Nova?** não (refino)  
**Board:** `13:12277` (relógio, mídia, notificações) e `13:14610` (instalações)  
**PNG:** `03-barra-organizador-chiba.png`, `05-popups-cartoes-osds-chiba.png`  
**QML da Pond:** `calendar/Clock.qml` (spec §3.3), `media/Player.qml` (§3.5), `notifications/SidebarCard.qml` (§3.6), `installs/SidebarCard.qml` e `Indicator.qml` (§3.9)

## Relógio + bateria

Aberto: cartão **156×76** (Pond era 75; alinhado à grade).

- Hora em Geist Serif 36, caixa 88×40 em (12,8), formato `h:mm` (exemplo 14:32). Sem AM/PM no desenho Armitage (a Pond tinha AM/PM em 11 px).
- Chip da data 40×40 em (104,8), raio **8** (Pond era 6 e y 9), borda `borderStrong`, sem fundo. “sex” 11 `muted` no topo; “13” 13 `text` embaixo, ambos centrados.
- Trilho da bateria 132×**4** (Pond era 2) em (12,60), raio 2, fundo `track`. Carga = largura × % na cor `text` a 80% (nas prévias; carregando / baixo usam `success` / `danger` — herdar a lógica da Pond, com as cores Armitage).
- Hover na hora: retângulo 148×50 em (4,4), raio 8, fundo `hover`. Clicar abre o calendário (ficha 09).
- Recolhido: cartão **48×156** (Pond 155). Hora em duas linhas Geist Mono 13 (“14” / “32”), divisor, dia da semana abreviado “SX” `muted` + número do dia, divisor, ícone de bateria 16 numa caixa 32×32 raio 8 em (8,116).

Outros estados da Pond (bateria baixa com faixa de aviso, pílula de % no hover da barra, altura 115) **não foram desenhados à parte no Figma**. Herdar o comportamento, aplicando tokens (`dangerText`, etc.) e grade de 4. Se um estado faltar medida nova, **pergunte** antes de inventar o layout.

## Mídia

- Repouso: 156×64. Capa genérica 40×40 raio 8 em (12,12). Título 13 em (60,12) caixa 84×20; artista 13 Regular `muted` em (60,32).
- Hover: cresce para **156×92**. Três botões ícone 32 em y 56, x 30 / 62 / 94 (voltar, pause selecionado, avançar). 180 ms (`Theme.mediaRevealDuration`).
- Recolhido: 48×48, capa 32×32 raio 8 em (8,8).
- A capa nas prévias é placeholder. Ícones de app/álbum reais no sistema, se existirem; senão o placeholder genérico.

## Notificações (cartão da barra)

- 156×48. Vazio: ícone `bell` 16 em (16,16) + texto “Notificações”.
- Com itens: ícone + contagem (ex. “3”) + divisor + até 3 ícones de app (os que não cabem ficam apagados a 40%).
- Recolhido: 48×48, sino 16 no centro, ponto não lido 6×6 `accent` em (28,14).
- Chegando (board 3b): o cartão cresce de 48 para 156 e mostra uma prévia 140×104 raio 12, em 300 ms. Ver ficha 10.
- Clique abre a central (ficha 10).

## Instalações

- Cartão 156×88. Linhas de 32 de altura com ícone, nome e, à direita, anel de progresso 16 (trilho `track`, arco `accent`, innerRadius 0,69) ou check `successText` ao terminar.
- Comportamento da Pond permanece (`installs/State.qml`).
