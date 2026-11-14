# 0002 — Niri como compositor e avaliação em sessão paralela ao GNOME

- **Data:** 2026-11-14
- **Estado:** Aceita

## Contexto

A shell precisa de um compositor Wayland e eu preciso de uma forma de testá-la de verdade, com janelas, monitores e gestos reais, sem arriscar a instalação que uso para trabalhar todos os dias.

## Decisão

O compositor é o Niri. A avaliação de cada fase acontece em uma sessão do Niri instalada ao lado da sessão do GNOME, na mesma máquina. Eu escolho a sessão na tela de login: GNOME para o dia a dia, Niri para avaliar a shell.

## Motivo

O organizador de workspaces, peça central da shell, foi desenhado em torno do modelo de colunas roláveis do Niri. Trocar de compositor significaria redesenhar a peça principal.

Avaliar em sessão paralela me dá um ambiente ao vivo para dar o veredito Go/NoGo de cada fase e mantém o GNOME intacto como rede de segurança. Se a shell quebrar, eu saio da sessão e continuo trabalhando.

## Consequências

- Nenhuma fase migra esta máquina para fora do GNOME. A migração acontece só na instalação nova.
- A configuração do Niri em `~/.config/niri/` muda durante a construção e só é recolhida para o repositório na fase F8.
- Tudo o que a shell assume sobre o ambiente (variáveis, serviços, portais) precisa funcionar em uma sessão do Niri iniciada pela tela de login, não só dentro de uma janela aninhada.
- Requisitos que acompanham todas as fases: teclado `us altgr-intl`, gestos de touchpad do Niri intactos e copiar e colar entre aplicativos Wayland e XWayland.
