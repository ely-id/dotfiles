# 0013 — Na interface, a marca é o logo com a palavra "Wintermute"

- **Data:** 2026-11-16
- **Estado:** Aceita

## Contexto

O rodapé da página Informações é o primeiro lugar da shell que mostra a marca. O Figma (board `13:16083`) escreve "Wintermute Shell" em Serif 17, com a versão embaixo e a grade de "+" à direita, e diz que a grade some no hover dos contatos, sem desenhar contato nenhum. A origem tinha ali o logotipo dela, a versão, os quatro contatos da marca dela e o logotipo "ARCH". Na `F4-T04` tirei os contatos e os logotipos da origem e abri a P-50.

Em 2026-11-16 respondi a P-50: "Utilizar apenas enfeites nessa área do painel, como um 'footer' fazer como na referencia em anexo usando a grade de + e o arch.svg". Na mesma resposta, sobre a marca: "seria válido também usar um ícone para 'combinar' com a marca Wintermute, algo como se fosse um logo em si que fica junto com a palavra 'Wintermute' e não usar 'Wintermute Shell' no design em si mas apenas 'Wintermute + Logo'". Ainda não tenho o logo, e pedi para usar por enquanto um SVG de broto como provisório, "para já facilitar ao montar os layouts onde vai levar a marca".

## Decisão

Onde a interface mostra a marca, ela aparece como **logo + a palavra "Wintermute"**. "Wintermute Shell" continua sendo o nome do projeto: no repositório, na pasta `wintermute-shell/`, no README e na documentação. Só não aparece no desenho.

Até eu ter o logo definitivo (P-51), uso como provisório o broto que separei em `~/Downloads/Wintermute Shell/sprout-working.svg` (40×40). Ele entra no repositório num lugar só, para que a troca pelo definitivo seja trocar um arquivo. A cor não vem do arquivo, que traz o roxo `#CBA6F7` da origem: vem dos tokens do tema, como todo valor visual.

O rodapé das Informações tem só enfeites: a marca (logo + "Wintermute") com a versão, a grade de "+" e o logotipo "ARCH" do Figma (símbolo `icon/information/arch`, nó `7:1799`, 151,43×42,96), na composição da referência que mandei, que é o rodapé da origem. Sem contatos e sem links. Esse ajuste é a `F4-T17`.

## Motivo

"Wintermute Shell" descreve o que o projeto é, mas no desenho funciona como um rótulo técnico, e a palavra sozinha com um símbolo é mais forte como marca. Deixar o logo num arquivo só, desde já, faz com que cada tela que leva a marca (o rodapé agora; o bloqueio, o login e o boot depois) já nasça com o lugar certo para ele, e a troca do provisório pelo definitivo não mexa em layout nenhum.

## Consequências

- A `F4-T17` refaz o rodapé das Informações: logo provisório + "Wintermute" + versão à esquerda, grade de "+" e "ARCH" como enfeites, sem o comportamento de hover, que dependia dos contatos. O `arch.svg` sai do nó `7:1799` do Figma; o da origem, de mesmo tamanho, foi apagado no `8042031` e pode servir de conferência.
- O broto provisório tem o mesmo desenho dos indicadores de terminal da origem (`assets/terminal-loaders/sprout-*`, 40×40, no roxo dela), embora o arquivo não seja idêntico a nenhum do clone de estudo. Serve como provisório, mas não pode chegar à publicação: a F11 confere que ele foi trocado (P-51 e `F11-T02`).
- As fases que desenham telas com a marca (F7, bloqueio e login; F9, Plymouth) seguem esta regra, a menos que o board da fase já decida outra coisa; nesse caso, registro a divergência em `PENDENCIAS.md`.
- O painel de teste de fontes (`FontTestPanel.qml`) mostra "Wintermute Shell" como legenda de conferência. Não é interface e fica como está.
