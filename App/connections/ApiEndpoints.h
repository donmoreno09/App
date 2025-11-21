#ifndef APIENDPOINTS_H
#define APIENDPOINTS_H

#include <QString>

namespace ApiEndpoints {
    extern QString BaseUrl;

    QString BaseUrlPoi();
    QString GetAllPoiSByLayerId();
    QString GetCategories();
    QString GetHealthStatuses();
    QString GetOperationalStates();
    QString GetTypes();

    QString BaseUrlShapes();

    QString BaseTrackSenderUrl();
    QString TrackSenderStart(const QString& topic);
    QString TrackSenderStop(const QString& topic);
    QString TrackHistorySenderStart(const QString& topic,
                                    const QString &track_iridess_uid);
    QString TrackHistorySenderStop(const QString& topic,
                                   const QString &track_iridess_uid);
}

#endif // APIENDPOINTS_H
