# Wintermute Shell

Interface gráfica em Quickshell/QML para o Niri, desenhada com o sistema visual **Armitage** nas três variações escuras (**Chiba**, **Freeside** e **Sprawl**).

O código parte de uma cópia da shell da Pond (`LICENSE-pond-interface.txt`, BSD-3-Clause) e recebe os tokens, a tipografia Geist, os ícones Lucide e as peças do meu design ao longo das fases F0 a F7.

## Como rodar

Dentro de uma sessão ativa do Niri (com `NIRI_SOCKET` definido no ambiente), abro a shell apontando o Quickshell direto para esta pasta, sem precisar copiar nada para `~/.config/quickshell/`:

```bash
qs -p ~/Projects/dotfiles/wintermute-shell
```

### Plugin de arraste da captura (opcional, em C++)

Arrastar a miniatura da captura para outro aplicativo usa um plugin do Qt em C++ (`screenshot/native/`). Ele precisa ser compilado uma vez, com `cmake`, um compilador de C++ e os cabeçalhos do Qt 6 (o instalador da F10 faz esse passo). A partir da raiz do repositório:

```bash
cmake -S wintermute-shell/screenshot/native -B wintermute-shell/screenshot/native/build
cmake --build wintermute-shell/screenshot/native/build
```

A pasta `build/` fica fora do git. **Sem o plugin a shell abre do mesmo jeito:** o arraste da prévia não existe (o cursor sobre ela fica o normal), uma linha de aviso vai para o log, e a prévia continua copiando, salvando, anotando e fechando. É o que acontece na bancada de prints e na tela de teste.

O Qt precisa achar o módulo `Wintermute.Screenshot.Native`, e há dois caminhos:

- **Instalado no sistema:** `sudo cmake --install wintermute-shell/screenshot/native/build --prefix /usr` copia o módulo para `lib/qt6/qml/Wintermute/Screenshot/Native`, que é a pasta de módulos QML do Qt no CachyOS. Sem `--prefix` o destino seria `/usr/local`, que o Qt não olha. Instalado ali, abro a shell normalmente.
- **Direto da pasta de build, sem instalar:** aponto `QML_IMPORT_PATH` para a pasta `build/` ao abrir a shell:

  ```bash
  QML_IMPORT_PATH=~/Projects/dotfiles/wintermute-shell/screenshot/native/build qs -p ~/Projects/dotfiles/wintermute-shell
  ```

Procurei um jeito de a shell achar a pasta `build/` sozinha e não há um limpo: o `//@ pragma Env QML_IMPORT_PATH = ...` do Quickshell funciona, mas o valor é copiado como está e o caminho relativo conta a partir da pasta onde o `qs` foi aberto, não da pasta da shell; e uma importação por caminho relativo não acha o plugin dentro do `qs`. Pôr um caminho absoluto no `shell.qml` poria um caminho pessoal no código, então a variável fica por conta de quem abre.

### Comandos IPC

Com a shell aberta, aciono ações pelo IPC do Quickshell (`qs -p ~/Projects/dotfiles/wintermute-shell ipc call <alvo> <função>`):

| Alvo e função | O que faz |
|---|---|
| `sidebar toggle` | Recolhe ou expande a barra lateral (156 px ↔ 48 px) |
| `demo toggle` / `open` / `close` | Abre ou fecha o painel de demonstração da F1 com toda a biblioteca de componentes base Armitage e os estados do board `13:11463` |
| `test toggle` / `open` / `close` | Abre ou fecha o painel de teste da F0 (Geist Serif, Geist, Geist Mono e troca rápida de variação) |
| `settings toggle` | Abre ou fecha a tela inicial de Ajustes e sessão |
| `settings open <página>` | Abre direto uma subpágina (`appearance`, `system`, `display`, `information`, `manual`, `wallpaper`) |
| `settings close` | Fecha os Ajustes |
| `launcher toggle` / `open` / `close` | Abre ou fecha o launcher no monitor em foco (F5) |
| `launcher clipboard` | Abre o launcher direto na página do histórico da área de transferência (F6-T16), ou fecha se ela já estava aberta; o Super+V chama este |
| `screenshot open` / `close` / `toggle` | Abre ou fecha a janela de captura de tela no monitor em foco (F6); o Super+Shift+1 chama o `open` |
| `manual open` | Abre o Manual de atalhos |
| `volume increase` / `decrease` | Ajusta o volume de saída em passos de 2% |
| `volume muteOutput` / `muteInput` | Alterna o mudo da saída ou do microfone |
| `brightness increase` / `decrease` | Ajusta o brilho do monitor focado em passos de 5% |
| `media playPause` / `next` / `previous` | Controla o reprodutor MPRIS ativo |

## Onde configurar

