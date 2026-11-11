import Foundation
import SwiftUI
import Testing
@testable import SwiftA2UIHostUI

// The README's A2UI quickstart, compiled and run. Keep the two in sync.

/// Holds every surface the agent has sent. Feed it the agent's bytes as they arrive.
@MainActor
final class AgentScreens {
    let store = A2UISurfaceStore()
    private var decoder = A2UILineDecoder()

    func receive(_ bytes: some Sequence<UInt8>) {
        store.apply(decoder.feed(bytes))   // any chunking: a message applies once its line is complete
    }
}

private struct Stay: Decodable {
    let name: String
    let price: String?
}

private struct StayCard: View {
    let stay: Stay
    var body: some View { Text(stay.name) }
}

/// Your catalog: the standard components plus your own, under your own id.
@MainActor
private let catalog = A2UICatalog(id: "com.example.travel:catalog/1", including: .basic)
    .registering(A2UIComponentSchema(name: "StayCard", properties: [
        .init("name", .string, required: true),
        .init("price", .string),
    ])) { context in
        if let stay = context.props(as: Stay.self) { StayCard(stay: stay) }
    }

private struct AgentSurface: View {
    let screens: AgentScreens
    let surfaceId: String
    let sendToAgent: (Data) -> Void

    var body: some View {
        A2UISurfaceView(store: screens.store, surfaceId: surfaceId, catalogs: [catalog]) { action in
            // Taps become messages for the agent. Side effects such as openUrl are yours to allow.
            if let message = action.messageToAgent, let data = try? message.encoded() {
                sendToAgent(data)
            }
        }
    }
}

@Suite("README snippets")
@MainActor
struct ReadmeSnippetTests {
    @Test func quickstartRendersACustomComponentFromChunkedBytes() throws {
        let screens = AgentScreens()
        let stream = """
        {"version":"1.0","createSurface":{"surfaceId":"trip","catalogId":"com.example.travel:catalog/1","components":[{"id":"root","component":"Column","children":["stay"]},{"id":"stay","component":"StayCard","name":{"@path":"/stay/name"},"price":"€148"}],"dataModel":{"stay":{"name":"Alfama River Suite"}}}}

        """
        for chunk in Array(stream.utf8).chunked(7) { screens.receive(chunk) }
        let surface = try #require(screens.store.surfaces["trip"])
        let tree = try #require(surface.resolvedTree())
        let stay = try #require(tree.children.first?.component)
        #expect(catalog.answers(to: try #require(surface.catalogId)))
        #expect(catalog.supports(stay))
        #expect(surface.string("name", of: stay) == "Alfama River Suite")
        _ = AgentSurface(screens: screens, surfaceId: "trip", sendToAgent: { _ in }).body

        let instructions = catalog.manifest(version: "1").agentInstructions()
        #expect(instructions.contains("- StayCard (v1)"))
        #expect(catalog.manifest(version: "1").rendererCapabilities["1.0"]?["supportedCatalogIds"] == ["com.example.travel:catalog/1"])
    }
}

private extension Array {
    func chunked(_ size: Int) -> [ArraySlice<Element>] {
        stride(from: 0, to: count, by: size).map { self[$0..<Swift.min($0 + size, count)] }
    }
}
