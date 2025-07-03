#ifndef POIOPTIONSCONTROLLER_H
#define POIOPTIONSCONTROLLER_H

#include <QObject>
#include <QVariantList>
#include "../connections/httpclient.h"


class PoiOptionsController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList categories READ categories NOTIFY categoriesChanged)
    Q_PROPERTY(QVariantList healthStatuses READ healthStatuses NOTIFY healthStatusesChanged)
    Q_PROPERTY(QVariantList operationalStates READ operationalStates NOTIFY operationalStatesChanged)
    Q_PROPERTY(QVariantList types READ types NOTIFY typesChanged)

public:
    explicit PoiOptionsController(QObject* parent = nullptr);
    void fetch(const QString& endpoint, std::function<void(QVariantList)> callback);

    Q_INVOKABLE void fetchAll();

    QVariantList categories() const;
    QVariantList healthStatuses() const;
    QVariantList operationalStates() const;
    QVariantList types() const;

signals:
    void categoriesChanged();
    void healthStatusesChanged();
    void operationalStatesChanged();
    void typesChanged();

private:
    HttpClient m_httpClient;

    QVariantList m_categories;
    QVariantList m_healthStatuses;
    QVariantList m_operationalStates;
    QVariantList m_types;
};

#endif // POIOPTIONSCONTROLLER_H
