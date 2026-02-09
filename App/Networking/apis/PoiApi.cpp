#include "PoiApi.h"
#include <QJsonDocument>
#include <QJsonObject>
#include "connections/ApiEndpoints.h"

PoiApi::PoiApi(HttpClient *client, QObject *parent)
    : BaseApi(client, parent) {}

void PoiApi::getMany(std::function<void(const QVector<Poi>&)> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    client()->get(ApiEndpoints::GetAllPoiSByLayerId() + "/1", [
        successCb = std::move(successCb),
        errorCb = std::move(errorCb)
    ](QRestReply& reply) mutable {
        expectArray(reply, errorCb, [&](const QJsonArray& arr) {
            if (!successCb) return;

            QVector<Poi> pois;
            for (const QJsonValue &val : arr) {
                if (!val.isObject()) continue;
                Poi poi;
                poi.fromJson(val.toObject());
                pois.append(poi);
            }
            successCb(pois);
        });
    });
}

void PoiApi::get(const QString& id, std::function<void(const Poi&)> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    client()->get(ApiEndpoints::BaseUrlPoi() + "/" + id, [
        successCb = std::move(successCb),
        errorCb = std::move(errorCb)
    ](QRestReply& reply) mutable {
        expectObject(reply, errorCb, [&](const QJsonObject& obj) {
            if (!successCb) return;

            Poi poi;
            poi.fromJson(obj);
            successCb(poi);
        });
    });
}

void PoiApi::post(const Poi& poi, std::function<void(const QString&)> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    const QJsonDocument body(poi.toJson());

    client()->post(ApiEndpoints::BaseUrlPoi(), body.toJson(), [
        successCb = std::move(successCb),
        errorCb   = std::move(errorCb)
    ](QRestReply& reply) mutable {
        expectString(reply, errorCb, [&](const QString& uuid) {
            if (!successCb) return;

            successCb(uuid);
        });
    });
}

void PoiApi::put(const Poi& poi, std::function<void()> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    const QJsonDocument body(poi.toJson());

    client()->put(ApiEndpoints::BaseUrlPoi() + "/" + poi.id, body.toJson(), [
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

void PoiApi::remove(const QString& id, std::function<void()> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    client()->remove(ApiEndpoints::BaseUrlPoi() + "/" + id, [
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

void PoiApi::getCategoriesTypes(std::function<void (const QJsonArray &)> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    client()->get(ApiEndpoints::GetTypes(), [
        successCb = std::move(successCb),
        errorCb = std::move(errorCb)
    ](QRestReply& reply) mutable {
        expectArray(reply, errorCb, [&](const QJsonArray& arr) {
            if (!successCb) return;

            successCb(arr);
        });
    });
}

void PoiApi::getHealthStatuses(std::function<void (const QJsonArray &)> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    client()->get(ApiEndpoints::GetHealthStatuses(), [
        successCb = std::move(successCb),
        errorCb = std::move(errorCb)
    ](QRestReply& reply) mutable {
        expectArray(reply, errorCb, [&](const QJsonArray& arr) {
            if (!successCb) return;

            successCb(arr);
        });
    });
}

void PoiApi::getOperationalStates(std::function<void (const QJsonArray &)> successCb, ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    client()->get(ApiEndpoints::GetOperationalStates(), [
        successCb = std::move(successCb),
        errorCb = std::move(errorCb)
    ](QRestReply& reply) mutable {
        expectArray(reply, errorCb, [&](const QJsonArray& arr) {
            if (!successCb) return;

            successCb(arr);
        });
    });
}
