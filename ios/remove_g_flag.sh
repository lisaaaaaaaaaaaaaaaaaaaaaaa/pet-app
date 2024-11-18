#!/bin/bash

# Find all .xcconfig files and remove -G flag
find . -name "*.xcconfig" -type f -exec sed -i "" "s/-G//g" {} +

# Find all project.pbxproj files and remove -G flag
find . -name "project.pbxproj" -type f -exec sed -i "" "s/-G//g" {} +

# Clean up Pods directory
rm -rf Pods
rm -rf Podfile.lock
