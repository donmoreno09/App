#ifndef DETAILS_H
#define DETAILS_H

#include <QString>
#include <QJsonObject>
#include <QJsonArray>
#include <QMap>
#include <QSharedPointer>
#include "../persistence/ipersistable.h"
#include "metadata/MetadataEntry.h"
#include "metadata/NoteMetadataEntry.h"

class Details : public IPersistable {
public:
    QMap<QString, QSharedPointer<MetadataEntry>> metadata;

    QJsonObject toJson() const override {
        QJsonObject metadataObj;
        for (const auto& key : metadata.keys()) {
            metadataObj[key] = metadata[key]->toJson();
        }

        QJsonObject detailsObj;
        detailsObj["metadata"] = metadataObj;

        return detailsObj;
    }

    void fromJson(const QJsonObject &json) override {
        QJsonObject metadataObj = json["metadata"].toObject();
        for (const QString& key : metadataObj.keys()) {
            if (key == "note") {
                auto entry = QSharedPointer<NoteMetadataEntry>::create();
                entry->fromJson(metadataObj[key]);
                metadata[key] = entry;
            }
        }
    }
};

#endif // DETAILS_H
