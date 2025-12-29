import Foundation

/// Switches to a specific input source
public struct SwitchCommand: Command {
    let inputSourceSpec: String

    public init(inputSourceSpec: String) {
        self.inputSourceSpec = inputSourceSpec
    }

    public func execute(options: GlobalOptions, formatter: OutputFormatter) throws {
        // Enumerate displays
        let displays = try DDCManager.enumerateDisplays()

        // Select target display
        let (display, warning) = try DisplayMatcher.selectDisplay(
            from: displays,
            specifier: options.displaySpecifier
        )

        // Print target info
        formatter.printInfo("Target: \(display.displayName)")

        // Print warning if multiple matches
        if let warning = warning {
            formatter.printWarning(warning)
        }

        // Resolve input source
        let inputSource = try InputSourceResolver.resolve(inputSourceSpec)

        // Write VCP
        try DDCManager.writeVCP(
            display: display,
            code: VCPCode.inputSource.rawValue,
            value: inputSource.value
        )

        // Success output
        formatter.printSuccess("Switched to: \(inputSource.formatted)")
    }
}
