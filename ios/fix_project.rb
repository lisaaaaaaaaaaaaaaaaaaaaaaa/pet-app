require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  target.build_configurations.each do |config|
    # Remove any existing flags
    config.build_settings.delete('OTHER_CFLAGS')
    config.build_settings.delete('OTHER_CPPFLAGS')
    config.build_settings.delete('OTHER_LDFLAGS')
    
    # Set safe defaults
    config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
    config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
    config.build_settings['ENABLE_TESTABILITY'] = 'YES'
  end
end

project.save
