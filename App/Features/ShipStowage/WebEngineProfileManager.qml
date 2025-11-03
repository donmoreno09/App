pragma Singleton
import QtQuick 6.8
import QtWebEngine 1.10

QtObject {
    readonly property WebEngineProfile sharedProfile: WebEngineProfile {
        storageName: "ShipStowageProfile"
        offTheRecord: false
        httpCacheType: WebEngineProfile.DiskHttpCache
        httpCacheMaximumSize: 100 * 1024 * 1024     // Increased to 100MB
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies

        // Better user agent
        httpUserAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }
}
