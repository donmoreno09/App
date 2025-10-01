#include "TrackMapLayer.h"
#include "../core/geoselectionutils.h"
#include <QDebug>

TrackMapLayer::TrackMapLayer(QObject* parent)
    : BaseMapLayer(parent)
{
    setObjectName("TrackMapLayer");

    m_clearTracksTimer = new QTimer(this);
    m_clearTracksTimer->setSingleShot(true);
    m_clearTracksTimer->setInterval(60 * 1000); // 60 seconds

    connect(m_clearTracksTimer, &QTimer::timeout, this, [this]() {
        if (!m_tracks.isEmpty()) {
            qDebug() << "[TrackMapLayer] Timeout: clearing tracks due to inactivity";
            m_tracks.clear();
            emit tracksChanged();
        }
    });
}

QVariantList TrackMapLayer::tracks() const {
    return m_tracks;
}

void TrackMapLayer::setTracks(const QVariantList& tracks) {
    if (m_tracks != tracks) {
        m_tracks = tracks;
        emit tracksChanged();
        qDebug() << "[TrackMapLayer] setting:" << tracks.size() << " tracks";
        // Reset timer everytime tracks has been updated
        m_clearTracksTimer->start();
    }
}

void TrackMapLayer::initialize() {
    qDebug() << "[TrackMapLayer:initialize] polling ...";
    BaseMapLayer::initialize();
}

void TrackMapLayer::selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight)
{
    // In order for selection to work, I'll mutate the tracks
    // for now to include geometry with the coordinate property so
    // that it'll conform to GeoSelection::selectInRect()'s selection logic.
    QVariantList geoTracks;
    for (const auto& track : std::as_const(m_tracks)) {
        QVariantMap editableTrack = track.toMap();

        QVariantMap coordinate;
        coordinate["x"] = editableTrack["longitude"];
        coordinate["y"] = editableTrack["latitude"];

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

void TrackMapLayer::loadData() {
}

void TrackMapLayer::handleLoadedObjects(const QList<IPersistable*>& objects) {
    for (auto obj : objects) {
        qDebug() << "[TrackMapLayer] Loaded object:" << obj;
    }
}

bool TrackMapLayer::active() const
{
    return m_active;
}

void TrackMapLayer::setActive(bool newActive)
{
    if (m_active == newActive)
        return;
    m_active = newActive;
    emit activeChanged();
}
