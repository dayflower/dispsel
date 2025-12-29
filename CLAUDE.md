# dispsel - Development Guide

This file provides guidance to Claude Code when working on the dispsel project.

## Project Overview

`dispsel` is a macOS command-line tool for switching monitor input sources and controlling monitor's built-in KVM via DDC/CI protocol.

- **Language**: Swift
- **Target Platform**: macOS (Apple Silicon and Intel)
- **Build System**: Swift Package Manager
- **DDC/CI Library**: [AppleSiliconDDC](https://github.com/waydabber/AppleSiliconDDC)

## Architecture Guidelines

### Code Organization

- Keep command-line interface logic separate from DDC/CI communication logic
- Use Swift's argument parsing capabilities for CLI (consider Swift Argument Parser)
- Implement display specifier matching as a separate, testable module
- Implement input source keyword resolution as a separate, testable module

### Error Handling

- Use Swift's error handling mechanisms (`throws`, `try`, `catch`)
- Provide clear error messages that help users understand what went wrong
- Return appropriate exit status codes (0 for success, non-zero for errors)
- Handle cases where displays don't support requested VCP codes gracefully

### Display Selection Logic

When implementing display selection (`-d, --display` option):

1. Parse display specifier into criteria (uuid, productName, productNameLike, serialNumber)
2. Query all displays using AppleSiliconDDC
3. Filter displays based on criteria (AND condition for multiple criteria)
4. Handle error/warning cases:
   - Error if no matching display found
   - Warning if multiple matches found (use first one)
   - Error if no displays found when no specifier provided
   - Use first display if multiple found when no specifier provided

### Input Source Handling

- Maintain a keyword-to-value mapping table as specified in SPEC.md
- Support case-insensitive keyword matching
- Support hexadecimal (0x prefix) and decimal number formats
- Validate keywords but not VCP values (write directly to VCP)

### Output Formatting

Follow the exact output formats specified in [SPEC.md](docs/SPEC.md):

- Info messages for target display selection
- Success messages for switch operations
- List command output format
- Respect `-q` (quiet) and `-m/--notification` options

## Development Workflow

### Building

```bash
swift build
```

### Testing

- Write unit tests for:
  - Display specifier parsing and matching
  - Input source keyword resolution
  - Command-line argument parsing
- Manual testing should be performed with actual displays when possible

### Dependencies

- AppleSiliconDDC: For DDC/CI communication
- Consider Swift Argument Parser for CLI argument handling

## Implementation Priorities

1. Core DDC/CI communication (using AppleSiliconDDC)
2. Display enumeration and selection
3. Basic `switch` command with input source specifiers
4. `list` command for display information
5. `switch next` command for cycling inputs
6. `kvm next` command for KVM switching
7. Global options (`-q`, `-m`, `-d`, `--version`)
8. Error handling and user feedback

## Code Style

- Follow Swift standard naming conventions
- Use meaningful variable and function names
- Add comments for complex logic, especially DDC/CI protocol details
- Keep functions focused and single-purpose

## Important Considerations

### DDC/CI Protocol

- VCP code 0x60: Input source selection
- VCP code 0xE7: KVM next (write 0xff00)
- The tool writes directly to VCP without validation

### Platform-Specific

- macOS-only tool (no cross-platform concerns)
- Works with both Apple Silicon and Intel Macs via AppleSiliconDDC

### User Experience

- Provide clear feedback about what operation is being performed
- Show which display is being targeted
- Handle common error cases gracefully (no displays, unsupported operations)
- Support scripting use cases (quiet mode, exit codes)

## References

- Full specification: [docs/SPEC.md](docs/SPEC.md)
- AppleSiliconDDC: https://github.com/waydabber/AppleSiliconDDC
- VESA DDC/CI specification for VCP codes
