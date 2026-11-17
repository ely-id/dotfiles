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

## Tela — 580×704 (580×644 no Figma, que não tem a linha Orientation)

- Desenho dos monitores **520×280** (Pond 520×281; alinhado à grade) raio 16, fundo `cardHover`, em (30,84).
- Monitores com raio 8; o selecionado usa `accentSubtle` + `accentRing` 2. Botão “Organizar”.
- Linhas: Escala, Resolução, Taxa de atualização, Sincronia adaptativa (VRR). Só aparecem quando há opção (comportamento da Pond).
- Conferido no Figma em 2026-11-16 (`F4-T03`, nó `13:16041`), o que esta ficha não dizia:
  - O desenho tem borda `border` de 1. As linhas começam em y 380, 16 abaixo dele, e o modal fecha em 644 com 32 de base.
  - Monitor em repouso: `raised` com borda `borderStrong` de 1. Nome "N · nome" em 13 Medium `text` e conector em 11 Medium `muted`, em duas linhas de 20 centradas juntas. No selecionado o conector passa a `text` (regra 5 do tema). Monitores vizinhos ficam com folga de 4.
  - Botão “Organizar”: o secundário pequeno da ficha 00 (`control` com borda `border`, raio 8, 13 Medium), 96×32, a 16 da direita e da base do desenho. Só aparece com mais de um monitor, como na origem.
  - Valores: a escala em porcentagem ("125%"; a origem mostrava "1.25x") e a resolução com "×".
- A segunda linha de cada monitor é só o nome do conector (`eDP-1`, `HDMI-A-1`), sem o "principal" do board (P-48, 2026-11-16: "utilize apenas os nomes dos monitores").
- **Orientação** (P-49, 2026-11-16: "Quero de volta", de um jeito intuitivo e coerente com o desenho, a partir de uma referência com a linha "Orientation" e quatro opções). A rotação volta como a primeira linha da Tela, acima da Escala, com o menu suspenso das outras linhas. As opções são Landscape, Portrait right, Portrait left e Landscape (flipped), e cada uma traz à esquerda o ícone `monitor` de 16 girado do jeito que o monitor vai ficar (0°, 90° no sentido horário, 90° no anti-horário e 180°); o texto anda para x 36. O desenho dos monitores muda de forma ao aplicar. No Niri o `transform` gira no sentido anti-horário, então Portrait right é `90` e Portrait left é `270`; uma tela espelhada (`flipped-*`) continua espelhada. A linha aparece sempre que há um monitor selecionado, e o modal passa a 704 com as cinco linhas.
- Escolhas minhas na `F4-T03`, onde o Figma não decide:
  - A numeração põe a tela embutida primeiro e segue pelo nome do conector, o que dá o "1 · Notebook, 2 · Monitor" do board. O nome da tela embutida fica "Built-in", o da origem; o externo usa o modelo, também como na origem.
  - Os dois botões de girar a tela da origem não estão no Figma e saíram da página na primeira versão da `F4-T03`; a rotação voltou como linha (ver acima).
  - Hover e foco do monitor não estão desenhados: uso o `raised` com a camada `hover` por cima, o token dos botões e linhas.

### Organizar monitores — 580×500

- Área de arraste 520×320. Guia de encaixe 1 px em `accentText`. Monitor arrastado com sombra. “Cancelar” / “Concluído”.
- Conferido no Figma em 2026-11-16 (`F4-T03`, nó `13:16062`):
  - Área em (30,84), `cardHover` com borda `border` de 1, raio 16. Os monitores encostam uns nos outros, sem folga. A grade de linhas da origem não está no Figma e saiu.
  - Monitor arrastado: `accentSubtle` com anel `accentRing` de 2 e a sombra do vidro; a segunda linha vira "arrastando" em `text` e o glifo `move` de 16 em `accentText` fica 22 abaixo do centro. Os outros monitores ficam no repouso da Tela.
  - Guia de encaixe: 1 px em `accentText` sobre a borda em comum com o vizinho, a 24 das bordas da área (vertical quando encostam de lado, horizontal quando encostam em cima ou embaixo). Aparece só durante o arraste.
  - Dica em (30,420), 13 Regular com linha de 20, `muted`, 300 de largura. O erro (ou o aviso de que os monitores mudaram) aparece no lugar dela, em `dangerText`.
  - “Cancelar” (secundário) e “Concluído” (primário), ambos de 104×40 com raio 10, em y 420, alinhados à direita com 16 entre eles. O modal fecha em 500, com 40 de base.

