.pragma library

function formatNotificationDate(timestamp, languageCode) {
    const dt = new Date(timestamp)
    const locale = Qt.locale(languageCode)
    const time = dt.toLocaleTimeString(locale, Locale.ShortFormat)
    const date = dt.toLocaleDateString(locale, Locale.ShortFormat)
    return { time: time, date: date }
}

function formatLocationText(location) {
    if (!location || !location.isValid) {
        return ""
    }
    return `Lat ${location.latitude.toFixed(4)}°, Lon ${location.longitude.toFixed(4)}°`
}
