# Notification Toast System - Technical Documentation

## Overview

This document describes the notification toast system workflow, from SignalR message reception to UI display. The system was refactored to include rate limiting to prevent UI blocking when many notifications arrive simultaneously.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              SIGNALR LAYER                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│  SignalRClientService.cpp                                                   │
│  ┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐    │
│  │ WebSocket       │───▶│ parseMessage()   │───▶│ handleNotification()│    │
│  │ Connection      │    │ (type: 1)        │    │                     │    │
│  └─────────────────┘    └──────────────────┘    └──────────┬──────────┘    │
│                                                             │               │
│                                              ┌──────────────▼──────────────┐│
│                                              │processNotificationInternal()││
│                                              │  - Maps eventTypeName       ││
│                                              │  - Routes to parser         ││
│                                              └──────────────┬──────────────┘│
└─────────────────────────────────────────────────────────────┼───────────────┘
                                                              │
┌─────────────────────────────────────────────────────────────┼───────────────┐
│                              PARSER LAYER                   │               │
├─────────────────────────────────────────────────────────────┼───────────────┤
│  ┌────────────────────────────┐    ┌────────────────────────▼─────────────┐ │
│  │ TruckNotificationSignalR   │    │ AlertZoneNotificationParser          │ │
│  │ Parser.h                   │    │ .h                                   │ │
│  │ (EventType 0, 1)           │    │ (EventType 2)                        │ │
│  └─────────────┬──────────────┘    └────────────────────────┬─────────────┘ │
│                │                                            │               │
│                │ QVector<TruckNotification>                 │ QVector<AlertZoneNotification>
└────────────────┼────────────────────────────────────────────┼───────────────┘
                 │                                            │
┌────────────────┼────────────────────────────────────────────┼───────────────┐
│                │           MODEL LAYER                      │               │
├────────────────┼────────────────────────────────────────────┼───────────────┤
│  ┌─────────────▼──────────────┐    ┌────────────────────────▼─────────────┐ │
│  │ TruckNotificationModel     │    │ AlertZoneNotificationModel           │ │
│  │ .cpp/.h                    │    │ .cpp/.h                              │ │
│  │                            │    │                                      │ │
│  │ - upsert()                 │    │ - upsert()                           │ │
│  │ - emits rowsInserted       │    │ - emits rowsInserted                 │ │
│  │ - initialLoadComplete flag │    │ - initialLoadComplete flag           │ │
│  └─────────────┬──────────────┘    └────────────────────────┬─────────────┘ │
│                │                                            │               │
│                │ Signal: rowsInserted(parent, first, last)  │               │
└────────────────┼────────────────────────────────────────────┼───────────────┘
                 │                                            │
┌────────────────┼────────────────────────────────────────────┼───────────────┐
│                │              UI LAYER                      │               │
├────────────────┼────────────────────────────────────────────┼───────────────┤
│  ┌─────────────▼────────────────────────────────────────────▼─────────────┐ │
│  │ NotificationToast.qml                                                  │ │
│  │                                                                        │ │
│  │ Connections {                                                          │ │
│  │   target: TruckNotificationModel / AlertZoneNotificationModel          │ │
│  │   onRowsInserted() ──▶ _addToast()                                     │ │
│  │ }                                                                      │ │
│  │                                                                        │ │
│  │ ┌─────────────┐   ┌─────────────┐   ┌─────────────────────────────┐   │ │
│  │ │ toastsModel │   │ toastQueue  │   │ ToastNotification (delegate)│   │ │
│  │ │ (max 3)     │   │ (max 3)     │   │                             │   │ │
│  │ └─────────────┘   └─────────────┘   └─────────────────────────────┘   │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Detailed Workflow

### 1. SignalR Message Reception

**File:** `App/connections/signalr/SignalRClientService.cpp`

When the server sends a notification:

```cpp
// WebSocket receives message
void SignalRClientService::onTextMessageReceived(const QString& message)
{
    QStringList messages = message.split(QChar(RECORD_SEPARATOR), Qt::SkipEmptyParts);
    for (int i = 0; i < messages.size(); ++i) {
        parseMessage(messages[i]);
    }
}
```

The message is parsed and routed:

```cpp
void SignalRClientService::parseMessage(const QString& message)
{
    // ...
    int type = obj["type"].toInt();

    switch (type) {
    case 1: {  // Invocation (server calling client method)
        QString target = obj["target"].toString();  // "ReceiveNotification"
        QVariantList args = /* extract arguments */;

        // Route to registered handler
        if (m_methodHandlers.contains(target)) {
            m_methodHandlers[target](args);  // calls handleNotification()
        }
        break;
    }
    // ...
    }
}
```