## Informações — 580×620

- 7 linhas, passo 48. Número em círculo 24 (Geist Mono 11). Rótulo 15 `muted`. Valor Geist Serif 17.
- Use **dados fictícios** (como na prévia: CachyOS · Linux 6.17, máquina “Wintermute”, etc.). Não leia hardware real para preencher prints de documentação; no runtime, a Pond já busca valores em `information/State.qml` — pode manter a leitura, mas nada de serial, MAC ou hostname pessoal em material compartilhado.
- Botão Manual 520×64. ~~Rodapé “Wintermute Shell” Serif 17 + versão Mono 11 `muted`. Grade de “+” 7×3 que some aos poucos no hover dos contatos (opacidade 1 / 0,6 / 0,3) — herdar a graça da Pond, nas medidas do Figma (152×56 em (398,536)).~~ Superado pela P-50 e pela P-58 (2026-11-17): o rodapé final está em "Rodapé só com enfeites", abaixo.
- Conferido no Figma em 2026-11-16 (`F4-T04`, board `13:16083`):
  - Linhas a partir de y 84, uma a cada 48. O círculo do número é `control` com borda `border` de 1, número em Geist Mono 11 Medium `text`. Rótulo 15 Medium `muted` em x 66, com 120 de largura; valor Serif 17 `text` em x 186, até a borda direita. Divisor `border` de 1 entre as linhas, não depois da última.
  - Rótulos: Sistema, Máquina, Placa, CPU, GPU, Memória, Disco (na shell: System, Machine, Board, CPU, GPU, Memory, Disk). A origem usava OS e Host.
  - Botão Manual em (30,436): `control` com borda `border`, raio 12. Bloco de 40×40, raio 10, em `accentSubtle` em (12,12), com o `book-open` de 20 em `accentText`; "Manual" 15 Medium `text` e "Atalhos e gestos" 13 Regular `muted` em x 64, em linhas de 20 a partir de y 12; seta `chevron-right` de 16 em `text` em (488,24). O hover não está desenhado: uso o `pressed`, como as linhas dos Ajustes.
  - ~~Rodapé: "Wintermute Shell" em (30,536) numa caixa de 24, a versão "V0.1 · prévia" logo abaixo numa caixa de 20. Na grade, cada "+" é Geist Mono 11 Medium `muted`, centrado em (10 + 20·coluna, 7 + 20·linha), e as opacidades 1 / 0,6 / 0,3 seguem em sequência pela grade.~~ Era o que o board desenhava (só o nome, a versão e a grade); superado pela P-58. Daqui ficam valendo só a fonte, o tamanho e a caixa do nome e da versão, e o Geist Mono 11 Medium `muted` da versão.
  - Os logotipos e os contatos da origem (X, Instagram, site e e-mail da marca dela) não estão no Figma e saíram na `F4-T04`.
