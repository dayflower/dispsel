import Foundation
import AppleSiliconDDC

/// Manager for DDC/CI communication with displays
public class DDCManager {
    /// Enumerate all connected displays
    /// - Throws: DispselError.noDisplaysFound if no displays are detected
    /// - Returns: Array of Display objects
    public static func enumerateDisplays() throws -> [Display] {
        let services = AppleSiliconDDC.getIoregServicesForMatching()

        guard !services.isEmpty else {
            throw DispselError.noDisplaysFound
        }

        return services.compactMap { service -> Display? in
            guard let ioService = service.service else { return nil }

            return Display(
                uuid: service.edidUUID,
                manufacturerID: service.manufacturerID,
                productName: service.productName,
                serialNumber: service.alphanumericSerialNumber,
                transportUpstream: service.transportUpstream.isEmpty ? nil : service.transportUpstream,
                transportDownstream: service.transportDownstream.isEmpty ? nil : service.transportDownstream,
                service: ioService
            )
        }
    }

    /// Read a VCP code value from a display
    /// - Parameters:
    ///   - display: Target display
    ///   - code: VCP code to read
    /// - Throws: DispselError.vcpReadFailed if read operation fails
    /// - Returns: Tuple of (current value, maximum value)
    public static func readVCP(display: Display, code: UInt8) throws -> (current: UInt16, max: UInt16) {
        guard let result = AppleSiliconDDC.read(service: display.service, command: code) else {
            throw DispselError.vcpReadFailed(code: code)
        }
        return result
    }

    /// Write a value to a VCP code on a display
    /// - Parameters:
    ///   - display: Target display
    ///   - code: VCP code to write
    ///   - value: Value to write
    /// - Throws: DispselError.vcpWriteFailed if write operation fails
    public static func writeVCP(display: Display, code: UInt8, value: UInt16) throws {
        let success = AppleSiliconDDC.write(service: display.service, command: code, value: value)
        guard success else {
            throw DispselError.vcpWriteFailed(code: code, value: value)
        }
    }
}
