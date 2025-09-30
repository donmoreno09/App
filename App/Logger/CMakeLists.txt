set(cpp_sources
    app_logger.h
    console_sink.h
    ilogsink.h
    log_record.h
    log_types.h
    logger.h
    logger_poi.cpp
    sink_registry.h
    sqlite_sink.h
)

qt_add_qml_module(app_logger
    URI App.Logger
    VERSION 1.0
    SOURCES ${cpp_sources}
)

include(GenerateExportHeader)
generate_export_header(app_logger
  EXPORT_FILE_NAME ${CMAKE_CURRENT_SOURCE_DIR}/app_logger_export.h)

target_link_libraries(app_logger
    PRIVATE
        Qt6::Core
        Qt6::Sql
)
