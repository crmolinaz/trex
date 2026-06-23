import CmuxCommandPalette
import CmuxMascot
import Foundation

extension ContentView {
    static func commandPaletteMascotContributions() -> [CommandPaletteCommandContribution] {
        func constant(_ value: String) -> (CommandPaletteContextSnapshot) -> String {
            { _ in value }
        }

        return [
            CommandPaletteCommandContribution(
                commandId: "palette.mascot",
                title: constant(String(localized: "command.mascot.title", defaultValue: "/mascot")),
                subtitle: constant(String(localized: "command.mascot.subtitle", defaultValue: "Mascot")),
                keywords: ["mascot", "rex", "trex", "dino", "dinosaur", "/mascot"]
            ),
        ]
    }

    func registerMascotCommandHandlers(_ registry: inout CommandPaletteHandlerRegistry) {
        registry.register(commandId: "palette.mascot") {
            AppDelegate.shared?.mascotController.toggle()
        }
    }
}
