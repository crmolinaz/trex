import AppKit
import SwiftUI

/// Owns the mascot's floating panel. The panel is a chrome-less, non-activating
/// `NSPanel` at floating level so the mascot sits above other windows without
/// stealing focus from the terminal, and survives across splits/workspaces.
///
/// It is `.titled` with a hidden/transparent title bar rather than `.borderless`:
/// a borderless window throws from `-[NSWindow _postWindowNeedsUpdateConstraints]`
/// when SwiftUI's hosting view drives auto-layout. A titled window with
/// `.fullSizeContentView` gives the same frameless look without the crash.
@MainActor
final class MascotWindowController {
    private let animator: MascotAnimator
    private var panel: NSPanel?

    init(animator: MascotAnimator) {
        self.animator = animator
    }

    var isVisible: Bool { panel?.isVisible ?? false }

    func show() {
        if let panel {
            panel.orderFrontRegardless()
            return
        }
        let size = NSSize(width: 168, height: 184)
        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        panel.contentViewController = NSHostingController(rootView: MascotView(animator: animator))
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.identifier = NSUserInterfaceItemIdentifier("cmux.mascot.panel")

        positionBottomTrailing(panel)
        panel.orderFrontRegardless()
        self.panel = panel
    }

    func hide() {
        panel?.orderOut(nil)
        panel?.close()
        panel = nil
    }

    private func positionBottomTrailing(_ panel: NSPanel) {
        guard let screen = NSScreen.main else {
            panel.center()
            return
        }
        let visible = screen.visibleFrame
        let margin: CGFloat = 24
        let origin = NSPoint(
            x: visible.maxX - panel.frame.width - margin,
            y: visible.minY + margin
        )
        panel.setFrameOrigin(origin)
    }
}
