#ifndef POIMODEL_H
#define POIMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QHash>
#include <QPointer>
#include <QQmlEngine>
#include <entities/Poi.h>
#include <persistence/poipersistencemanager.h>
#include "ModelHelper.h"
#include "CoordinatesModel.h"

class PoiModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Not intended for instantiation. Use it as a singleton.")
    QML_SINGLETON

    Q_PROPERTY(bool loading READ loading WRITE setLoading NOTIFY loadingChanged FINAL)

public:
    explicit PoiModel(QObject *parent = nullptr);

    enum Roles {
        // Poi
        IdRole = Qt::UserRole + 1,
        LabelRole,
        LayerIdRole,
        LayerNameRole,
        TypeIdRole,
        TypeNameRole,
        CategoryIdRole,
        CategoryNameRole,
        HealthStatusIdRole,
        HealthStatusNameRole,
        OperationalStateIdRole,
        OperationalStateNameRole,

        // Geometry
        ShapeTypeIdRole,
        SurfaceRole,
        HeightRole,
        LatitudeRole,   // coordinate.x
        LongitudeRole,  // coordinate.y
        CoordinatesRole,
        RadiusARole,
        RadiusBRole,

        // Details/Metadata
        NoteRole,
    };

    Q_ENUM(Roles);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    QHash<int, QByteArray> roleNames() const override;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    QVector<Poi>& pois();

    Q_INVOKABLE void append(const QVariantMap &data);

    Q_INVOKABLE void update(const QVariantMap &data);

    Q_INVOKABLE void remove(const QString &id);

    Q_INVOKABLE QQmlPropertyMap* getEditablePoi(int index);

    Q_INVOKABLE void discardChanges();

    Q_INVOKABLE void printData();

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
    // TODO: The PoiModel shouldn't really know about what poi is being saved,
    //       perhaps modify the httpclient class to give back the poi on response.
    std::unique_ptr<Poi> m_poiSave = nullptr;
    std::unique_ptr<Poi> m_oldPoi = nullptr;
    QPointer<PoiPersistenceManager> m_persistenceManager;
    QVector<Poi> m_pois;
    QPointer<ModelHelper> m_helper;
    QHash<QString, CoordinatesModel*> m_coordsModels;

    static QList<QVector2D> parseCoordinatesVariant(const QVariant& v);

    static bool compareCoords(const QList<QVector2D>& a, const QList<QVector2D>& b);

    CoordinatesModel* getCoordsModel(const QString& id, const QList<QVector2D>& pts);

    void removeCoordsModel(const QString& id);

    void buildPoiSave(const QVariantMap &data);

private slots:
    void handleObjectsLoaded(const QList<IPersistable*> &objects);
    void handlePoiSaved(bool success, const QString &uuid);
    void handlePoiUpdated(bool success);
    void handlePoiGot(const IPersistable *object);
    void handlePoiRemoved(bool success);
};

#endif // POIMODEL_H
