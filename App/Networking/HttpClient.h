#pragma once

#include <QObject>
#include <QByteArray>
#include <QJsonDocument>
#include <QList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QNetworkRequestFactory>
#include <QPointer>
#include <QRestAccessManager>
#include <QRestReply>
#include <QTimer>
#include <QUrl>
#include <QVariantMap>
#include <QtGlobal>

#include <concepts>
#include <functional>
#include <memory>
#include <type_traits>
#include <utility>

#include "NetworkingLogger.h"

struct RetryPolicy {
    int maxAttempts = 1;      // 1 = no retry
    int baseDelayMs = 200;
    double multiplier = 2.0;
    int maxDelayMs = 5000;

    bool retryOnNetworkError = true;
    QList<int> retryHttpStatus = { 408, 429, 500, 502, 503, 504 };

    // Optional override. maxAttempts is still enforced before this is called.
    std::function<bool(const QRestReply&)> shouldRetry = {};
};

class RequestHandle : public QObject
{
    Q_OBJECT

public:
    explicit RequestHandle(QObject* parent = nullptr)
        : QObject(parent)
    {}

    Q_INVOKABLE void abort()
    {
        if (m_aborted)
            return;

        m_aborted = true;

        if (m_reply)
            m_reply->abort();

        emit canceled();
        deleteLater();
    }

    bool aborted() const
    {
        return m_aborted;
    }

signals:
    void attempt(int n);
    void finished(int httpStatus);
    void failed(QString message, int httpStatus);
    void canceled();

private:
    friend class HttpClient;

    void setReply(QNetworkReply* reply)
    {
        if (m_reply == reply)
            return;

        m_reply = reply;

        if (m_reply) {
            QObject::connect(
                m_reply,
                &QObject::destroyed,
                this,
                [this] { m_reply = nullptr; },
                Qt::SingleShotConnection);
        }
    }

private:
    QPointer<QNetworkReply> m_reply;
    bool m_aborted = false;
};

template<typename T>
concept RestBody =
    std::same_as<std::remove_cvref_t<T>, QByteArray> ||
    std::same_as<std::remove_cvref_t<T>, QJsonDocument> ||
    std::same_as<std::remove_cvref_t<T>, QVariantMap>;

class HttpClient : public QObject
{
    Q_OBJECT

public:
    explicit HttpClient(const QUrl& baseUrl = {}, QObject* parent = nullptr);
    explicit HttpClient(QObject* parent = nullptr);

    void setBaseUrl(const QUrl& baseUrl);
    void setBearerToken(const QByteArray& token);
    void clearBearerToken();

    QRestAccessManager& rest() { return m_rest; }
    QNetworkRequestFactory& factory() { return m_factory; }

signals:
    void networkError(QString message, int httpStatus);

public:
    template<typename Functor>
        requires std::invocable<Functor, QRestReply&>
    RequestHandle* get(const QString& urlOrPath, Functor&& callback)
    {
        RetryPolicy policy;
        policy.maxAttempts = 3;
        return get(urlOrPath, std::forward<Functor>(callback), policy);
    }

    template<typename Functor>
        requires std::invocable<Functor, QRestReply&>
    RequestHandle* get(const QString& urlOrPath, Functor&& callback, RetryPolicy policy)
    {
        return sendWithRetry(
            urlOrPath,
            [this](const QNetworkRequest& req, QObject* ctx, auto&& done) -> QNetworkReply* {
                return m_rest.get(req, ctx, std::forward<decltype(done)>(done));
            },
            std::forward<Functor>(callback),
            std::move(policy));
    }

    template<typename Data, typename Functor>
        requires RestBody<Data> && std::invocable<Functor, QRestReply&>
    RequestHandle* post(const QString& urlOrPath, const Data& data, Functor&& callback)
    {
        return post(urlOrPath, data, std::forward<Functor>(callback), RetryPolicy{});
    }

    template<typename Data, typename Functor>
        requires RestBody<Data> && std::invocable<Functor, QRestReply&>
    RequestHandle* post(const QString& urlOrPath, const Data& data, Functor&& callback, RetryPolicy policy)
    {
        return sendWithRetry(
            urlOrPath,
            [this, data](const QNetworkRequest& req, QObject* ctx, auto&& done) mutable -> QNetworkReply* {
                return m_rest.post(req, data, ctx, std::forward<decltype(done)>(done));
            },
            std::forward<Functor>(callback),
            std::move(policy));
    }

    template<typename Data, typename Functor>
        requires RestBody<Data> && std::invocable<Functor, QRestReply&>
    RequestHandle* put(const QString& urlOrPath, const Data& data, Functor&& callback)
    {
        return put(urlOrPath, data, std::forward<Functor>(callback), RetryPolicy{});
    }

