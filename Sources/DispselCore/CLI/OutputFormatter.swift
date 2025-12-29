import Foundation
import UserNotifications

/// Handles output formatting and routing based on global options
public class OutputFormatter {
    private let options: GlobalOptions

    public init(options: GlobalOptions) {
        self.options = options
    }

    /// Print an info message (e.g., target display)
    public func printInfo(_ message: String) {
        guard !options.shouldSuppressOutput else { return }
        print(message)
    }

    /// Print a warning message to stderr
    public func printWarning(_ message: String) {
        guard !options.shouldSuppressOutput else { return }
        fputs("Warning: \(message)\n", stderr)
    }

    /// Print an error message (stderr or notification)
    public func printError(_ message: String) {
        guard !options.shouldSuppressOutput else { return }

        if options.shouldUseNotification {
            sendNotification(message)
        } else {
            fputs("Error: \(message)\n", stderr)
        }
    }

    /// Print a success message
    public func printSuccess(_ message: String) {
        guard !options.shouldSuppressOutput else { return }
        print(message)
    }

    /// Send error notification to Notification Center
    private func sendNotification(_ message: String) {
        let content = UNMutableNotificationContent()
        content.title = "dispsel Error"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                // If notification fails, fall back to stderr
                fputs("Failed to send notification: \(error.localizedDescription)\n", stderr)
                fputs("Error: \(message)\n", stderr)
            }
        }
    }
}
