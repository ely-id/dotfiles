# 0009 — Tema Armitage único, com uma camada de compatibilidade até a F6

- **Data:** 2026-11-14
- **Estado:** Aceita

## Contexto

O código de partida e o tema Armitage falam línguas diferentes. O código lê o tema por papéis: cerca de cem nomes como `Theme.colors.sidebarCardFill` ou `Theme.colors.closeHoverGlyph`, um para cada uso, mais 25 propriedades soltas. O tema Armitage trabalha com tokens: poucos nomes (`accent`, `hover`, `border`, `track`) que as fichas combinam em cada peça.

Ao integrar o tema, na fase F0, eu tinha três caminhos:

1. Mapear agora os cem papéis para tokens.
2. Manter os temas da origem ao lado do Armitage.
3. Trocar o tema inteiro e manter os nomes antigos em uma camada separada, temporária.

Apareceu também um problema que ninguém tinha visto, porque o arquivo aprovado nunca tinha sido carregado: o token `onAccent` impede o QML de abrir o arquivo. Um nome que começa com `on` seguido de maiúscula é lido como tratador de sinal.

## Decisão

O `Theme.qml` Armitage é o único tema da shell e mora em `wintermute-shell/`. Os cinco temas da origem saíram.

Os nomes que o código antigo ainda lê ficam em dois lugares marcados como temporários: o bloco "Compatibilidade com o código de partida", no fim do `Theme.qml`, e o arquivo `LegacyColors.qml`. Os valores são os do tema padrão da origem. Só o acento e o texto principal já vêm dos tokens.

Cada fase de F1 a F6 apaga dali o que a peça dela deixou de ler. No fim da F6 o bloco e o arquivo deixam de existir. Código novo não lê nada da camada de compatibilidade.

No QML, o token `onAccent` se chama `textOnAccent`. No `tokens.json` e nas fichas ele continua `onAccent`.

## Motivo

**Não mapear tudo agora,** porque decidir que token cada papel vira é redesenhar cada peça, e isso é o trabalho das fichas, peça por peça, com print ao lado da referência. Fazer de uma vez, sem conferir, seria escolher cores no escuro, e a regra do projeto é nunca inventar valor.

**Não manter os temas da origem,** porque a decisão 0003 não traz os temas dela e a shell é sempre escura, com três variações que mudam só o acento.

**Uma camada separada e marcada,** porque assim a shell abre desde a F0, com o visual antigo que a fase aceita, e o que falta redesenhar fica visível: é o que ainda está na camada. Ela funciona como lista de trabalho.

**Ligar o acento desde já,** porque o critério de aceite da F0 pede que trocar a variação troque só os acentos, e porque é o único papel cuja correspondência com o token não deixa dúvida.

**`textOnAccent` e não outro nome,** porque diz o que o token é: a cor do texto e do ícone que ficam em cima de um preenchimento de acento. Mantive `onAccent` no `tokens.json` e nas fichas para não reescrever o que foi aprovado.

## Consequências

- Até a F6 a shell mistura duas origens de cor. Peças não redesenhadas aparecem com o cinza da origem e com roxos escritos direto no código, que não acompanham o acento.
- Toda fase de F1 a F6 tem uma tarefa de conferência: o que a peça deixou de ler sai da camada.
- A F11 confere que `LegacyColors.qml` e o bloco de compatibilidade não existem mais.
- Quem lê uma ficha e procura `onAccent` no código precisa saber que o nome é `textOnAccent`. Está anotado em `docs/design/README.md` e no próprio `Theme.qml`.
