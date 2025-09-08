add_library(app_logging STATIC
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

target_include_directories(app_logging
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(app_logging
    PUBLIC
        Qt6::Core
        Qt6::Sql
)
