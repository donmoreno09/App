#ifndef IPERSISTENCEMANAGER_H
#define IPERSISTENCEMANAGER_H

#include <QObject>
#include <QList>
#include "ipersistable.h"

class IPersistenceManager : public QObject
{
    Q_OBJECT
public:
    explicit IPersistenceManager(QObject *parent = nullptr) : QObject(parent) {}

    virtual void load() = 0;
    virtual void get(const QString &objectId) = 0;
    virtual void save(const IPersistable &object) = 0;
    virtual void update(const IPersistable &object) = 0;
    virtual void remove(const QString &objectId) = 0;

signals:
    void objectsLoaded(const QList<IPersistable *> &objects);
    void objectGot(const IPersistable *objects);
    void objectSaved(bool success, const QString &objectId);
    void objectUpdated(bool success);
    void objectRemoved(bool success);
};

#endif // IPERSISTENCEMANAGER_H
