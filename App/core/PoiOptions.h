#ifndef POIOPTIONS_H
#define POIOPTIONS_H

#include <QObject>
#include <QVariantList>
#include <QQmlEngine>
#include <QJsonArray>
#include <connections/httpclient.h>

class PoiOptions : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    QML_UNCREATABLE("PoiOptions is not intended to be instantiated. Use it as a singleton.")

    Q_PROPERTY(QVariantList categories READ categories NOTIFY categoriesChanged)
    Q_PROPERTY(QVariantList healthStatuses READ healthStatuses NOTIFY healthStatusesChanged)
    Q_PROPERTY(QVariantList operationalStates READ operationalStates NOTIFY operationalStatesChanged)

public:
    explicit PoiOptions(QObject* parent = nullptr);
    void fetch(const QString& endpoint, std::function<void(QVariantList)> callback);

    Q_INVOKABLE void fetchAll();
    Q_INVOKABLE void updateTranslations(); // Check Main.qml; on language changed, it calls this method from there.
    Q_INVOKABLE QVariantList typesForCategory(int categoryKey) const;

    QVariantList categories() const;
    QVariantList healthStatuses() const;
    QVariantList operationalStates() const;

signals:
    void categoriesChanged();
    void healthStatusesChanged();
    void operationalStatesChanged();

private:
    HttpClient m_httpClient;
    QVariantList m_categories;
    QVariantList m_healthStatuses;
    QVariantList m_operationalStates;
    QHash<int, QVariantList> m_typesByCategory;

    QJsonArray rawCategoriesTypes;
    QJsonArray rawHealthStatuses;
    QJsonArray rawOperationalStates;

    QHash<QString, QString> trCategoryMap;
    QHash<QString, QString> trTypeMap;
    QHash<int, QString> trHealthStatusesMap;
    QHash<int, QString> trOperationalStatesMap;

    void buildTranslationMaps();
    void buildCategoriesTypes();
    void buildHealthStatuses();
    void buildOperationalStates();
};

#endif // POIOPTIONS_H