- **Rodapé só com enfeites** (P-50, 2026-11-16: "Utilizar apenas enfeites nessa área do painel, como um 'footer' fazer como na referencia em anexo usando a grade de + e o arch.svg"). Sem contatos, sem links e sem hover. A marca é o logo + "Wintermute", não "Wintermute Shell" (decisão 0013). Implementado na `F4-T17`.
  - **P-58** (2026-11-17), que vale mais que a P-50 no que diverge: "Acho que eu tiraria a grade e manteria apenas Broto | Wintermute | logo ARCH". O broto num tom "meio termo" entre branco e cinza, e o "ARCH" no cinza `muted`. A grade de "+" saiu, e as medidas dela (152×56 em (398,536)) ficam como a caixa do "ARCH".
  - Composição final no modal de 580×620 (o `Footer` tem 56 de altura em y 536; dentro dele, y = y do modal − 536):
    - **Faixa:** y 536 a 592 (56), centro em y 564. Origem: o 152×56 em (398,536) que a grade ocupava no board `13:16083`.
    - **Broto (logo provisório, P-51):** 40×40 em (30,544). x é `settingsBodyInset`; y vem da conta (56 − 40) / 2 = 8 dentro do rodapé. Cor `Theme.brandMark` (#DADCDE), token novo: como não existe token entre `text` (#F2F3F5) e `muted` (#C2C4C7), é a média canal a canal, (242+194)/2 = 218, (243+196)/2 = 219,5 → 220, (245+199)/2 = 222. O arquivo é um só, `assets/brand/logo.svg` (decisão 0013), desenhado em branco (#FFFFFF), e a cor vem da colorização com `Theme.brandMark`.
    - **"Wintermute":** x 78 = 30 + 40 + 8, caixa de 24 de altura (y 542 a 566), Geist Serif 17 Normal `text`, `letterSpacing` 0. Fonte, tamanho e caixa são os do nome do board `13:16083`; x é da P-58.
    - **Versão "V0.1 · preview":** x 78, caixa de 20 logo abaixo do nome (y 566 a 586), Geist Mono 11 Medium `muted`. Do board `13:16083`.
    - **y do bloco de texto (composição, A-05):** o bloco de 24 + 20 = 44 fica centrado na faixa de 56, como o broto: (56 − 44) / 2 = 6, ou seja y 542 no modal.
    - **"ARCH":** caixa de 152×43 em (398,542), com o desenho de 151,43×42,96 alinhado à direita, terminando em x 550 = 580 − 30 (P-58). Tamanho do símbolo `icon/information/arch`, nó `7:1799`. O topo em y 542 é composição (A-05): (56 − 43) / 2 = 6,5, arredondado para baixo, o mesmo topo do bloco de texto. Cor `muted` por colorização; as nove listras a 50% de opacidade são do desenho.
  - **De onde vem o `arch.svg`:** o nó `7:1799` é um grupo de máscara (as letras "ARCH" sobre nove listras horizontais brancas a 50%). Os caminhos são os mesmos do arquivo que apaguei no `8042031`, ponto a ponto, deslocados 9,716 em x, porque o export do Figma sai cortado pela célula de 132 do catálogo de ícones e traz os fundos do board junto. Por isso o arquivo em `assets/information/arch.svg` é o do `8042031^`, que é o símbolo limpo.
  - O `logo.svg` é branco (#FFFFFF) porque a colorização do Qt multiplica a cor pela luminância do desenho: só com o desenho em branco o broto sai exatamente #DADCDE e o "ARCH" (máscara branca) exatamente `muted`. Com o traço em #F2F3F5, como nos ícones Lucide, o broto sairia #D0D2D3 (medi no print).
- Formato dos valores, seguindo os do Figma: "CachyOS · Linux 6.17" (sistema e kernel), o nome da máquina, a placa, "Ryzen 7 · 8 cores" (modelo sem o fabricante e núcleos físicos), "Radeon · 16 GB" (a VRAM só na GPU dedicada), a memória total e "1 TB NVMe · 412 GB free" (disco em unidades decimais, livre para o usuário). Os exemplos são os do Figma, fictícios. O "DDR5" do Figma fica de fora: o fastfetch só lê o tipo da memória pelo SMBIOS, que pede root. A origem atualizava memória e disco a cada 3 s; como o Figma mostra totais, leio uma vez por abertura.

## Manual — 500×656, sem título no modal

- Seletor Teclado / Touchpad no topo.
- Tutorial 440×240 raio 16 (a Pond tinha 440×420 + um SVG grande que **não** está neste pacote). Sigo o layout do Figma, não o SVG antigo (P-10, 2026-11-15: "Segue o do Figma").
- Lista de atalhos (teclas + texto `muted`). A lista sai das binds que configurei em `~/.config/niri/cfg/keybinds.kdl` e das anotações dele, mais estas, que defini em 2026-11-15 (P-11):
  - Super+Return: Terminal (a descrição fica só "Terminal").
  - Super+\`: recolher/expandir a barra da Wintermute. Substitui o Super+B.
  - Super+E: launcher.
  - Super+Shift+E: gerenciador de arquivos (Files).
  - Super+Escape: tela inicial dos Ajustes.
  - Super+Shift+Escape: atalho de emergência que devolve o teclado quando um app em tela cheia o segura (P-43).
  - Super+Shift+/: lista de atalhos do Niri (`show-hotkey-overlay`), que sai do Super+Shift+Escape para dar lugar ao atalho de emergência (P-45, 2026-11-16). No `keybinds.kdl` a tecla se escreve `Mod+Shift+Slash`.
  - Super+L: tela de bloqueio.
  - Capturas: Super+Shift+1, 2 e 3, como anotei no arquivo (hoje Ctrl+Shift+1, 2 e 3).
  - A área de transferência ainda não tem atalho; entra na lista quando a F6 definir.
- Os textos da lista ficam em inglês (decisão 0012). Posso trocar os binds depois, então eles ficam num único arquivo (`F4-T07`). Desde a `F4-T07` (2026-11-17, decisão 0015) esse arquivo é o `wintermute-shell/settings/manual/shortcuts.json`: cada atalho tem a tecla do Niri, a descrição e a ação; o Manual deriva dele as teclas que mostra e o `keybinds.py`, ao lado, gera o bloco `binds { }` do Niri.
- Abre sozinho na primeira vez (`shell.qml:55-65`). Botão “Entendi” primário 440×40.
- Conferido no Figma em 2026-11-17 (`F4-T05`, board `13:16155`, modal `13:16158`), o que esta ficha não dizia:
  - Seletor segmentado de 168×40 em (166,24), com "Teclado" e "Touchpad" (na shell: Keyboard e Touchpad). Ele fica no modal, fora do tutorial; na origem ficava dentro. Só troca o tutorial: a lista é a mesma nas duas abas.
  - Tutorial em (30,80): `cardHover` com borda `border` de 1, raio 16. Legenda 13 Medium `muted`, centrada, numa caixa de 440×24 em y 192.
  - Aba Touchpad: touchpad de 200×128 em (120,48) dentro do tutorial, `control` com borda `borderStrong` de 1, raio 12. Três dedos de 16 em `accentText` a 90%, em x 64, 92 e 120, y 56. Quatro setas `chevron-*` de 16 em `accentText`: para cima em (92,24), para baixo em (92,88), para a esquerda em (24,56) e para a direita em (160,56). Legenda "3 dedos ↕ workspaces · 3 dedos ↔ colunas".
  - Lista: linhas de 44 a partir de y 336. As teclas (componente Tecla da ficha 00, com 4 entre elas) ficam em x 30, centradas na linha; a descrição é 13 Medium `muted`, alinhada à direita em 470, numa caixa de 230. Divisor `border` de 1×440 no fim de cada linha, inclusive da última (y 600).
  - Botão “Entendi” em (30,604): `accent`, raio 10, texto 13 Medium `onAccent`. O modal fecha em 656, com 12 de base. O botão fechar pendurado fica onde fica nos outros modais.
  - O board desenha seis linhas de exemplo (Super+Roda, Super+Shift+Roda, Super+Espaço, Print, Super+V, Super+B). Elas vêm da origem e não são a minha lista, que é a da P-11.
- **Lista completa, rolando** (P-52, 2026-11-17: "Completa, rolando"). Entram todas as binds de teclado e de roda com Super, menos as teclas de mídia e de brilho, uma bind por linha, na ordem Wintermute, aplicativos, janelas, workspaces, layout e sistema. O modal continua 500×656: a lista rola na área das seis linhas do Figma (de y 336 a 600) e o botão fica fixo. Sem rótulo de grupo, que o Figma não desenha. Super+1 a 9 ocupam uma linha só.
- **Aba Teclado** (P-53, 2026-11-17: "Desenho da origem"). O Figma não desenha essa aba. Uso o desenho da origem (`NavigationTutorial.qml`): o mini teclado de 209×86 (teclas de 20 de altura em quatro fileiras, cantos de fora com raio 8 e os outros com 2) e o mouse de 40×56 com raio 12, 24 à direita dele, com a roda de 10. O conjunto de 273×86 fica centrado onde fica o touchpad, em (84,69). As cores passam para os tokens: contorno em `borderStrong`, destaque em `accentText`. A legenda segue a da aba Touchpad: "Super + wheel ↕ workspaces · Super + A / D ↔ columns".
- **Colunas pelo teclado** (P-54, 2026-11-17: "Seguir o keybinds.kdl"). O Figma (`13:16176`) e a origem ensinam Super+Shift+Roda para andar entre colunas. No meu `keybinds.kdl` esse atalho move a coluna de workspace, e andar entre colunas é Super+A / Super+D. Vale o que configurei: o tutorial destaca as teclas A e D (a segunda e a quarta da fileira que começa com a tecla de 32) no lugar do Shift, e a lista traz Super+Shift+Roda como "Move column to workspace".
- **Animação** (P-55, 2026-11-17: "Movimento da origem"). A sequência e os tempos são os da origem: acender em 160 ms (teclado) ou 220 ms (touchpad), pausa de 140 ou 160, movimento de 720 em InOutCubic e apagar em 240 ou 280. No touchpad os dedos partem do quadro do Figma e deslizam até 8 px de cada seta, um sentido por vez (16 para os lados, 8 para cima e para baixo); 100 ms depois voltam ao centro, sumindo em 200 ms e reaparecendo em 280, e esperam 150 até o gesto seguinte. No teclado, a ida e a volta da roda e as duas teclas ficam a 450 ms uma da outra. No teclado, a tecla Super acende com a roda, que desce e sobe 16; depois o contorno de A e D passa a `accentText` em 280 ms e cada uma acende com a Super. O rastro da roda (2 px, do transparente ao `accentText`) continua; o rastro dos dedos saiu, porque na origem ele só aparece depois de 10 px de curso. As mini janelas da origem não estão no Figma e saíram. Parado (na vitrine e nos prints), o tutorial mostra o quadro do Figma, com os dedos acesos.
- Escolhas minhas na `F4-T05`, onde o Figma não decide:
  - A aba que abre é a Teclado, como na origem. O board mostra a Touchpad porque é o estado desenhado.
  - O hover do botão “Got it” é o do botão primário da ficha 00 (`accentHover`).
  - A lista rola com a roda e com as setas, Page Up, Page Down, Home e End, como o manual da origem.
  - As teclas levam o nome que o Niri usa, sem símbolo: Return, Esc, Tab, Space, Up, Down, Left, Right, Del. A roda é "Wheel", e a roda inclinada, "Wheel left" e "Wheel right".
  - Na troca de aba, o desenho que sai some em 150 ms e o que entra aparece em 280 ms, subindo 8 px, como na origem.

## Papel de parede — modal 624×608

- Grade 2×3 de miniaturas **276×156** raio 12 (Pond: 155 de uma das dimensões — refinado).
- Escolhida: anel `accent` 1 px com folga de 4 px + check 24 fundo `accent`.
- Hover: título e autor sobre degradê preto 0→80% na base.
- Tile “Escolher imagem” com traço tracejado `[4,4]`. “Dinâmico” pode permanecer (shader da Pond), visualmente como na prévia.
- As imagens da grade são as minhas, uma por variação (Chiba, Freeside, Sprawl), e moram no repositório. As fotos da origem não entram (decidido em 2026-11-14, P-31). Vão para o repositório só as versões de 1920×1080, em PNG, sem perda: medi os formatos sem perda mais leves e as seis imagens juntas ainda somariam 40 MB (P-37).
- Conferido no Figma em 2026-11-17 (`F4-T06`, modal `13:16208`), o que esta ficha não dizia:
  - Título "Papel de parede" (na shell: Wallpaper) em Serif 32, em (30,20). Miniaturas em duas colunas, x 24 e x 324 (24 entre elas), e três linhas, y 84, 256 e 428 (16 entre elas). O modal fecha em 608, com 24 de base.
  - Miniatura de imagem: borda `border` de 1, raio 12. O degradê do hover tem 276×80 e começa em y 76; o título é 13 Medium `text` em (16,108), numa caixa de 244×20, e o autor é 11 Medium `muted` em (16,128), numa caixa de 244×14.
  - "Dinâmico" (na shell: Dynamic) mostra o título sempre, 13 Medium `text` em (16,120), sem segunda linha e sem degradê.
  - Selecionada: o anel `accent` de 1 fica 4 px para fora (284×164, raio 16). A marca é um círculo de 24 em `accent` em (240,12), no canto de cima à direita, com o `check` de 16 em `onAccent`. Na origem a marca era branca, de 26, no canto de baixo.
  - "Escolher imagem" (na shell: Choose an image): fundo `cardHover`, contorno `borderStrong` de 1 tracejado, `image-plus` de 20 em (128,52) e o texto 13 Medium `text` centrado numa caixa de 276×24 em y 80.
  - O board desenha seis miniaturas: "Escolher imagem", "Dinâmico", Chiba, Freeside, Sprawl e uma quarta imagem, "Matrix", que eu não tenho. Só uma miniatura traz texto de hover: "Chiba à noite" e "Paleta Armitage".
- Escolhas minhas na `F4-T06`, onde o Figma não decide:
  - A ordem é a do board: "Choose an image", "Dynamic", as três imagens nativas e, no fim, as que eu acrescentar. Na origem as acrescentadas vinham antes do "Dinâmico". Com as cinco fixas o sexto lugar fica vazio, e a primeira imagem que eu escolher entra ali (P-59, respondida na `F4-T22`: ver a seção abaixo).
  - O título de cada imagem nativa é o nome da variação (Chiba, Freeside, Sprawl) e a segunda linha é "Armitage palette" (P-59). As acrescentadas não levam título: levam número (`F4-T22`).
  - Com mais de seis miniaturas a grade rola dentro do modal, que continua em 608, como na origem.
  - O hover e o foco de "Choose an image" usam o fundo `pressed`, como o botão Manual. O foco pelo teclado mostra o mesmo anel da selecionada, como na origem.
  - A mensagem de erro fica onde ficava na origem, entre o título e a grade, que desce 28; a cor passa a `dangerText`.
  - O seletor de arquivo é o do sistema, pelo portal `org.freedesktop.portal.FileChooser` (P-60, respondida em 2026-11-17: "Realmente o portal é minha escolha."). O `zenity` sai da lista de pacotes da F10. `control.py pick` chama `OpenFile` pelo `Gio` (`python-gobject`, que a shell já usa no Bluetooth), sem dependência nova. O diálogo abre como o do `zenity` abria: título "Choose a wallpaper", filtro "Images" (`*.png *.jpg *.jpeg *.webp *.bmp *.gif *.svg *.PNG *.JPG *.JPEG`) selecionado, filtro "All files" (`*`) e, quando existe, a pasta de papéis de parede (`Pictures/Wallpapers`; desde a `F4-T22` ela é só a pasta em que o diálogo abre, a lista não a lê mais). Cancelar não muda nada e não mostra erro. Resposta "encerrado de outro jeito", resposta sem arquivo ou portal que falha na chamada (ausente, sem backend de `FileChooser`) viram a mensagem de erro da página: "Could not open the image picker", com o motivo depois de dois-pontos quando a chamada devolve um. O backend da sessão do Niri (`xdg-desktop-portal-gnome` ou `-gtk`) é conferido no QA ao vivo; antes disso o teste é com o portal de mentira `.agents/bancada/portal-falso.py`. Ainda não passo a janela da shell como `parent_window`.

### Grade sem tamanho travado e imagens numeradas (`F4-T22`, P-59 respondida em 2026-11-17)

- Minha resposta à P-59, que vale mais que o Figma e que a origem: a grade não tem tamanho travado, continua com duas colunas, e "tudo bem ficar o espaço vazio depois do último", porque as imagens novas vão entrando nesse vazio. Os papéis de parede nativos do tema ficam "fixados exatamente onde estão, no topo", com nome. Os acrescentados levam número, "começando do 01 e adiante", na ordem em que entram: "os únicos que carregam nome são os 'originais', os extras trazem números". Não existe escolha de pasta.
- A grade cresce para baixo, duas colunas em x 24 e 324, linhas a cada 172 (156 + 16) a partir de y 84 e 24 de base (tokens `settingsWallpaper*` do `Theme.qml`, nada novo). O modal continua em 624×608 e a grade rola dentro dele. Depois da última miniatura o lugar fica vazio. Sem acrescentadas o seletor é o de antes: cinco miniaturas e o sexto lugar vazio.
- Onde moram: "Choose an image" copia a imagem escolhida para `~/.local/share/wintermute-shell/backgrounds/` (`$XDG_DATA_HOME/wintermute-shell/backgrounds/`), que só é criada na primeira cópia, e seleciona a cópia. A cópia leva o nome original; se já há um arquivo com esse nome e outro conteúdo, ganha `-2`, `-3`, ... antes da extensão; se já há um arquivo com o mesmo conteúdo, não copia de novo e usa o que está lá. Escolher uma imagem que já está na pasta, ou uma das três nativas, só seleciona. Uma imagem posta à mão na pasta entra no fim da fila, por data de modificação e depois por nome. A ordem de entrada fica em `imports` do `wallpaper.json`. Erro ao copiar (sem espaço, sem permissão) vira "Could not save the image: " e a primeira linha do motivo.
- **Miniatura numerada (quarta forma, sem board; composição pela regra A-05):** a mesma miniatura da imagem, sem nenhuma medida ou cor nova. Fora do hover só a imagem. No hover e no foco entra o mesmo degradê preto de 80% e o número, em uma linha só, sem autor:
  - Posição: onde o "Dynamic" põe o título de uma linha só, em (16,120), caixa 200×20 (`settingsWallpaperTextX`, `settingsWallpaperDynamicTitleY`, `settingsWallpaperDynamicTitleWidth`, `settingsWallpaperTitleHeight`).
  - Fonte: `monoFontFamily` (Geist Mono), `fontMonoNumber` (13), Regular, `text`, `letterSpacing` 0. Origem: regra da shell de número em Geist Mono; 13 é o tamanho do título da miniatura e `fontMonoNumber` é o token de Mono 13 que existe.
  - O número tem dois dígitos ("01", "02", ...); a partir de 100, sem zero à esquerda. O nome acessível é "Wallpaper 01".
  - Selecionada, anel e marca são os das outras miniaturas. A aprovação é minha, pelo print, no QA ao vivo.
- Pendências abertas na `F4-T22`, que não travam:
  - **P-65:** o número é a posição na ordem de entrada, sem buraco. Se uma imagem some da pasta, as seguintes descem um número. Não há botão de remover.
  - **P-66:** as acrescentadas são só as imagens da pasta da shell. A varredura de `~/Pictures/Wallpapers` deixa de alimentar a lista, porque pela P-59 as acrescentadas moram na pasta da shell e têm ordem de entrada. A pasta continua sendo a em que o diálogo do portal abre.

### Cartão "Customize": papel de parede por modo e por monitor (`F4-T24`, ajuste A-05, P-67 respondida em 2026-11-17)

- Minha resposta à P-67: "Aprovado", a proposta inteira. Um botão "Customize" no seletor abre um cartão que empilha na frente dele, como as páginas do Wi-Fi; no cartão, duas chaves independentes e uma linha por lugar; tocar numa linha volta à grade, que escolhe para aquele lugar; "Dynamic" vale em qualquer lugar; lugar sem escolha usa o marcado na grade; monitor desligado some da lista e a escolha fica guardada; quando o modo dos aplicativos troca (`F4-T23`), à mão ou pelo horário, cada tela passa ao papel de parede do modo novo.
- **Nada disto tem board.** É composição pela regra A-05: só componentes e tokens que a shell já usa, e cada medida nova sai de uma conta sobre tokens, escrita aqui. A aprovação é minha, pelo print, no QA ao vivo.
- **Botão "Customize"** no seletor: o secundário pequeno do "Arrange" da Tela (`control` com borda `border`, raio 8, 13 Medium `text`), 96×32 (`settingsDisplayArrangeWidth`). Posição no modal de 624: x 504 = 624 − 24 (`settingsWallpaperGridInset`) − 96, alinhado à direita com a grade; y 26 = 20 + (44 − 32) / 2, centrado na caixa do título (y 20, altura 44). Some quando a grade escolhe para um lugar e quando o seletor é a carta de trás.
- **Pilha** (tokens do `PanelStyle.qml`, os da ficha 05):
  - Cartão da frente: modal de 580 (`settingsModalWidth`), raio 32, 32 abaixo do topo do conjunto (`frontInsetStacked`).
  - Carta de trás: o seletor na escala original, cortado em 548 = 580 − 2 × 16 (`backOffsetX`), a 16 de cada lado da frente e 32 acima dela, com a base rente à da frente; raio 32, o mesmo vidro e o mesmo contorno; conteúdo a 50% (`backContentOpacity`) com blur 8 (`backContentBlur`), inclusive no trecho acima da frente. O conteúdo fica à esquerda e o que passa de 548 é cortado, como no `CardLayer`. Sem botão de fechar e sem clique.
  - O botão de fechar pendurado é o do cartão da frente, em (largura − 20, −13), e volta ao seletor.
  - Transição: 350 ms (`pageDuration`) na curva `[0.19, 1, 0.22, 1]`; a frente entra de escala 0,92 a 1 com a opacidade de 0 a 1 e sai com a escala `max(0, 1 − 2 × progresso)`; a carta de trás interpola largura (624 a 548), posição, opacidade do conteúdo e blur; a altura do conjunto interpola junto.
  - O seletor e o cartão são um componente só (`WallpaperStack.qml`), carregado nas páginas `wallpaper` e `customize`, para o seletor continuar vivo atrás do cartão com a rolagem onde estava.
- **Cartão**: título "Customize" em Serif 32 em (30,20). Linhas de 520×52 em x 30, a primeira em y 84, passo 60 (`settingsBodyInset`, `settingsBodyTop`, `settingsRowPitch`):
  - y 84: chave "Follow light and dark mode".
  - y 144: chave "One wallpaper per display".
  - y 204 em diante: uma linha por lugar.
  - Base de 32 (`settingsBottomPadding`). Altura: 84 + 60 × (2 + n) − 8 + 32, ou seja 228 sem linhas, 348 com duas e 468 com quatro. Passando da altura disponível, o corpo rola.
  - O erro aparece depois da última linha, em `dangerText`, com quebra, como nas outras páginas de linhas.
- **Linha de lugar**: a linha com seta dos Ajustes (`chevron-right` de 16 em (484,18) em `muted`; hover `pressed`), sem valor à direita, com:
  - Miniatura de 64×36 em (8,8). Altura 36 = 52 − 2 × 8, com a mesma folga em cima, embaixo e à esquerda; largura 64 = 36 × 16 / 9, a proporção das imagens de 1920×1080. Raio 8 (`settingsDisplayTileRadius`, o do monitor em miniatura da Tela), conteúdo recortado e borda `border` de 1 por cima, como na miniatura da grade. Mostra o que vale no lugar: a escolha dele ou, sem escolha, o marcado na grade; "Dynamic" mostra o céu, sem texto.
  - Nome em x 84 = 8 + 64 + 12 (12 é a folga entre o bloco e o texto do botão Manual), Geist 15 Regular `text`.
- **Quais linhas aparecem**: com as duas chaves desligadas, nenhuma; só a do modo, "Light" e "Dark"; só a dos monitores, uma por monitor ligado, pelo nome do conector (`eDP-1`, `HDMI-A-1`, como na P-48); as duas, "eDP-1 · Light" e "eDP-1 · Dark" para cada monitor, com o mesmo " · " do "1 · Built-in" da Tela. A tela embutida vem primeiro (`eDP-`, `LVDS-`, `DSI-`, `DPI-`) e depois os outros pelo nome; Light antes de Dark.
- **Grade escolhendo para um lugar**: o título do seletor passa a ser o nome do lugar (o texto da linha), o botão "Customize" some, e o anel e a marca mostram o que vale ali. Tocar numa miniatura grava no lugar e o cartão volta; "Choose an image" abre o portal, copia a imagem para a pasta da shell e a põe no lugar; cancelar o portal não muda nada. Fechar ou Escape voltam ao cartão sem mudar nada.
- **Como fica guardado**: o `wallpaper.json` ganha `followScheme`, `perDisplay` e `places`, um dicionário de chave de lugar para `{mode, path, url}`. As chaves são `light`, `dark`, `display:<conector>` e `display:<conector>:light` ou `:dark`. O `mode`, o `path` e o `url` de sempre continuam sendo o marcado na grade. Lugar sem entrada usa o marcado na grade e não herda de outro lugar. As escolhas ficam guardadas quando desligo uma chave e quando o monitor não está ligado. Um lugar cuja imagem sumiu sai de `places`. O `control.py` ganhou `place`, `option` e `pick <chave>`.
- **Na área de trabalho**: cada tela recebe o papel de parede que vale para o conector dela e para o modo atual dos aplicativos (`appsScheme` da `F4-T23`), então a troca de modo troca o papel de parede sozinha. Com as duas chaves desligadas é o de antes: um papel de parede para todas as telas.
- Escolhas minhas na `F4-T24`, que aprovo ou corrijo no QA ao vivo: o título do cartão é "Customize", o do botão que o abre; o título da grade em escolha é o nome do lugar; a linha não mostra o nome do papel de parede, só a miniatura; não há botão para limpar a escolha de um lugar (para voltar ao marcado na grade, escolho de novo a mesma imagem).

## A CONFIRMAR

- ~~Ícone do perfil Desempenho na home: `zap` aqui vs `rocket` no pop-up da bateria (ficha 08).~~ Definido em 2026-11-15 (P-07): `zap` nos dois lugares.
- ~~O tutorial do Manual da Pond era um SVG de 2,9 MB não baixado. Seguir o layout do Figma (440×240).~~ Definido em 2026-11-15 (P-10): segue o Figma.
- ~~Lista definitiva de atalhos.~~ Definida em 2026-11-15 (P-11), na seção do Manual.
- ~~O "principal" do conector no monitor selecionado da Tela.~~ Definido em 2026-11-16 (P-48): só o nome do conector.
- ~~A rotação da tela volta, e onde.~~ Definido em 2026-11-16 (P-49): linha "Orientation" no topo das linhas da Tela.
- ~~Os contatos das Informações e o que faz a grade de "+" sumir.~~ Definido em 2026-11-16 (P-50): rodapé só com enfeites, sem contatos.
- O logo definitivo da Wintermute (P-51). Até lá, o broto provisório.
