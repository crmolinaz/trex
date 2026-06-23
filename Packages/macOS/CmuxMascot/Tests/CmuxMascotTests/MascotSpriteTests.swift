import Testing
@testable import CmuxMascot

struct MascotSpriteTests {
    @Test
    func everyClipFrameShipsInTheBundle() {
        for clip in MascotClip.allCases {
            for name in clip.frameNames {
                #expect(
                    MascotSprite.bundledURL(forFrame: name) != nil,
                    "missing bundled frame asset: \(name)"
                )
            }
        }
    }

    @MainActor
    @Test
    func animatorAdvancesAndWrapsWithinClip() {
        let animator = MascotAnimator()
        animator.setClip(.run)
        let count = MascotClip.run.frameNames.count
        #expect(count > 1)
        #expect(animator.frameIndex == 0)

        for step in 1...count {
            animator.advance()
            #expect(animator.frameIndex == step % count)
        }
        // A full lap returns to the first frame.
        #expect(animator.frameIndex == 0)
    }

    @MainActor
    @Test
    func switchingClipResetsToFirstFrame() {
        let animator = MascotAnimator()
        animator.setClip(.run)
        animator.advance()
        #expect(animator.frameIndex == 1)

        animator.setClip(.idle)
        #expect(animator.frameIndex == 0)
        #expect(animator.currentFrameName == MascotClip.idle.frameNames.first)
    }
}
