import Foundation

/// Global options applicable to all commands
public struct GlobalOptions: Sendable {
    /// Quiet mode: suppress all output
    public let quiet: Bool
    /// Notification mode: send errors to Notification Center
    public let notification: Bool
    /// Display specifier for selecting target display
    public let displaySpecifier: DisplaySpecifier?

    public init(quiet: Bool, notification: Bool, displaySpecifier: DisplaySpecifier?) {
        self.quiet = quiet
        self.notification = notification
        self.displaySpecifier = displaySpecifier
    }

    /// Whether to suppress all output
    public var shouldSuppressOutput: Bool {
        quiet
    }

    /// Whether to use notification for errors
    public var shouldUseNotification: Bool {
        !quiet && notification
    }
}
