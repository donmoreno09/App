#ifndef APIENDPOINTS_H
#define APIENDPOINTS_H

#include <QString>

namespace ApiEndpoints {
    //static const QString BaseUrl = "https://dear-ghost-free.ngrok-free.app";
    static const QString BaseUrl = "http://localhost:7000";

    static const QString BaseUrlPoi = BaseUrl + "/pointofinterest";

    static const QString GetAllPoiSByLayerId = BaseUrlPoi + "/layer";
    static const QString GetCategories = BaseUrlPoi + "/getCategories";
    static const QString GetHealthStatuses = BaseUrlPoi + "/getHealthStatuses";
    static const QString GetOperationalStates = BaseUrlPoi + "/getOperationalStates";
    static const QString GetTypes = BaseUrlPoi + "/getTypes";

    static const QString BaseUrlShapes = BaseUrl + "/shape";

    static const QString BaseUrlMenuManager = BaseUrl + "/menumanager";
    static const QString GetMenuManager = BaseUrlMenuManager + "/getMenu";

    static const QString BaseTrackSenderUrl = BaseUrl + "/tracksender";
    static const QString TrackSenderStart(const QString& topic) { return BaseTrackSenderUrl + "/" + topic + "/start"; }
    static const QString TrackSenderStop(const QString& topic) { return BaseTrackSenderUrl + "/" + topic + "/stop"; }
}

#endif // APIENDPOINTS_H
