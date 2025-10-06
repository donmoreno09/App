#ifndef NOTEMETADATAENTRY_H
#define NOTEMETADATAENTRY_H

#include <QString>
#include "MetadataEntry.h"

class NoteMetadataEntry : public MetadataEntry {
public:
    QString note;

    QJsonValue toJson() const override {
        return note;
    }

    void fromJson(const QJsonValue& obj) override {
        note = obj.toString();
    }
};

#endif // NOTEMETADATAENTRY_H
