#include "AuthService.h"
#include "SecureTokenStorage.h"
#include "PermissionManager.h"
#include "apis/AuthApi.h"
#include <QDebug>

AuthService::AuthService(QObject* parent)
    : QObject(parent)
{
    m_refreshTimer.setSingleShot(true);
    connect(&m_refreshTimer, &QTimer::timeout, this, [this]() {
        if (m_state != AuthState::Authenticated || !m_api) return;

        qDebug() << "[AuthService] Token refresh timer fired";

        m_api->refresh(m_tokens.refreshToken,
            [this](const LoginResult& result) {
                handleLoginResult(result);
                qDebug() << "[AuthService] Token refreshed successfully";
            },
            [this](const ErrorResult& err) {
                qWarning() << "[AuthService] Token refresh failed:" << err.message;
                clearSession();
                setState(AuthState::Unauthenticated);
                emit sessionExpired();
            });
    });
}

void AuthService::initialize(AuthApi* api,
                              SecureTokenStorage* storage,
                              PermissionManager* permissions)
{
    m_api = api;
    m_storage = storage;
    m_permissions = permissions;
}

void AuthService::login(const QString& username, const QString& password, bool rememberMe)
{
    m_rememberMe = rememberMe;

    if (m_state != AuthState::Unauthenticated && m_state != AuthState::Error) {
        qWarning() << "[AuthService] login() called in invalid state:" << static_cast<int>(m_state);
        return;
    }

    if (!m_api) {
        handleAuthError("AuthService not initialized");
        return;
    }

    m_errorMessage.clear();
    setState(AuthState::LoggingIn);

    m_api->login(username, password,
        [this](const LoginResult& result) {
            handleLoginResult(result);
            emit loginSucceeded();
            qDebug() << "[AuthService] Login succeeded for" << m_session.username;
        },
        [this](const ErrorResult& err) {
            qWarning() << "[AuthService] Login failed:" << err.message;
            handleAuthError(err.message);
            emit loginFailed(err.message);
        });
}

void AuthService::logout()
{
    if (m_state != AuthState::Authenticated) return;

    qDebug() << "[AuthService] Logging out" << m_session.username;

    if (m_api) {
        m_api->logout([]() {}, [](const ErrorResult&) {});
    }

    clearSession();
    setState(AuthState::Unauthenticated);
    emit loggedOut();
}

void AuthService::tryAutoLogin()
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

    m_rememberMe = true; // stored tokens imply the user previously chose to remember
    setState(AuthState::AutoLoggingIn);
    qDebug() << "[AuthService] Attempting auto-login with stored token";

    m_api->refresh(stored.refreshToken,
        [this](const LoginResult& result) {
            handleLoginResult(result);
            qDebug() << "[AuthService] Auto-login succeeded for" << m_session.username;
        },
        [this](const ErrorResult& err) {
            qWarning() << "[AuthService] Auto-login failed:" << err.message;
            if (m_storage) m_storage->clearAll();
            setState(AuthState::Unauthenticated);
        });
}

// --- Private ---

void AuthService::setState(AuthState newState)
{
    if (m_state == newState) return;
    m_state = newState;
    emit stateChanged();
}

void AuthService::handleLoginResult(const LoginResult& result)
{
    m_tokens = result.tokens;
    m_session = result.user;

    if (m_storage && m_rememberMe) {
        m_storage->saveTokens(m_tokens);
        m_storage->saveUserSession(m_session);
    }

    if (m_permissions) {
        m_permissions->loadFromSession(m_session.roles, m_session.permissions);
    }

    emit tokenChanged(m_tokens.accessToken.toUtf8());

    scheduleTokenRefresh();

    emit userChanged();
    setState(AuthState::Authenticated);
}

void AuthService::handleAuthError(const QString& message)
{
    m_errorMessage = message;
    setState(AuthState::Error);
}

void AuthService::scheduleTokenRefresh()
{
    m_refreshTimer.stop();

    if (m_tokens.expiresIn <= 0) return;

    // Refresh 60 seconds before expiration, but at least 10 seconds from now
    int refreshInMs = qMax(10, m_tokens.expiresIn - 60) * 1000;

    qDebug() << "[AuthService] Scheduling token refresh in" << refreshInMs / 1000 << "seconds";
    m_refreshTimer.start(refreshInMs);
}

void AuthService::clearSession()
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

// Property getters

AuthState AuthService::state() const { return m_state; }
QString AuthService::errorMessage() const { return m_errorMessage; }
QString AuthService::username() const { return m_session.username; }
QString AuthService::displayName() const { return m_session.displayName; }
QString AuthService::email() const { return m_session.email; }
QStringList AuthService::roles() const { return m_session.roles; }
QString AuthService::accessToken() const { return m_tokens.accessToken; }
