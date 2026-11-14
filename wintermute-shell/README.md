# Wintermute Shell

Shell de desktop em Quickshell/QML para o Niri, com o visual Armitage.

> **Estado:** esta pasta ainda não tem código. Ele entra na fase F0.

## O que a shell terá

| Peça | Fase |
|---|---|
| Tema Armitage (Chiba, Freeside, Sprawl), fontes Geist e ícones Lucide | F0 |
| Vidro e componentes base | F1 |
| Barra lateral e organizador de workspaces | F2 |
| Painéis de Wi-Fi, Bluetooth, som, bateria, calendário, notificações e OSDs | F3 |
| Ajustes | F4 |
| Launcher, seletor de cor e emoji | F5 |
| Captura de tela e histórico da área de transferência | F6 |

As medidas, os estados e o comportamento de cada peça estão nas fichas em [`docs/design/pecas/`](../docs/design/README.md).

## Como esta pasta será organizada

Quando o código entrar, este README passa a responder a três perguntas, nesta ordem:

1. **Como rodo a shell?** Dependências e o comando para abrir a shell na sessão do Niri.
2. **Onde configuro?** O arquivo de tema, o arquivo de atalhos e as preferências do usuário, cada um com o caminho e um exemplo.
3. **Onde fica cada peça?** Um mapa das pastas, uma por peça.

## Origem do código

A shell parte do código da interface da Pond, sob licença BSD-3-Clause. O motivo e as condições estão na [decisão 0003](../docs/decisoes/0003-base-de-codigo-da-pond.md). O aviso de licença da origem acompanhará o código nesta pasta.
