#!/opt/puppetlabs/puppet/bin/ruby

# Usage:
#
#   ./merge-yaml-files.rb low-priority.yaml high-priority.yaml > merged.yaml
#
require 'yaml'

file1 = ARGV[0]
file2 = ARGV[1]

if file1.nil? || !File.exist?(file1)
  puts 'Argument 1 needs to be a path to a yaml file'
  exit 1
end

if file2.nil? || !File.exist?(file2)
  puts 'Argument 2 needs to be a path to a yaml file'
  exit 1
end

hash1 = YAML.load_file(file1)
hash2 = YAML.load_file(file2)

merged = hash1.merge(hash2)

STDOUT.puts(merged.to_yaml)
