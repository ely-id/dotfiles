# 0016 — Os dados de emoji vêm do Unicode e entram no repositório já gerados

- **Data:** 2026-11-19
- **Estado:** Aceita

## Contexto

Na P-14 (2026-11-18) escolhi o inventário padrão do Unicode para o seletor de emoji, com os nomes em português e em inglês das anotações do CLDR, para a busca valer nas duas línguas. Ao construir a peça (`F5-T09`) vi que esta máquina não tem esses dados em lugar nenhum: o CachyOS não instala a lista de emojis nem as anotações do CLDR, e o que existe são os dicionários compilados do IBus, que não servem de fonte. A shell precisava decidir de onde ler a lista. As opções eram:

1. Depender de um pacote do sistema com os dados e ler os arquivos dele.
2. Baixar os dados na instalação.
3. Trazer para o repositório um arquivo gerado a partir das fontes oficiais.

## Decisão

O repositório traz `wintermute-shell/launcher/emoji/emoji.json`, gerado por `wintermute-shell/launcher/emoji/build.py` a partir de cinco arquivos oficiais:

- `emoji-test.txt` do Emoji 17.0 (`unicode.org/Public/17.0.0/emoji/`), que dá a lista, os grupos e a ordem;
- as anotações do CLDR 48 em inglês e em português (`unicode-org/cldr-json`, `cldr-annotations-full` e `cldr-annotations-derived-full`), que dão o nome e as palavras-chave.

As fontes cruas não entram no repositório: são 2,4 MB, e o script diz de onde baixá-las. Entram o arquivo gerado (305 KB), o script e a licença (`LICENSE-unicode.txt`, Unicode License V3), e o `README.md` cita o Unicode na seção de licenças.

O gerador fica só com as sequências `fully-qualified`, tira o grupo de componentes e as variações de tom de pele (que a P-14 deixou para depois) e confere os números: 1.914 emojis em nove grupos, todos com nome nas duas línguas. Se uma conta não fecha, ele falha em vez de escrever.

## Motivo

**No repositório, e não num pacote,** porque a instalação tem que ser reproduzível por qualquer pessoa, e eu não achei nesta máquina um pacote que traga a lista e as anotações em português num formato estável. Depender de um seria amarrar a peça a um caminho de arquivo que não controlo.

**Gerado, e não baixado na instalação,** porque a shell não deve precisar de rede para funcionar, e porque a versão dos dados tem que andar junto com a versão da fonte: o Emoji 17.0 é o que a Noto Color Emoji instalada desenha inteiro. Com os dados fixos no repositório, um emoji novo só aparece na grade depois de eu conferir que a fonte o desenha.

**Com o script junto,** para a origem ficar conferível: rodar o `build.py` sobre as fontes reproduz o arquivo byte a byte, e trocar de versão é baixar as fontes novas e ajustar as contagens.

## Consequências

- Os dados do Unicode são o segundo material de terceiros distribuído com a shell, depois dos ícones Lucide. A licença acompanha os dados, e a citação fica no `README.md`.
- Atualizar para um Emoji novo é um passo manual: baixar as cinco fontes, rodar o gerador, conferir que a fonte instalada cobre os novos e ajustar as contagens esperadas no script.
- Os tons de pele, quando entrarem, mudam o gerador (as variações voltam, agrupadas pelo emoji de base), e não a origem dos dados.
- A F10 instala o `noto-fonts-emoji`; sem ele os emojis caem na fonte do sistema.
