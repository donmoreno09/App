#include "PoiOptions.h"
#include <connections/httpclient.h>
#include <connections/apiendpoints.h>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QVariantMap>

PoiOptions::PoiOptions(QObject* parent)
    : QObject(parent)
{}

void PoiOptions::fetchAll() {
    // Parse categories + build typesByCategory from the same payload
    m_httpClient.get(QUrl(ApiEndpoints::GetTypes), [this](QByteArray data){
        QVariantList categories;                // [{ key, name }]
        QHash<int, QVariantList> byCat;         // key -> [{ key, value }]

        const QJsonDocument doc = QJsonDocument::fromJson(data);
        if (doc.isArray()) {
            const QJsonArray arr = doc.array();
            for (int i = 0; i < 2/*arr.size()*/; ++i) {
                const QJsonObject cat = arr.at(i).toObject();
                const int catKey = cat.value("key").toInt();
                const QString catName = cat.value("name").toString();

                QVariantMap catItem;
                catItem.insert("key", catKey);
                catItem.insert("name", catName);
                categories.append(catItem);

                QVariantList typesForCat;
                const QJsonArray values = cat.value("values").toArray();
                for (int j = 0; j < values.size(); ++j) {
                    const QJsonObject t = values.at(j).toObject();
                    QVariantMap typeItem;
                    typeItem.insert("key", t.value("key").toInt());
                    typeItem.insert("value", t.value("value").toString());
                    typesForCat.append(typeItem);
                }
                byCat.insert(catKey, typesForCat);
            }
        }

        m_categories = categories;
        m_typesByCategory = byCat;

        emit categoriesChanged();
    });

    fetch(ApiEndpoints::GetHealthStatuses, [this](QVariantList list) {
        m_healthStatuses = list;
        emit healthStatusesChanged();
    });

    fetch(ApiEndpoints::GetOperationalStates, [this](QVariantList list) {
        m_operationalStates = list;
        emit operationalStatesChanged();
    });
}

void PoiOptions::fetch(const QString& endpoint, std::function<void(QVariantList)> callback)
{
    QUrl url(endpoint);
    m_httpClient.get(url, [callback](QByteArray data){
        QList<QVariant> list;
        const QJsonDocument doc = QJsonDocument::fromJson(data);
        if (doc.isArray()) {
            const QJsonArray arr = doc.array();
            for (int i = 0, n = arr.size(); i < n; ++i) {
                list.append(arr.at(i).toVariant());
            }
        }
        callback(list);
    });
}

QVariantList PoiOptions::typesForCategory(int categoryKey) const {
    return m_typesByCategory.value(categoryKey);
}

QVariantList PoiOptions::categories() const { return m_categories; }
QVariantList PoiOptions::healthStatuses() const { return m_healthStatuses; }
QVariantList PoiOptions::operationalStates() const { return m_operationalStates; }
