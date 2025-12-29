import Foundation

/// Protocol for all dispsel commands
public protocol Command {
    /// Execute the command
    /// - Parameters:
    ///   - options: Global options (quiet, notification, display specifier)
    ///   - formatter: Output formatter for printing messages
    /// - Throws: DispselError or other errors
    func execute(options: GlobalOptions, formatter: OutputFormatter) throws
}
