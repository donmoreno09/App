#ifndef ALERTZONEMODEL_H
#define ALERTZONEMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QHash>
#include <QPointer>
#include <QPointF>
#include <QQmlEngine>
#include <entities/AlertZone.h>
#include <QtPositioning/QGeoCoordinate>
#include "Networking/HttpClient.h"
#include "Networking/apis/AlertZoneApi.h"
#include "ModelHelper.h"

class AlertZoneModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Not intended for instantiation. Use it as a singleton.")
    QML_SINGLETON

    Q_PROPERTY(bool loading READ loading WRITE setLoading NOTIFY loadingChanged FINAL)

public:
    explicit AlertZoneModel(QObject *parent = nullptr);

    enum Roles {
        IdRole = Qt::UserRole + 1,
        LabelRole,

        // Geometry
        ShapeTypeIdRole,
        SurfaceRole,
        HeightRole,
        CoordinateRole,
        CoordinatesRole,
        TopLeftRole,
        BottomRightRole,
        RadiusARole,
        RadiusBRole,
        IsRectangleRole,

        NoteRole,
        SeverityRole,
        ActiveRole,
        LayersRole,
        ModelIndexRole,
    };

    Q_ENUM(Roles);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    QHash<int, QByteArray> roleNames() const override;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QVector<AlertZone>& alertZones();

    Q_INVOKABLE void setCoordinate(int row, int coordIndex, const QGeoCoordinate& coord);

    Q_INVOKABLE void append(const QVariantMap &data);

    Q_INVOKABLE void update(const QVariantMap &data);

    Q_INVOKABLE void remove(const QString &id);

    Q_INVOKABLE QQmlPropertyMap* getEditableAlertZone(int index);

    Q_INVOKABLE void discardChanges();

    Q_INVOKABLE void printData();

    void initialize(HttpClient* client);
    void fetch();
    void clear();

    bool loading() const;
    void setLoading(bool newLoading);

signals:
    void appended();
    void updated();
    void removed();
    void fetched(const QString &id);

    void loadingChanged();

private:
    bool m_loading = false;
    // TODO: Read the TODO in PoiModel.h regarding these unique ptrs
    std::unique_ptr<AlertZone> m_alertZoneSave = nullptr;
    std::unique_ptr<AlertZone> m_oldAlertZone = nullptr;
    HttpClient*    m_httpClient = nullptr;
    AlertZoneApi*  m_api        = nullptr;
    QVector<AlertZone> m_alertZones;
    QPointer<ModelHelper> m_helper;

    static QList<QPointF> parseCoordinatesVariant(const QVariant& v);
    static bool compareCoords(const QList<QPointF>& a, const QList<QPointF>& b);
    static bool isRectangle(const Geometry& geom);

    void buildAlertZoneSave(const QVariantMap &data);
};

#endif // ALERTZONEMODEL_H
