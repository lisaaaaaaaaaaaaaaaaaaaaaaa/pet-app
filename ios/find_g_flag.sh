#!/bin/bash

# Find all xcconfig files
echo "Searching xcconfig files..."
find . -name "*.xcconfig" -type f -exec grep -l "\-G" {} \;

# Find all pbxproj files
echo "Searching project files..."
find . -name "project.pbxproj" -type f -exec grep -l "\-G" {} \;

# Clean all xcconfig files
echo "Cleaning xcconfig files..."
find . -name "*.xcconfig" -type f -exec sed -i '' 's/-G[[:space:]]*//g' {} \;

# Clean build settings in project files
find . -name "project.pbxproj" -type f -exec sed -i '' 's/-G[[:space:]]*//g' {} \;