- **Tema e tokens (`Theme.qml`):** única fonte de verdade em código para cores, tipografia, raios, sombras, medidas e durações. Espelha `../docs/design/tokens/tokens.json`.
- **Variação ativa (`~/.config/wintermute-shell/theme.json`):** guarda a escolha entre `"chiba"`, `"freeside"` e `"sprawl"`. Pode ser trocada pelos três discos da página **Aparência** nos Ajustes ou gravando `{"theme": "chiba"}` no arquivo; o `FileView` de `Theme.qml` observa o arquivo e aplica a mudança na hora.
- **Anel de foco do Niri (`settings/appearance/niri_theme.py` e `NiriTheme.qml`, F6-T08):** a shell escreve `~/.config/niri/cfg/wintermute.kdl` (ou o que `XDG_CONFIG_HOME` apontar) com o anel de 2 px no acento da variação e o raio 12 das janelas, uma vez quando começa e de novo a cada troca de variação. O arquivo é só dela, marcado `[wintermute]`; o script se recusa a escrever em arquivo sem esse marcador. Ele só vale com `include "./cfg/wintermute.kdl"` no fim do `config.kdl`, que eu ponho à mão. Detalhes na ficha 19.
- **Atalhos e IPC (`Shortcuts.qml` e `shell.qml`):** definem os receptores IPC que os atalhos do Niri chamam.
- **Atalhos (`settings/manual/shortcuts.json`):** a única lista de atalhos. Cada um tem a tecla do Niri (`bind`), a descrição em inglês (`label`) e a ação. O Manual tira dela as teclas que mostra e o `keybinds.py` gera as binds do Niri. Como editar e gerar está em "Atalhos do Niri", logo abaixo.
- **Primeira execução (`~/.local/state/wintermute-shell/manual-shown`):** o Manual abre sozinho na primeira vez que a shell roda e cria esse arquivo. Apagar o arquivo faz o Manual abrir de novo na próxima vez.

## Atalhos do Niri

Edito os atalhos só no `settings/manual/shortcuts.json`, nunca no `keybinds.kdl`. Cada item é uma seção (`{ "section": "Windows" }`, que vira comentário no KDL) ou um atalho: `bind` (a tecla como o Niri escreve, ex. `Mod+Shift+A`), `label` e uma ação, que é `niri` (ação do Niri), `spawn` (um programa), `sh` (um comando de shell) ou `ipc` (uma chamada ao IPC desta shell). `options` leva propriedades do Niri (`cooldown-ms=150`), `"manual": false` esconde o atalho do Manual, `"overlay": true` põe o `label` como título da bind no overlay do Niri (só os que abrem uma peça da shell e os que eu já tinha com título; os outros ficam com a descrição do Niri; não vale em linha com `binds` nem junto com `"manual": false`) e `"waits": "F5"` marca o atalho cuja ação só existe numa fase futura (sai comentado). Uma linha do Manual que junta várias binds (a roda, Super+1 a 9) usa `keys` e `binds`.

```bash
wintermute-shell/settings/manual/keybinds.py check      # confere a lista
wintermute-shell/settings/manual/keybinds.py generate   # escreve o bloco binds { } na saída padrão
wintermute-shell/settings/manual/keybinds.py generate --output ~/.config/niri/cfg/keybinds.kdl --apply
```

`--shell CAMINHO` troca a pasta da shell nos comandos de IPC; sem ela uso a pasta onde o script mora, com o começo igual a `$HOME` escrito como `~`. Escrever dentro de `~/.config` pede `--apply`, que guarda antes uma cópia `keybinds.kdl.bak-AAAAMMDD-HHMMSS` ao lado e só aplica se o `niri validate` aceitar o arquivo.

## Mapa das pastas

