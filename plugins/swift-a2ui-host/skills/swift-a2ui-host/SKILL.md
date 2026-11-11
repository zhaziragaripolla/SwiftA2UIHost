---
name: swift-a2ui-host
description: Renders A2UI agent-built screens natively in a SwiftUI or iOS app with the SwiftA2UIHost Swift package. Use when an iOS, macOS or visionOS app needs to show A2UI surfaces (createSurface, updateComponents, updateDataModel), generative or agent-driven UI from an LLM agent, server-driven agent UI, or custom A2UI catalog components in SwiftUI.
---

# SwiftA2UIHost

SwiftA2UIHost renders [A2UI](https://a2ui.org) 1.0 (Google's declarative agent-UI format) as native SwiftUI. It implements all 18 basic-catalog components, all 14 basic functions, bindings, checks, function calls in both directions, and mixed catalogs. v0.9 messages are upgraded on decode. It is not a transport: the app brings its own connection to the agent.

Full reference: https://github.com/zhaziragaripolla/SwiftA2UIHost/blob/main/llms.txt

## Steps

1. **Add the package** and depend on the `SwiftA2UIHostUI` product:
   ```swift
   .package(url: "https://github.com/zhaziragaripolla/SwiftA2UIHost.git", from: "1.0.0"),
   ```

2. **Keep one store and one decoder** per conversation, on the main actor. Feed the agent's JSONL bytes as they arrive, in any chunking:
   ```swift
   let store = A2UISurfaceStore()
   var decoder = A2UILineDecoder()
   store.apply(decoder.feed(bytes))
   ```
   For messages that are already JSON values, use `store.apply(try A2UIMessage.decode(value))`.

3. **Build the app's catalog** under the app's own id, starting from the basic catalog. Describe each custom component with a schema so the agent learns it:
   ```swift
   let catalog = A2UICatalog(id: "com.example.app:catalog/1", including: .basic)
       .registering(A2UIComponentSchema(name: "ProductCard", properties: [.init("title", .string, required: true)])) { context in
           if let product = context.props(as: Product.self) { ProductCard(product) }
       }
   ```

4. **Show a surface**, and send taps to the agent:
   ```swift
   A2UISurfaceView(store: store, surfaceId: id, catalogs: [catalog]) { action in
       if let message = action.messageToAgent, let data = try? message.encoded() { send(data) }
   }
   ```
   Also set `store.onMessageToAgent` to send function responses and errors.

5. **Tell the agent what exists:** put `catalog.manifest(version:).agentInstructions()` in its prompt, and send `manifest.rendererCapabilities` in the transport metadata.

## Rules

- A2UI 1.0 bindings are `{"@path": "/x"}` and calls are `{"@call": "name", "args": {…}}`. A plain `{"path": …}` is data, except in a list template's `children`.
- The agent's output is untrusted. Never pass agent URLs or values to `openURL`, purchases or other side effects without the app's own checks. `.localFunction` actions are requests: the app decides.
- Register side-effecting app functions as `.effect` with `requiresUserActivation: true`, so they run only from a tap and never from the agent or a binding.
- Each component is drawn by the catalog its `@catalogId`, or the surface's `catalogId`, names. If the surface's catalog isn't in `catalogs:`, nothing is drawn. Make the ids match.
- Check `store.diagnostics` when something doesn't appear.
