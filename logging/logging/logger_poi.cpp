#include "app_logger.h"

static Logger& poisLog() {
    static Logger L = AppLogger::get().child({
        kv("service", "PoIs")
    });
    return L;
}
