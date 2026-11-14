# 0001 — CachyOS como base do sistema

- **Data:** 2026-11-14
- **Estado:** Aceita

## Contexto

A instalação nova precisa de uma base Arch para rodar o Niri e o Quickshell em versões recentes. O meu hardware depende de um fix do TSC que só existe no kernel do CachyOS. Considerei duas bases: Arch Linux puro e CachyOS.

## Decisão

A instalação nova é construída sobre o CachyOS.

## Motivo

No Arch Linux eu teria uma etapa a mais antes de conseguir aplicar o fix: instalar o sistema com o kernel padrão e depois trocá-lo pelo kernel do CachyOS. Essa troca é um ponto extra de falha em um processo que quero simples e repetível. No CachyOS o kernel certo já vem instalado, e o fix pode ser aplicado direto.

A Pond, que serve de referência para a interface, é uma distribuição completa. Dela eu aproveito apenas o desenho da interface, não a base do sistema.

## Consequências

- O instalador e o guia da fase F8 assumem CachyOS. Outras bases Arch podem funcionar, mas não são testadas.
- O fix do TSC precisa ser documentado na fase F8 com sintoma, procedimento e forma de verificar. Esse detalhamento ainda não está escrito.
- A lista de pacotes usa os repositórios do CachyOS como fonte.