    template<typename Data, typename Functor>
        requires RestBody<Data> && std::invocable<Functor, QRestReply&>
    RequestHandle* put(const QString& urlOrPath, const Data& data, Functor&& callback, RetryPolicy policy)
    {
        return sendWithRetry(
            urlOrPath,
            [this, data](const QNetworkRequest& req, QObject* ctx, auto&& done) mutable -> QNetworkReply* {
                return m_rest.put(req, data, ctx, std::forward<decltype(done)>(done));
            },
            std::forward<Functor>(callback),
            std::move(policy));
    }

    template<typename Data, typename Functor>
        requires RestBody<Data> && std::invocable<Functor, QRestReply&>
    RequestHandle* patch(const QString& urlOrPath, const Data& data, Functor&& callback)
    {
        return patch(urlOrPath, data, std::forward<Functor>(callback), RetryPolicy{});
    }

    template<typename Data, typename Functor>
        requires RestBody<Data> && std::invocable<Functor, QRestReply&>
    RequestHandle* patch(const QString& urlOrPath, const Data& data, Functor&& callback, RetryPolicy policy)
    {
        return sendWithRetry(
            urlOrPath,
            [this, data](const QNetworkRequest& req, QObject* ctx, auto&& done) mutable -> QNetworkReply* {
                return m_rest.patch(req, data, ctx, std::forward<decltype(done)>(done));
            },
            std::forward<Functor>(callback),
            std::move(policy));
    }

    template<typename Functor>
        requires std::invocable<Functor, QRestReply&>
    RequestHandle* remove(const QString& urlOrPath, Functor&& callback)
    {
        return remove(urlOrPath, std::forward<Functor>(callback), RetryPolicy{});
    }

    template<typename Functor>
        requires std::invocable<Functor, QRestReply&>
    RequestHandle* remove(const QString& urlOrPath, Functor&& callback, RetryPolicy policy)
    {
        return sendWithRetry(
            urlOrPath,
            [this](const QNetworkRequest& req, QObject* ctx, auto&& done) -> QNetworkReply* {
                return m_rest.deleteResource(req, ctx, std::forward<decltype(done)>(done));
            },
            std::forward<Functor>(callback),
            std::move(policy));
    }

private:
    static Logger& _logger()
    {
        static Logger logger = NetworkingLogger::get().child({
            {"service", "HTTP_CLIENT"}
        });
        return logger;
    }

    QNetworkRequest buildRequest(const QString& urlOrPath) const;
    static int retryDelayMs(const RetryPolicy& policy, int attemptNo);
    bool shouldRetry(const QRestReply& reply, const RetryPolicy& policy, int attemptNo) const;
    static QString failureMessage(const QRestReply& reply);

    template<typename Sender, typename Callback>
    struct RequestState {
        QString urlOrPath;
        Sender sender;
        Callback callback;
        RetryPolicy policy;
        QPointer<RequestHandle> handle;
    };

    template<typename Sender, typename Callback>
    RequestHandle* sendWithRetry(const QString& urlOrPath,
                                 Sender&& sender,
                                 Callback&& callback,
                                 RetryPolicy policy)
    {
        auto* handle = new RequestHandle(this);

        using State = RequestState<std::decay_t<Sender>, std::decay_t<Callback>>;
        auto state = std::make_shared<State>(State{
            urlOrPath,
            std::forward<Sender>(sender),
            std::forward<Callback>(callback),
            std::move(policy),
            handle
        });

        performAttempt(state, 1);
        return handle;
    }

    template<typename State>
    void performAttempt(const std::shared_ptr<State>& state, int attemptNo)
    {
        RequestHandle* handle = state->handle.data();
        if (!handle || handle->aborted())
            return;

        emit handle->attempt(attemptNo);

        const QNetworkRequest req = buildRequest(state->urlOrPath);
        if (!req.url().isValid()) {
            emit handle->failed(QStringLiteral("Invalid URL"), 0);
            handle->deleteLater();
            return;
        }

        QNetworkReply* rawReply = state->sender(
            req,
            handle,
            [this, state, attemptNo](QRestReply& reply) mutable {
                RequestHandle* handle = state->handle.data();
                if (!handle || handle->aborted())
                    return;

                handle->setReply(nullptr);

                if (reply.isSuccess()) {
                    state->callback(reply);
                    emit handle->finished(reply.httpStatus());
                    handle->deleteLater();
                    return;
                }

                if (shouldRetry(reply, state->policy, attemptNo)) {
                    const int delayMs = retryDelayMs(state->policy, attemptNo);

                    QTimer::singleShot(delayMs, handle, [this, state, attemptNo] {
                        performAttempt(state, attemptNo + 1);
                    });
                    return;
                }

                const QString message = failureMessage(reply);
                emit networkError(message, reply.httpStatus());

                state->callback(reply);
                emit handle->failed(message, reply.httpStatus());
                handle->deleteLater();
            });

        handle->setReply(rawReply);
    }

private:
    QNetworkAccessManager m_nam;
    QRestAccessManager m_rest;
    QNetworkRequestFactory m_factory;
};
