import Foundation

/// Resolves input source specifiers (keywords, hex, decimal) to VCP values
public class InputSourceResolver {
    /// Keyword to (value, canonical name) mapping
    /// Keywords are case-insensitive
    private static let keywordMap: [String: (UInt16, String)] = [
        // 0x0f - DisplayPort 1
        "displayport1": (0x0f, "displayport1"),
        "displayport": (0x0f, "displayport1"),
        "dp1": (0x0f, "displayport1"),
        "dp": (0x0f, "displayport1"),
        // 0x10 - DisplayPort 2
        "displayport2": (0x10, "displayport2"),
        "dp2": (0x10, "displayport2"),
        // 0x17 - HDMI 1
        "hdmi1": (0x17, "hdmi1"),
        "hdmi": (0x17, "hdmi1"),
        // 0x18 - HDMI 2
        "hdmi2": (0x18, "hdmi2"),
        // 0x25 - Thunderbolt/USB-C 1
        "thunderbolt1": (0x25, "thunderbolt1"),
        "usb1": (0x25, "thunderbolt1"),
        "thunderbolt": (0x25, "thunderbolt1"),
        "usb": (0x25, "thunderbolt1"),
        // 0x27 - Thunderbolt/USB-C 2
        "thunderbolt2": (0x27, "thunderbolt2"),
        "usb2": (0x27, "thunderbolt2"),
    ]

    /// Reverse lookup: value to canonical name
    private static let valueToCanonical: [UInt16: String] = [
        0x0f: "displayport1",
        0x10: "displayport2",
        0x17: "hdmi1",
        0x18: "hdmi2",
        0x25: "thunderbolt1",
        0x27: "thunderbolt2",
    ]

    /// Resolve an input source specifier to an InputSource
    /// - Parameter input: Specifier (keyword, hex with 0x prefix, or decimal)
    /// - Throws: DispselError.invalidInputSource if the specifier is invalid
    /// - Returns: InputSource with resolved value and canonical name
    public static func resolve(_ input: String) throws -> InputSource {
        let trimmed = input.trimmingCharacters(in: .whitespaces)

        // Try hex format (0x prefix)
        if trimmed.lowercased().hasPrefix("0x") {
            let hexString = String(trimmed.dropFirst(2))
            guard let value = UInt16(hexString, radix: 16) else {
                throw DispselError.invalidInputSource(input: input)
            }
            let canonical = valueToCanonical[value] ?? "unknown"
            return InputSource(value: value, canonicalName: canonical)
        }

        // Try decimal
        if let value = UInt16(trimmed) {
            let canonical = valueToCanonical[value] ?? "unknown"
            return InputSource(value: value, canonicalName: canonical)
        }

        // Try keyword (case-insensitive)
        let lowercased = trimmed.lowercased()
        guard let (value, canonical) = keywordMap[lowercased] else {
            throw DispselError.invalidInputSource(input: input)
        }

        return InputSource(value: value, canonicalName: canonical)
    }

    /// Create an InputSource from a VCP value
    /// Used for displaying current input source
    /// - Parameter value: VCP value
    /// - Returns: InputSource with canonical name (or "unknown" if not recognized)
    public static func fromValue(_ value: UInt16) -> InputSource {
        let canonical = valueToCanonical[value] ?? "unknown"
        return InputSource(value: value, canonicalName: canonical)
    }
}
