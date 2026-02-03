import Foundation
import IOKit

/// IOAVService is an alias for AnyObject
typealias IOAVService = AnyObject

/// Represents a physical display device
public struct Display {
    /// Unique identifier (EDID UUID)
    public let uuid: String
    /// Manufacturer identifier (e.g., "DEL" for Dell)
    public let manufacturerID: String
    /// Product name
    public let productName: String
    /// Alphanumeric serial number
    public let serialNumber: String
    /// Upstream transport type (e.g., "DP", "HDMI")
    public let transportUpstream: String?
    /// Downstream transport type
    public let transportDownstream: String?
    /// Internal IOAVService reference for DDC communication
    let service: IOAVService

    /// Formatted display name for output
    /// Format: "(manufacturerID) productName serialNumber"
    public var displayName: String {
        "(\(manufacturerID)) \(productName) \(serialNumber)"
    }
}
