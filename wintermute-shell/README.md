# Wintermute Shell

Interface gráfica em Quickshell/QML para o Niri, desenhada com o sistema visual **Armitage** nas três variações escuras (**Chiba**, **Freeside** e **Sprawl**).

O código parte de uma cópia da shell da Pond (`LICENSE-pond-interface.txt`, BSD-3-Clause) e recebe os tokens, a tipografia Geist, os ícones Lucide e as peças do meu design ao longo das fases F0 a F7.

## Como rodar

Dentro de uma sessão ativa do Niri (com `NIRI_SOCKET` definido no ambiente), abro a shell apontando o Quickshell direto para esta pasta, sem precisar copiar nada para `~/.config/quickshell/`:

```bash
qs -p ~/Projects/dotfiles/wintermute-shell
```

### Comandos IPC

Com a shell aberta, aciono ações pelo IPC do Quickshell (`qs -p ~/Projects/dotfiles/wintermute-shell ipc call <alvo> <função>`):

| Alvo e função | O que faz |
|---|---|
| `sidebar toggle` | Recolhe ou expande a barra lateral (156 px ↔ 48 px) |
| `settings toggle` | Abre ou fecha a tela inicial de Ajustes e sessão |
| `settings open <página>` | Abre direto uma subpágina (`appearance`, `system`, `display`, `information`, `manual`, `wallpaper`) |
| `settings close` | Fecha os Ajustes |
| `manual open` | Abre o Manual de atalhos |
| `volume increase` / `decrease` | Ajusta o volume de saída em passos de 2% |
| `volume muteOutput` / `muteInput` | Alterna o mudo da saída ou do microfone |
| `brightness increase` / `decrease` | Ajusta o brilho do monitor focado em passos de 5% |
| `media playPause` / `next` / `previous` | Controla o reprodutor MPRIS ativo |
| `screenshot loaded <caminho> [saída]` | Mostra a prévia de uma captura recém-salva |

## Onde configurar

- **Tema e tokens (`Theme.qml`):** única fonte de verdade em código para cores, tipografia, raios, sombras, medidas e durações. Espelha `../docs/design/tokens/tokens.json`.
- **Variação ativa (`~/.config/wintermute-shell/theme.json`):** guarda a escolha entre `"chiba"`, `"freeside"` e `"sprawl"`. Pode ser trocada pelos três discos da página **Aparência** nos Ajustes ou gravando `{"theme": "chiba"}` no arquivo; o `FileView` de `Theme.qml` observa o arquivo e aplica a mudança na hora.
- **Atalhos e IPC (`Shortcuts.qml` e `shell.qml`):** definem os receptores IPC que os atalhos do Niri chamam.

## Mapa das pastas

| Caminho | O que guarda |
|---|---|
| `shell.qml` | Raiz da shell: instancia o papel de parede, a barra lateral, os pop-ups, a tela de Ajustes e os receptores IPC por monitor |
| `Theme.qml`, `LegacyColors.qml`, `PanelStyle.qml` | Tokens Armitage, variações de acento, tipografia Geist e camada de compatibilidade com o código de partida |
| `Sidebar.qml`, `BottomControls.qml` | Janela da barra lateral (`WlrLayershell`) e cartão inferior de controles (Wi-Fi, som, ajustes e recolher) |
| `NiriMsg.qml` | Integração com o Niri (`niri msg event-stream` e soquete IPC): workspaces, janelas, foco e marcador do launcher (até a F5) |
| `Shortcuts.qml` | Receptores IPC de volume, mídia e brilho |
| `Card.qml`, `CardStack.qml`, `CardLayer.qml`, `DeviceList.qml`, `DeviceDetails.qml`, `Field.qml`, `Slider.qml`, `Toggle.qml`, `IconButton.qml`, `PanelCloseButton.qml` | Componentes base compartilhados entre cartões e painéis |
| `icons/` | Os 111 ícones Lucide do conjunto Armitage (`#F2F3F5`) e `LICENSE-lucide.txt` (ISC) |
| `minimap/` | Organizador de workspaces na barra: linhas, círculos de janela, botão `+`, arraste e indicador de terminal com agente |
| `calendar/` | Cartão do relógio + bateria na barra (`Clock.qml`) e pop-up de calendário mensal (`Card.qml`, `Window.qml`) |
| `media/` | Cartão do reprodutor MPRIS na barra (`Player.qml`, `State.qml`) |
| `notifications/` | Cartão de notificações na barra, central (`CenterWindow.qml`) e toasts com a barra recolhida (`ToastWindow.qml`) |
| `installs/`, `updates/` | Cartão de progresso de instalações na barra e selo de atualizações na tela de Ajustes |
| `wifi/` | Painel empilhado de Wi-Fi: lista de redes, senha, rede oculta, detalhes e status (`State.qml` via `nmcli`) |
| `bluetooth/` | Painel empilhado de Bluetooth: pareados, próximos, pareamento e detalhes (`actions.py` via BlueZ/D-Bus) |
| `audio/` | Painel de som: abas de saída/entrada, slider de volume e lista de dispositivos PipeWire |
| `battery/` | Pop-up de bateria e seletor de perfil de energia (`power-profiles-daemon`), indicador e alerta de bateria baixa |
| `settings/` | Tela inicial de Ajustes, botões de sessão (`session.py`), bandeja do sistema (`Tray.qml`), leitor KDL (`kdl.py`) e subpáginas em `appearance/`, `display/`, `system/`, `information/` e `manual/` |
| `screenshot/` | Prévia de captura de tela na barra (`Preview.qml`), cópia para a área de transferência (`clipboard.py`) e código do plugin C++ de arraste (`native/`, desligado até a F6) |
| `wallpaper/` | Camada de papel de parede por monitor (`desktop/`), shader dinâmico (`daylight/`) e script de seleção (`control.py`) |
| `assets/` | Recursos visuais herdados da origem que permanecem até o redesenho de cada peça nas fases F1 a F6 |
