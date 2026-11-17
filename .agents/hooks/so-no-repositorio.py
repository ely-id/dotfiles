#!/usr/bin/env python3
"""Hook PreToolUse dos subagentes do ciclo: escrita só dentro do repositório.

No ciclo (decisão 0014), só a sessão principal escreve no painel, que não tem
controle de versão, e ninguém escreve em ~/.config/. Os subagentes dev-shell e
varredura editam código, então não dá para tirar deles o Edit e o Write; este
hook recusa a escrita quando o arquivo fica fora do repositório. O qa-visual
nem tem as ferramentas de escrita.

Recebo o JSON da chamada na entrada padrão. Saída 2 recusa, com o motivo em
stderr; saída 0 deixa passar. Comando de terminal não passa por aqui.
"""

import json
import os
import sys
from pathlib import Path

repo = Path(os.environ.get("CLAUDE_PROJECT_DIR") or Path(__file__).resolve().parents[2]).resolve()

try:
    entrada = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(0)

args = entrada.get("tool_input") or {}
alvo = args.get("file_path") or args.get("notebook_path")
if not alvo:
    sys.exit(0)

destino = Path(os.path.expanduser(alvo))
if not destino.is_absolute():
    destino = Path(entrada.get("cwd") or repo) / destino
destino = Path(os.path.realpath(destino))

if not destino.is_relative_to(repo):
    print(
        f"Escrita recusada em {destino}: no ciclo, os subagentes só escrevem dentro de {repo}. "
        "O painel é escrito pela sessão principal, e ~/.config/ fica para a sessão ao vivo. "
        "Devolva no relatório o que precisa ser registrado ou aplicado.",
        file=sys.stderr,
    )
    sys.exit(2)
sys.exit(0)
