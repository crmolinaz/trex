import AppKit
import SwiftUI

/// Owns the mascot's floating panel. The panel is a frameless, non-activating
/// `NSPanel` at floating level so the mascot sits above other windows without
/// stealing focus from the terminal, and survives across splits/workspaces.
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
        let size = NSSize(width: 180, height: 200)
        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.identifier = NSUserInterfaceItemIdentifier("cmux.mascot.panel")

        let hosting = NSHostingView(rootView: MascotView(animator: animator))
        hosting.frame = NSRect(origin: .zero, size: size)
        panel.contentView = hosting

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
