#!/opt/puppetlabs/puppet/bin/ruby

# Usage:
#
#   ./separate-out-common-data.rb OUTPUT.yaml INPUT-1.yaml INPUT-2.yaml [INPUT-N.yaml ...]
#
require 'yaml'

if ARGV.empty?
  puts 'Description:'
  puts
  puts '  From a list of Hiera yaml data files, create a new file'
  puts '  containing all of the keys which are identical in all of the input files,'
  puts '  and modify the input files in-place to remove those keys.'
  puts
  puts 'Usage:'
  puts
  puts '  ./separate-out-common-data.rb OUTPUT.yaml INPUT-1.yaml INPUT-2.yaml [...]'

  exit 1
end

# From a list of filenames for Hiera yaml data files, create a hash containing
# all of the keys which are identical in all of the given files.
#
# @param inputs [Array] array of filenames
def common_data(filenames)
  inputs = filenames.reduce({}) do |memo, filename|
    memo.merge({
      path: filename,
      data: YAML.load_file(filename),
    })
  end

  keys = inputs.reduce([]) do |memo, input|
    (memo + input[:data].keys).uniq
  end

  common_data_keys = keys.select do |key|
    inputs.all? { |input| inputs.first[:data][key] == input[:data][key] }
  end

  common_data_keys.reduce({}) do |memo, key|
    memo[key] = inputs.first[:data][key]
    memo
  end
end

# Update a Hiera yaml file in-place and remove from it all of the specified keys.
#
# @param keys [Array] a list of keys to remove from a file
# @param file [String] a filename to remove the keys from
def remove_keys!(file, remove_keys)
  subtracted = YAML.load_file(file).select { |key| !remove_keys.include?(key) }
  File.write(file, subtracted.to_yaml)
end

## MAIN

output = ARGV.shift
if File.exist?(output)
  puts "File #{output} already exists! Cowardishly refusing to continue."
  exit 1
end

inputs = ARGV

File.write(output, common_data(inputs).to_yaml)
inputs.each { |input| remove_keys!(input) }
