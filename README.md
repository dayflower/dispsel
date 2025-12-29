# dispsel

A macOS command-line tool for switching monitor input sources and controlling monitor's built-in KVM via DDC/CI protocol.

## Features

- Switch monitor input sources (DisplayPort, HDMI, Thunderbolt/USB-C)
- Cycle through multiple input sources
- Control monitor's built-in KVM (USB upstream switching)
- List all connected displays with their properties
- Select target display by UUID, product name, or serial number
- Send error notifications to macOS Notification Center

## Requirements

- macOS 13.0 or later
- Swift 6.0 or later
- Displays that support DDC/CI protocol

## Installation

### Building from Source

```bash
# Clone the repository
git clone https://github.com/dayflower/dispsel.git
cd dispsel

# Build the project
swift build -c release

# The binary will be at .build/release/dispsel
# Optionally, copy it to your PATH
cp .build/release/dispsel /usr/local/bin/
```

## Usage

### List Connected Displays

```bash
dispsel list
```

Output example:

```
[Display #1]
  uuid:            10FF0FFF-0000-0000-7777-333311112222
  manufacturer id: DEL
  product name:    DELL U4025QW
  serial number:   999XX99
  connection:      DP -> DP
  current input:   displayport1 (0x0f)
```

### Switch Input Source

```bash
# Switch to DisplayPort using keyword
dispsel switch dp

# Switch to HDMI using hex value
dispsel switch 0x17

# Switch to specific display by UUID
dispsel -d 'uuid=10FF0FFF-0000-0000-7777-333311112222' switch hdmi
```

### Cycle Through Input Sources

```bash
# Cycle between DisplayPort, HDMI, and Thunderbolt
dispsel switch next dp,hdmi,thunderbolt

# If current input is dp, switches to hdmi
# If current input is hdmi, switches to thunderbolt
# If current input is thunderbolt, switches back to dp
```

### Switch Built-in KVM

```bash
# Switch monitor's built-in KVM to next upstream port
dispsel kvm next
```

## Input Source Keywords

Keywords are case-insensitive:

| VCP Value | Keywords                             |
| --------- | ------------------------------------ |
| 0x0f      | displayport1, displayport, dp1, dp   |
| 0x10      | displayport2, dp2                    |
| 0x11      | hdmi1, hdmi                          |
| 0x12      | hdmi2                                |
| 0x19      | thunderbolt1, usb1, thunderbolt, usb |
| 0x1B      | thunderbolt2, usb2                   |

You can also use hexadecimal (e.g., `0x0f`) or decimal (e.g., `15`) values directly.

## Display Selection

Use the `-d` or `--display` option to select a specific display:

```bash
# Select by UUID
dispsel -d 'uuid=10FF0FFF-0000-0000-7777-333311112222' switch dp

# Select by product name (exact match, case-sensitive)
dispsel -d 'productName=DELL U4025QW' switch hdmi

# Select by partial product name (case-insensitive)
dispsel -d 'productNameLike=U4025QW' switch dp

# Select by serial number (exact match, case-sensitive)
dispsel -d 'serialNumber=99XX99' switch hdmi

# Combine multiple criteria (AND condition)
dispsel -d 'productNameLike=DELL:serialNumber=99XX99' switch dp

# UUID without field name
dispsel -d '10FF0FFF-0000-0000-7777-333311112222' switch hdmi
```

### Display Specifier Criteria

- `uuid`: UUID match (case-insensitive, hyphens optional)
- `productName`: Exact product name match (case-sensitive)
- `productNameLike`: Partial product name match (case-insensitive)
- `serialNumber`: Exact serial number match (case-sensitive)

Multiple criteria can be joined with `:` (AND condition).

## Global Options

### Quiet Mode

Suppress all output:

```bash
dispsel -q switch dp
```

### Notification Mode

Send errors to Notification Center instead of stderr:

```bash
dispsel -m switch dp
```

Note: `-q` takes precedence over `-m`.

### Version Information

```bash
dispsel --version
```

## Exit Status Codes

- `0`: Success
- Non-zero: Error occurred

## Disclaimer

**USE AT YOUR OWN RISK**

This tool directly controls monitor hardware via DDC/CI protocol. While DDC/CI is a standard protocol, improper use or unexpected behavior may potentially cause monitor malfunctions or damage. The authors and contributors of this software:

- Provide this software "as is" without any warranty
- Are not responsible for any damage to your hardware
- Do not guarantee compatibility with all monitors
- Recommend testing with non-critical displays first

Always ensure you understand what commands you are sending to your monitor before execution.

## License

See [LICENSE](./LICENSE) file for details.

## Acknowledgments

This project uses the following libraries:

- [AppleSiliconDDC](https://github.com/waydabber/AppleSiliconDDC) - DDC/CI library for macOS ([MIT License](https://github.com/waydabber/AppleSiliconDDC/blob/main/LICENSE))
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser) - Command-line argument parsing ([Apache License 2.0](https://github.com/apple/swift-argument-parser/blob/main/LICENSE.txt))
