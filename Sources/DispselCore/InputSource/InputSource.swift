import Foundation

/// Represents a display input source
public struct InputSource {
    /// VCP value for this input source
    let value: UInt16
    /// Canonical name (e.g., "displayport1", "hdmi1")
    let canonicalName: String

    /// Formatted string for output
    /// Format: "canonicalName (0xHH)"
    var formatted: String {
        "\(canonicalName) (0x\(String(format: "%02x", value)))"
    }
}
