import Foundation

/// Sets the display volume to a specified value
public struct VolumeCommand: Command {
    let volumeValue: Int

    public init(volumeValue: Int) {
        self.volumeValue = volumeValue
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

        // Read current volume to get max value
        let (_, maxVolume) = try DDCManager.readVCP(
            display: display,
            code: VCPCode.volume.rawValue
        )

        // Validate volume value
        guard volumeValue >= 0 && volumeValue <= Int(maxVolume) else {
            throw DispselError.invalidVolumeValue(value: volumeValue, max: maxVolume)
        }

        // Write VCP
        try DDCManager.writeVCP(
            display: display,
            code: VCPCode.volume.rawValue,
            value: UInt16(volumeValue)
        )

        // Success output
        formatter.printSuccess("Volume set to: \(volumeValue)")
    }
}
