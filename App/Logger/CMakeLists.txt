qt_add_library(app_logger STATIC)

set(cpp_sources
    AppLogger.h
    PoiLogger.h

    core/BaseLogger.h
    core/Logger.h
    core/Logger.cpp
    core/LoggerQmlHandle.h
    core/LogRecord.h
    core/LogTypes.h
    core/SinkRegistry.h

    sinks/ConsoleSink.h
    sinks/ConsoleSink.cpp
    sinks/ILogSink.h
    sinks/SqliteSink.h
    sinks/SqliteSink.cpp
)

qt_add_qml_module(app_logger
    URI App.Logger
    VERSION 1.0
    SOURCES ${cpp_sources}
)

target_link_libraries(app_logger
    PUBLIC
        Qt6::Core
        Qt6::Sql
        Qt6::Qml
)

target_include_directories(app_logger PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
