# 0003 — Partir do código da interface da Pond, sem vínculo com o repositório de origem

- **Data:** 2026-11-14
- **Estado:** Aceita

## Contexto

O desenho da Wintermute Shell nasceu do estudo da interface da Pond: barra lateral, organizador de workspaces, pilha de painéis e ajustes. O design Armitage redesenha o visual e acrescenta peças que a Pond não tem (launcher próprio, seletor de cor, emoji, captura de tela integrada e histórico da área de transferência), mas mantém o comportamento das peças existentes.

Eu tinha dois caminhos: escrever a shell do zero, usando a Pond só como estudo, ou partir do código da interface da Pond, que é distribuído sob BSD-3-Clause.

## Decisão

A shell parte de uma cópia do código da interface da Pond. A cópia entra no repositório como código meu a ser transformado, e não existe nenhum vínculo técnico com o repositório de origem. Ao final do projeto, a única ligação que resta é a menção de licença.

## Motivo

O comportamento que eu quero preservar (a leitura do estado do Niri, o arraste de janelas e workspaces, a pilha de painéis) já está resolvido naquele código, e as fichas do design descrevem cada peça em relação aos arquivos dele. Reescrever tudo do zero custaria semanas para chegar ao mesmo comportamento, com mais chance de erro.

Não quero vínculo com o repositório de origem porque este projeto segue um rumo próprio: outro visual, outras peças, outro nome. Um fork formal sugeriria uma relação de acompanhamento que não existe e que eu não pretendo manter.

## Consequências

- A cópia é feita uma única vez, na fase F0, a partir de um ponto fixo do código de origem. Não acompanho atualizações posteriores.
- Sem fork do GitHub, sem remoto `upstream`, sem submódulo e sem importar histórico de commits.
- A licença BSD-3-Clause exige manter o aviso de copyright e o texto da licença da origem. Eles acompanham o código derivado e são citados na seção de licenças do README. Essa é a única menção.
- Nomes, identificadores, caminhos de configuração e elementos de marca da origem são substituídos pelos da Wintermute ao longo das fases. A fase F11 inclui uma varredura para confirmar que não sobrou nenhum.
- Recursos visuais da origem que não fazem parte do design Armitage (papéis de parede, temas, marca) não entram no repositório.
- Só a interface da shell é aproveitada. O restante da Pond (instalador, gerenciador de pacotes, tela de bloqueio, tema de inicialização) fica de fora.
