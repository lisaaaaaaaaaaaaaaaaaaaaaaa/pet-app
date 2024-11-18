require 'xcodeproj'

def fix_target(target)
  target.build_configurations.each do |config|
    # Remove compiler flags
    ['OTHER_CFLAGS', 'OTHER_CPPFLAGS', 'OTHER_LDFLAGS'].each do |key|
      if config.build_settings[key].kind_of?(Array)
        config.build_settings[key] = ['$(inherited)']
      else
        config.build_settings[key] = '$(inherited)'
      end
    end
    
    # Set some safe defaults
    config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
    config.build_settings['ENABLE_BITCODE'] = 'NO'
    config.build_settings['COMPILER_INDEX_STORE_ENABLE'] = 'NO'
  end
end

# Fix Pods project
pods_project = Xcodeproj::Project.open('Pods/Pods.xcodeproj')
boringssl_target = pods_project.targets.find { |t| t.name == 'BoringSSL-GRPC' }
fix_target(boringssl_target) if boringssl_target
pods_project.save

# Fix Runner project
runner_project = Xcodeproj::Project.open('Runner.xcodeproj')
runner_project.targets.each { |t| fix_target(t) }
runner_project.save
