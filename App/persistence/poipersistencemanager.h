#ifndef POIPERSISTENCEMANAGER_H
#define POIPERSISTENCEMANAGER_H

#include "persistencemanagerbase.h"

class PoiPersistenceManager : public PersistenceManagerBase
{
    Q_OBJECT
public:
    explicit PoiPersistenceManager(QObject *parent = nullptr);

    virtual void load() override;

protected:
    QString getApiEndpoint() const override;
    IPersistable* createPersistable() const override;
};

#endif // POIPERSISTENCEMANAGER_H
