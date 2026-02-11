#ifndef ALERTZONEAPI_H
#define ALERTZONEAPI_H

#include <QVariantList>
#include <QVariantMap>
#include <QVector>
#include <functional>
#include <QJsonArray>
#include "entities/AlertZone.h"

#include "BaseApi.h"

class AlertZoneApi : public BaseApi
{
    Q_OBJECT

public:
    explicit AlertZoneApi(HttpClient* client, QObject* parent = nullptr);

    void getMany(std::function<void(const QVector<AlertZone>&)> successCb, ErrorCb errorCb);
    void get(const QString& id, std::function<void(const AlertZone&)> successCb, ErrorCb errorCb);
    void post(const AlertZone& az, std::function<void(const QString&)> successCb, ErrorCb errorCb);
    void put(const AlertZone& az, std::function<void()> successCb, ErrorCb errorCb);
    void remove(const QString& id, std::function<void()> successCb, ErrorCb errorCb);
};

#endif // ALERTZONEAPI_H
