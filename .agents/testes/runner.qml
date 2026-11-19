import QtQuick
import Quickshell
import "apoio.js" as Apoio
import "caso.test.js" as Caso

// Runner dos testes das bibliotecas puras (F6-T18). É genérico: o `testar.sh` o copia como `shell.qml` para uma pasta temporária,
// junto com o arquivo de teste (copiado como `caso.test.js`), as bibliotecas que ele importa e o `apoio.js`. Importar o arquivo de
// teste já roda os casos; aqui só leio o resultado, escrevo no log numa forma que o script entende e saio.
//
// Não abre janela. Cada linha começa com "TESTE|" e o tipo: FALHA, SKIP e, por último, FIM (sem o FIM o script trata o runner como
// não terminado). Quebra de linha dentro da mensagem vira espaço, para a linha continuar uma linha só.
ShellRoot {
  function oneLine(text) {
    return String(text).replace(/\s*\n\s*/g, " ");
  }

  Component.onCompleted: {
    // `Caso` só aparece aqui para o import acontecer; os casos já rodaram quando o QML o carregou.
    const result = Apoio.result();
    result.failures.forEach(line => console.log("TESTE|FALHA|" + oneLine(line)));
    result.skipped.forEach(entry => console.log("TESTE|SKIP|" + oneLine(entry.name) + "|" + oneLine(entry.reason) + "|" + oneLine(entry.state)));
    console.log("TESTE|FIM|" + result.passed + "|" + result.failures.length + "|" + result.skipped.length);
    Qt.callLater(Qt.quit);
  }
}
