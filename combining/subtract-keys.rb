#!/opt/puppetlabs/puppet/bin/ruby

# Usage:
#
#   ./extract-duplicates.rb keys-to-subtract.yaml subtract-from-file.yaml
#
require 'yaml'

keys_to_subtract_file = ARGV[0]
subtract_from_file = ARGV[1]

if keys_to_subtract_file.nil? || !File.exist?(keys_to_subtract_file)
  puts 'Argument 1 needs to be a path to a yaml file that lists duplicated keys'
  exit 1
end

if subtract_from_file.nil? || !File.exist?(subtract_from_file)
  puts 'Argument 2 needs to be a path to a yaml file to modify'
  exit 1
end

keys_to_subtract = YAML.load_file(keys_to_subtract_file).keys

subtracted = YAML.load_file(subtract_from_file).select { |key| !keys_to_subtract.include?(key) }

File.write(subtract_from_file, subtracted.to_yaml)
