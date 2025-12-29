import Foundation

/// Represents criteria for selecting a display
public struct DisplaySpecifier: Sendable {
    /// Types of criteria for matching displays
    enum Criterion: Sendable {
        /// UUID match (case-insensitive, hyphens optional)
        case uuid(String)
        /// Product name exact match (case-sensitive)
        case productName(String)
        /// Product name partial match (case-insensitive)
        case productNameLike(String)
        /// Serial number exact match (case-sensitive)
        case serialNumber(String)
    }

    /// List of criteria (combined with AND logic)
    let criteria: [Criterion]

    /// Parse a display specifier from command-line string
    ///
    /// Syntax examples:
    /// - `uuid=ABC123`
    /// - `productNameLike=U4025QW:serialNumber=99XX99`
    /// - `ABC123` (no field name defaults to UUID)
    ///
    /// - Parameter input: Specifier string
    /// - Throws: DispselError.invalidDisplaySpecifier if parsing fails
    /// - Returns: DisplaySpecifier with parsed criteria
    public static func parse(_ input: String) throws -> DisplaySpecifier {
        let parts = input.split(separator: ":").map(String.init)
        var criteria: [Criterion] = []

        for part in parts {
            if part.contains("=") {
                let components = part.split(separator: "=", maxSplits: 1).map(String.init)
                guard components.count == 2 else {
                    throw DispselError.invalidDisplaySpecifier(specifier: input)
                }

                let key = components[0].trimmingCharacters(in: .whitespaces)
                let value = components[1].trimmingCharacters(in: .whitespaces)

                switch key {
                case "uuid":
                    criteria.append(.uuid(value))
                case "productName":
                    criteria.append(.productName(value))
                case "productNameLike":
                    criteria.append(.productNameLike(value))
                case "serialNumber":
                    criteria.append(.serialNumber(value))
                default:
                    throw DispselError.invalidDisplaySpecifier(specifier: input)
                }
            } else {
                // No field name = UUID
                criteria.append(.uuid(part.trimmingCharacters(in: .whitespaces)))
            }
        }

        guard !criteria.isEmpty else {
            throw DispselError.invalidDisplaySpecifier(specifier: input)
        }

        return DisplaySpecifier(criteria: criteria)
    }
}
