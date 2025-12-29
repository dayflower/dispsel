import Foundation
import IOKit

// IOAVService is an alias for AnyObject
typealias IOAVService = AnyObject

/// Represents a physical display device
public struct Display {
    /// Unique identifier (EDID UUID)
    let uuid: String
    /// Manufacturer identifier (e.g., "DEL" for Dell)
    let manufacturerID: String
    /// Product name
    let productName: String
    /// Alphanumeric serial number
    let serialNumber: String
    /// Upstream transport type (e.g., "DP", "HDMI")
    let transportUpstream: String?
    /// Downstream transport type
    let transportDownstream: String?
    /// Internal IOAVService reference for DDC communication
    let service: IOAVService

    /// Formatted display name for output
    /// Format: "(manufacturerID) productName serialNumber"
    var displayName: String {
        "(\(manufacturerID)) \(productName) \(serialNumber)"
    }
}
