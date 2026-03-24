#ifndef AUTHTOKENS_H
#define AUTHTOKENS_H

#include <QString>
#include <QtTypes>

struct AuthTokens {
    QString accessToken;
    QString refreshToken;
    qint64  expiresAt = 0;  // Unix timestamp sourced from the JWT exp claim

    bool isValid() const { return !accessToken.isEmpty(); }

    void clear()
    {
        accessToken.clear();
        refreshToken.clear();
        expiresAt = 0;
    }
};

#endif // AUTHTOKENS_H
