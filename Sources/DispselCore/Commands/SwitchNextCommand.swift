import Foundation

/// Cycles to the next input source from a provided list
public struct SwitchNextCommand: Command {
    let inputSourceList: [String]

    public init(inputSourceList: String) {
        self.inputSourceList = inputSourceList.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
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

        if let warning = warning {
            formatter.printWarning(warning)
        }

        // Resolve input source list
        let sources = try inputSourceList.map { try InputSourceResolver.resolve($0) }

        // Special case: single item list (no action)
        guard sources.count > 1 else {
            return
        }

        // Read current input
        let (rawCurrentValue, _) = try DDCManager.readVCP(
            display: display,
            code: VCPCode.inputSource.rawValue
        )

        // Normalize the current value for comparison
        // (Some monitors return duplicated bytes like 0x0f0f)
        let currentSource = InputSourceResolver.fromValue(rawCurrentValue)
        let currentValue = currentSource.value

        // Find current in list
        guard let currentIndex = sources.firstIndex(where: { $0.value == currentValue }) else {
            throw DispselError.currentInputNotInList(current: currentValue)
        }

        // Calculate next index (wrap around)
        let nextIndex = (currentIndex + 1) % sources.count
        let nextSource = sources[nextIndex]

        // Write VCP
        try DDCManager.writeVCP(
            display: display,
            code: VCPCode.inputSource.rawValue,
            value: nextSource.value
        )

        // Success output (use already-computed currentSource)
        formatter.printSuccess("Switched to: \(nextSource.formatted) from: \(currentSource.formatted)")
    }
}
