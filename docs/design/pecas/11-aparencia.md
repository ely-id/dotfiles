# 11 · Aparência

**Nova?** não (os 5 temas da Pond viram as 3 variações)  
**Board:** `13:14610`  
**PNG:** `referencias/armitage/05-popups-cartoes-osds-chiba.png`  
**QML da Pond:** `settings/appearance/Panel.qml`, `ThemeButton.qml`, `Accordion.qml`, `State.qml`, `settings/Modal.qml` (spec §3.21)

## Modal — 580×456, raio 32 (palco 600×476 com o X pendurado)

> Com as duas chaves dos aplicativos (`F4-T23`, seção abaixo) o modal tem 576 e “Screen brightness” e “Display” descem 120. Os números deste cabeçalho e das medidas conferidas são os do board, que não desenha as chaves.

- X = voltar, 40×40 em (560, 7) no palco (isto é, `w − 20`, y 7 — `lib45.js` `MODAL`).
- Título “Aparência” Geist Serif 32 em (30,20), caixa 400×44.
- Rótulo “Variação” `muted` em (30,64).
- Três discos de 88×88 raio 44, com amostra de acento 40×40 no centro e, se selecionado, check 24×24 fundo `accent` no canto. Anel `accentRing` 2 px quando selecionado; senão borda 1 `border`.
- Nomes embaixo, 13 Medium: Chiba, Freeside, Sprawl. Selecionado `text`, os outros `muted`.
  - Amostras: Chiba `#52C2F6`, Freeside `#7F89E1`, Sprawl `#F4A846`.
- Escolher um disco chama `Theme.setName(...)` e persiste em `~/.config/wintermute-shell/theme.json` (caminho confirmado em 2026-11-14).
- Accordion 520×52 raio 12, fundo `control` (hover `pressed`), x 30: “Papel de parede”, “Brilho da tela”, “Tela”. Título 15 Regular, valor 13 Medium `muted` à direita, chevron de 16 em (largura − 36, 18). Abertura 240 ms InOutCubic. As três linhas levam o chevron para baixo no print; a origem apontava para a direita nas que só navegam, e segui o print.
- Medidas conferidas no print: modal de 580×456 (260 + 3 linhas de 52 + 2 espaços de 8 + 24 embaixo); “Variação” em (30,64); discos em y 88 e nomes em y 188; linhas a partir de y 260. Como essas medidas são do modal inteiro, a página Aparência usa `bodyTop: 0` (as outras páginas continuam com 82 até a F4). O brilho aberto mostra o slider (altura 111). Com as duas chaves dos aplicativos entre “Wallpaper” e “Screen brightness”, as linhas ficam em y 260, 320, 380, 440 e 500, e o modal tem 576 (260 + 5 linhas de 52 + 4 espaços de 8 + 24 embaixo).
- O desenho mora em `settings/appearance/Body.qml`, sem ler estado; `Panel.qml` liga o estado real e a vitrine liga valores fictícios.

- **Brilho indisponível** (`F4-T14`, 2026-11-17). A linha "Brilho da tela" continua desligada com "Indisponível", e o motivo aparece no texto de erro que a página já tinha, abaixo das linhas, em `dangerText` 13: "Brightness for this display needs ddcutil, which is not installed.", "No permission to control this display. Add your user to the i2c group." ou "Brightness is unavailable for this display: " com a primeira linha do erro. Outro erro da página (do tema ou do papel de parede) toma o lugar do motivo enquanto existir. O modal cresce 25 com uma linha de erro, como já crescia.

O papel de parede em si está na ficha 13 (seletor). “Brilho” e “Tela” navegam para as páginas já existentes.

## Modo claro e escuro dos aplicativos (`F4-T23`, 2026-11-17)

Peça sem board, composta pela regra do ajuste A-05. Nas minhas palavras: “O ideal seria justamente poder trocar os modos claro e escuro dos apps com papel trocando junto se caso o usuário configurou assim ou então se caso tiver o horário dinâmico também ter essa troca. Ambos devem ser toggle” e “a ideia é justamente isso, ter a regra do dia e noite”. A shell continua sempre escura: as chaves mexem só no modo dos aplicativos. O papel de parede que troca junto é a `F4-T24`.

