pragma ComponentBehavior: Bound
import QtQuick
import "." as Appearance
import ".." as Settings
import "../display" as Display
import "../.." as Shell

// Página Aparência (ficha 11): modal de 580×576. O desenho está em Body.qml; aqui só entram o estado
// real (tema, modo dos aplicativos, papel de parede, brilho e tela) e a navegação.
Settings.Modal {
  id: root
  title: "Appearance"
  bodyTop: 0
  contentHeight: body.contentHeight
  onBackRequested: Settings.State.back()
  Keys.onEscapePressed: Settings.State.back()

  Body {
    id: body
    selectedTheme: Shell.Theme.name
    wallpaperSummary: Appearance.State.wallpaperMode === "dynamic" ? "Dynamic" : "Custom"
    appsDark: Appearance.State.appsScheme === "dark"
    appsAutomatic: Appearance.State.appsAutomatic
    brightnessAvailable: Appearance.State.brightnessAvailable
    brightness: Appearance.State.brightness
    brightnessExpanded: Appearance.State.expandedSection === "brightness"
    displaySummary: Display.State.summary
    // Um erro de ação (tema, papel de parede, brilho arrastado) vale mais que o aviso permanente;
    // sem ele, a linha de brilho desligada ganha o motivo no mesmo texto de erro.
    error: Appearance.State.error !== "" ? Appearance.State.error
        : Appearance.State.brightnessAvailable ? "" : Appearance.State.brightnessError
    onThemeSelected: key => Appearance.State.selectTheme(key)
    onWallpaperRequested: Settings.State.openPage("wallpaper")
    onAppsDarkToggled: dark => Appearance.State.setAppsDark(dark)
    onAppsAutomaticToggled: automatic => Appearance.State.setAppsAutomatic(automatic)
    onBrightnessToggled: Appearance.State.toggleSection("brightness")
    onBrightnessMoved: value => Appearance.State.setBrightness(value)
    onBrightnessDragStarted: Appearance.State.draggingBrightness = true
    onBrightnessDragFinished: {
      Appearance.State.draggingBrightness = false;
      Appearance.State.flushBrightness();
    }
  }
}
