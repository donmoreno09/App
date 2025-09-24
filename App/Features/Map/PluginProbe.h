#pragma once

#include <QtLocation/QGeoServiceProvider>
#include <QtCore/QVariantMap>
#include <QtCore/QStringList>
#include <QtCore/QDebug>
#include "app_features_map_export.h"

struct APP_FEATURES_MAP_EXPORT PluginInfo {
    QString name;
    QGeoServiceProvider::Error error = QGeoServiceProvider::NoError;
    QString errorString;
    QGeoServiceProvider::MappingFeatures mapping = QGeoServiceProvider::NoMappingFeatures;
    QGeoServiceProvider::RoutingFeatures routing = QGeoServiceProvider::NoRoutingFeatures;
    QGeoServiceProvider::GeocodingFeatures geocoding = QGeoServiceProvider::NoGeocodingFeatures;
};

inline APP_FEATURES_MAP_EXPORT QList<PluginInfo> probeGeoPlugins(const QVariantMap& commonParams = {}) {
    QList<PluginInfo> out;
    const QStringList names = QGeoServiceProvider::availableServiceProviders(); // discover installed plugins
    for (const QString& n : names) {
        QGeoServiceProvider prov(n, commonParams);
        PluginInfo info;
        info.name = n;
        info.error = prov.error();
        info.errorString = prov.errorString();
        info.mapping = prov.mappingFeatures(); // mapping capability
        info.routing = prov.routingFeatures();
        info.geocoding = prov.geocodingFeatures();
        out.push_back(info);
    }
    return out;
}
