#pragma once

#include <functional>
#include <QDateTime>
#include <QJsonArray>
#include <QJsonObject>
#include "BaseApi.h"

class ViGateApi : public BaseApi
{
    Q_OBJECT

public:
    explicit ViGateApi(HttpClient* client, QObject* parent = nullptr);

    void getActiveGates(std::function<void(const QJsonArray&)> successCb,
                        ErrorCb errorCb);

    void getFilteredData(int gateId,
                         const QDateTime& startDate,
                         const QDateTime& endDate,
                         bool pedestrian,
                         bool vehicle,
                         int pageNumber,
                         int pageSize,
                         const QString& sortBy,
                         bool sortDescending,
                         std::function<void(const QJsonObject&)> successCb,
                         ErrorCb errorCb);
};
