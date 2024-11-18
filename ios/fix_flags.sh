#!/bin/bash

# Find all xcconfig files
find . -name "*.xcconfig" -type f -exec sed -i '' 's/-G//g' {} +

# Find all pbxproj files
find . -name "project.pbxproj" -type f -exec sed -i '' 's/-G//g' {} +

# Clean up CocoaPods
rm -rf Pods/
rm -rf Podfile.lock

# Create a custom config
mkdir -p Flutter
cat > Flutter/Override.xcconfig << 'CONFIG'
OTHER_CFLAGS = $(inherited)
OTHER_CPLUSPLUSFLAGS = $(inherited)
CONFIG

# Update permissions
chmod +x fix_flags.sh
