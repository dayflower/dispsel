#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch to Next Input
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️
# @raycast.packageName Display Input Control

# Documentation:
# @raycast.description Cycle through DisplayPort, HDMI, and Thunderbolt input sources
# @raycast.author dayflower
# @raycast.authorURL https://github.com/dayflower/dispsel

# Cycle between DP, HDMI, and Thunderbolt
dispsel switch next dp,hdmi,thunderbolt -m
