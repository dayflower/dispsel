# Raycast Script Commands for dispsel

This directory contains example [Raycast Script Commands](https://github.com/raycast/script-commands) for the `dispsel` CLI tool.

## Prerequisites

1. Install [Raycast](https://www.raycast.com/)
2. Install `dispsel` and ensure it's in your PATH (e.g., `/usr/local/bin/dispsel`)
3. Grant necessary permissions for DDC/CI access

## Installation

### Option 1: Copy Scripts to Raycast Script Commands Directory

1. Create a directory for your custom script commands:
   ```bash
   mkdir -p ~/raycast-scripts/display-control
   ```

2. Copy the scripts:
   ```bash
   cp examples/raycast/*.sh ~/raycast-scripts/display-control/
   ```

3. Make scripts executable:
   ```bash
   chmod +x ~/raycast-scripts/display-control/*.sh
   ```

4. In Raycast:
   - Open Raycast preferences (⌘,)
   - Go to Extensions → Script Commands
   - Click "Add Directories" and select `~/raycast-scripts`

### Option 2: Add This Repository Directory Directly

1. Make scripts executable:
   ```bash
   chmod +x examples/raycast/*.sh
   ```

2. In Raycast:
   - Open Raycast preferences (⌘,)
   - Go to Extensions → Script Commands
   - Click "Add Directories" and select this `examples/raycast` directory

## Available Commands

After installation, you can invoke these commands from Raycast:

### Input Source Switching
- **Switch to DisplayPort** - Switch monitor input to DisplayPort
- **Switch to HDMI** - Switch monitor input to HDMI
- **Switch to Thunderbolt/USB-C** - Switch monitor input to Thunderbolt/USB-C
- **Switch to Next Input** - Cycle through DP, HDMI, and Thunderbolt

### KVM Control
- **Switch KVM to Next PC** - Switch monitor's built-in KVM to next PC

## Customization

### Adjusting Input Source Cycling

Edit `switch-to-next-input.sh` to customize which input sources to cycle through:

```bash
# Example: Cycle between only DP and HDMI
dispsel -m switch next dp,hdmi

# Example: Include DisplayPort 2
dispsel -m switch next dp,dp2,hdmi
```

### Target Specific Display

If you have multiple displays, add the `-d` option to target a specific display:

```bash
# Target display by product name
dispsel -d 'productNameLike=U4025QW' -m switch dp

# Target display by serial number
dispsel -d 'serialNumber=99XX99' -m switch hdmi
```

### Notification Behavior

All example scripts use the `-m` flag to send error messages to macOS Notification Center instead of showing them in Raycast. This provides a better user experience when running commands from Raycast.

If you prefer to see all output in Raycast, remove the `-m` flag and change `@raycast.mode` from `silent` to `fullOutput`:

```bash
# Before
# @raycast.mode silent
dispsel -m switch dp

# After
# @raycast.mode fullOutput
dispsel switch dp
```

### Change Icons

Customize the icons by editing the `@raycast.icon` metadata:

```bash
# @raycast.icon 🖥️   # Monitor
# @raycast.icon 🔄   # Cycle
# @raycast.icon ⌨️   # Keyboard
# @raycast.icon 📋   # Clipboard
# @raycast.icon 💻   # Laptop
# @raycast.icon ⚡   # Thunderbolt
```

## Keyboard Shortcuts

You can assign keyboard shortcuts to these commands in Raycast:

1. Open Raycast and search for the command
2. Press ⌘K to open actions
3. Select "Assign Keyboard Shortcut"
4. Press your desired key combination

## Troubleshooting

### "dispsel: command not found"

Ensure `dispsel` is in your PATH. Check with:
```bash
which dispsel
```

If not found, either:
- Copy `dispsel` to `/usr/local/bin/`
- Update the scripts to use the full path (e.g., `/path/to/dispsel`)

### Permission Issues

DDC/CI access may require specific permissions. If you encounter errors:
1. Ensure your user has permission to access display hardware
2. Try running the command manually from Terminal first
3. Check macOS System Settings → Privacy & Security

### Scripts Not Appearing in Raycast

1. Verify scripts have execute permissions: `chmod +x *.sh`
2. Check that the directory is added in Raycast → Preferences → Extensions → Script Commands
3. Try refreshing: Open Raycast preferences and toggle the directory off and on

## Related Links

- [dispsel GitHub Repository](https://github.com/dayflower/dispsel)
- [Raycast Script Commands Documentation](https://github.com/raycast/script-commands)
- [Raycast Script Commands Repository](https://github.com/raycast/script-commands)