### 2. Notification Processing

**File:** `App/connections/signalr/SignalRClientService.cpp`

```cpp
void SignalRClientService::processNotificationInternal(
    const QString& id,
    const QVariant& payloadVar,
    const QString& eventTypeName,
    const QString& timestamp)
{
    // Map event type name to integer
    int eventType = -1;
    if (eventTypeName == "TirAppIssueCreated") eventType = 0;
    else if (eventTypeName == "TirAppIssueResolved") eventType = 1;
    else if (eventTypeName == "ControlRoomAlertZoneIntrusion") eventType = 2;

    // Get the appropriate parser
    auto* baseParser = m_eventTypeParsers.value(eventType);

    // Route to model based on event type
    if (eventType == 0 || eventType == 1) {
        // Truck notifications
        auto* parser = dynamic_cast<ISignalRMessageParser<TruckNotification>*>(baseParser);
        QVector<TruckNotification> notifications = parser->parse(envelope);
        model->upsert(notifications);  // TruckNotificationModel

    } else if (eventType == 2) {
        // Alert zone notifications
        auto* parser = dynamic_cast<ISignalRMessageParser<AlertZoneNotification>*>(baseParser);
        QVector<AlertZoneNotification> notifications = parser->parse(envelope);
        model->upsert(notifications);  // AlertZoneNotificationModel
    }
}
```

### 3. Model Update

**File:** `App/models/AlertZoneNotificationModel.cpp`

```cpp
void AlertZoneNotificationModel::upsert(const QVector<AlertZoneNotification> &notifications)
{
    for (const auto& notif : notifications) {
        // Skip if already deleted locally
        if (m_deletedIds.contains(notif.id)) continue;

        auto it = m_upsertMap.find(notif.id);

        if (it != m_upsertMap.end()) {
            // UPDATE existing notification
            const int row = it.value();
            QVector<int> changed = diffRoles(m_notifications[row], notif);
            if (!changed.empty()) {
                m_notifications[row] = notif;
                emit dataChanged(idx, idx, changed);
            }
        } else {
            // INSERT new notification
            const int row = m_notifications.size();

            beginInsertRows({}, row, row);      // ← Triggers rowsInserted signal
            m_notifications.append(notif);
            m_upsertMap.insert(notif.id, row);
            endInsertRows();
        }
    }
}
```

**Key Signal:** `rowsInserted(QModelIndex parent, int first, int last)`
- Emitted by `endInsertRows()`
- `first` and `last` indicate the range of inserted rows

### 4. Toast Creation (UI Layer)

**File:** `App/Features/Notifications/NotificationToast.qml`

The QML component listens to model signals:

```qml
Connections {
    target: AlertZoneNotificationModel

    function onRowsInserted(parent, first, last) {
        // Skip during initial load to prevent toast spam on app startup
        if (!AlertZoneNotificationModel.initialLoadComplete) { return }

        // RATE LIMITING: Only process last 3 if batch is large
        const batchSize = last - first + 1
        const startIndex = batchSize > maxVisibleToasts ? last - maxVisibleToasts + 1 : first

        for (let i = startIndex; i <= last; i++) {
            const notification = AlertZoneNotificationModel.getEditableNotification(i)
            if (!notification) continue

            _addToast({
                toastTitle: qsTr("New Notification"),
                toastMessage: qsTr("From ") + notification.id,
                toastType: "alertzone",
                toastId: notification.id
            })
        }
    }
}
```

### 5. Toast Queue Management

**File:** `App/Features/Notifications/NotificationToast.qml`

```qml
readonly property int maxVisibleToasts: 3  // Max toasts on screen
readonly property int maxQueuedToasts: 3   // Max toasts waiting in queue

function _addToast(toastData) {
    if (toastsModel.count < maxVisibleToasts) {
        // Add directly to visible toasts
        toastsModel.insert(0, toastData)
    } else {
        // QUEUE LIMITING: Drop oldest if queue is full
        if (toastQueue.length >= maxQueuedToasts) {
            toastQueue.shift()  // Remove oldest queued toast
        }
        toastQueue.push(toastData)
    }
}

function _processQueue() {
    // Called when a toast is destroyed (closed/timed out)
    if (toastQueue.length > 0 && toastsModel.count < maxVisibleToasts) {
        const nextToast = toastQueue.shift()
        toastsModel.insert(0, nextToast)
    }
}
```

---

## Rate Limiting Strategy

### Problem

When many notifications arrive rapidly (e.g., 100+ alert zone intrusions), the system would:
1. Create 100+ toast objects
2. Queue them all for display
3. Overwhelm the UI, causing crashes or freezes

