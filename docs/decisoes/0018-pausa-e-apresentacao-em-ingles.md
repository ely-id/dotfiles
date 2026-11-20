# 0018 — Pausa do projeto, apresentação em inglês e a documentação do fluxo de agentes

- **Data:** 2026-11-20
- **Estado:** Aceita

## Contexto

No QA ao vivo do lote (S39), com a F4 e a F5 em `go` e a F6 no meio do roteiro, decidi pausar o projeto. Vou migrar para o Fedora e usar o GNOME, para focar em produtividade e estudos, então a instalação com o Niri e a Wintermute Shell deixa de ser o meu próximo passo. Não quero que o repositório fique como uma obra parada no meio: quero que ele mostre bem o que foi construído e como.

## Decisão

1. **O projeto fica pausado em 2026-11-20**, no estado em que o QA ao vivo o deixou. As fases F7 a F11 não começam. A F6 fica sem veredito, com o defeito da captura registrado.
2. **A apresentação do repositório passa a ser em inglês:** o `README.md` da raiz, o da shell, o da pasta `niri/`, um catálogo visual das peças em `docs/showcase/` e a documentação do fluxo de trabalho em `docs/agent-workflow/`. Continuo escrevendo em primeira pessoa.
3. **O registro de trabalho continua em português, como história:** as decisões (`docs/decisoes/`), as fichas e os tokens (`docs/design/`), o `AGENTS.md`, o `CLAUDE.md`, as skills e os comentários do código. Traduzir tudo seria reescrever o histórico, e ele vale como foi escrito.
4. **A pasta `docs/agent-workflow/` documenta a estrutura de agentes e o painel do Obsidian**, com os nomes das ferramentas. É uma exceção, escolhida por mim, à regra de que a atribuição a ferramentas de IA fica só na seção de licenças e reconhecimentos do README (decisão 0006). As mensagens de commit continuam sem rodapé de coautoria e sem menção a ferramentas.
5. **A interface da shell continua em inglês** (decisão 0012). Nada muda no código por causa desta decisão.

## Motivo

O que mais aprendi neste projeto foi o próprio método: fases com portão, fichas como fonte da verdade, um painel fora do repositório e um ciclo de agentes com papéis separados. Isso merece estar documentado tanto quanto a shell. Em inglês, porque é a língua em que um repositório assim é lido por mais gente; e a história em português, porque foi nela que eu pensei e decidi.

## Consequências

- O README deixa de dizer "em construção" e passa a dizer "pausado", com o que funciona, o que não foi validado e os defeitos conhecidos.
- A pendência P-22 (o que do ferramental de agente fica público) fica respondida em parte: o ferramental e a documentação dele ficam no repositório. Tornar o repositório público continua dependendo de um pedido meu.
- Quem retomar o projeto começa pelo `PAINEL.md`, pela subfase `F6.1` (a queda da captura) e pela `F7-T10`.
