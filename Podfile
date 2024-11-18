platform :ios, '13.0'

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  # Force remove the flag from all possible locations
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Clear all compiler flags
      ['OTHER_CFLAGS', 'OTHER_CPPFLAGS', 'OTHER_LDFLAGS', 'WARNING_CFLAGS'].each do |key|
        config.build_settings[key] = '$(inherited)'
      end

      # Force override any GCC settings
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = ['$(inherited)']
      
      # Set basic settings
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
      
      # Explicitly set compiler
      config.build_settings['CC'] = '/usr/bin/clang'
      config.build_settings['COMPILER_INDEX_STORE_ENABLE'] = 'NO'
    end
  end

  # Clean up xcconfig files
  Dir.glob("Pods/Target Support Files/**/*.xcconfig") do |config_file|
    text = File.read(config_file)
    new_text = text.gsub(/-G\s+/, ' ').gsub(/-G$/, '')
    File.write(config_file, new_text)
  end
  
  flutter_additional_ios_build_settings(installer)
end
