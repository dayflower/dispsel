#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch to Thunderbolt/USB-C
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️
# @raycast.packageName Display Input Control

# Documentation:
# @raycast.description Switch monitor input source to Thunderbolt/USB-C
# @raycast.author dayflower
# @raycast.authorURL https://github.com/dayflower/dispsel

# Switch to Thunderbolt/USB-C input
dispsel -m switch thunderbolt
