#include "PoiOptions.h"
#include <connections/httpclient.h>
#include <connections/apiendpoints.h>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QVariantMap>
#include <QHash>

PoiOptions::PoiOptions(QObject* parent)
    : QObject(parent)
{
    buildTranslationMaps();
}

void PoiOptions::fetchAll() {
    // Parse categories + build typesByCategory from the same payload
    m_httpClient.get(QUrl(ApiEndpoints::GetTypes), [this](QByteArray data){
        rawCategoriesTypes = QJsonDocument::fromJson(data).array();
        buildCategoriesTypes();
    });

    m_httpClient.get(QUrl(ApiEndpoints::GetHealthStatuses), [this](QByteArray data){
        rawHealthStatuses = QJsonDocument::fromJson(data).array();
        buildHealthStatuses();
    });

    m_httpClient.get(QUrl(ApiEndpoints::GetOperationalStates), [this](QByteArray data){
        rawOperationalStates = QJsonDocument::fromJson(data).array();
        buildOperationalStates();
    });
}

void PoiOptions::updateTranslations()
{
    buildTranslationMaps();
    buildCategoriesTypes();
    buildHealthStatuses();
    buildOperationalStates();
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

void PoiOptions::buildTranslationMaps()
{
    trCategoryMap = {
        { QStringLiteral("ADMIN_CONTROL_BUILDINGS"),        tr("Administrative and Control Buildings") },
        { QStringLiteral("PERSONNEL_OPERATIONAL_SUPPORT"),  tr("Personnel and Operational Support Buildings") },
        { QStringLiteral("CARGO_HANDLING_STORAGE"),         tr("Cargo Handling and Storage Facilities") },
        { QStringLiteral("PRODUCTION_TECH_MAINTENANCE"),    tr("Production, Technical and Maintenance Buildings") },
        { QStringLiteral("TRANSPORT_LOGISTICS_INFRA"),      tr("Transport and Logistics Infrastructure") },
        { QStringLiteral("PASSENGER_FERRY_TERMINALS"),      tr("Passenger and Ferry Terminals") },
        { QStringLiteral("ASSETS"),                         tr("Assets") },
        { QStringLiteral("TERMINALS"),                      tr("Terminals") },
        { QStringLiteral("SECURITY"),                       tr("Security") },
    };

    trTypeMap = {
        { QStringLiteral("PORT_AUTHORITY_HQ"),                   tr("Port Authority Headquarters") },
        { QStringLiteral("CONTROL_TOWER_VTS"),                   tr("Control Tower / Vessel Traffic Service (VTS) Center") },
        { QStringLiteral("CUSTOMS_BORDER_CONTROL"),              tr("Customs and Border Control Offices") },
        { QStringLiteral("SECURITY_SURVEILLANCE_CENTER"),        tr("Security and Surveillance Center") },

        { QStringLiteral("CREW_ACCOMMODATION"),                  tr("Crew Accommodation / Seafarers’ Center") },
        { QStringLiteral("ADMIN_OFFICES_PORT_OPERATORS"),        tr("Administrative Offices for Port Operators") },
        { QStringLiteral("SECURITY_POSTS_GATEHOUSES"),           tr("Security Posts / Gatehouses") },
        { QStringLiteral("FIREFIGHTING_STATIONS"),               tr("Firefighting Stations") },
        { QStringLiteral("MEDICAL_FIRST_AID_CENTER"),            tr("Medical / First Aid Center") },
        { QStringLiteral("TRAINING_CENTERS"),                    tr("Training Centers") },

        { QStringLiteral("WAREHOUSES"),                          tr("Warehouses") },
        { QStringLiteral("COLD_STORAGE"),                        tr("Cold Storage / Refrigerated Warehouses") },
        { QStringLiteral("BULK_STORAGE_SILOS"),                  tr("Bulk Storage Silos") },
        { QStringLiteral("CARGO_CONSOLIDATION_CENTERS"),         tr("Cargo Consolidation Centers") },

        { QStringLiteral("POWER_PUMPING_STATIONS"),              tr("Power Substations and Pumping Stations") },
        { QStringLiteral("PANEL_LINE"),                          tr("Panel Line") },
        { QStringLiteral("STEEL_CUTTING_FORMING"),               tr("Steel Cutting and Forming") },
        { QStringLiteral("WELDING_ASSEMBLY_HALLS"),              tr("Welding and Assembly Halls") },
        { QStringLiteral("SURFACE_TREATMENT_PAINTING_HALLS"),    tr("Surface Treatment and Painting Halls") },
        { QStringLiteral("FITTING_OUT_INTEGRATION_HALLS"),       tr("Fitting-out and Integration Halls") },

        { QStringLiteral("FREIGHT_FORWARDING_OFFICES"),          tr("Freight Forwarding Offices") },
        { QStringLiteral("TRUCK_PARKING_INSPECTION"),            tr("Truck Parking Areas and Inspection Stations") },
        { QStringLiteral("WEIGHBRIDGES"),                        tr("Weighbridges") },
        { QStringLiteral("CONTAINER_FREIGHT_STATIONS"),          tr("Container Freight Stations (CFS)") },
        { QStringLiteral("RAIL_TERMINALS_INTERMODAL"),           tr("Rail Terminals / Intermodal Facilities") },
        { QStringLiteral("PARKING_MAINTENANCE_DEPOTS"),          tr("Parking Areas & Maintenance Depots") },

        { QStringLiteral("CRUISE_TERMINALS"),                    tr("Cruise Terminals") },
        { QStringLiteral("FERRY_TERMINALS"),                     tr("Ferry Terminals") },
        { QStringLiteral("TICKETING_CHECKIN"),                   tr("Ticketing & Check-in Buildings") },
        { QStringLiteral("VISITOR_INFO_CENTERS"),                tr("Visitor & Information Centers") },
        { QStringLiteral("SECURITY_CUSTOMS_POSTS"),              tr("Security & Customs Posts") },

        { QStringLiteral("GOLIATH_CRANES"),                      tr("Goliath Cranes") },
        { QStringLiteral("PORTAL_CRANES"),                       tr("Portal Cranes") },
        { QStringLiteral("TOWER_CRANES"),                        tr("Tower Cranes") },
        { QStringLiteral("MOBILE_CRANES"),                       tr("Mobile Cranes") },
        { QStringLiteral("SPMTS"),                               tr("Self-Propelled Modular Transporters (SPMTs)") },
        { QStringLiteral("BLOCK_TRANSPORTERS"),                  tr("Block Transporters / Heavy-load Trailers") },
        { QStringLiteral("MONORAIL_HOISTS_WINCHES"),             tr("Monorail Systems, Hoists, and Winches") },

        { QStringLiteral("CONTAINER_TERMINALS"),                 tr("Container Yards / Terminals") },
        { QStringLiteral("RORO_TERMINALS"),                      tr("Ro-Ro (Roll-on/Roll-off) Terminals") },
        { QStringLiteral("SHIP_REPAIR_DOCKS"),                   tr("Ship Repair Docks / Dry Docks") },

        { QStringLiteral("CCTV"),                                tr("CCTV") },
        { QStringLiteral("ACCESS_CONTROL_SERVERS"),              tr("Access Control Servers") },
        { QStringLiteral("NVR_CYBER_HARDENED"),                  tr("Network Video Recorders (NVRs) with Cybersecurity Hardening") },
        { QStringLiteral("DIGITAL_TWIN_SITUATIONAL_AWARENESS"),  tr("Digital Twin / Situational Awareness Systems (GIS-based Threat Visualization)") },
    };

    trHealthStatusesMap = {
        { 1, tr("Active") },
        { 2, tr("Off") },
        { 3, tr("Degraded") },
        { 4, tr("Maintenance") },
    };

    trOperationalStatesMap = {
        { 1, tr("Standby") },
        { 2, tr("Operating") },
        { 3, tr("In transit") },
        { 4, tr("Waiting") },
    };
}

void PoiOptions::buildCategoriesTypes()
{
    QVariantList categories;        // [{ key, name }]
    QHash<int, QVariantList> byCat; // key -> [{ key, value }]

    for (int i = 0; i < rawCategoriesTypes.size(); i++) {
        const QJsonObject cat = rawCategoriesTypes.at(i).toObject();
        const int catKey = cat.value("key").toInt();
        const QString catCode = cat.value("code").toString();
        const QString catName = cat.value("name").toString();

        QVariantMap catItem;
        catItem.insert("key", catKey);
        catItem.insert("code", catCode);
        catItem.insert("name", trCategoryMap.value(catCode, catName));
        categories.append(catItem);

        QVariantList typesForCat;
        const QJsonArray values = cat.value("values").toArray();
        for (int j = 0; j < values.size(); j++) {
            const QJsonObject t = values.at(j).toObject();
            const QString typeCode = t.value("code").toString();
            const QString typeValue = t.value("value").toString();

            QVariantMap typeItem;
            typeItem.insert("key", t.value("key").toInt());
            typeItem.insert("code", typeCode);
            typeItem.insert("value", trTypeMap.value(typeCode, typeValue));
            typesForCat.append(typeItem);
        }
        byCat.insert(catKey, typesForCat);
    }

    m_categories = categories;
    m_typesByCategory = byCat;

    emit categoriesChanged();
}

void PoiOptions::buildHealthStatuses()
{
    QVariantList healthStatuses;

    for (int i = 0; i < rawHealthStatuses.size(); i++) {
        const QJsonObject hs = rawHealthStatuses.at(i).toObject();
        const int hsKey = hs.value("key").toInt();
        const QString hsValue = hs.value("value").toString();

        QVariantMap hsItem;
        hsItem.insert("key", hsKey);
        hsItem.insert("value", trHealthStatusesMap.value(hsKey, hsValue));
        healthStatuses.append(hsItem);
    }

    m_healthStatuses = healthStatuses;
    emit healthStatusesChanged();
}

void PoiOptions::buildOperationalStates()
{
    QVariantList operationalStates;

    for (int i = 0; i < rawOperationalStates.size(); i++) {
        const QJsonObject hs = rawOperationalStates.at(i).toObject();
        const int hsKey = hs.value("key").toInt();
        const QString hsValue = hs.value("value").toString();

        QVariantMap hsItem;
        hsItem.insert("key", hsKey);
        hsItem.insert("value", trOperationalStatesMap.value(hsKey, hsValue));
        operationalStates.append(hsItem);
    }

    m_operationalStates = operationalStates;
    emit operationalStatesChanged();
}
