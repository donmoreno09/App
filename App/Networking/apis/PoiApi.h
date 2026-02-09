#ifndef POIAPI_H
#define POIAPI_H

#include <QVariantList>
#include <QVariantMap>
#include <QVector>
#include <functional>
#include <QJsonArray>
#include "entities/Poi.h"

#include "BaseApi.h"

class PoiApi : public BaseApi
{
    Q_OBJECT

public:
    explicit PoiApi(HttpClient* client, QObject* parent = nullptr);

    void getMany(std::function<void(const QVector<Poi>&)> successCb, ErrorCb errorCb);
    void get(const QString& id, std::function<void(const Poi&)> successCb, ErrorCb errorCb);
    void post(const Poi& poi, std::function<void(const QString&)> successCb, ErrorCb errorCb);
    void put(const Poi& poi, std::function<void()> successCb, ErrorCb errorCb);
    void remove(const QString& id, std::function<void()> successCb, ErrorCb errorCb);

    // Options
    void getCategoriesTypes(std::function<void(const QJsonArray& arr)> successCb, ErrorCb errorCb);
    void getHealthStatuses(std::function<void(const QJsonArray& arr)> successCb, ErrorCb errorCb);
    void getOperationalStates(std::function<void(const QJsonArray& arr)> successCb, ErrorCb errorCb);
};

#endif // POIAPI_H
