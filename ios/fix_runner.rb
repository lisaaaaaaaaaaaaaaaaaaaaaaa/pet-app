require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Runner target
runner_target = project.targets.find { |target| target.name == 'Runner' }
if runner_target
  runner_target.build_configurations.each do |config|
    # Remove the build settings we don't want
    config.build_settings.delete('OTHER_CFLAGS')
    config.build_settings.delete('OTHER_CPPFLAGS')
    config.build_settings.delete('OTHER_LDFLAGS')
    
    # Set safe defaults
    config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
  end
  
  project.save
end
