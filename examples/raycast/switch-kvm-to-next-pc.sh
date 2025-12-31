#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch KVM to Next PC
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️
# @raycast.packageName Display Input Control

# Documentation:
# @raycast.description Switch monitor's built-in KVM to next PC
# @raycast.author dayflower
# @raycast.authorURL https://github.com/dayflower/dispsel

# Switch KVM to next PC
dispsel kvm next -m
