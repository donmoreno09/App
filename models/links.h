#ifndef LINKS_H
#define LINKS_H


#include <QJsonObject>
#include <QString>

struct Links {
    QString self;

    QJsonObject toJson() const {
        QJsonObject obj;
        obj["self"] = self;
        return obj;
    }

    static Links fromJson(const QJsonObject &obj) {
        Links l;
        l.self = obj["self"].toString();
        return l;
    }
};

#endif // LINKS_H
