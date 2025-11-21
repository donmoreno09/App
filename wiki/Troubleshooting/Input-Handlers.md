# Input Handlers

[[_TOC_]]

Input handlers in QML are used to handle input events such as keyboard, mouse, touch, stylus, etc. They're non-visual QML types (`TapHandler`, `DragHandler`, `WheelHandler`, ...) that you attach to an `Item` to make it react to input.

Before, pointer input was usually handled with `MouseArea` (and `Flickable`), but those are _items_ (visual) and heavier. Input handlers were introduced so you can have many more of them without blowing up memory: one handler per "behavior" instead of one `MouseArea` per thing.

From the docs on [Qt Quick Input Handlers](https://doc.qt.io/qt-6/qtquickhandlers-index.html):

> In contrast to event-handling items, such as **[MouseArea](https://doc.qt.io/qt-6/qml-qtquick-mousearea.html)** and **[Flickable](https://doc.qt.io/qt-6/qml-qtquick-flickable.html)**, input handlers are explicitly non-visual, require less memory and are intended to be used in greater numbers: one handler instance per aspect of interaction.

## Pointer Grab

An important concept with input handlers is the idea of a **grab**. The official docs have a section on [Pointer Grab](https://doc.qt.io/qt-6/qtquickhandlers-index.html#pointer-grab), but it's not super intuitive at first, so I will try in this section to explain it.

### What's a grab?

A grab is basically **"who owns this pointer for this 'press -> move -> release' sequence"**. A **pointer** here is "this specific mouse button press" or "this specific touch point". And a grab just means: "send all future events for this pointer to _me_."

Qt items can only take **exclusive** grabs. Pointer handlers can do two kinds of grabs: **passive** and **exclusive**. So don't think _"grab == input event itself"_, it's more _"grab == the association between a pointer and whoever is handling it"_.

### Passive Grab

A **passive grab** is _"I want to keep watching this pointer, but I'm not blocking anyone else."_  Multiple handlers can have a passive grab on the _same_ pointer. If a handler takes a _passive grab_, Qt guarantees that handler will keep getting updates and the final release event for that pointer, _even if_ something else later takes exclusive grab.

Therefore, a passive grab means a handler is subscribed to that pointer's life cycle. Other handlers can still take over exclusively, but the passive one just keeps getting notifications.

To control how an input handler manages its grabs, they have a property called `grabPermissions` and they **do not** affect passive grabs directly: they only kick in when someone wants to switch to or negotiate **exclusive grab**.

### Exclusive Grab

An **exclusive grab** is _"I'm now the main handler for this pointer"_. The handler with exclusive grab becomes the primary receiver of future events for that pointer. Handlers that _already_ had a passive grab will still get updates, but everyone else basically stops seeing that pointer.

For example:

```qml
TapHandler {
    gesturePolicy: TapHandler.ReleaseWithinBounds
}
```

`gesturePolicy` is specific to `TapHandler`, but with `TapHandler.ReleaseWithinBounds`, the tap handler takes **exclusive grab on press** (as long as the tap was made within bounds), so this tap is effectively "owned" by that handler.

Effect in practice:

1. The top-most `TapHandler` using `ReleaseWithinBounds` will take exclusive grab.
2. Another `TapHandler` _behind it_ won't get the tap anymore.
3. Other handler types (`DragHandler`, `WheelHandler`, etc.) can still react to their own events if they are bound to the same pointer in ways allowed by their own grab logic.

### How are events propagated?

Pointer events (press) are delivered **in top-down Z order**, meaning the top-most child component's handlers are called first, and then its parent and so on.

So imagine something like:

```qml
Item {
    TapHandler {
        id: innerHandler
        gesturePolicy: TapHandler.ReleaseWithinBounds
    }
}

TapHandler {
    id: outerHandler
    gesturePolicy: TapHandler.ReleaseWithinBounds
}
```

Imagine `Item` is a modal that visually sits on top of the thing that has `outerHandler`, and both handlers cover the same region:

1. The press arrives.
2. Qt visits the topmost item first (`Item` and its handlers) which is the `innerHandler`.
3. Because `innerHandler` uses `ReleaseWithinBounds`, it takes **exclusive grab** right away.
4. `outerHandler` _never_ even gets a chance to claim exclusive grab for that tap.

Now compare this with default gesture policy:

```qml
Item {
    TapHandler {
        id: innerHandler
    }
}

TapHandler {
    id: outerHandler
}
```

If you don't specify `gesturePolicy`, the default is `TapHandler.DragThreshold`, which is designed to work using **only a passive grab**, so it doesn't block other handlers.

In this case:

1. Neither `innerHandler` nor `outerHandler` takes exclusive grab.
2. Both can tap just fine (as long as nothing else tries to take exclusive grab for that pointer).
3. You can think of them as both "listening in" on the same tap, instead of fighting over ownership.

## Conclusion

Understanding how input handlers work in Qt, especially passive vs exclusive grabs, makes it much easier to reason about _"why is this event leaking through?"_ or _"why doesn't this thing react when there's a window above it?"_

Typical use cases:

- Stopping events from propagating to things behind a custom floating window (title bars, dialogs, overlays).
- Making sure a side panel eats clicks so they don't hit the map or content behind it.
- Letting some handlers passively _observe_ input while another one owns it.

If you're debugging weird interactions, always check the `grabPermissions` docs for the handler you're using. For example, `TapHandler.grabPermissions` is documented here:
[https://doc.qt.io/qt-6/qml-qtquick-taphandler.html#grabPermissions-prop](https://doc.qt.io/qt-6/qml-qtquick-taphandler.html#grabPermissions-prop)
