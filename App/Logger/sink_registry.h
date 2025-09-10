#ifndef SINK_REGISTRY_H
#define SINK_REGISTRY_H

#include <memory>
#include <unordered_map>
#include <type_traits>
#include <functional>
#include "ilogsink.h"
#include "log_types.h"

namespace detail {
struct SinkHash {
    std::size_t operator()(Sink s) const noexcept {
        using U = std::underlying_type_t<Sink>;
        return std::hash<U>{}(static_cast<U>(s));
    }
};
}

class SinkRegistry {
public:
    using Ptr = std::shared_ptr<ILogSink>;

    void set(Sink id, Ptr s) { sinks_[id] = std::move(s); }

    template <class T, class... Args>
    void emplace(Sink id, Args&&... args) {
        sinks_[id] = std::make_shared<T>(std::forward<Args>(args)...);
    }

    ILogSink* get(Sink id) const {
        auto it = sinks_.find(id);
        return it == sinks_.end() ? nullptr : it->second.get();
    }

    void forEach(const std::function<void(ILogSink*)>& f) {
        for (auto& kv : sinks_) f(kv.second.get());
    }

private:
    std::unordered_map<Sink, Ptr, detail::SinkHash> sinks_;
};


#endif // SINK_REGISTRY_H
