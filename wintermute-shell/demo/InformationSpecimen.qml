import QtQuick
import "../settings/information" as Information

// A página Informações (settings/information/Panel.qml) de verdade, com o serviço fictício de
// demo/InformationService.qml, no quadro do board 13:16083 (modal de 580×620; o botão de fechar pendura
// 13 acima, então o quadro tem 600×633, como na vitrine).
// `manualHovered`: fixa o hover no botão Manual.
Item {
  id: root
  property bool manualHovered: false

  implicitWidth: 600
  implicitHeight: 633

  InformationService { id: demoService }

  Information.Panel {
    y: 13
    service: demoService
    manualHovered: root.manualHovered
  }
}
