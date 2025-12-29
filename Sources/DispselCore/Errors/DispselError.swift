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

    public var errorDescription: String? {
        switch self {
        case .noDisplaysFound:
            return "No displays found"
        case .noMatchingDisplay(let specifier):
            return "No display matching '\(specifier)' found"
        case .multipleMatchingDisplays(let count, let specifier):
            return "Multiple displays (\(count)) matching '\(specifier)' found"
        case .vcpReadFailed(let code):
            return "Failed to read VCP code 0x\(String(format: "%02x", code))"
        case .vcpWriteFailed(let code, let value):
            return "Failed to write VCP code 0x\(String(format: "%02x", code)) with value 0x\(String(format: "%04x", value))"
        case .invalidInputSource(let input):
            return "Invalid input source: \(input)"
        case .currentInputNotInList(let current):
            return "Current input source 0x\(String(format: "%02x", current)) is not in the provided list"
        case .invalidDisplaySpecifier(let specifier):
            return "Invalid display specifier: \(specifier)"
        }
    }
}
