import SwiftUI

/// Renders the mascot's current frame as crisp pixel art. Observes the animator
/// so the image swaps as the frame index advances.
struct MascotView: View {
    @Bindable var animator: MascotAnimator

    var body: some View {
        image
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .padding(8)
            .frame(width: 168, height: 184)
            .accessibilityLabel(Text(
                String(
                    localized: "mascot.accessibilityLabel",
                    defaultValue: "T-Rex mascot",
                    bundle: .module
                )
            ))
    }

    private var image: Image {
        if let nsImage = MascotSprite.image(named: animator.currentFrameName) {
            return Image(nsImage: nsImage)
        }
        return Image(systemName: "questionmark.square.dashed")
    }
}
