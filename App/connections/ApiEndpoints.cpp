#include "ApiEndpoints.h"

namespace ApiEndpoints {
    QString BaseUrl = "http://localhost:7000";

    QString BaseUrlPoi() { return BaseUrl + "/pointofinterest"; }
    QString GetAllPoiSByLayerId() { return BaseUrlPoi() + "/layer"; }
    QString GetCategories() { return BaseUrlPoi() + "/getCategories"; }
    QString GetHealthStatuses() { return BaseUrlPoi() + "/getHealthStatuses"; }
    QString GetOperationalStates() { return BaseUrlPoi() + "/getOperationalStates"; }
    QString GetTypes() { return BaseUrlPoi() + "/getTypes"; }

    QString BaseUrlShapes() { return BaseUrl + "/shape"; }

    QString BaseUrlMenuManager() { return BaseUrl + "/menumanager"; }
    QString GetMenuManager() { return BaseUrlMenuManager() + "/getMenu"; }

    QString BaseTrackSenderUrl() { return BaseUrl + "/tracksender"; }

    QString TrackSenderStart(const QString& topic) { return BaseTrackSenderUrl() + "/" + topic + "/start"; }
    QString TrackSenderStop(const QString& topic) { return BaseTrackSenderUrl() + "/" + topic + "/stop"; }

    QString TrackHistorySenderStart(const QString& topic,
                                    const QString &track_iridess_uid) {
        return BaseTrackSenderUrl() + "/" + topic + "/history/" + track_iridess_uid + "/start";
    }

    QString TrackHistorySenderStop(const QString& topic,
                                   const QString &track_iridess_uid) {
        return BaseTrackSenderUrl() + "/" + topic + "/history/" + track_iridess_uid + "/stop";
    }
}
