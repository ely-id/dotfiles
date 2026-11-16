# 13 · Ajustes e subpáginas

**Nova?** não (refino; as telas que faltavam na 1ª referência estão aqui)  
**Board:** `13:15787`  
**PNG:** `referencias/armitage/06-ajustes-chiba.png`  
**QML da Pond:** `settings/Window.qml`, `Modal.qml`, `CategoryButton.qml`, `SessionButton.qml`, `Tray.qml`, `Style.qml`, `Switcher.qml`, `Dropdown.qml`, `Field.qml`, `system/Panel.qml`, `Mouse.qml`, `Lock.qml`, `Idle.qml`, `Picker.qml`, `State.qml`, `display/Panel.qml`, `Arrange.qml`, `Monitor.qml`, `information/Panel.qml`, `Label.qml`, `Footer.qml`, `manual/Panel.qml`, `NavigationTutorial.qml`, `appearance/WallpaperPicker.qml`, `WallpaperTile.qml` (spec §3.20–3.25, §3.27)

Os textos desta ficha estão em português como referência de sentido. Na shell eles aparecem em inglês (decisão 0012, 2026-11-15).

## Tela inicial

- Tela cheia com véu `scrim` 80%. Composição **672×536** (cartões + sessão).
- Cartão de categoria **264×264** raio 16, passo **272** (Pond usava 274, fora da grade). Ícone em tile 48×48 raio 12 em (32,32); nome Geist Serif 32 em (32,184). Hover: vidro + `accentRing` e seta `arrow-up-right` `accentText` em (212,32).
- Quatro cartões: Aparência, Bluetooth, Sistema, Informações. (Wi-Fi e Som continuam pelos controles da barra; Bluetooth também tem cartão aqui.)
- Botão de sessão **128×128** raio 12, passo **136** (Pond 127). Círculo 80×80 raio 40 em (24,24), ícone 20 no centro. Hover de Desligar: o botão inteiro vira `danger` e o nome aparece à direita em Serif 32 `dangerText`, **60 ms depois**. Bloquear / Suspender / Reiniciar: o mesmo padrão com a cor de acento (não com perigo). Ponto `dangerText` 8×8 no Desligar em repouso.
- Bandeja no topo (ícones 16 em botões 36×36 raio 6, faixa 204×44 raio 8).
- Perfil de energia na borda direita: coluna 48×136 com três botões ícone 40 (Economia, Equilibrado selecionado, Desempenho). O ícone do Desempenho é `zap`, o mesmo do pop-up da bateria (P-07, 2026-11-15).
- Selo de atualização embaixo: pílula `accentSubtle`, ícone + “N atualizações disponíveis” `accentText`. A contagem vem do estado do Cachy Update (decidido em 2026-11-14, P-32).
- Entrada: cada cartão 0,86→1 em ordem aleatória, **28 ms** entre eles, cada um em 32 ms (`settings/Window.qml:369-421`). Fechar 180 ms.
- Conferido no Figma em 2026-11-15 (`F4-T01`, nós `13:15797` e `13:15855`), o que esta ficha não dizia:
  - Cartão em repouso: bloco do ícone em `control`, sem borda. No hover o bloco vira `accentSubtle` com anel `accentRing` de 1 px e o rim do cartão inteiro vira `accentRing`.
  - Botão de sessão: vidro de raio 12 **sem** o brilho do acento, círculo em `control`. No hover o rim some, o círculo vira `#0D0E11` a 55% e o ícone continua `text`. O nome aparece com opacidade cheia (a origem usava 70%), em caixa de 48 a partir de x 144. O ponto do Desligar some no hover.
  - Perfil de energia: vidro de raio 16 sem o brilho do acento. Ícones de repouso em `text` a 100%; o selecionado é o botão ícone Selecionado (`accent` + `onAccent`). Sem a aba de 16×5 em cima e sem o rótulo de hover que a origem tinha (P-44, 2026-11-15: "Pode manter igual o Figma").
  - Bandeja: só a borda `border` de 1 px, sem fundo nem desfoque; botões a cada 40 a partir de (4,4).
  - Selo: 248×32, raio 8 (não é pílula de raio cheio), ícone `download` de 16 à esquerda em (12,8) e texto a partir de x 36. Os outros estados da origem (atualizando, concluída, reiniciar) usam a mesma pílula.
  - A composição fica no centro da tela, como na origem. No quadro de 1120×680 do Figma ela começa em y 80, 8 px abaixo do centro, porque o quadro não é a tela real.

