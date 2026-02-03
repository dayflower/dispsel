import Foundation

/// Errors that can occur during dispsel operations
public enum DispselError: LocalizedError {
    case noDisplaysFound
    case noMatchingDisplay(specifier: String)
    case multipleMatchingDisplays(count: Int, specifier: String)
    case vcpReadFailed(code: UInt8)
    case vcpWriteFailed(code: UInt8, value: UInt16)
    case invalidInputSource(input: String)
    case currentInputNotInList(current: UInt16)
    case invalidDisplaySpecifier(specifier: String)
    case invalidVolumeValue(value: Int, max: UInt16)

    public var errorDescription: String? {
        switch self {
        case .noDisplaysFound:
            "No displays found"
        case let .noMatchingDisplay(specifier):
            "No display matching '\(specifier)' found"
        case let .multipleMatchingDisplays(count, specifier):
            "Multiple displays (\(count)) matching '\(specifier)' found"
        case let .vcpReadFailed(code):
            "Failed to read VCP code 0x\(String(format: "%02x", code))"
        case let .vcpWriteFailed(code, value):
            "Failed to write VCP code 0x\(String(format: "%02x", code)) with value 0x\(String(format: "%04x", value))"
        case let .invalidInputSource(input):
            "Invalid input source: \(input)"
        case let .currentInputNotInList(current):
            "Current input source 0x\(String(format: "%02x", current)) is not in the provided list"
        case let .invalidDisplaySpecifier(specifier):
            "Invalid display specifier: \(specifier)"
        case let .invalidVolumeValue(value, max):
            "Invalid volume value: \(value). Must be between 0 and \(max)"
        }
    }
}
