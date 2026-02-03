import Foundation

/// Lists all connected displays with their properties
public struct ListCommand: Command {
    public init() {}

    public func execute(options: GlobalOptions, formatter: OutputFormatter) throws {
        let displays = try DDCManager.enumerateDisplays()

        for (index, display) in displays.enumerated() {
            formatter.printInfo("[Display #\(index + 1)]")
            formatter.printInfo("  uuid:            \(display.uuid)")
            formatter.printInfo("  manufacturer id: \(display.manufacturerID)")
            formatter.printInfo("  product name:    \(display.productName)")
            formatter.printInfo("  serial number:   \(display.serialNumber)")

            if let upstream = display.transportUpstream,
               let downstream = display.transportDownstream {
                formatter.printInfo("  connection:      \(upstream) -> \(downstream)")
            }

            // Read current input source
            do {
                let (current, _) = try DDCManager.readVCP(display: display, code: VCPCode.inputSource.rawValue)
                let source = InputSourceResolver.fromValue(current)
                formatter.printInfo("  current input:   \(source.formatted)")
            } catch {
                // Silently skip if VCP read fails (display may not support input source query)
            }

            // Read current volume
            do {
                let (current, max) = try DDCManager.readVCP(display: display, code: VCPCode.volume.rawValue)
                formatter.printInfo("  volume:          \(current) (max: \(max))")
            } catch {
                // Silently skip if VCP read fails (display may not support volume control)
            }

            formatter.printInfo("")
        }
    }
}
