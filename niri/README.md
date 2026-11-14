# Niri

Configuração do compositor Niri para a instalação nova.

> **Estado:** esta pasta fica vazia até a fase F8.

## Por que só no final

Durante a construção da shell, a configuração do Niri em `~/.config/niri/` muda a cada fase: atalhos novos para o launcher e a captura, regras de janela, reserva de espaço da barra lateral, anel de foco. Versionar essa configuração agora significaria corrigi-la a cada fase. Prefiro recolher tudo uma vez, quando a shell estiver pronta e a configuração estiver estável.

## O que a varredura da fase F8 recolhe

- Atalhos de teclado, em um único arquivo fácil de editar.
- Entrada: teclado `us altgr-intl`, touchpad e gestos.
- Telas e escala.
- Layout: espaçamentos, anel de foco e a reserva de espaço da barra lateral.
- Regras de janela.
- Animações.
- Inicialização da sessão: a shell e os serviços de que ela depende.
- Qualquer arquivo fora de `~/.config/niri/` que a sessão precise para funcionar (variáveis de ambiente, portais, entrada de sessão).

Cada arquivo recolhido recebe um comentário de cabeçalho dizendo o que configura, e dados específicos desta máquina (nomes de monitor, caminhos pessoais) são separados do que é genérico.
