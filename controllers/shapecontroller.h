#ifndef SHAPECONTROLLER_H
#define SHAPECONTROLLER_H

#include <QObject>
#include <QVariantMap>
#include "../persistence/shapepersistencemanager.h"

class ShapeController : public QObject
{
    Q_OBJECT
public:
    explicit ShapeController(QObject *parent = nullptr);

    Q_INVOKABLE void saveShapeFromQml(const QVariantMap &data);
    Q_INVOKABLE void updateShapeFromQml(const QVariantMap &data);
    Q_INVOKABLE void deleteShapeFromQml(const QString &id);

signals:
    void shapeSavedSuccessfully(const QString &objectId);
    void shapeSaveFailed();

    void shapeUpdatedSuccessfully();
    void shapeUpdateFailed();

    void shapeDeletedSuccessfully();
    void shapeDeleteFailedNotFound();
    void shapeDeleteFailed();

private:
    ShapePersistenceManager m_persistenceManager;
};

#endif // SHAPECONTROLLER_H
