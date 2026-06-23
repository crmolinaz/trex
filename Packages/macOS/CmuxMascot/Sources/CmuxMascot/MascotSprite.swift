import AppKit
import Foundation

/// The mascot's animation clips. Each clip is an ordered list of authored frame
/// images bundled with the package (see `scripts/generate-trex-sprites.swift`).
enum MascotClip: CaseIterable {
    case idle
    case run
    case blink

    /// Frame asset basenames, in playback order. The `run` cycle revisits the
    /// neutral mid-stride frame so the leg motion reads as a loop.
    var frameNames: [String] {
        switch self {
        case .idle: return ["trex-idle-0", "trex-idle-1"]
        case .run: return ["trex-run-0", "trex-run-1", "trex-run-2", "trex-run-1"]
        case .blink: return ["trex-blink-0"]
        }
    }
}

/// Loads and caches the mascot's frame images from the package bundle.
@MainActor
enum MascotSprite {
    private static var cache: [String: NSImage] = [:]

    /// Every distinct frame name across all clips, in first-seen order.
    static var allFrameNames: [String] {
        var seen = Set<String>()
        var ordered: [String] = []
        for clip in MascotClip.allCases {
            for name in clip.frameNames where seen.insert(name).inserted {
                ordered.append(name)
            }
        }
        return ordered
    }

    /// Eagerly load every frame so the render path never touches disk.
    static func preload() {
        for name in allFrameNames where cache[name] == nil {
            if let image = load(name) { cache[name] = image }
        }
    }

    static func image(named name: String) -> NSImage? {
        cache[name] ?? load(name)
    }

    private static func load(_ name: String) -> NSImage? {
        guard let url = bundledURL(forFrame: name) else { return nil }
        return NSImage(contentsOf: url)
    }

    /// Resolves a frame's bundled URL. `nonisolated` so tests can assert every
    /// declared frame ships in the package without hopping to the main actor.
    nonisolated static func bundledURL(forFrame name: String) -> URL? {
        Bundle.module.url(forResource: name, withExtension: "png")
    }
}
