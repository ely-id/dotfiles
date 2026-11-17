#!/usr/bin/env bash
# Lint de proveniência: procura valor visual inventado nas linhas que mudaram.
#
# A regra do AGENTS.md é que cor, medida, raio, tempo e tipografia saem dos
# tokens e das fichas. Medida e tempo literais são comuns e legítimos no QML
# (a ficha diz 16, o código diz 16), então não dá para checar sem gerar ruído.
# Cor e família de fonte são diferentes: toda cor da shell mora no Theme.qml e
# toda família vem de Theme.fontFamily, titleFontFamily ou monoFontFamily.
# Uma cor ou fonte escrita direto numa peça é quase sempre valor inventado.
#
# Só olho linhas acrescentadas ou alteradas, para que o código herdado da
# origem, que ainda vai ser refeito, não reprove o trabalho de hoje.
#
# Erro (termina com 1):
#   - cor literal: "#RRGGBB", "#AARRGGBB", "#RGB", Qt.rgba(), Qt.rgb(), Qt.hsla(), Qt.hsva()
#   - família de fonte literal: font.family: "..."
# Aviso (não reprova):
#   - Qt.darker(), Qt.lighter() e Qt.rgba() montado com componentes de um token
#     (Theme.accent.r etc.): derivam uma cor nova de um token
# Não conta: Qt.rgba(0, 0, 0, 0), que é só transparente.
#   - texto de interface com acento: a interface fala inglês (decisão 0012)
#
# Ficam de fora o Theme.qml, o LegacyColors.qml, a vitrine (ComponentDemoPanel.qml,
# FontTestPanel.qml) e os dados fictícios de demo/. Uma linha com o comentário
# "proveniencia:" seguido da fonte (ex.: // proveniencia: ficha 13, logo) também
# fica de fora: é o jeito de dizer de onde veio um valor que não é token.
#
# Uso:
#   lint-proveniencia.sh            compara a árvore de trabalho (com o que está no índice) com o HEAD
#   lint-proveniencia.sh <commit>   compara a árvore de trabalho com <commit> (ex.: o início da tarefa)

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo"
base="${1:-HEAD}"

fora='^wintermute-shell/(Theme\.qml|LegacyColors\.qml|ComponentDemoPanel\.qml|FontTestPanel\.qml|demo/)'

# Texto de interface com letra acentuada (À a ÿ). Com a locale em UTF-8 o bash recusa a faixa [À-ÿ]
# no [[ =~ ]] ("Invalid range end"), e a checagem ficava desligada sem reprovar nada. O grep com
# expressão do Perl entende a faixa pelos números das letras, em qualquer locale UTF-8.
tem_acento() {
  grep -qP '(text|title|label|placeholder)[A-Za-z]*:\s*".*[\x{C0}-\x{FF}]' <<< "$1"
}

linhas_novas() {
  # Saída: arquivo<TAB>linha<TAB>conteúdo, só das linhas acrescentadas.
  git diff --unified=0 --no-color "$base" -- 'wintermute-shell/*.qml' \
    | awk '
        /^\+\+\+ / { arquivo = substr($0, 7); next }
        /^@@/ {
          split($3, partes, ",")
          linha = substr(partes[1], 2) + 0
          next
        }
        /^\+/ { printf "%s\t%d\t%s\n", arquivo, linha, substr($0, 2); linha++; next }
      '
  # Arquivos novos que ainda não estão no índice entram inteiros.
  git ls-files --others --exclude-standard -- 'wintermute-shell/*.qml' \
    | while read -r arquivo; do
        awk -v a="$arquivo" '{ printf "%s\t%d\t%s\n", a, NR, $0 }' "$arquivo"
      done
}

erros=0
avisos=0
while IFS=$'\t' read -r arquivo linha conteudo; do
  [[ "$arquivo" =~ $fora ]] && continue
  [[ "$conteudo" == *proveniencia:* ]] && continue
  codigo="${conteudo%%//*}"   # comentário de linha não conta
  codigo="${codigo//Qt.rgba(0, 0, 0, 0)/}"
  if [[ "$codigo" =~ Qt\.(rgba|rgb|hsla|hsva)\([^\)]*Theme\. ]]; then
    echo "AVISO $arquivo:$linha  cor derivada de token: ${conteudo#"${conteudo%%[![:space:]]*}"}"
    avisos=$(( avisos + 1 ))
  elif [[ "$codigo" =~ \"#[0-9A-Fa-f]{3,8}\" ]] || [[ "$codigo" =~ Qt\.(rgba|rgb|hsla|hsva)\( ]]; then
    echo "ERRO  $arquivo:$linha  cor literal: ${conteudo#"${conteudo%%[![:space:]]*}"}"
    erros=$(( erros + 1 ))
  elif [[ "$codigo" =~ font\.family:[[:space:]]*\" ]]; then
    echo "ERRO  $arquivo:$linha  fonte literal: ${conteudo#"${conteudo%%[![:space:]]*}"}"
    erros=$(( erros + 1 ))
  elif [[ "$codigo" =~ Qt\.(darker|lighter)\( ]]; then
    echo "AVISO $arquivo:$linha  cor derivada de token: ${conteudo#"${conteudo%%[![:space:]]*}"}"
    avisos=$(( avisos + 1 ))
  elif tem_acento "$codigo"; then
    echo "AVISO $arquivo:$linha  texto com acento na interface: ${conteudo#"${conteudo%%[![:space:]]*}"}"
    avisos=$(( avisos + 1 ))
  fi
done < <(linhas_novas)

echo "Lint de proveniência contra $base: $erros erro(s), $avisos aviso(s)."
[ "$erros" -eq 0 ]
