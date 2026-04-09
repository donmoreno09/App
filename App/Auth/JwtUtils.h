#ifndef JWTUTILS_H
#define JWTUTILS_H

#include <QString>
#include <QByteArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>

namespace JwtUtils {

inline QJsonObject decodePayload(const QString& token)
{
    const QStringList parts = token.split('.');
    if (parts.size() != 3)
        return {};

    const QByteArray decoded = QByteArray::fromBase64(
        parts[1].toUtf8(),
        QByteArray::Base64UrlEncoding
        );

    QJsonParseError err;
    const QJsonDocument doc = QJsonDocument::fromJson(decoded, &err);

    if (err.error != QJsonParseError::NoError || !doc.isObject())
        return {};

    return doc.object();
}

}

#endif // JWTUTILS_H
