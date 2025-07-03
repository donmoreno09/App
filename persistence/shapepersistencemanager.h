#ifndef SHAPEPERSISTENCEMANAGER_H
#define SHAPEPERSISTENCEMANAGER_H

#include "persistencemanagerbase.h"

class ShapePersistenceManager : public PersistenceManagerBase
{
    Q_OBJECT
public:
    explicit ShapePersistenceManager(QObject *parent = nullptr);

protected:
    QString getApiEndpoint() const override;
    IPersistable* createPersistable() const override;
};

#endif // SHAPEPERSISTENCEMANAGER_H
