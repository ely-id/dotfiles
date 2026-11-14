# 0010 — Ferramental de agente comum em `.agents/`, para o Claude Code e o Antigravity

- **Data:** 2026-11-14
- **Estado:** Aceita

## Contexto

Até aqui todo o ferramental de agente estava em `.claude/`: as três skills do projeto, o hook que injeta o painel, o mapa de skills e os bloqueios. Os limites semanais do Claude Code começaram a apertar e quero poder abrir sessões também no Antigravity, sem mudar o protocolo.

O Antigravity lê o `AGENTS.md` da raiz em todo turno e procura o resto em `.agents/`: skills em `.agents/skills/<nome>/SKILL.md`, no mesmo formato das do Claude Code, regras em `.agents/rules/`, hooks em `.agents/hooks.json` e servidores MCP em `.agents/mcp_config.json`. Ele não lê `.claude/` nem o `CLAUDE.md`, e o Claude Code não lê `.agents/`.

As diferenças que pesam:

- O hook `SessionStart` do Antigravity espera JSON na saída, com a lista `injectSteps`, e não recebe `CLAUDE_PROJECT_DIR`.
- O Antigravity não tem arquivo de permissão por projeto: as regras de bloqueio ficam na configuração global dele.
- `/code-review`, `/simplify` e `/security-review` são comandos do próprio Claude Code. Não há arquivo para levar.
- As skills externas vêm de plugins do Claude Code, que o Antigravity não lê.

Para ter as skills nas duas pastas, as opções eram link simbólico ou cópia. O Claude Code tem falhas registradas com skills em links simbólicos (descoberta no app de desktop, autocompletar, validação), e a documentação do Antigravity não diz se segue links.

## Decisão

- `.agents/` guarda o que é comum: as skills do projeto, o hook de estado, os scripts e o mapa de skills.
- `.claude/skills/` passa a ser uma cópia de `.agents/skills/`, refeita por `.agents/scripts/sincronizar-skills.sh`. O hook de início de sessão avisa quando as duas divergem.
- O mesmo `estado-do-projeto.sh` serve às duas ferramentas. No Antigravity, `antigravity-inicio.py` embrulha a saída no JSON que o hook pede.
- Os bloqueios de `ESCOPO.md` e de `~/Projects/referencias/` são repetidos no Antigravity por um hook `PreToolUse` versionado, `antigravity-protecao.py`, em vez de depender da configuração global.
- As skills externas são copiadas para `~/.gemini/config/skills/` por `.agents/scripts/instalar-skills-externas.sh`, fora do repositório.
- O que é de uma ferramenta só fica com ela: `CLAUDE.md` e `.claude/settings.json` para o Claude Code; `.agents/rules/antigravity.md`, `.agents/hooks.json` e `.agents/mcp_config.json` para o Antigravity.

## Motivo

Uma fonte só para as skills e para o aviso de início de sessão é o que garante que as duas ferramentas sigam o mesmo protocolo. Se cada uma tivesse a sua versão, a primeira correção feita numa delas já deixaria a outra para trás sem ninguém perceber.

Escolhi cópia em vez de link porque uma skill que some em silêncio é pior do que uma cópia que pode ficar velha: a cópia velha o hook detecta; a skill que não carregou ninguém vê. A fonte é `.agents/` e não `.claude/` porque `.agents/` é a convenção aberta, a mesma do `AGENTS.md`, e não pertence a nenhuma das duas ferramentas.

Os bloqueios no hook, e não na configuração global, porque eles são regra deste projeto e precisam acompanhar o repositório, como acontece no Claude Code.

As skills externas ficam fora do repositório porque são de terceiros, com licenças próprias, e o repositório vai ser público na F11.

## Consequências

- Skill se edita só em `.agents/skills/`, e a cópia entra no mesmo commit.
- No Antigravity, o painel precisa estar adicionado como segunda pasta do projeto, ou a sessão não consegue registrar nada.
- As etapas de `/code-review`, `/simplify` e `/security-review` continuam acontecendo no Claude Code.
- O formato do hook `SessionStart`, a pasta em que o Antigravity roda os comandos dos hooks e o servidor MCP do Figma não foram testados no Antigravity quando escrevi isto. A primeira sessão nele confere os três.
- Uma ferramenta por vez: o painel continua sem controle de versão.
- A P-22 (o que do ferramental fica público) passa a incluir `.agents/`.
