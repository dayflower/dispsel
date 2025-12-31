#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch to HDMI
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️
# @raycast.packageName Display Input Control

# Documentation:
# @raycast.description Switch monitor input source to HDMI
# @raycast.author dayflower
# @raycast.authorURL https://github.com/dayflower/dispsel

# Switch to HDMI input
dispsel switch -m hdmi