## Modal padrão

- Largura **580**, raio 32, título Geist Serif 32 em (30,20) caixa (w−80)×44. X pendurado em (w−20, 7).
- Linhas de ajuste 520×52 a cada **60** (Pond 51), x 30, a partir de y 84.

## Sistema — 580×288

Linhas com seta: Mouse e touchpad, Bloqueio e suspensão, Idioma do teclado. O Figma desenha 580×348 com uma quarta linha, Fuso horário, que saiu na `F4-T02` (ver abaixo); com três linhas o modal tem 84 + 3 × 60 − 8 + 32 = 288. O valor do Mouse é "Default" quando os dois aparelhos estão no passo 5 e "Custom" fora disso.

### Mouse e touchpad — 580×452

- Dois sliders de **480** (trilho 12 raio 6, 9 marcas a cada 60, alça 24 `knob`), rótulo 15 + valor `muted`. Conferido no Figma (`13:15927`): marcas `borderStrong` de 1×8 a 8 px do trilho, valor "N de 9" 13 Medium, legendas "Lento" e "Rápido" 11 Medium `muted` a 20 px do trilho, alça com a sombra do vidro pela metade. Um slider é o **touchpad** e o outro é o **mouse**, cada um com o próprio `accel-speed`: o passo 5 é o 0 do Niri e cada passo anda 0,25. O `scroll-factor` da origem não aparece mais.
- Chave “Aceleração do ponteiro”.
- Linha “Rolagem natural” com seletor Touchpad / Mouse. A nota do Figma diz "rolagem natural por aparelho": cada metade liga ou desliga a rolagem natural do próprio aparelho e a metade acesa é a que está ligada (as duas podem ficar acesas ou apagadas). Confirmado em 2026-11-15 (P-47): "ambas são uma espécie de toggle".

### Bloqueio e suspensão — 580×420

- Seletor “Na tomada” / “Na bateria”.
- Valores: Bloquear a tela, Desligar a tela, Suspender. Chave “Pedir senha ao acordar”. Conferido no Figma (`13:15971`): o seletor fica em (30,84) e as linhas começam em 144, sem número na frente (a origem numerava). Sem bateria o seletor some e as linhas sobem para 84, como na origem. A chave fica guardada no arquivo dos tempos de inatividade e passa a valer com a tela de bloqueio da F7. Cada valor abre o menu suspenso da origem, que não tem desenho Armitage ainda; fica assim por enquanto (P-46, 2026-11-15: "Manter como está no original por enquanto").

### Idioma do teclado / Fuso horário

- Fuso horário: a origem troca o fuso com uma regra de `sudo` sem senha. Procuro um caminho sem essa regra; se não houver um caminho limpo, a página de fuso sai e o relógio segue o horário do sistema (decidido em 2026-11-14, P-34).
- **Resultado da pesquisa (2026-11-15, `F4-T02`):** não há caminho limpo. O `timedatectl` passa pelo `systemd-timedated`, cuja ação `org.freedesktop.timedate1.set-timezone` pede `auth_admin_keep` até para a sessão ativa, e a sessão do Niri não tem agente do polkit para mostrar o pedido de senha. Os caminhos que sobram são uma regra de `sudo`, uma regra do polkit ou instalar um agente do polkit na sessão. **A página de fuso saiu**, o relógio segue o horário do sistema e o `control.py` deixou de precisar do PyQt6.
- Modal com busca 520×44 (caret no acento) + lista 520×44. Escolhida: fundo `accentSubtle`, check `accentText`, código Mono 11 vira `text` (não `muted`). Conferido no Figma (`13:15984`): busca em `control` com anel `accentRing` de 1 px quando tem foco e lupa de 16 em `text` em (16,14), texto 15 em x 44; opções a partir de y 140, nome 13 Medium em x 16, código alinhado à direita em 476, check em (488,14), hover `hover`. O código sai do identificador do layout (`br(dvorak)` vira `br · dvorak`). O chip "Shortcut" da origem não está no Figma e saiu; o atalho de troca de layout vai para o Manual.
- Altura máxima da lista: 460, com rolagem (Pond `Picker.qml`).
- Inclua “Inglês (EUA, internacional)” / `us · intl` — é o layout do escopo.

## Tela — 580×644

