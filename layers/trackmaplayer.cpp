#include "trackmaplayer.h"
#include "../events/selectionboxbus.h"
#include "../core/geoselectionutils.h"
#include <QDebug>

TrackMapLayer::TrackMapLayer(QObject* parent)
    : BaseMapLayer(parent)
{
    setObjectName("TrackMapLayer");

    connect(SelectionBoxBus::instance(), &SelectionBoxBus::selected, this, &TrackMapLayer::handleSelectionBoxSelected);
    connect(SelectionBoxBus::instance(), &SelectionBoxBus::deselected, this, &TrackMapLayer::handleSelectionBoxDeselected);
}

QVariantList TrackMapLayer::tracks() const {
    return m_tracks;
}

void TrackMapLayer::setTracks(const QVariantList& tracks) {
    if (m_tracks != tracks) {
        m_tracks = tracks;
        emit tracksChanged();
        qDebug() << "[TrackMapLayer] setTracks:" << tracks.size() << " elementi";
    }
}

void TrackMapLayer::initialize() {
    qDebug() << "[TrackMapLayer:initialize] polling ...";
    BaseMapLayer::initialize();
}

void TrackMapLayer::loadData() {
}

void TrackMapLayer::handleLoadedObjects(const QList<IPersistable*>& objects) {
    for (auto obj : objects) {
        qDebug() << "Loaded object:" << obj; // supponendo che IPersistable abbia toString()
    }
}

void TrackMapLayer::handleSelectionBoxSelected(const QString &target, const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight, int mode)
{
    if (target != layerName())
        return;

    // In order for selection to work, I'll mutate the tracks
    // for now to include geometry with the coordinate property so
    // that it'll conform to GeoSelection::selectInRect()'s selection logic.
    QVariantList geoTracks;
    for (const auto& track : m_tracks) {
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
    qDebug() << "elek: selectedTracks: " << selectedTracks;
    m_selectedTracks = selectedTracks;
    emit selectedObjectsChanged();
}

void TrackMapLayer::handleSelectionBoxDeselected(const QString &target, int mode)
{
    if (target != layerName())
        return;

    m_selectedTracks.clear();
    emit selectedObjectsChanged();
}
