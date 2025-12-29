import Foundation
import ArgumentParser
import DispselCore

@main
struct Dispsel: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "dispsel",
        abstract: "macOS CLI tool for switching monitor input sources via DDC/CI",
        discussion: """
            DISPLAY SPECIFIERS:
              uuid=<UUID>         Match by UUID (case-insensitive, hyphens optional)
              productName=<NAME>  Match by exact product name (case-sensitive)
              productNameLike=<PATTERN> Match by partial product name (case-insensitive)
              serialNumber=<SN>   Match by serial number (case-sensitive)

              Multiple criteria can be joined with ':' (AND condition)
              Example: -d 'productNameLike=U4025QW:serialNumber=99XX99'

            INPUT SOURCES:
              Keywords (case-insensitive):
                dp, displayport, dp1, displayport1  (0x0f)
                dp2, displayport2                   (0x10)
                hdmi, hdmi1                         (0x11)
                hdmi2                               (0x12)
                usb, thunderbolt, usb1, thunderbolt1 (0x19)
                usb2, thunderbolt2                  (0x1B)

              Hex format: 0x0f, 0x11, etc.
              Decimal format: 15, 17, etc.
            """,
        version: "0.1.3",
        subcommands: [
            HelpCmd.self,
            ListCmd.self,
            SwitchCmd.self,
            KVMCmd.self
        ],
        defaultSubcommand: HelpCmd.self
    )
}

// MARK: - Global Options Group

struct GlobalOptionsGroup: ParsableArguments {
    @Flag(name: .shortAndLong, help: "Quiet mode (suppress all output)")
    var quiet: Bool = false

    @Flag(name: [.customShort("m"), .long], help: "Send errors to Notification Center")
    var notification: Bool = false

    @Option(name: [.short, .long], help: "Display specifier")
    var display: String?

    var globalOptions: GlobalOptions {
        GlobalOptions(
            quiet: quiet,
            notification: notification,
            displaySpecifier: {
                guard let spec = display else { return nil }
                return try? DisplaySpecifier.parse(spec)
            }()
        )
    }
}

// MARK: - Help Command

struct HelpCmd: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "help",
        abstract: "Display help information"
    )

    @Argument(help: "The subcommand to show help for")
    var subcommand: String?

    func run() throws {
        if let subcommand = subcommand {
            // Show help for specific subcommand
            switch subcommand.lowercased() {
            case "list":
                print(ListCmd.helpMessage())
            case "switch":
                print(SwitchCmd.helpMessage())
            case "kvm":
                print(KVMCmd.helpMessage())
            default:
                throw ValidationError("Unknown subcommand '\(subcommand)'")
            }
        } else {
            // Show general help
            print(Dispsel.helpMessage())
        }
    }
}

// MARK: - List Command

struct ListCmd: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all connected displays"
    )

    @OptionGroup var options: GlobalOptionsGroup

    func run() throws {
        let command = ListCommand()
        let formatter = OutputFormatter(options: options.globalOptions)

        do {
            try command.execute(options: options.globalOptions, formatter: formatter)
        } catch {
            formatter.printError(error.localizedDescription)
            throw ExitCode.failure
        }
    }
}

// MARK: - Switch Command

struct SwitchCmd: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "switch",
        abstract: "Switch input source",
        subcommands: [Next.self]
    )

    @Argument(help: "Input source (keyword, hex, or decimal)")
    var inputSource: String

    @OptionGroup var options: GlobalOptionsGroup

    func run() throws {
        let command = SwitchCommand(inputSourceSpec: inputSource)
        let formatter = OutputFormatter(options: options.globalOptions)

        do {
            try command.execute(options: options.globalOptions, formatter: formatter)
        } catch {
            formatter.printError(error.localizedDescription)
            throw ExitCode.failure
        }
    }

    // MARK: Switch Next Subcommand

    struct Next: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "next",
            abstract: "Cycle to next input source"
        )

        @Argument(help: "Comma-separated list of input sources")
        var inputSourceList: String

        @OptionGroup var options: GlobalOptionsGroup

        func run() throws {
            let command = SwitchNextCommand(inputSourceList: inputSourceList)
            let formatter = OutputFormatter(options: options.globalOptions)

            do {
                try command.execute(options: options.globalOptions, formatter: formatter)
            } catch {
                formatter.printError(error.localizedDescription)
                throw ExitCode.failure
            }
        }
    }
}

// MARK: - KVM Command

struct KVMCmd: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "kvm",
        abstract: "KVM control",
        subcommands: [Next.self]
    )

    struct Next: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "next",
            abstract: "Switch KVM to next input"
        )

        @OptionGroup var options: GlobalOptionsGroup

        func run() throws {
            let command = KVMNextCommand()
            let formatter = OutputFormatter(options: options.globalOptions)

            do {
                try command.execute(options: options.globalOptions, formatter: formatter)
            } catch {
                formatter.printError(error.localizedDescription)
                throw ExitCode.failure
            }
        }
    }
}
