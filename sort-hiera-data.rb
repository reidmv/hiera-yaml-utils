#!/opt/puppetlabs/puppet/bin/ruby

chunks = []

union = Regexp.union([
  %r{^#},
  %r{^$},
  %r{^\s+},
])


File.open('common.yaml') do |file|
  # Prime the loop
  line, chunk = [file.readline, []]

  loop do
    until line =~ union
      chunk << line
      chunks << chunk
      line, chunk = [nil, []]
      break if file.eof?
      line = file.readline
    end

    until line !~ union
      chunk << line
      break if file.eof?
      line = file.readline
    end

    if file.eof?
      chunk << line
      chunks << chunk unless chunk.empty?
      break
    end
  end

  require 'pry'; binding.pry

  dump = chunks.sort_by { |lines| lines.find { |line| line !~ union } }
               .sort_by { |lines| lines.last =~ %r{^---$} ? 0 : 1 }
               .map { |lines| lines.join('') }
               .join('')

  puts dump
end
