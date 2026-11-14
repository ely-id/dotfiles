#!/usr/bin/env python3
"""Hook SessionStart do Antigravity.

Roda o mesmo estado-do-projeto.sh que o Claude Code usa e entrega a saída
no formato que o Antigravity espera: um JSON com a lista injectSteps. Assim
a lógica do aviso fica num lugar só e as duas ferramentas abrem a sessão
com o mesmo texto.
"""

import json
import subprocess
import sys
from pathlib import Path

PASTA = Path(__file__).resolve().parent
REPO = PASTA.parent.parent

# O Antigravity manda os dados da sessão pela entrada padrão. Não preciso de
# nenhum campo, mas leio para não deixar o cano cheio.
sys.stdin.read()

try:
    texto = subprocess.run(
        ["bash", str(PASTA / "estado-do-projeto.sh")],
        cwd=REPO,
        capture_output=True,
        text=True,
        timeout=10,
    ).stdout.strip()
except (OSError, subprocess.TimeoutExpired):
    texto = ""

if texto:
    saida = {"injectSteps": [{"systemMessage": {"systemMessage": texto}}]}
else:
    saida = {}

print(json.dumps(saida, ensure_ascii=False))
