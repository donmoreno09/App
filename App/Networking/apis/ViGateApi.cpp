#include "ViGateApi.h"

#include <QUrlQuery>

#include "NetworkingLogger.h"
#include "connections/ApiEndpoints.h"

namespace {
Logger& _logger()
{
    static Logger logger = NetworkingLogger::get().child({
        {"service", "VI-GATE-API"}
    });
    return logger;
}
}

ViGateApi::ViGateApi(HttpClient* client, QObject* parent)
    : BaseApi(client, parent) {}

void ViGateApi::getActiveGates(std::function<void(const QJsonArray&)> successCb,
                               ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    _logger().info("GET active gates", {
        kv("url", ApiEndpoints::ViGateGetActiveGates())
    });

    client()->get(ApiEndpoints::ViGateGetActiveGates(), [
                                                            successCb = std::move(successCb),
                                                            errorCb   = std::move(errorCb)
    ](QRestReply& reply) mutable {
        expectArray(reply, errorCb, [&](const QJsonArray& arr) {
            if (successCb) successCb(arr);
        });
    });
}

void ViGateApi::getFilteredData(int gateId,
                                const QDateTime& startDate,
                                const QDateTime& endDate,
                                bool pedestrian,
                                bool vehicle,
                                int pageNumber,
                                int pageSize,
                                const QString& sortBy,
                                bool sortDescending,
                                std::function<void(const QJsonObject&)> successCb,
                                ErrorCb errorCb)
{
    if (!ensureClient(errorCb)) return;

    QUrlQuery q;
    q.addQueryItem("GateId",      QString::number(gateId));
    q.addQueryItem("StartDate",   startDate.toString(Qt::ISODate));
    q.addQueryItem("EndDate",     endDate.toString(Qt::ISODate));
    q.addQueryItem("Pedestrian",  pedestrian ? "true" : "false");
    q.addQueryItem("Vehicle",     vehicle    ? "true" : "false");
    q.addQueryItem("PageNumber",  QString::number(pageNumber));
    q.addQueryItem("PageSize",    QString::number(pageSize));
    if (!sortBy.isEmpty()) {
        q.addQueryItem("SortBy",          sortBy);
        q.addQueryItem("SortDescending",  sortDescending ? "true" : "false");
    }

    const QString url = ApiEndpoints::ViGateGetFilteredData() + "?" + q.toString();

    _logger().info("GET filtered data", {
        kv("url", url)
    });

    client()->get(url, [
                           successCb = std::move(successCb),
                           errorCb   = std::move(errorCb)
    ](QRestReply& reply) mutable {
        expectObject(reply, errorCb, [&](const QJsonObject& obj) {
            if (successCb) successCb(obj);
        });
    });
}
