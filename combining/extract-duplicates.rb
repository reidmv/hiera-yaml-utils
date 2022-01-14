#!/opt/puppetlabs/puppet/bin/ruby

# Usage:
#
#   ./extract-duplicates.rb file1.yaml file2.yaml [...] > duplicated-values.yaml
#
require 'yaml'

files = ARGV
hashes = files.map { |f| YAML.load_file(f) }

keys = hashes.reduce([]) do |memo, hash|
  (memo + hash.keys).uniq
end

duplicates_keys = keys.select do |key|
  hashes.all? { |hash| hashes[0][key] == hash[key] }
end

duplicates = duplicates_keys.reduce({}) do |memo, key|
  memo[key] = hashes[0][key]
  memo
end

STDOUT.puts(duplicates.to_yaml)