**Composição.** Duas linhas `Settings.Field { toggle: true }` (ficha 00, tipo Chave), as mesmas de “Ask for password on wake” em Lock & sleep: 520×52, raio 12, fundo `control` (hover `pressed`), título 15 Regular `text` em x 20, `Toggle` de 54×28 em (446,12) da linha, ligada em `accent` e desligada em `track` com borda. Entram na mesma coluna das linhas da página, logo depois de “Wallpaper”, no passo de 60 (52 + 8): “Dark mode for apps” em y 320 e “Switch with day and night” em y 380. “Screen brightness” passa a y 440 e “Display” a y 500 (260 + 60 × n). O modal passa de 456 a 576 (456 + 2 × 60). Nenhum valor novo: tudo sai da ficha 00 e da grade desta página.

**Títulos** (decisão 0012, em inglês): “Dark mode for apps” (ligada, os aplicativos ficam no escuro; desligada, no claro) e “Switch with day and night”.

**Comportamento.** As duas chaves são independentes: nenhuma muda a outra.
- A primeira mostra o modo que está valendo, lido do GSettings. Ligar grava escuro, desligar grava claro, e vale na hora.
- A segunda, ligada, aplica o modo do horário: na hora em que eu a ligo, na subida da shell e a cada passagem do dia para a noite e da noite para o dia. Desligada, nada troca sozinho. O estado fica em `~/.config/wintermute-shell/apps.json` (`{"automatic": true}`), ao lado do `theme.json` (P-01).
- Com a automática ligada eu ainda posso virar a primeira à mão: vale na hora, e a próxima passagem (06:30 ou 18:30) aplica o modo do horário de novo. A automática não desliga sozinha.
- A troca por horário não depende de um temporizador até a próxima passagem, porque a máquina suspende: a shell confere o período a cada minuto, enquanto a automática está ligada, e aplica só quando o período mudou desde o último que ela aplicou (ou quando não houve nenhum: subida da shell, chave recém-ligada). Dentro do mesmo período ela não regrava nada. Se a gravação falha, o período volta a “não aplicado” e a tentativa se repete no minuto seguinte.
- O modo é relido quando a página abre (eu posso ter mudado por fora); o GSettings não é vigiado o tempo todo.
- Erro de gravação: “Could not change the app color mode: ” com a primeira linha do motivo (“gsettings is not installed” quando o comando não existe) vai para o texto de erro da página (`dangerText`, no fim da coluna), e a chave volta a mostrar o modo de verdade. Erro só de leitura na subida não aparece na tela, vai para o log.

**Regra de horário.** É a do “Dynamic” do papel de parede: `SkyState.DEFAULTS.sunrise` (6,5) e `.sunset` (18,5), em hora decimal do relógio local. Dia das 06:30 às 18:30 (claro); fora disso, noite (escuro). A shell lê esses dois números de lá, não os copia. Horário configurável e nascer do sol calculado ficam fora.

**Por onde o modo chega aos aplicativos.** Pelo portal `org.freedesktop.portal.Settings`, chave `org.freedesktop.appearance` `color-scheme` (0 sem preferência, 1 escuro, 2 claro). Os backends `xdg-desktop-portal-gnome` e `-gtk`, que o Niri usa, leem isso do GSettings `org.gnome.desktop.interface` `color-scheme`, então a shell grava essa chave com o `gsettings` (`prefer-dark` para escuro, `prefer-light` para claro). Na leitura, `prefer-dark` é escuro e qualquer outro valor (`default` inclusive) é claro. O código está em `settings/appearance/control.py` (`apps-status`, `apps-scheme`, `apps-automatic`) e no `State.qml` (`appsScheme`, `appsAutomatic`, `setAppsDark`, `setAppsAutomatic`).

**Fica para o QA ao vivo (sessão do Niri).** Conferir no print que as duas linhas e as chaves nas três variações estão como as outras linhas de ajuste; virar a primeira chave e ver um aplicativo GTK e um Qt trocarem de modo pelo portal; ligar a automática fora e dentro do horário; e conferir se um aplicativo já aberto acompanha a troca ou só os novos. Esta tarefa não rodou `gsettings set` de verdade: os testes usaram um `gsettings` de mentira.
