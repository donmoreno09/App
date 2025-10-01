#ifndef METADATAENTRY_H
#define METADATAENTRY_H

#include <QJsonValue>

class MetadataEntry {
public:
    virtual QJsonValue toJson() const = 0;
    virtual void fromJson(const QJsonValue& obj) = 0;
    virtual ~MetadataEntry() = default;
};

#endif // METADATAENTRY_H
