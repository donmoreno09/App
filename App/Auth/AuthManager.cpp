#include "AuthManager.h"
#include "SecureTokenStorage.h"
#include "PermissionManager.h"
#include "Networking/apis/AuthApi.h"
#include "JwtUtils.h"
#include "RolePermissions.h"
#include "AppLogger.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>

namespace {
Logger& _logger()
{
    static Logger logger = AppLogger::get().child({
        {"service", "AUTH-MANAGER"}
    });
    return logger;
}
}

AuthManager::AuthManager(QObject* parent)
    : QObject(parent)
{
    m_refreshTimer.setSingleShot(true);
    connect(&m_refreshTimer, &QTimer::timeout, this, [this]() {
        if (m_state != AuthState::Authenticated || !m_api) return;

        _logger().info("Token refresh timer fired");

        m_api->refresh(m_tokens.refreshToken,
                       [this](const LoginResult& result) {
                           handleLoginResult(result);
                           _logger().info("Token refreshed successfully");
                       },
                       [this](const ErrorResult& err) {
                           _logger().warn("Token refresh failed", {
                               kv("error", err.message)
                           });
                           clearSession();
                           m_sessionExpired = true;
                           emit sessionExpiredFlagChanged();
                           setState(AuthState::Unauthenticated);
                           emit sessionExpired();
                       });
    });
}

void AuthManager::initialize(AuthApi* api,
                             SecureTokenStorage* storage,
                             PermissionManager* permissions)
{
    m_api = api;
    m_storage = storage;
    m_permissions = permissions;
}

void AuthManager::login(const QString& email, const QString& password, bool rememberMe)
{
    m_rememberMe = rememberMe;

    if (m_state != AuthState::Unauthenticated && m_state != AuthState::Error) {
        _logger().warn("login() called in invalid state", {
            kv("state", static_cast<int>(m_state))
        });
        return;
    }

    if (!m_api) {
        handleAuthError("AuthManager not initialized");
        return;
    }

    m_errorMessage.clear();
    emit errorMessageChanged();
    m_sessionExpired = false;
    emit sessionExpiredFlagChanged();
    setState(AuthState::LoggingIn);

    m_api->login(email, password,
                 [this](const LoginResult& result) {
                     handleLoginResult(result);
                     emit loginSucceeded();
                     _logger().info("Login succeeded", {
                         kv("displayName", m_session.displayName())
                     });
                 },
                 [this](const ErrorResult& err) {
                     const QByteArray raw = err.reply ? err.reply->readAll() : QByteArray{};
                     const QJsonObject obj = QJsonDocument::fromJson(raw).object();
                     const QString message = !obj["error"].toString().isEmpty() ? obj["error"].toString() : (!raw.isEmpty() ? QString::fromUtf8(raw) : err.message);
                     _logger().warn("Login failed", {
                         kv("error", message)
                     });
                     handleAuthError(message);
                     emit loginFailed(message);
                 });
}

void AuthManager::requestLogout()
{
    emit logoutConfirmationRequested();
}

void AuthManager::logout()
{
    if (m_state != AuthState::Authenticated) return;

    _logger().info("Logging out", {
        kv("displayName", m_session.displayName())
    });

    if (m_api) {
        m_api->logout([]() {}, [](const ErrorResult&) {});
    }

    clearSession();
    setState(AuthState::Unauthenticated);
    emit loggedOut();
}

void AuthManager::tryAutoLogin()
{
    if (!m_storage || !m_api) {
        setState(AuthState::Unauthenticated);
        return;
    }

    if (!m_storage->hasStoredTokens()) {
        setState(AuthState::Unauthenticated);
        return;
    }

    AuthTokens stored = m_storage->loadTokens();
    if (stored.refreshToken.isEmpty()) {
        setState(AuthState::Unauthenticated);
        return;
    }

    const qint64 expiresAt = m_storage->loadExpiresAt();
    const qint64 now       = QDateTime::currentSecsSinceEpoch();

    if (expiresAt - now <= 0) {
        _logger().info("Stored access token is expired; session marked expired");
        m_storage->clearAll();
        m_sessionExpired = true;
        emit sessionExpiredFlagChanged();
        setState(AuthState::Unauthenticated);
        emit sessionExpired();
        return;
    }

    _logger().info("Stored access token still valid", {
        kv("secondsRemaining", expiresAt - now)
    });

    LoginResult result;
    result.tokens = stored;
    result.user   = m_storage->loadUserSession();

    m_rememberMe = true;
    setState(AuthState::AutoLoggingIn);
    handleLoginResult(result);
    emit loginSucceeded();
}

void AuthManager::setState(AuthState newState)
{
    if (m_state == newState) return;
    m_state = newState;
    emit stateChanged();
}

void AuthManager::handleLoginResult(const LoginResult& result)
{
    m_tokens  = result.tokens;
    m_session = result.user;

    const QJsonObject claims = JwtUtils::decodePayload(m_tokens.accessToken);
    if (!claims.isEmpty()) {
        m_session.role = claims["IPOSRole"].toString();
        m_tokens.expiresAt = claims["exp"].toInteger();
    }

    if (m_storage && m_rememberMe) {
        m_storage->saveTokens(m_tokens);
        m_storage->saveUserSession(m_session);
    }

    if (m_permissions) {
        m_permissions->loadFromSession(m_session.role, RolePermissions::permissionsFor(m_session.role));
    }

    emit tokenChanged(m_tokens.accessToken.toUtf8());

    scheduleTokenRefresh();

    emit userChanged();
    setState(AuthState::Authenticated);
}

void AuthManager::handleAuthError(const QString& message)
{
    m_errorMessage = message;
    emit errorMessageChanged();
    setState(AuthState::Error);
}

void AuthManager::scheduleTokenRefresh()
{
    m_refreshTimer.stop();

    if (m_tokens.expiresAt <= 0) return;

    const qint64 now = QDateTime::currentSecsSinceEpoch();
    const qint64 ttl = m_tokens.expiresAt - now;

    if (ttl <= 0) return;

    // Refresh 20% before expiry, capped at 120 s for long-lived tokens.
    const qint64 marginSecs  = qMin<qint64>(120, ttl / 5);
    const int    refreshInMs = static_cast<int>(qMax<qint64>(5, ttl - marginSecs)) * 1000;

    _logger().info("Scheduling token refresh", {
        kv("seconds", refreshInMs / 1000)
    });
    m_refreshTimer.start(refreshInMs);
}

void AuthManager::clearSession()
{
    m_refreshTimer.stop();
    m_tokens.clear();
    m_session.clear();
    m_errorMessage.clear();

    if (m_storage) m_storage->clearAll();
    if (m_permissions) m_permissions->clear();

    emit tokenChanged(QByteArray{});
    emit userChanged();
}

AuthState AuthManager::state() const { return m_state; }
QString AuthManager::errorMessage() const { return m_errorMessage; }
bool AuthManager::isSessionExpired() const { return m_sessionExpired; }
QString AuthManager::userId() const { return m_session.userId; }
QString AuthManager::username() const { return m_session.email; }
QString AuthManager::displayName() const { return m_session.displayName(); }
QString AuthManager::email() const { return m_session.email; }
QString AuthManager::role() const { return m_session.role; }
QString AuthManager::accessToken() const { return m_tokens.accessToken; }
