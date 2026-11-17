import QtQuick
import Quickshell

// Bancada de prints. A bancada.sh copia a shell para fora do repositório e põe
// este arquivo no lugar do shell.qml da cópia. Em vez de abrir a barra e os
// pop-ups, que pedem o protocolo de camadas do Niri, ele abre uma janela comum
// com uma peça só, espera ela assentar, grava o print e sai.
//
// Tudo chega por variável de ambiente, definida pela bancada.sh:
//   BANCADA_ALVO    arquivo QML relativo à raiz da shell (ex.: demo/WifiSpecimen.qml)
//   BANCADA_PROPS   propriedades da peça em JSON (ex.: {"page": "join"})
//   BANCADA_SAIDA   caminho do PNG
//   BANCADA_ESPERA  milissegundos entre carregar e gravar
//   BANCADA_MARGEM  folga em volta da peça, em px
//   BANCADA_FUNDO   imagem opcional atrás da peça; sem ela o fundo fica transparente
ShellRoot {
  id: root

  readonly property string alvo: Quickshell.env("BANCADA_ALVO") || ""
  readonly property string saida: Quickshell.env("BANCADA_SAIDA") || ""
  readonly property int espera: Number(Quickshell.env("BANCADA_ESPERA") || 1200)
  readonly property int margem: Number(Quickshell.env("BANCADA_MARGEM") || 32)
  readonly property string fundo: Quickshell.env("BANCADA_FUNDO") || ""
  readonly property var props: {
    try {
      return JSON.parse(Quickshell.env("BANCADA_PROPS") || "{}");
    } catch (error) {
      console.error("BANCADA: BANCADA_PROPS não é um JSON válido:", error);
      return {};
    }
  }

  FloatingWindow {
    visible: true
    color: "transparent"
    title: "bancada"
    implicitWidth: Math.max(64, quadro.width)
    implicitHeight: Math.max(64, quadro.height)

    Item {
      id: quadro
      width: carga.width + 2 * root.margem
      height: carga.height + 2 * root.margem

      Image {
        anchors.fill: parent
        visible: root.fundo !== ""
        source: root.fundo !== "" ? "file://" + root.fundo : ""
        fillMode: Image.PreserveAspectCrop
      }

      Loader {
        id: carga
        x: root.margem
        y: root.margem
        Component.onCompleted: {
          if (root.alvo === "") {
            console.error("BANCADA: BANCADA_ALVO vazio.");
            Qt.quit();
            return;
          }
          setSource(Qt.resolvedUrl(root.alvo), root.props);
        }
        onStatusChanged: {
          if (status === Loader.Error) {
            console.error("BANCADA: não consegui carregar", root.alvo);
            Qt.quit();
          }
        }
        onLoaded: relogio.start()
      }
    }

    Timer {
      id: relogio
      interval: root.espera
      onTriggered: quadro.grabToImage(resultado => {
        const gravou = resultado.saveToFile(root.saida);
        if (gravou)
          console.log("BANCADA: gravei", root.saida);
        else
          console.error("BANCADA: não consegui gravar", root.saida);
        Qt.quit();
      })
    }
  }
}
