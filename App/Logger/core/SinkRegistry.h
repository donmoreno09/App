#ifndef SINK_REGISTRY_H
#define SINK_REGISTRY_H

#include <memory>
#include <unordered_map>
#include <type_traits>
#include <functional>

#include "sinks/ILogSink.h"
#include "LogTypes.h"

class SinkRegistry {
public:
    using ILogSinkPtr = std::shared_ptr<ILogSink>;

    void set(Sink sink, ILogSinkPtr sinkPtr) { m_sinks[sink] = std::move(sinkPtr); }

    template <class T, class... Args>
    void emplace(Sink sink, Args&&... args) {
        m_sinks[sink] = std::make_shared<T>(std::forward<Args>(args)...);
    }

    ILogSink* get(Sink sink) const {
        auto it = m_sinks.find(sink);
        return it == m_sinks.end() ? nullptr : it->second.get();
    }

    void forEach(const std::function<void(ILogSink*)>& cb) {
        for (auto& kv : m_sinks) cb(kv.second.get());
    }

    struct SinkHash {
        std::size_t operator()(Sink sink) const noexcept {
            using U = std::underlying_type_t<Sink>;
            return std::hash<U>{}(static_cast<U>(sink));
        }
    };

private:
    std::unordered_map<Sink, ILogSinkPtr, SinkHash> m_sinks;
};

#endif // SINK_REGISTRY_H
