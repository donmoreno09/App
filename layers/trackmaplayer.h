#ifndef TRACKMAPLAYER_H
#define TRACKMAPLAYER_H

#include "./basemaplayer.h"
#include <QGeoCoordinate>
#include <QVariantList>
#include <QTimer>

class TrackMapLayer : public BaseMapLayer
{
    Q_OBJECT
    Q_PROPERTY(QVariantList tracks READ tracks WRITE setTracks NOTIFY tracksChanged)

public:
    explicit TrackMapLayer(QObject* parent = nullptr);

    QVariantList tracks() const;
    void setTracks(const QVariantList& tracks);
    QVariantList selectedObjects() const override { return m_selectedTracks; }

    Q_INVOKABLE void initialize() override;

    void loadData() override;
    void handleLoadedObjects(const QList<IPersistable*>& objects) override;

signals:
    void tracksChanged();
    void activated();
    void deactivated();

protected slots:
    void handleSelectionBoxSelected(const QString& target,
                                    const QGeoCoordinate& topLeft,
                                    const QGeoCoordinate& bottomRight,
                                    int mode) override;

    void handleSelectionBoxDeselected(const QString& target, int mode) override;

private:
    QVariantList m_tracks;
    QVariantList m_selectedTracks;
    QTimer* m_clearTracksTimer = nullptr;
};

#endif // TRACKMAPLAYER_H
