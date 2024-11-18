def fix_flags(installer)
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      ['OTHER_CFLAGS', 'OTHER_CPLUSPLUSFLAGS'].each do |flags_key|
        if config.build_settings[flags_key]
          flags = config.build_settings[flags_key]
          if flags.kind_of?(String)
            flags = flags.split(' ')
          end
          flags = flags.reject { |flag| flag.include?('-G') }
          config.build_settings[flags_key] = flags
        end
      end
    end
  end
end
