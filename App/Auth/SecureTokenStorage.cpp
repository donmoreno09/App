#include "SecureTokenStorage.h"
#include <QJsonDocument>
#include <QJsonObject>

SecureTokenStorage::SecureTokenStorage(QObject* parent)
    : QObject(parent)
{
}

void SecureTokenStorage::saveTokens(const AuthTokens& tokens)
{
    m_settings.beginGroup("auth");
    m_settings.setValue("accessToken",  tokens.accessToken);
    m_settings.setValue("refreshToken", tokens.refreshToken);
    m_settings.setValue("expiresAt",    tokens.expiresAt);
    m_settings.endGroup();
    m_settings.sync();
}

AuthTokens SecureTokenStorage::loadTokens() const
{
    AuthTokens tokens;
    QSettings s;
    s.beginGroup("auth");
    tokens.accessToken  = s.value("accessToken").toString();
    tokens.refreshToken = s.value("refreshToken").toString();
    tokens.expiresAt    = s.value("expiresAt", 0).toLongLong();
    s.endGroup();
    return tokens;
}

void SecureTokenStorage::saveUserSession(const UserSession& session)
{
    QJsonDocument doc(session.toJson());
    m_settings.setValue("auth/userSession", QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
    m_settings.sync();
}

UserSession SecureTokenStorage::loadUserSession() const
{
    UserSession session;
    QSettings s;
    QString json = s.value("auth/userSession").toString();
    if (!json.isEmpty()) {
        QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());
        if (doc.isObject())
            session.fromJson(doc.object());
    }
    return session;
}

void SecureTokenStorage::clearAll()
{
    m_settings.beginGroup("auth");
    m_settings.remove("");
    m_settings.endGroup();
    m_settings.sync();
}

qint64 SecureTokenStorage::loadExpiresAt() const
{
    QSettings s;
    s.beginGroup("auth");
    const qint64 expiresAt = s.value("expiresAt", 0).toLongLong();
    s.endGroup();
    return expiresAt;
}

bool SecureTokenStorage::hasStoredTokens() const
{
    QSettings s;
    s.beginGroup("auth");
    bool has = !s.value("refreshToken").toString().isEmpty();
    s.endGroup();
    return has;
}
