set(qml_files
    TitleBar.qml
)

set(cpp_singletons
    WindowsNcController.h
    WindowsNcController.cpp
)

qt_add_qml_module(app_features_titlebar
    URI App.Features.TitleBar
    VERSION 1.0
    QML_FILES ${qml_files}
    SOURCES ${cpp_singletons}
)

target_link_libraries(app_features_titlebar
    PRIVATE
        Qt6::Quick
)