| Caminho | O que guarda |
|---|---|
| `shell.qml` | Raiz da shell: instancia o papel de parede, a barra lateral, os pop-ups, a tela de Ajustes e os receptores IPC por monitor |
| `Theme.qml`, `LegacyColors.qml`, `PanelStyle.qml` | Tokens Armitage, variações de acento, tipografia Geist e camada de compatibilidade com o código de partida |
| `Sidebar.qml`, `BottomControls.qml` | Janela da barra lateral (`WlrLayershell`) e cartão inferior de controles (Wi-Fi, som, ajustes e recolher) |
| `NiriMsg.qml` | Integração com o Niri (`niri msg event-stream` e soquete IPC): workspaces, janelas, foco e o pedido do launcher pelo "+" do organizador |
| `Shortcuts.qml` | Receptores IPC de volume, mídia e brilho |
| `GlassSurface.qml`, `GradientFill.qml`, `PanelBorder.qml`, `Shadow.qml`, `Card.qml`, `CardStack.qml`, `CardLayer.qml`, `PanelBackground.qml` | Superfície de vidro Armitage (degradê vertical com dithering, borda interna em degradê, brilho superior de 1 px, brilho de acento na base e sombra em duas camadas) e cartões empilhados |
| `IconButton.qml`, `PanelCloseButton.qml`, `ActionButton.qml`, `Toggle.qml`, `Slider.qml`, `Field.qml`, `CheckBox.qml`, `RadioButton.qml`, `ListRow.qml`, `SettingsRow.qml`, `SegmentedSelector.qml`, `Chip.qml`, `Tag.qml`, `KeyCap.qml`, `AppTile.qml`, `DeviceList.qml`, `DeviceDetails.qml` | Biblioteca de componentes base Armitage (ficha `00-componentes-base.md`) |
| `ComponentDemoPanel.qml`, `FontTestPanel.qml` | Painéis de inspeção e QA para as fases F1 (componentes base) e F0 (fontes e variações) |
| `icons/` | Os 112 ícones Lucide do conjunto Armitage, desenhados em branco (`#FFFFFF`): a cor vem sempre da peça, pela colorização com um token (ficha 00). Mais o `LICENSE-lucide.txt` (ISC) |
| `minimap/` | Organizador de workspaces na barra: linhas, círculos de janela, botão `+`, arraste e indicador de terminal com agente |
| `calendar/` | Cartão do relógio + bateria na barra (`Clock.qml`) e pop-up de calendário mensal (`Card.qml`, `Window.qml`) |
| `media/` | Cartão do reprodutor MPRIS na barra (`Player.qml`, `State.qml`) |
| `notifications/` | Cartão de notificações na barra, central (`CenterWindow.qml`) e toasts com a barra recolhida (`ToastWindow.qml`) |
| `installs/`, `updates/` | Cartão de progresso de instalações na barra e selo de atualizações na tela de Ajustes |
| `wifi/` | Painel empilhado de Wi-Fi: lista de redes, senha, rede oculta, detalhes e status (`State.qml` via `nmcli`) |
| `bluetooth/` | Painel empilhado de Bluetooth: pareados, próximos, pareamento e detalhes (`actions.py` via BlueZ/D-Bus) |
| `audio/` | Painel de som: abas de saída/entrada, slider de volume e lista de dispositivos PipeWire |
| `battery/` | Pop-up de bateria e seletor de perfil de energia (`power-profiles-daemon`), indicador e alerta de bateria baixa |
| `launcher/` | Launcher (ficha 14): janela por tela com o véu, o vidro com busca, lista por seções e rodapé, e o estado `State.qml` que a peça lê. A busca (`Search.js`, biblioteca pura) casa e ordena apps, arquivos (`FileSearch.qml`, que roda o `fd`), páginas dos Ajustes e comandos de sessão, e os recentes ficam em `$XDG_STATE_HOME/wintermute-shell/launcher-recents.json`. Quando nada é achado, o launcher oferece "Search the web" (o Google, pelo `xdg-open`) e "Search files", que repete a busca de arquivos na pasta pessoal inteira, com as ocultas e sem `.git`, só no grupo Files. Também o seletor de cor (ficha 15): a página de resultado (`ColorPage.qml`, `Colors.js` com formatos, nome da cor e histórico, e o histórico em `$XDG_STATE_HOME/wintermute-shell/colors.json`) e a lupa sobre a tela congelada (`LoupeWindow.qml` por tela, `LoupeState.qml`, a peça `ColorLoupe.qml` e `PixelReader.qml`, que lê os pixels de qualquer item). O menu de ações (Ctrl+K, `ActionsHeader.qml` e `Actions.js`) é uma subpágina do launcher com as ações do item selecionado (abrir, abrir num workspace, copiar o caminho, rodar, copiar o resultado). O seletor de emoji (ficha 16) é outra subpágina (`EmojiPage.qml`, `Emoji.js` e o inventário `emoji/emoji.json`, que o `emoji/build.py` gera do Unicode 17 e do CLDR 48, com busca em inglês e em português, fonte Noto Color Emoji e os recentes em `$XDG_STATE_HOME/wintermute-shell/emoji-recents.json`) |
| `clipboard/` | Histórico da área de transferência (ficha 18), dentro do launcher: a página `ClipboardPage.qml` (campo "Search history", a lista de 280 com "Pinned" e "Today" ou "N results", a prévia de texto, imagem ou link e os metadados, e o vazio), a linha `ClipboardRow.qml`, a prévia `ClipboardPreview.qml` e a conta pura em `Clipboard.js` (filtrar, separar em seções, o tempo relativo, o texto de tamanho, o servidor de uma URL e a posição das linhas). O chip "Clipboard" do launcher abre a página (`page === "clipboard"`); Enter devolve o item à área de transferência e fecha, Ctrl+P fixa e Del apaga. O `State.qml` (F6-T16) é o serviço: escuta a área de transferência com dois `wl-paste --watch` (texto e `image/png`, só PNG) que chamam o `watch.py` uma vez por mudança, e o `watch.py` escreve uma linha de JSON por item. Só liga quando o `shell.qml` de verdade chama `start()`; a vitrine e a bancada não ganham processo. Guarda até 50 itens não fixados só na sessão (nada vai para o disco; as imagens ficam em `$XDG_RUNTIME_DIR/wintermute-shell/clipboard/`, que é memória e some ao sair), não guarda o que o gerenciador de senhas marca como sigiloso, classifica (cor, link, e-mail, comando de terminal, texto) pelo `Clipboard.js` e tem o teto de memória da proposta da F6-T16 (texto até 1 MB, PNG até 16 MB, imagens somando até 64 MB). Precisa do `wl-clipboard` (`wl-paste` e `wl-copy`) e de um compositor com o protocolo de controle de dados, como o Niri; no GNOME o histórico fica vazio, com uma linha de aviso no log. O Super+V (`launcher clipboard` no IPC) abre o launcher direto nessa página, e o Ctrl+K dela abre o menu de ações do launcher com Copy, Pin, Delete e "Clear history" |
| `settings/` | Tela inicial de Ajustes, botões de sessão (`session.py`), bandeja do sistema (`Tray.qml`), leitor KDL (`kdl.py`) e subpáginas em `appearance/`, `display/`, `system/`, `information/` e `manual/` |
| `screenshot/` | Janela de captura de tela (ficha 17): uma por tela (`CaptureWindow.qml`, com o quadro congelado do monitor), a peça (`Capture.qml`: véu, mira com coordenadas, dica, `CaptureModeBar.qml`, e a seleção de área com `CaptureSelection.qml`, a pílula de tamanho e `CaptureActions.qml`; a conta da seleção é do `Selection.js`; os modos Window e Screen desenham o anel e a pílula em `CaptureTarget.qml`, com a conta das janelas no `Windows.js`) e o estado (`CaptureState.qml`, que sempre abre do zero, sem seleção e com a foto das janelas do momento em que abre). Capturar e copiar saem do quadro congelado: a janela tira dois quadros por monitor (sem e com o cursor), o `FrameCropper.qml` recorta o que está à mostra e grava um PNG em `$XDG_RUNTIME_DIR/wintermute-shell/` (a conta do recorte é do `Crop.js`), e o estado copia o arquivo e o entrega à prévia. Prévia de captura de tela na barra (`Preview.qml` e o botão redondo `PreviewButton.qml`: miniatura de 156×112 ou 48×48 recolhida, véu e botões no hover, some em `capturePreviewDuration` e não some com o ponteiro em cima), cópia para a área de transferência (`clipboard.py`, com `copy-file` para um PNG em arquivo) e o plugin C++ do arraste da prévia para outro aplicativo (`native/`, compilado à parte, ver "Plugin de arraste da captura"; `NativeDrag.qml` é o arquivo que importa o módulo, e a `Preview.qml` o carrega por um `Loader`, para a prévia abrir também sem o plugin). Editor de anotação (F6-T14, `AnnotateWindow.qml` e a peça `Annotate.qml`, de 720×480: as ferramentas, as cinco cores, o desfazer, "Copy" e "Save", e a área da imagem em `AnnotateCanvas.qml`): as marcas são guardadas em pixels da imagem (a conta, o recorte e o desfazer são do `Annotate.js`; o documento, do `AnnotateDocument.qml`), desenhadas por `AnnotateMark.qml` dentro de uma cena do tamanho da imagem (`AnnotateScene.qml`) e exportadas com o `FrameCropper.qml` a partir dessa mesma cena; o estado (`AnnotateState.qml`) abre pela captura (o botão do lápis na pílula da seleção) e pela prévia da barra, e "Copy" grava, copia, mostra na prévia e fecha. Salvar (F6-T03) existe nos três lugares (a pílula de ações da seleção, a prévia e o "Save" do editor): grava um PNG em `~/Pictures/Screenshots` com o nome do Niri (a conta é do `Save.js`; o destino e o relógio do aviso são do `SavedState.qml`; a prévia grava pelo `clipboard.py save`, que nunca sobrescreve) e mostra o aviso "Screenshot saved" (`SavedToast.qml`, a peça de 280×64, na janela `SavedToastWindow.qml`, embaixo ao lado da barra) |
| `wallpaper/` | Camada de papel de parede por monitor (`desktop/`), shader dinâmico (`daylight/`) e script de seleção (`control.py`) |
| `assets/` | Recursos visuais herdados da origem que permanecem até o redesenho de cada peça nas fases F1 a F6 |
