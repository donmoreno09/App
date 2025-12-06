.pragma library

function formatNotificationDate(timestamp, languageCode) {
    // Validate timestamp
    if (!timestamp) {
        return { time: "", date: "" }
    }

    const dt = new Date(timestamp)

    // Check if date is valid
    if (isNaN(dt.getTime())) {
        console.warn("[NotificationUtils] Invalid timestamp:", timestamp)
        return { time: "", date: "" }
    }

    // Use toLocaleString with locale code
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
