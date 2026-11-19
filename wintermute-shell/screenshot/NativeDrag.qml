import QtQuick
import Wintermute.Screenshot.Native

// O arraste da captura para outro aplicativo, feito pelo plugin em C++ de native/. Este arquivo existe só para o `import`
// acima ficar longe da Preview.qml: se o plugin não foi compilado ou o Qt não o acha, este arquivo não carrega, e a prévia
// segue com um substituto que recusa o arraste (o Loader da Preview.qml).
ScreenshotDrag {}
