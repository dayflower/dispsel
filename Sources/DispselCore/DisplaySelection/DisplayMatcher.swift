import Foundation

/// Handles display selection based on specifiers
public class DisplayMatcher {
    /// Select a display from the list based on specifier
    ///
    /// Behavior:
    /// - If no specifier: use first display
    /// - If specifier provided: filter by criteria (AND logic)
    /// - Error if no matches found
    /// - Warning if multiple matches (uses first)
    ///
    /// - Parameters:
    ///   - displays: List of available displays
    ///   - specifier: Optional display specifier
    /// - Throws: DispselError if no displays or no matches found
    /// - Returns: Tuple of (selected display, optional warning message)
    public static func selectDisplay(
        from displays: [Display],
        specifier: DisplaySpecifier?
    ) throws -> (display: Display, warning: String?) {
        guard !displays.isEmpty else {
            throw DispselError.noDisplaysFound
        }

        // No specifier: use first display
        guard let specifier = specifier else {
            return (displays[0], nil)
        }

        // Filter by criteria
        let matches = displays.filter { display in
            specifier.criteria.allSatisfy { criterion in
                matchesCriterion(display: display, criterion: criterion)
            }
        }

        if matches.isEmpty {
            throw DispselError.noMatchingDisplay(specifier: describeSpecifier(specifier))
        }

        let warning: String? = matches.count > 1
            ? "Multiple displays (\(matches.count)) matched. Using first one."
            : nil

        return (matches[0], warning)
    }

    /// Check if a display matches a single criterion
    private static func matchesCriterion(display: Display, criterion: DisplaySpecifier.Criterion) -> Bool {
        switch criterion {
        case .uuid(let pattern):
            // Case-insensitive, hyphens optional
            let normalizedPattern = pattern.replacingOccurrences(of: "-", with: "").lowercased()
            let normalizedUUID = display.uuid.replacingOccurrences(of: "-", with: "").lowercased()
            return normalizedUUID == normalizedPattern

        case .productName(let name):
            // Exact match, case-sensitive
            return display.productName == name

        case .productNameLike(let pattern):
            // Partial match, case-insensitive
            return display.productName.lowercased().contains(pattern.lowercased())

        case .serialNumber(let serial):
            // Exact match, case-sensitive
            return display.serialNumber == serial
        }
    }

    /// Create a human-readable description of the specifier
    private static func describeSpecifier(_ specifier: DisplaySpecifier) -> String {
        specifier.criteria.map { criterion in
            switch criterion {
            case .uuid(let v): return "uuid=\(v)"
            case .productName(let v): return "productName=\(v)"
            case .productNameLike(let v): return "productNameLike=\(v)"
            case .serialNumber(let v): return "serialNumber=\(v)"
            }
        }.joined(separator: ":")
    }
}
