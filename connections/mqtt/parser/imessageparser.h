#ifndef IMESSAGEPARSER_H
#define IMESSAGEPARSER_H

#include <QVariantList>
#include <QByteArray>

class IMessageParser {
public:
    virtual ~IMessageParser() = default;
    virtual QVariantList parse(const QByteArray& message) = 0;
};

#endif // IMESSAGEPARSER_H
