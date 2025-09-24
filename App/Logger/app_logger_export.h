
#ifndef APP_LOGGER_EXPORT_H
#define APP_LOGGER_EXPORT_H

#ifdef APP_LOGGER_STATIC_DEFINE
#  define APP_LOGGER_EXPORT
#  define APP_LOGGER_NO_EXPORT
#else
#  ifndef APP_LOGGER_EXPORT
#    ifdef app_logger_EXPORTS
        /* We are building this library */
#      define APP_LOGGER_EXPORT __declspec(dllexport)
#    else
        /* We are using this library */
#      define APP_LOGGER_EXPORT __declspec(dllimport)
#    endif
#  endif

#  ifndef APP_LOGGER_NO_EXPORT
#    define APP_LOGGER_NO_EXPORT 
#  endif
#endif

#ifndef APP_LOGGER_DEPRECATED
#  define APP_LOGGER_DEPRECATED __declspec(deprecated)
#endif

#ifndef APP_LOGGER_DEPRECATED_EXPORT
#  define APP_LOGGER_DEPRECATED_EXPORT APP_LOGGER_EXPORT APP_LOGGER_DEPRECATED
#endif

#ifndef APP_LOGGER_DEPRECATED_NO_EXPORT
#  define APP_LOGGER_DEPRECATED_NO_EXPORT APP_LOGGER_NO_EXPORT APP_LOGGER_DEPRECATED
#endif

/* NOLINTNEXTLINE(readability-avoid-unconditional-preprocessor-if) */
#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef APP_LOGGER_NO_DEPRECATED
#    define APP_LOGGER_NO_DEPRECATED
#  endif
#endif

#endif /* APP_LOGGER_EXPORT_H */
