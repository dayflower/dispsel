import Foundation

/// Lists all connected displays with their properties
public struct ListCommand: Command {
    public init() {}

    public func execute(options: GlobalOptions, formatter: OutputFormatter) throws {
        let displays = try DDCManager.enumerateDisplays()

        for (index, display) in displays.enumerated() {
            print("[Display #\(index + 1)]")
            print("  uuid:            \(display.uuid)")
            print("  manufacturer id: \(display.manufacturerID)")
            print("  product name:    \(display.productName)")
            print("  serial number:   \(display.serialNumber)")

            if let upstream = display.transportUpstream,
               let downstream = display.transportDownstream {
                print("  connection:      \(upstream) -> \(downstream)")
            }

            // Read current input source
            if let (current, _) = try? DDCManager.readVCP(display: display, code: VCPCode.inputSource.rawValue) {
                let source = InputSourceResolver.fromValue(current)
                print("  current input:   \(source.formatted)")
            }

            print()
        }
    }
}
