cmake_minimum_required(VERSION 3.21)
project(wintermute_screenshot_drag LANGUAGES CXX)
find_package(Qt6 6.11 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.7)
qt_add_qml_module(wintermute_screenshot_drag
    URI Wintermute.Screenshot.Native
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/Wintermute/Screenshot/Native"
    SOURCES ScreenshotDrag.h
)
target_link_libraries(wintermute_screenshot_drag PRIVATE Qt6::Quick)
set_target_properties(wintermute_screenshot_dragplugin PROPERTIES INSTALL_RPATH "$ORIGIN")
install(TARGETS wintermute_screenshot_drag wintermute_screenshot_dragplugin
    LIBRARY DESTINATION lib/qt6/qml/Wintermute/Screenshot/Native)
# O qmldir e o qmltypes são gerados dentro da pasta do módulo. Instalo pela pasta, filtrando os dois, porque instalar
# um arquivo gerado por nome faz o CMake avisar que ele não é a saída única de um alvo.
install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/Wintermute/Screenshot/Native/"
    DESTINATION lib/qt6/qml/Wintermute/Screenshot/Native
    FILES_MATCHING PATTERN "qmldir" PATTERN "*.qmltypes")
