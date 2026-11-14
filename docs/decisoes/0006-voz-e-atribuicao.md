# 0006 — Primeira pessoa em tudo e atribuição apenas no README

- **Data:** 2026-11-14
- **Estado:** Aceita

## Contexto

Construo este projeto com o apoio de um agente de código. Documentação escrita por agente costuma sair em terceira pessoa ("o usuário pediu", "foi solicitado"), o que deixa a leitura artificial e esconde o que mais importa: o motivo de cada escolha.

## Decisão

Todo texto do projeto é escrito em primeira pessoa do singular, como se eu tivesse construído cada parte: código, comentários, documentação, decisões, commits, relatórios e handoffs. O idioma é o português do Brasil.

A atribuição ao Claude Code aparece em um único lugar: a seção de licenças e reconhecimentos do README.

## Motivo

Quero reler qualquer arquivo daqui a um ano e entender por que tomei cada decisão, com a naturalidade de quem lê as próprias anotações. A primeira pessoa obriga cada registro a carregar um motivo, porque "escolhi X" pede um "porque" logo em seguida.

Concentrar a atribuição no README mantém o reconhecimento honesto e visível sem espalhar marcas de ferramenta pelo histórico e pelos arquivos.

## Consequências

- Mensagens de commit não levam rodapé de coautoria. A atribuição automática está desligada na configuração do projeto.
- Textos herdados de outras fontes são reescritos nessa voz quando entram no repositório.
- A regra vale também para o painel do projeto, fora do repositório.
