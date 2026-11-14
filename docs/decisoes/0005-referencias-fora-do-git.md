# 0005 — Material de estudo e imagens de referência fora do git

- **Data:** 2026-11-14
- **Estado:** Aceita

## Contexto

Para construir a shell eu consulto três materiais que não são parte do produto: o código da interface da Pond, o pacote de entrega original do design e 40 MB de imagens de referência. Eu precisava decidir onde eles ficam.

## Decisão

Todo material de estudo fica em `~/Projects/referencias/dotfiles-estudo/`, fora do repositório e tratado como somente leitura. O repositório guarda apenas a versão em texto do design: as fichas das peças e os tokens, em `docs/design/`.

## Motivo

Separar o que é construção do que é estudo deixa o repositório enxuto e sem ambiguidade sobre o que é meu. Binários versionados ficam no histórico do git para sempre, e 40 MB de PNGs transformariam cada clone em um download pesado sem nenhum ganho para quem só quer instalar.

As fichas e os tokens, por outro lado, são texto leve e são a fonte da verdade dos valores. Eles precisam estar versionados junto do código que os implementa.

## Consequências

- As fichas citam as imagens por um caminho relativo (`referencias/armitage/...`). Esse caminho se resolve dentro do pacote original, conforme [design/README.md](../design/README.md).
- Quem clonar o repositório não recebe as imagens. O Figma é a referência visual pública, e capturas leves da shell pronta entram no README na fase F9.
- O pacote de entrega original fica preservado como veio. A versão que vale é a de `docs/design/`, com os caminhos e os identificadores do Figma corrigidos.
