#ifndef METADATA_H
#define METADATA_H

#include <QJsonObject>
#include <QString>

struct Metadata {
    QString lastUpdated;
    QString createdAt;
    QString source;

    QJsonObject toJson() const {
        QJsonObject obj;
        obj["lastUpdated"] = lastUpdated;
        obj["createdAt"] = createdAt;
        obj["source"] = source;
        return obj;
    }

    static Metadata fromJson(const QJsonObject &obj) {
        Metadata m;
        m.lastUpdated = obj["lastUpdated"].toString();
        m.createdAt = obj["createdAt"].toString();
        m.source = obj["source"].toString();
        return m;
    }
};

#endif // METADATA_H