- Desenho dos monitores **520×280** (Pond 520×281; alinhado à grade) raio 16, fundo `cardHover`, em (30,84).
- Monitores com raio 8; o selecionado usa `accentSubtle` + `accentRing` 2. Botão “Organizar”.
- Linhas: Escala, Resolução, Taxa de atualização, Sincronia adaptativa (VRR). Só aparecem quando há opção (comportamento da Pond).

### Organizar monitores — 580×500

- Área de arraste 520×320. Guia de encaixe 1 px em `accentText`. Monitor arrastado com sombra. “Cancelar” / “Concluído”.

## Informações — 580×620

- 7 linhas, passo 48. Número em círculo 24 (Geist Mono 11). Rótulo 15 `muted`. Valor Geist Serif 17.
- Use **dados fictícios** (como na prévia: CachyOS · Linux 6.17, máquina “Wintermute”, etc.). Não leia hardware real para preencher prints de documentação; no runtime, a Pond já busca valores em `information/State.qml` — pode manter a leitura, mas nada de serial, MAC ou hostname pessoal em material compartilhado.
- Botão Manual 520×64. Rodapé “Wintermute Shell” Serif 17 + versão Mono 11 `muted`. Grade de “+” 7×3 que some aos poucos no hover dos contatos (opacidade 1 / 0,6 / 0,3) — herdar a graça da Pond, nas medidas do Figma (152×56 em (398,536)).

## Manual — 500×656, sem título no modal

- Seletor Teclado / Touchpad no topo.
- Tutorial 440×240 raio 16 (a Pond tinha 440×420 + um SVG grande que **não** está neste pacote). Sigo o layout do Figma, não o SVG antigo (P-10, 2026-11-15: "Segue o do Figma").
- Lista de atalhos (teclas + texto `muted`). A lista sai das binds que configurei em `~/.config/niri/cfg/keybinds.kdl` e das anotações dele, mais estas, que defini em 2026-11-15 (P-11):
  - Super+Return: Terminal (a descrição fica só "Terminal").
  - Super+\`: recolher/expandir a barra da Wintermute. Substitui o Super+B.
  - Super+E: launcher.
  - Super+Shift+E: gerenciador de arquivos (Files).
  - Super+Escape: tela inicial dos Ajustes.
  - Super+Shift+Escape: atalho de emergência que devolve o teclado quando um app em tela cheia o segura (P-43). A lista de atalhos do Niri, que está nessa tecla hoje, depende da P-45.
  - Super+L: tela de bloqueio.
  - Capturas: Super+Shift+1, 2 e 3, como anotei no arquivo (hoje Ctrl+Shift+1, 2 e 3).
  - A área de transferência ainda não tem atalho; entra na lista quando a F6 definir.
- Os textos da lista ficam em inglês (decisão 0012). Posso trocar os binds depois, então eles ficam num único arquivo (`F4-T07`).
- Abre sozinho na primeira vez (`shell.qml:55-65`). Botão “Entendi” primário 440×40.

## Papel de parede — modal 624×608

- Grade 2×3 de miniaturas **276×156** raio 12 (Pond: 155 de uma das dimensões — refinado).
- Escolhida: anel `accent` 1 px com folga de 4 px + check 24 fundo `accent`.
- Hover: título e autor sobre degradê preto 0→80% na base.
- Tile “Escolher imagem” com traço tracejado `[4,4]`. “Dinâmico” pode permanecer (shader da Pond), visualmente como na prévia.
- As imagens da grade são as minhas, uma por variação (Chiba, Freeside, Sprawl), e moram no repositório. As fotos da origem não entram (decidido em 2026-11-14, P-31). Vão para o repositório só as versões de 1920×1080, em PNG, sem perda: medi os formatos sem perda mais leves e as seis imagens juntas ainda somariam 40 MB (P-37).

## A CONFIRMAR

- ~~Ícone do perfil Desempenho na home: `zap` aqui vs `rocket` no pop-up da bateria (ficha 08).~~ Definido em 2026-11-15 (P-07): `zap` nos dois lugares.
- ~~O tutorial do Manual da Pond era um SVG de 2,9 MB não baixado. Seguir o layout do Figma (440×240).~~ Definido em 2026-11-15 (P-10): segue o Figma.
- ~~Lista definitiva de atalhos.~~ Definida em 2026-11-15 (P-11), na seção do Manual.
