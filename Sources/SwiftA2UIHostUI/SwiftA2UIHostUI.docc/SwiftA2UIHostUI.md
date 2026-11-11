# ``SwiftA2UIHostUI``

Render A2UI agent-built screens as native SwiftUI.

## Overview

An AI agent describes a screen in [A2UI](https://a2ui.org) 1.0. Feed its messages to an ``A2UISurfaceStore``, and show each surface with ``A2UISurfaceView``. Draw the agent's components with ``A2UICatalog/basic``, which covers all 18 standard components, plus your own components registered in your app's catalog.

```swift
let store = A2UISurfaceStore()
var decoder = A2UILineDecoder()
store.apply(decoder.feed(bytesFromAgent))

let catalog = A2UICatalog(id: "com.example.app:catalog/1", including: .basic)

A2UISurfaceView(store: store, surfaceId: "main", catalogs: [catalog]) { action in
    if let message = action.messageToAgent, let data = try? message.encoded() { send(data) }
}
```

## Topics

### Rendering

- ``A2UISurfaceView``
- ``A2UICatalog``
- ``A2UIComponentContext``
