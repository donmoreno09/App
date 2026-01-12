#ifndef ALERTZONEPERSISTENCEMANAGER_H
#define ALERTZONEPERSISTENCEMANAGER_H

#include "persistencemanagerbase.h"

class AlertZonePersistenceManager : public PersistenceManagerBase
{
    Q_OBJECT
public:
    explicit AlertZonePersistenceManager(QObject *parent = nullptr);

    virtual void load() override;

protected:
    QString getApiEndpoint() const override;
    IPersistable* createPersistable() const override;
};

#endif // ALERTZONEPERSISTENCEMANAGER_H
