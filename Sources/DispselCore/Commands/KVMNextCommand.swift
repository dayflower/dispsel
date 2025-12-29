import Foundation

/// Switches KVM to the next input (for PIP/PBP mode)
public struct KVMNextCommand: Command {
    public init() {}

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

        // Write VCP 0xE7 = 0xff00
        try DDCManager.writeVCP(
            display: display,
            code: VCPCode.kvmSwitch.rawValue,
            value: VCPValue.kvmNext
        )

        // Silent success (no output even without -q)
    }
}
