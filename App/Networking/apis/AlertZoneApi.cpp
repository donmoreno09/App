#include "AlertZoneApi.h"
#include <QJsonDocument>
#include <QJsonObject>
#include "connections/ApiEndpoints.h"

AlertZoneApi::AlertZoneApi(HttpClient *client, QObject *parent)
    : BaseApi(client, parent) {}

void AlertZoneApi::getMany(std::function<void(const QVector<AlertZone>&)> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    client()->get(ApiEndpoints::GetAllAlertZone(), [ // TODO
        successCb = std::move(successCb),
        errorCb = std::move(errorCb)
    ](QRestReply& reply) mutable {
        expectArray(reply, errorCb, [&](const QJsonArray& arr) {
            if (!successCb) return;

            QVector<AlertZone> zones;
            for (const QJsonValue &val : arr) {
                if (!val.isObject()) continue;
                AlertZone az;
                az.fromJson(val.toObject());
                zones.append(az);
            }
            successCb(zones);
        });
    });
}

void AlertZoneApi::get(const QString& id, std::function<void(const AlertZone&)> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    client()->get(ApiEndpoints::BaseUrlAlertZone() + "/" + id, [ // TODO
        successCb = std::move(successCb),
        errorCb = std::move(errorCb)
    ](QRestReply& reply) mutable {
        expectObject(reply, errorCb, [&](const QJsonObject& obj) {
            if (!successCb) return;

            AlertZone az;
            az.fromJson(obj);
            successCb(az);
        });
    });
}

void AlertZoneApi::post(const AlertZone& az, std::function<void(const QString&)> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    const QJsonDocument body(az.toJson());

    client()->post(ApiEndpoints::BaseUrlAlertZone(), body.toJson(), [
        successCb = std::move(successCb),
        errorCb = std::move(errorCb)
    ](QRestReply& reply) mutable {
        expectString(reply, errorCb, [&](const QString& uuid) {
            if (!successCb) return;

            successCb(uuid);
        });
    });
}

void AlertZoneApi::put(const AlertZone& az, std::function<void()> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    const QJsonDocument body(az.toJson());

    client()->put(ApiEndpoints::BaseUrlAlertZone() + "/" + az.id, body.toJson(), [
        successCb = std::move(successCb),
        errorCb = std::move(errorCb)
    ](QRestReply& reply) mutable {
        if (!reply.isSuccess()) {
            emitError(errorCb, fromReply(reply));
            return;
        }

        if (successCb) successCb();
    });
}

void AlertZoneApi::remove(const QString& id, std::function<void()> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    client()->remove(ApiEndpoints::BaseUrlAlertZone() + "/" + id, [
        successCb = std::move(successCb),
        errorCb = std::move(errorCb)
    ](QRestReply& reply) mutable {
        if (!reply.isSuccess()) {
            emitError(errorCb, fromReply(reply));
            return;
        }

        if (successCb) successCb();
    });
}
