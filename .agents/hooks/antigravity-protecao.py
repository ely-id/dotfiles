#!/usr/bin/env python3
"""Hook PreToolUse do Antigravity: bloqueia escrita onde o projeto proíbe.

No Claude Code, os bloqueios de ESCOPO.md e de ~/Projects/referencias/ estão
em .claude/settings.json. O Antigravity guarda permissões só na configuração
global, então repito os bloqueios aqui, versionados com o repositório.
Cobre as ferramentas de escrita de arquivo com os dois conjuntos de nomes que
encontrei: write_to_file, replace_file_content e multi_replace_file_content,
com o caminho em TargetFile, como na documentação dos hooks; e write_file e
edit_file, com o caminho em Path, como o próprio agente do Antigravity
descreveu as ferramentas dele na primeira sessão. Comando de terminal não
passa por aqui, como também não passa no Claude Code.
"""

import json
import os
import sys
from pathlib import Path


def caminho(texto):
    return Path(os.path.realpath(os.path.expanduser(texto)))


painel = caminho(os.environ.get("DOTFILES_PAINEL", "~/Documents/Journal/projeto-dotfiles"))
ARQUIVOS = [painel / "ESCOPO.md"]
PASTAS = [caminho("~/Projects/referencias")]

try:
    entrada = json.loads(sys.stdin.read() or "{}")
except json.JSONDecodeError:
    entrada = {}

args = (entrada.get("toolCall") or {}).get("args") or {}
alvo = args.get("TargetFile") or args.get("Path")
decisao = {"decision": "allow"}

if alvo:
    destino = caminho(alvo)
    if destino in ARQUIVOS:
        decisao = {
            "decision": "deny",
            "reason": "ESCOPO.md é imutável (AGENTS.md, seção Escopo). "
            "Mudança de escopo vira entrada nova em AJUSTES-DE-ESCOPO.md.",
        }
    elif any(destino.is_relative_to(p) for p in PASTAS):
        decisao = {
            "decision": "deny",
            "reason": "~/Projects/referencias/ é somente leitura (AGENTS.md, "
            "seção Código de origem externa).",
        }

print(json.dumps(decisao, ensure_ascii=False))
