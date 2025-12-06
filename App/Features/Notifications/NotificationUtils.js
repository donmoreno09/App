.pragma library

function formatNotificationDate(timestamp, languageCode) {
    if (!timestamp) {
        return { time: "", date: "" }
    }

    const dt = new Date(timestamp)

    if (isNaN(dt.getTime())) {
        console.warn("[NotificationUtils] Invalid timestamp:", timestamp)
        return { time: "", date: "" }
    }

    const timeOptions = { hour: '2-digit', minute: '2-digit' }
    const dateOptions = { year: 'numeric', month: '2-digit', day: '2-digit' }

    const time = dt.toLocaleTimeString(languageCode, timeOptions)
    const date = dt.toLocaleDateString(languageCode, dateOptions)

    return { time: time, date: date }
}

function formatLocationText(location) {
    if (!location || !location.isValid) {
        return ""
    }
    return `Lat ${location.latitude.toFixed(4)}°, Lon ${location.longitude.toFixed(4)}°`
}
