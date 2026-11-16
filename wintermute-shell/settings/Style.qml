pragma Singleton
import QtQuick
import ".." as Shell

// O que as páginas dos Ajustes que ainda não redesenhei leem do estilo antigo.
// A tela inicial (F4-T01) já lê o tema direto; cada página sai daqui quando for
// refeita, e o arquivo some na F4-T08.
QtObject {
  readonly property color card: Shell.Theme.colors.card
  readonly property int closeDuration: Shell.Theme.settingsCloseDuration
  readonly property int hoverDuration: Shell.Theme.settingsHoverDuration
}
