#ifndef ALERTZONEMODEL_H
#define ALERTZONEMODEL_H

#include <QAbstractListModel>
#include <QVector>
#include <QHash>
#include <QPointer>
#include <QQmlEngine>
#include <entities/AlertZone.h>
#include <persistence/alertzonepersistencemanager.h>
#include <QtPositioning/QGeoCoordinate>
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
        LayerIdRole,
        LayerNameRole,
        ShapeTypeIdRole,
        CoordinatesRole,
        NoteRole,
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
    std::unique_ptr<AlertZone> m_alertZoneSave = nullptr;
    std::unique_ptr<AlertZone> m_oldAlertZone = nullptr;
    QPointer<AlertZonePersistenceManager> m_persistenceManager;
    QVector<AlertZone> m_alertZones;
    QPointer<ModelHelper> m_helper;

    static QList<QVector2D> parseCoordinatesVariant(const QVariant& v);
    static bool compareCoords(const QList<QVector2D>& a, const QList<QVector2D>& b);

    void buildAlertZoneSave(const QVariantMap &data);

private slots:
    void handleObjectsLoaded(const QList<IPersistable*> &objects);
    void handleAlertZoneSaved(bool success, const QString &uuid);
    void handleAlertZoneUpdated(bool success);
    void handleAlertZoneGot(const IPersistable *object);
    void handleAlertZoneRemoved(bool success);
};

#endif // ALERTZONEMODEL_H
