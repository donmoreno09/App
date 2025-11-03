pragma Singleton
import QtQuick 6.8
import QtWebEngine 1.10

QtObject {
    readonly property WebEngineProfile sharedProfile: WebEngineProfile {
        storageName: "ShipStowageProfile"
        offTheRecord: false                         // Salva cache su disco
        httpCacheType: WebEngineProfile.DiskHttpCache
        httpCacheMaximumSize: 50 * 1024 * 1024     // 50MB cache
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
    }
}
