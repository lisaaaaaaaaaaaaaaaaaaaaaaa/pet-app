require 'xcodeproj'

def remove_g_flag_from_target(target)
  target.build_configurations.each do |config|
    ['OTHER_CFLAGS', 'OTHER_CPLUSPLUSFLAGS'].each do |setting|
      if config.build_settings[setting]
        flags = config.build_settings[setting]
        flags = flags.split(' ') if flags.is_a?(String)
        flags = flags.reject { |f| f == '-G' || f.include?('-G') }
        config.build_settings[setting] = flags
      end
    end
  end
end

# Process main project
project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
project.targets.each do |target|
  remove_g_flag_from_target(target)
end
project.save

# Process Pods project if it exists
pods_path = 'Pods/Pods.xcodeproj'
if File.exist?(pods_path)
  pods_project = Xcodeproj::Project.open(pods_path)
  pods_project.targets.each do |target|
    remove_g_flag_from_target(target)
  end
  pods_project.save
end
