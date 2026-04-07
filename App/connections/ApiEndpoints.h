#ifndef APIENDPOINTS_H
#define APIENDPOINTS_H

#include <QString>

// TODO: Move ApiEndpoints.{h,cpp} to Networking module
namespace ApiEndpoints {
    extern QString BaseUrl;

    // Auth
    QString AuthLogin();
    QString AuthRefresh();
    QString AuthLogout();

    QString BaseUrlAlertZone();
    QString GetAllAlertZone();

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
    QString TrackSenderStopAll();

    extern QString BaseClustersUrl;
    QString ClustersStart();
    QString ClustersStop();

    QString TrackHistorySenderStart(const QString& topic,
                                    const QString &track_iridess_uid);
    QString TrackHistorySenderStop(const QString& topic,
                                   const QString &track_iridess_uid);

    QString ViGateGetActiveGates();
    QString ViGateGetFilteredData();
}

#endif // APIENDPOINTS_H
