#ifndef POICONTROLLER_H
#define POICONTROLLER_H

#include <QObject>
#include <QVariantMap>
#include "../persistence/poipersistencemanager.h"

class PoiController : public QObject
{
    Q_OBJECT
public:
    explicit PoiController(QObject *parent = nullptr);

    Q_INVOKABLE void getPoi(const QString& id);
    Q_INVOKABLE void savePoiFromQml(const QVariantMap &data);
    Q_INVOKABLE void updatePoiFromQml(const QVariantMap &data);
    Q_INVOKABLE void deletePoiFromQml(const QString &id);


signals:
    void poiFetchedSuccessfully(const QVariant poi);
    void poiFetchFailed();

    void poiSavedSuccessfully(const QString &objectId);
    void poiSaveFailed();

    void poiUpdatedSuccessfully();
    void poiUpdateFailed();

    void poiDeletedSuccessfully();
    void poiDeleteFailedNotFound();
    void poiDeleteFailed();

private:
    PoiPersistenceManager m_persistenceManager;
};

#endif // POICONTROLLER_H
