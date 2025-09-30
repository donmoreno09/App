
#ifndef APP_FEATURES_MAP_EXPORT_H
#define APP_FEATURES_MAP_EXPORT_H

#ifdef APP_FEATURES_MAP_STATIC_DEFINE
#  define APP_FEATURES_MAP_EXPORT
#  define APP_FEATURES_MAP_NO_EXPORT
#else
#  ifndef APP_FEATURES_MAP_EXPORT
#    ifdef app_features_map_EXPORTS
        /* We are building this library */
#      define APP_FEATURES_MAP_EXPORT __declspec(dllexport)
#    else
        /* We are using this library */
#      define APP_FEATURES_MAP_EXPORT __declspec(dllimport)
#    endif
#  endif

#  ifndef APP_FEATURES_MAP_NO_EXPORT
#    define APP_FEATURES_MAP_NO_EXPORT 
#  endif
#endif

#ifndef APP_FEATURES_MAP_DEPRECATED
#  define APP_FEATURES_MAP_DEPRECATED __declspec(deprecated)
#endif

#ifndef APP_FEATURES_MAP_DEPRECATED_EXPORT
#  define APP_FEATURES_MAP_DEPRECATED_EXPORT APP_FEATURES_MAP_EXPORT APP_FEATURES_MAP_DEPRECATED
#endif

#ifndef APP_FEATURES_MAP_DEPRECATED_NO_EXPORT
#  define APP_FEATURES_MAP_DEPRECATED_NO_EXPORT APP_FEATURES_MAP_NO_EXPORT APP_FEATURES_MAP_DEPRECATED
#endif

/* NOLINTNEXTLINE(readability-avoid-unconditional-preprocessor-if) */
#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef APP_FEATURES_MAP_NO_DEPRECATED
#    define APP_FEATURES_MAP_NO_DEPRECATED
#  endif
#endif

#endif /* APP_FEATURES_MAP_EXPORT_H */
