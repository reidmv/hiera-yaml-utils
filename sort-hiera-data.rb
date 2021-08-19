#!/opt/puppetlabs/puppet/bin/ruby

class Chunker
  attr_reader :chunks

  def initialize
    @chunks = [ [] ]
  end

  def <<(line)
    @chunks.last << line
  end

  def chunk
    @chunks << []
  end

  def sorted_yaml
    sorted = @chunks.sort_by { |lines| sortkey(lines) }
    topsort(%r{^lookup_options:\s*(#.*)?}, sorted)
    topsort(%r{^---$}, sorted)

    sorted.map { |lines| lines.join('') }
          .join('')
  end

  private

  def sortkey(lines)
    lines.find { |line| line =~ %r{^[^#\s]} } || ''
  end

  def topsort(search, chunks)
    index = chunks.index { |lines| sortkey(lines) =~ search }
    return unless index
    chunks.unshift(chunks.delete_at(index))
  end
end

keep_together = Regexp.union([
  %r{^\s*$},
  %r{^\s+},
])

comment = Regexp.union([
  %r{^#},
])

chunker = Chunker.new

File.open('common.yaml') do |file|
  chunker << file.readline
  file.rewind
  file.each_cons(2) do |prev, line|
    chunker.chunk unless (line =~ keep_together) || (prev =~ comment)
    chunker << line
  end
end

puts chunker.sorted_yaml
