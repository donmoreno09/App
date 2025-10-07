#include "poioptionscontroller.h"
#include "../connections/httpclient.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonValue>
#include <QVariantList>

#include "../connections/apiendpoints.h"


PoiOptionsController::PoiOptionsController(QObject* parent)
    : QObject(parent)
{}

void PoiOptionsController::fetchAll() {
    fetch(ApiEndpoints::GetCategories, [=](QVariantList list) {
        m_categories = list;
        emit categoriesChanged();
    });
    fetch(ApiEndpoints::GetHealthStatuses, [=](QVariantList list) {
        m_healthStatuses = list;
        emit healthStatusesChanged();
    });
    fetch(ApiEndpoints::GetOperationalStates, [=](QVariantList list) {
        m_operationalStates = list;
        emit operationalStatesChanged();
    });
    fetch(ApiEndpoints::GetTypes, [=](QVariantList list) {
        m_types = list;
        emit typesChanged();
    });
}

void PoiOptionsController::fetch(const QString& endpoint, std::function<void(QList<QVariant>)> callback)
{
    QUrl url(endpoint);
    m_httpClient.get(url, [callback](QByteArray data){
        QList<QVariant> list;
        QJsonDocument doc = QJsonDocument::fromJson(data);
        if(doc.isArray()){
            for(const auto& val : doc.array()){
                list.append(val.toVariant());
            }
        }
        callback(list);
    });
}

QVariantList PoiOptionsController::categories() const { return m_categories; }
QVariantList PoiOptionsController::healthStatuses() const { return m_healthStatuses; }
QVariantList PoiOptionsController::operationalStates() const { return m_operationalStates; }
QVariantList PoiOptionsController::types() const { return m_types; }
