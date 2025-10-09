
# InputShield

[[_TOC_]]

## Overview

`InputShield` is a component that prevents tap, drag, pinch, and wheel events from propagating to items beneath it.

This is particularly helpful when you have overlays or UI panels above a map: you can block interactions from reaching the map.

> Note: `InputShield` is designed with the `Map` component in mind, so its semantics assume that typical map input handlers lie “below.”

## Usage

Insert an `InputShield` over whatever area you want to shield. **It must cover that area fully** (either via anchors or explicit width/height), so that events hitting that area are caught.

```qml
Item {
    // ...
    UI.InputShield {
        anchors.fill: parent
    }
}

Item {
    // ...
    UI.InputShield {
        width: parent.width
        height: parent.height
    }
}
```

## Motivation and Behavior

In Qt, input handling involves two key ideas:

1. **Passive vs exclusive pointer grabs**
2. **Z-ordering rather than parent/child propagation**

### Passive vs exclusive grabs

- A **passive grab** means a handler *listens* to the event but doesn’t block propagation.
- An **exclusive grab** "takes over" the event, preventing further delivery to handlers underneath.

Handlers like `TapHandler`, `DragHandler`, `WheelHandler` etc. can be configured via properties such as `gesturePolicy` (in `TapHandler`) and `grabPermissions` to decide whether they act passively or exclusively.

For instance, in `TapHandler`, the default `gesturePolicy` is `DragThreshold`, which leads it to use a passive grab. If you want it to take an exclusive grab (i.e. stop propagation), you might use `TapHandler.ReleaseWithinBounds` or `TapHandler.WithinBounds`. ([TapHandler QML Type](https://doc.qt.io/qt-6/qml-qtquick-taphandler.html#gesturePolicy-prop))

### Z-order vs hierarchical propagation

Unlike web-style event bubbling (child -> parent -> ancestor), Qt delivers input based on **Z-order**: the highest-z items get the first chance to handle the event, regardless of parent/child relations.

If a handler in a higher-Z item takes an exclusive grab, lower ones won’t get the event. If it uses a passive grab, the event can still be propagated downward.

Because of this, `InputShield` works by residing on top (with high Z) and grabbing inputs exclusively, so the ones below (e.g. map handlers) never see them.

### Nuances

- Even if a handler claims to _"take an exclusive grab,"_ it doesn’t always block **all** other handlers of different types (e.g. a `DragHandler` might not block `WheelHandler`). There seems to be a _"domain"_ for each handler type.
- If a component has both a `MouseArea` and `TapHandler`, only `MouseArea` will handle the click/tap event. The `TapHandler` won't even receive it.
- It is **recommended** to use input handlers than the legacy event handlers such as `MouseArea` or `Flickable`. (For more information, see [Mouse Events](https://doc.qt.io/qt-6/qtquick-input-mouseevents.html) and [Qt Quick Input Handlers](https://doc.qt.io/qt-6/qtquickhandlers-index.html))