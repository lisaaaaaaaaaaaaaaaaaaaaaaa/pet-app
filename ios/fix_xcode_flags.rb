require 'xcodeproj'

def remove_g_flag(config)
  ['OTHER_CFLAGS', 'OTHER_CPLUSPLUSFLAGS'].each do |setting|
    if config.build_settings[setting]
      flags = config.build_settings[setting]
      flags = flags.split(' ') if flags.is_a?(String)
      flags = flags.reject { |f| f == '-G' || f.include?('-G') }
      config.build_settings[setting] = flags
    end
  end
end

# Fix main project
project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
project.targets.each do |target|
  target.build_configurations.each do |config|
    remove_g_flag(config)
  end
end
project.save

# Fix Pods project if it exists
pods_path = 'Pods/Pods.xcodeproj'
if File.exist?(pods_path)
  pods_project = Xcodeproj::Project.open(pods_path)
  pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      remove_g_flag(config)
    end
  end
  pods_project.save
end