### Solution

Two-level rate limiting was implemented:

#### Level 1: Batch Limiting (onRowsInserted)

When notifications arrive in a **batch** (single `rowsInserted` with multiple rows):

```qml
const batchSize = last - first + 1
const startIndex = batchSize > maxVisibleToasts ? last - maxVisibleToasts + 1 : first
```

| Scenario | Behavior |
|----------|----------|
| 1 notification arrives | Process it (batch size = 1) |
| 5 notifications arrive at once | Only process last 3 (indices 2, 3, 4) |
| 100 notifications arrive at once | Only process last 3 (indices 97, 98, 99) |

#### Level 2: Queue Limiting (_addToast)

When notifications arrive **one-by-one** rapidly (separate `rowsInserted` signals):

```qml
if (toastQueue.length >= maxQueuedToasts) {
    toastQueue.shift()  // Drop oldest queued
}
toastQueue.push(toastData)
```

| State | Action |
|-------|--------|
| 3 visible, 0 queued | Add to queue (now 3 visible, 1 queued) |
| 3 visible, 3 queued | Drop oldest queued, add new (still 3 visible, 3 queued) |

### Maximum Toast Objects

With both limits in place:
- **Maximum visible:** 3
- **Maximum queued:** 3
- **Total maximum:** 6 toast objects at any time

---

## Key Properties and Signals

### AlertZoneNotificationModel

| Property | Type | Description |
|----------|------|-------------|
| `count` | int | Number of notifications in model |
| `initialLoadComplete` | bool | True after initial unread notifications are loaded |

| Signal | Description |
|--------|-------------|
| `rowsInserted(parent, first, last)` | Emitted when new notifications are inserted |
| `dataChanged(topLeft, bottomRight, roles)` | Emitted when existing notifications are updated |
| `countChanged()` | Emitted when notification count changes |

### NotificationToast.qml

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `maxVisibleToasts` | int | 3 | Max toasts displayed simultaneously |
| `maxQueuedToasts` | int | 3 | Max toasts waiting in queue |
| `toastQueue` | array | [] | Queue of pending toasts |

| Function | Description |
|----------|-------------|
| `_addToast(toastData)` | Add toast to visible or queue |
| `_removeToast(index)` | Remove toast from visible model |
| `_processQueue()` | Move queued toast to visible when slot available |

---

## Event Type Mapping

| Event Type Name | Event Type ID | Model |
|-----------------|---------------|-------|
| `TirAppIssueCreated` | 0 | TruckNotificationModel |
| `TirAppIssueResolved` | 1 | TruckNotificationModel |
| `ControlRoomAlertZoneIntrusion` | 2 | AlertZoneNotificationModel |

---

## Debug Logging

Debug logging is enabled in `NotificationToast.qml`. Log prefix: `[NotificationToast]`

### Log Examples

```
[NotificationToast] 2026-01-26T10:49:03.054Z ALERTZONE rowsInserted - first: 53, last: 53, batchSize: 1
[NotificationToast] 2026-01-26T10:49:03.054Z ALERTZONE processing from index 53 to 53
[NotificationToast] 2026-01-26T10:49:03.054Z _addToast called - visible: 2, queued: 0, id: a182e144-...
[NotificationToast] 2026-01-26T10:49:03.054Z _addToast inserting to visible model
[NotificationToast] 2026-01-26T10:49:03.055Z Toast CREATED - index: 0, id: a182e144-..., visible: 3, queued: 0
```

### What to Monitor

| Log Pattern | Indicates |
|-------------|-----------|
| `batchSize: 1` | Notifications arriving one-by-one |
| `batchSize: N` (N > 1) | Notifications arriving in batch |
| `DROPPED oldest queued` | Queue limit reached, dropping old toasts |
| `_removeToast INVALID index!` | Potential race condition |
| Rapid timestamps | High notification throughput |

---

## Files Reference

| File | Layer | Purpose |
|------|-------|---------|
| `App/connections/signalr/SignalRClientService.cpp` | SignalR | WebSocket connection, message routing |
| `App/connections/signalr/parser/AlertZoneNotificationParser.h` | Parser | Parse alert zone notification payload |
| `App/connections/signalr/parser/TruckNotificationSignalRParser.h` | Parser | Parse truck notification payload |
| `App/models/AlertZoneNotificationModel.cpp` | Model | Store and manage alert zone notifications |
| `App/models/TruckNotificationModel.cpp` | Model | Store and manage truck notifications |
| `App/Features/Notifications/NotificationToast.qml` | UI | Toast display with rate limiting |
| `App/Components/ToastNotification.qml` | UI | Individual toast component |
