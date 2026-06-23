import Foundation

/// Public entry point for the T-Rex mascot.
///
/// The app target owns a single instance (the composition root) and drives it —
/// there is deliberately no shared singleton here, so the module stays free of
/// app-global state and is easy to lift into another project.
///
/// Future hearts/quest behavior attaches here: a `MascotState` value plus a
/// hydration-quest loop (the same cancellable `Task`/`Clock` primitive the
/// animator uses) would hang off this controller without touching the app.
@MainActor
public final class MascotController {
    private let animator: MascotAnimator
    private let windowController: MascotWindowController

    public init() {
        let animator = MascotAnimator()
        self.animator = animator
        self.windowController = MascotWindowController(animator: animator)
        MascotSprite.preload()
    }

    public var isShowing: Bool { windowController.isVisible }

    /// Shows the mascot: it runs in, then settles into an idle loop.
    public func show() {
        windowController.show()
        animator.setClip(.run)
        animator.start()
        Task { [weak animator] in
            try? await Task.sleep(for: .milliseconds(1200))
            animator?.setClip(.idle)
        }
    }

    /// Hides the mascot and stops the animation loop.
    public func hide() {
        animator.stop()
        windowController.hide()
    }

    public func toggle() {
        if isShowing {
            hide()
        } else {
            show()
        }
    }
}
