Dir.glob("Pods/Target Support Files/**/*.xcconfig").each do |config_file|
  content = File.read(config_file)
  
  # Remove -G flag from all configurations
  modified_content = content.gsub(/-G\b/, '')
  
  # Remove any empty flag declarations
  modified_content = modified_content.gsub(/OTHER_CFLAGS = $/, '')
  modified_content = modified_content.gsub(/OTHER_CPLUSPLUSFLAGS = $/, '')
  
  File.write(config_file, modified_content)
end
