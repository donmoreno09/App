#ifndef TRACKMAPLAYER_H
#define TRACKMAPLAYER_H

#include "./BaseMapLayer.h"
#include <QGeoCoordinate>
#include <QVariantList>
#include <QTimer>
#include <QQmlEngine>

class TrackMapLayer : public BaseMapLayer
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active NOTIFY activeChanged FINAL)
    Q_PROPERTY(QVariantList tracks READ tracks WRITE setTracks NOTIFY tracksChanged)
    QML_ELEMENT

public:
    explicit TrackMapLayer(QObject* parent = nullptr);

    QVariantList tracks() const;
    void setTracks(const QVariantList& tracks);
    QVariantList selectedObjects() const override { return m_selectedTracks; }

    Q_INVOKABLE void initialize() override;

    Q_INVOKABLE void selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight) override;
    Q_INVOKABLE void clearSelection() override;

    void loadData() override;
    void handleLoadedObjects(const QList<IPersistable*>& objects) override;

    bool active() const;
    void setActive(bool newActive);

signals:
    void activeChanged();

    void tracksChanged();

private:
    QVariantList m_tracks;
    QVariantList m_selectedTracks;
    QTimer* m_clearTracksTimer = nullptr;
    bool m_active = false;
};

#endif // TRACKMAPLAYER_H
