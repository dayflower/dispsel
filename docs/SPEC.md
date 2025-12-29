# dispsel - Display Selector Specification

## Overview

`dispsel` is a macOS CLI tool for switching monitor input sources and controlling USB KVM switches via DDC/CI protocol.

## Requirements

- **Platform**: macOS (Apple Silicon and Intel)
- **Build Requirements**: Command Line Tools (no Xcode required)
- **Build Command**: `swift build`

## Core Functionality

1. Switch to a specified input source
2. Cycle to the next input source
3. Switch USB KVM during PBP/PIP mode

## Command Line Interface

### Synopsis

```
dispsel [OPTIONS] <SUBCOMMAND> [ARGUMENTS]
```

If no subcommand is provided, the `help` command is invoked.

### Global Options

#### Feedback Control

- **`-q`**: Quiet mode

  - Suppresses all warning/error/info messages
  - Exit status code is still returned
  - Takes precedence over `-o` if both are specified

- **`-o, --notification`**: Notification mode
  - Error messages are sent to Notification Center instead of stdout/stderr
  - Warning and info messages are still printed to stdout/stderr

#### Version Information

- **`--version`**: Display version information

#### Display Selection

Display selection does not apply to the `list` command.

- **`-d, --display <SPECIFIER>`**: Select target display
  - Error if no matching display is found
  - Warning if multiple matches are found (first one is used)
  - If not specified:
    - Error if no displays are found
    - Use first display if multiple are found (in library-returned order, no sorting)

When a display is selected, print an info message:

```
Target: (DEL) DELL U4025QW 999XX99
```

**Display Specifier Syntax**:

```
-d 'uuid=10FF0FFF-0000-0000-7777-333311112222'
-d 'productNameLike=U4025QW'
-d 'productNameLike=U4025QW:serialNumber=99XX99'
-d '10FF0FFF-0000-0000-7777-333311112222'
```

- Multiple criteria can be joined with `:` (AND condition)
- If no field name is provided, treat as UUID specifier
- See "Display Specifiers" section for details

## Subcommands

### help

Display command usage information.

```
dispsel help
```

### list

List all connected displays.

```
dispsel list
```

**Output Format** (per display):

```
[Display #1]
  uuid:            10FF0FFF-0000-0000-7777-333311112222
  manufacturer id: DEL
  product name:    DELL U4025QW
  serial number:   999XX99
  connection:      DP -> DP
  current input:   displayport1 (0x0f)
```

- `connection`: Shows `transportUpstream -> transportDownstream`

### switch

Switch to a specific input source.

```
dispsel switch <INPUT_SOURCE>
```

**Example**:

```
dispsel switch dp
```

See "Input Source Specifiers" section for available input sources.

**Success Output**:

```
Switched to: displayport1 (0x0f)
```

### switch next

Cycle to the next input source from a provided list.

```
dispsel switch next <INPUT_SOURCE_LIST>
```

**Example**:

```
dispsel switch next thunderbolt,dp,hdmi
```

If current input is `dp`, switches to `hdmi`.

**Behavior**:

- Reads the current input source from the monitor
- Error if current input is not in the provided list
- If duplicate entries exist in the list, the first match is used
- Cycles to the first item if current input is the last in the list
- No action if list contains only one item

**Success Output**:

```
Switched to: hdmi1 (0x11) from: displayport1 (0x0f)
```

### kvm next

Switch KVM input to the next PC when using PIP/PBP mode with multiple input sources.

```
dispsel kvm next
```

Triggers the monitor's built-in KVM to switch to the next connected PC.

**Success Output**:

None (silent even without `-q` option)

## Specifiers

### Display Specifiers

- **`uuid`**: UUID match

  - Case-insensitive
  - Hyphens are optional

- **`productName`**: Product name exact match

  - Case-sensitive

- **`productNameLike`**: Product name partial match

  - Case-insensitive

- **`serialNumber`**: Serial number exact match
  - Case-sensitive

### Input Source Specifiers

Input sources can be specified using:

- **Keywords** (case-insensitive, recommended)
- **Hexadecimal values** (e.g., `0x0f`)
- **Decimal values** (e.g., `15`)

If a keyword is provided but doesn't match any defined keyword, an error is returned.

#### Input Source Keywords

Keywords are case-insensitive (lowercase is canonical).

| Keywords                             | Description         |
| ------------------------------------ | ------------------- |
| displayport1, displayport, dp1, dp   | DisplayPort 1       |
| displayport2, dp2                    | DisplayPort 2       |
| hdmi1, hdmi                          | HDMI 1              |
| hdmi2                                | HDMI 2              |
| thunderbolt1, usb1, thunderbolt, usb | Thunderbolt/USB-C 1 |
| thunderbolt2, usb2                   | Thunderbolt/USB-C 2 |

**Note**: The tool sends commands directly to the monitor. If your monitor doesn't support a particular input source, the command may be ignored or result in unexpected behavior.

## Exit Status Codes

- **0**: Success
- **Non-zero**: Error (specific codes TBD based on error types)
