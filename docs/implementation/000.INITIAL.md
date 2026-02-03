# dispsel - Implementation Specification

This document describes the internal implementation details of `dispsel` for developers and maintainers.

## Build System and Dependencies

### Language and Platform

- **Language**: Swift
- **Platform**: macOS (Apple Silicon and Intel)
- **Build System**: Swift Package Manager
- **Build Command**: `swift build`
- **Test Command**: `swift test`

### External Dependencies

- **[AppleSiliconDDC](https://github.com/waydabber/AppleSiliconDDC)**: Core library for DDC/CI communication
  - Handles low-level I2C communication with displays
  - Works on both Apple Silicon and Intel Macs
  - Provides VCP read/write operations

**Dependency Declaration** (in `Package.swift`):
```swift
.package(url: "https://github.com/waydabber/AppleSiliconDDC", ...),
```

All DDC/CI functionality is implemented using this library via the `DDCManager` wrapper.

## Architecture Overview

### Module Structure

```
dispsel/
├── Sources/
│   ├── dispsel/           # CLI entry point
│   └── DispselCore/       # Core library
│       ├── Commands/      # Command implementations
│       ├── DDC/           # DDC/CI communication
│       ├── Display/       # Display enumeration and matching
│       ├── InputSource/   # Input source resolution
│       └── Common/        # Shared types and utilities
└── Tests/
    └── DispselCoreTests/  # Unit tests
```

### Design Principles

1. **Separation of Concerns**: CLI logic is separate from DDC/CI communication
2. **Testability**: Core logic is testable without actual hardware
3. **Error Transparency**: Clear error messages for debugging
4. **Extensibility**: Easy to add new commands and input source keywords

## Core Components

### 1. DDC/CI Communication Layer

**Module**: `Sources/DispselCore/DDC/`

**Responsibilities**:
- Enumerate displays using AppleSiliconDDC library
- Read VCP (Virtual Control Panel) codes
- Write VCP codes

**Key Files**:
- `DDCManager.swift`: Wrapper around AppleSiliconDDC
- `VCPCode.swift`: VCP code definitions

**Implementation Details**:

#### VCP Read Operation

```swift
public static func readVCP(display: Display, code: UInt8) throws -> (current: UInt16, max: UInt16)
```

- Uses `AppleSiliconDDC.read()` to perform I2C communication
- Returns tuple of (current value, maximum value)
- Throws `DispselError.vcpReadFailed` on communication failure

#### VCP Write Operation

```swift
public static func writeVCP(display: Display, code: UInt8, value: UInt16) throws
```

- Uses `AppleSiliconDDC.write()` to perform I2C communication
- Throws `DispselError.vcpWriteFailed` on communication failure

### 2. Display Selection

**Module**: `Sources/DispselCore/Display/`

**Responsibilities**:
- Parse display specifiers
- Match displays based on criteria
- Handle multiple/no match cases

**Key Files**:
- `DisplaySpecifier.swift`: Display specifier parsing
- `DisplayMatcher.swift`: Display matching logic
- `Display.swift`: Display model

**Matching Logic**:

1. Parse specifier into criteria (uuid, productName, productNameLike, serialNumber)
2. Filter displays using AND logic for multiple criteria
3. Return first match with optional warning if multiple matches found

### 3. Input Source Resolution

**Module**: `Sources/DispselCore/InputSource/`

**Responsibilities**:
- Resolve input source keywords to VCP values
- Parse hexadecimal and decimal input formats
- Normalize VCP values from monitors

**Key Files**:
- `InputSourceResolver.swift`: Input source resolution logic
- `InputSource.swift`: Input source model

**Resolution Strategy**:

1. Try hex format (0x prefix) → parse as base-16
2. Try decimal format → parse as base-10
3. Try keyword lookup (case-insensitive)
4. Throw error if no match

**VCP Value Normalization**:

Some monitors (notably DELL) return duplicated bytes for VCP 0x60. For example:
- Writing `0x0f` (DisplayPort) and reading back returns `0x0f0f`
- Writing `0x11` (HDMI) and reading back returns `0x1111`

**Normalization Logic** (in `InputSourceResolver.normalizeVCPValue()`):

```swift
let highByte = (value >> 8) & 0xFF
let lowByte = value & 0xFF

if highByte == lowByte {
    return lowByte  // 0x0f0f → 0x0f
}

return value  // 0x1234 → 0x1234 (unchanged)
```

**Where Normalization Occurs**:
- `InputSourceResolver.fromValue()`: Normalizes when converting VCP value to InputSource
- Used by both `list` command (display current input) and `switch next` command (compare current input)

**Why This Approach**:
- Centralized: Single point of normalization
- Transparent: Commands don't need to know about monitor quirks
- Testable: Easy to unit test normalization logic

### 4. Command Implementations

**Module**: `Sources/DispselCore/Commands/`

**Common Pattern**:

```swift
public protocol Command {
    func execute(options: GlobalOptions, formatter: OutputFormatter) throws
}
```

All commands:
1. Receive global options (quiet mode, display specifier, etc.)
2. Use `OutputFormatter` for consistent output
3. Throw typed errors for error handling

**Key Commands**:

#### ListCommand
- Enumerates all displays
- Reads VCP 0x60 (input source) for each display
- Silently skips VCP read errors (some displays don't support query)

#### SwitchCommand
- Resolves input source specifier
- Writes to VCP 0x60

#### SwitchNextCommand
- Reads current input via VCP 0x60
- **Normalizes the value** using `InputSourceResolver.fromValue()`
- Finds current input in provided list
- Calculates next input (with wrap-around)
- Writes next input to VCP 0x60

#### KvmNextCommand
- Writes `0xff00` to VCP 0xE7
- Silent success (no output)

## DDC/CI Protocol Details

### Protocol Overview

**DDC/CI (Display Data Channel / Command Interface)** is a standardized protocol for communicating with monitors:
- Uses I2C bus over the video cable (DisplayPort, HDMI, etc.)
- Allows reading and writing monitor settings
- **VCP (Virtual Control Panel)**: Set of standardized control codes

**VCP Operations**:
- **Read**: Query current value of a VCP code (returns current and max values)
- **Write**: Set a new value for a VCP code

All monitor control in `dispsel` is implemented via VCP codes using the AppleSiliconDDC library.

### VCP Code 0x60: Input Source Select

**Read Operation**:
- Returns current input source value
- **Important**: Some monitors return duplicated bytes (e.g., 0x0f0f instead of 0x0f)
- Solution: Normalize before use (see "VCP Value Normalization" above)

**Write Operation**:
- Sets input source
- **No validation**: The tool writes values directly to VCP without checking if the monitor supports them
- Monitor behavior on invalid values:
  - May silently ignore the command
  - May accept but not apply the value
  - No error feedback from the monitor
- This design choice allows users to specify any value (hex/decimal) for monitors with non-standard input source codes

**Known Values**:

| Value | Description         |
|-------|---------------------|
| 0x0f  | DisplayPort 1       |
| 0x10  | DisplayPort 2       |
| 0x11  | HDMI 1              |
| 0x12  | HDMI 2              |
| 0x19  | Thunderbolt/USB-C 1 |
| 0x1B  | Thunderbolt/USB-C 2 |

### VCP Code 0xE7: KVM Switch

**Write Operation**:
- Writing `0xff00` triggers KVM switch to next input
- Used for monitors with built-in KVM in PIP/PBP mode
- No read operation defined

## Error Handling

### Error Types

Defined in `DispselError.swift`:

- `vcpReadFailed`: VCP read operation failed
- `vcpWriteFailed`: VCP write operation failed
- `noDisplaysFound`: No displays enumerated
- `displayNotFound`: No display matching specifier
- `invalidInputSource`: Invalid input source keyword
- `currentInputNotInList`: Current input not in switch next list

### Error Propagation

1. Low-level errors (DDC/CI) → `DispselError`
2. Command execution throws errors
3. Main catches and formats for user

### Quiet Mode Handling

When `-q` flag is set:
- All output suppressed (including errors)
- Exit status code still returned
- Useful for scripting

## Testing Strategy

### Unit Tests

**Location**: `Tests/DispselCoreTests/`

**Coverage**:
- Display specifier parsing and matching
- Input source resolution (keywords, hex, decimal)
- **VCP value normalization** (duplicated bytes)
- Command argument parsing

**Key Test Cases for Normalization**:
- `vcpValueNormalization()`: Tests 0x0f0f → 0x0f, 0x1111 → 0x11
- `nonDuplicatedBytesNotNormalized()`: Tests 0x1234 → 0x1234 (unchanged)
- `normalizationEdgeCases()`: Tests 0x0000, 0xFFFF, single-byte values

### Integration Tests

**Manual Testing Required**:
- Actual DDC/CI communication with monitors
- Display enumeration on different systems
- VCP read/write operations
- **Testing with DELL monitors** (to verify normalization works)

## Known Issues and Considerations

### Monitor-Specific Behavior

1. **DELL Monitors - Duplicated Bytes**:
   - VCP 0x60 read returns duplicated bytes (e.g., 0x0f0f)
   - Handled by normalization in `InputSourceResolver.fromValue()`
   - Affects both `list` and `switch next` commands

2. **Unsupported VCP Codes**:
   - Some monitors don't support VCP 0x60 query (write-only)
   - `list` command silently skips read errors
   - `switch next` command fails if read not supported

3. **Invalid VCP Values**:
   - Tool writes directly to VCP without validation
   - Monitor may ignore invalid values
   - No feedback if value not supported

### Platform Limitations

- **macOS only**: Uses AppleSiliconDDC which is macOS-specific
- **Requires display connection**: Must be connected via DisplayPort/HDMI/Thunderbolt
- **Permission requirements**: May require accessibility permissions on some macOS versions

## Future Enhancements

### Potential Improvements

1. **VCP Value Validation**:
   - Query supported input sources from monitor (VCP 0x60 max value)
   - Validate before writing

2. **Configuration File**:
   - Store favorite input source lists
   - Monitor-specific profiles

3. **Additional VCP Codes**:
   - Brightness control
   - Contrast control
   - Power management

4. **Better Error Messages**:
   - Suggest valid input sources on error
   - Diagnose common issues (permissions, unsupported monitors)

## References

- [AppleSiliconDDC Library](https://github.com/waydabber/AppleSiliconDDC)
- [VESA DDC/CI Specification](https://www.vesa.org/) - VCP code definitions
- [SPEC.md](SPEC.md) - User-facing specification
- [CLAUDE.md](../CLAUDE.md) - Development guidelines for AI assistants
