#include "HttpClient.h"

#include <QHttpHeaders>
#include <cmath>

HttpClient::HttpClient(const QUrl& baseUrl, QObject* parent)
    : QObject(parent)
    , m_rest(&m_nam, this)
    , m_factory(baseUrl)
{
    QHttpHeaders headers;
    headers.append(QHttpHeaders::WellKnownHeader::Accept, "application/json");
    headers.append(QHttpHeaders::WellKnownHeader::ContentType, "application/json");
    headers.append("ngrok-skip-browser-warning", "true");
    m_factory.setCommonHeaders(headers);

    m_factory.setTransferTimeout(std::chrono::seconds(15));
}

HttpClient::HttpClient(QObject* parent)
    : HttpClient(QUrl{}, parent)
{
}

void HttpClient::setBaseUrl(const QUrl& baseUrl)
{
    m_factory.setBaseUrl(baseUrl);
}

void HttpClient::setBearerToken(const QByteArray& token)
{
    m_factory.setBearerToken(token);
}

void HttpClient::clearBearerToken()
{
    m_factory.setBearerToken(QByteArray{});
}

QNetworkRequest HttpClient::buildRequest(const QString& urlOrPath) const
{
    const QUrl url(urlOrPath);

    if (url.isValid() && url.isRelative())
        return m_factory.createRequest(urlOrPath);

    QNetworkRequest req = m_factory.createRequest();
    req.setUrl(url.isValid() ? url : QUrl{});
    return req;
}

int HttpClient::retryDelayMs(const RetryPolicy& policy, int attemptNo)
{
    const int expIndex = qMax(0, attemptNo - 1);
    const double raw = static_cast<double>(policy.baseDelayMs) * std::pow(policy.multiplier, expIndex);
    const int delay = static_cast<int>(raw);
    return qBound(0, delay, policy.maxDelayMs);
}

bool HttpClient::shouldRetry(const QRestReply& reply, const RetryPolicy& policy, int attemptNo) const
{
    if (attemptNo >= policy.maxAttempts)
        return false;

    if (reply.error() == QNetworkReply::OperationCanceledError)
        return false;

    if (policy.shouldRetry)
        return policy.shouldRetry(reply);

    if (reply.hasError())
        return policy.retryOnNetworkError;

    return policy.retryHttpStatus.contains(reply.httpStatus());
}

QString HttpClient::failureMessage(const QRestReply& reply)
{
    if (reply.hasError()) {
        const QString err = reply.errorString().trimmed();
        return err.isEmpty() ? QStringLiteral("Network error") : err;
    }

    const int status = reply.httpStatus();
    if (status > 0)
        return QStringLiteral("HTTP %1").arg(status);

    return QStringLiteral("Unknown network error");
}
