#include "TrackMapLayer.h"
#include <QDebug>
#include <core/GeoSelectionUtils.h>
#include <core/TrackManager.h>


TrackMapLayer::TrackMapLayer(QObject* parent)
    : BaseTrackMapLayer(parent)
{
    setObjectName("TrackMapLayer");
    m_trackModel = new TrackModel(this);

    if (auto* tm = TrackManager::instance()) {
        QObject::connect(m_trackModel, &TrackModel::historyPayloadArrived,
                         tm, &TrackManager::onHistoryPayloadArrived);
    } else {
        qWarning() << "[TrackModel] TrackManager singleton not yet constructed.";
    }

    m_clearTracksTimer = new QTimer(this);
    m_clearTracksTimer->setSingleShot(true);
    m_clearTracksTimer->setInterval(60 * 1000); // 60 seconds

    connect(m_clearTracksTimer, &QTimer::timeout, this, [this]() {
        if (!m_trackModel->tracks().isEmpty()) {
            qDebug() << "[TrackMapLayer] Timeout: clearing tracks due to inactivity";
            m_trackModel->clear();
        }
    });
}

void TrackMapLayer::selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight)
{
    // In order for selection to work, I'll mutate the tracks
    // for now to include geometry with the coordinate property so
    // that it'll conform to GeoSelection::selectInRect()'s selection logic.
    QVariantList geoTracks;
    const auto& tracks = m_trackModel->tracks();
    for (auto it = tracks.cbegin(); it != tracks.cend(); it++) {
        QVariantMap editableTrack;

        QVariantMap coordinate;
        coordinate["x"] = it->pos.longitude();
        coordinate["y"] = it->pos.latitude();

        QVariantMap geometry;
        geometry["shapeTypeId"] = static_cast<int>(GeoSelection::ShapeType::Point);
        geometry["coordinate"] = coordinate;

        editableTrack["geometry"] = geometry;
        geoTracks.append(editableTrack);
    }

    QVariantList selectedTracks = GeoSelection::selectInRect(geoTracks, topLeft, bottomRight);
    qDebug() << "[TrackMapLayer] selectedTracks: " << selectedTracks;
    m_selectedTracks = selectedTracks;
    emit selectedInRect();
}

void TrackMapLayer::clearSelection()
{
    m_selectedTracks.clear();
    emit clearedSelection();
}

TrackModel *TrackMapLayer::trackModel() const
{
    return m_trackModel;
}
