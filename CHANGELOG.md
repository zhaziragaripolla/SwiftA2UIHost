# Changelog

All notable changes to SwiftA2UIHost. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org).

## [Unreleased]

### Added
- First release. Native SwiftUI rendering for A2UI 1.0, moved out of FluidStreamKit's v2 preview into its own package.
- `SwiftA2UIHost` (protocol and state, no UI):
  - A2UI 1.0 decoding, with v0.9 and v0.9.1 messages upgraded on decode.
  - A byte-level JSONL decoder.
  - Surfaces with bindings, list templates, and cycle and size limits.
  - All 14 basic-catalog functions.
  - `@checks` validation.
  - Function calls in both directions, with `allowedCallers` and `requiresUserActivation` enforced.
  - Actions, and renderer messages back to the agent.
  - Composition rules.
- `SwiftA2UIHostUI`:
  - `A2UISurfaceView`, with mixed catalogs resolved per component.
  - `A2UICatalog`, with all 18 basic components as native SwiftUI views.
  - Custom components.
  - `@accessibility` mapped to VoiceOver.
  - `A2UICatalog.extended`, which adds a data-driven `Table`.
- Catalog schemas, versions and fallbacks: `A2UIComponentSchema`, `A2UICatalogManifest` (with agent instructions, 1.0 catalog definitions and renderer capabilities), and `A2UIDowncompiler`.
- A conformance suite that runs Google's 43 official A2UI 1.0 examples end to end.
- `Examples/TravelDemo`, `llms.txt`, and a Claude Code plugin with a skill for the package.
