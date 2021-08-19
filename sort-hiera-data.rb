#!/opt/puppetlabs/puppet/bin/ruby

class Chunker
  attr_reader :chunks

  def self.keep_together?(line)
    !!(line =~ KEEP_TOGETHER)
  end

  def self.comment?(line)
    !!(line =~ COMMENT)
  end

  def initialize
    @chunks = [ [] ]
  end

  def <<(line)
    @chunks.last << line
  end

  def chunk
    @chunks << []
  end

  def to_sorted_yaml
    sorted = @chunks.sort_by { |lines| sortkey(lines) }
    topsort(%r{^lookup_options:\s*(#.*)?}, sorted)
    topsort(%r{^---$}, sorted)

    sorted.map { |lines| lines.join('') }
          .join('')
  end

  private

  KEEP_TOGETHER = Regexp.union([ %r{^\s*$}, %r{^\s+}, %r{^- }])
  COMMENT = Regexp.union([%r{^#}])

  def sortkey(lines)
    lines.find { |line| line =~ %r{^[^#\s]} } || ''
  end

  def topsort(search, chunks)
    index = chunks.index { |lines| sortkey(lines) =~ search }
    return unless index
    chunks.unshift(chunks.delete_at(index))
  end
end

file = ARGF.file
chunker = Chunker.new

# Put the first line into the chunker's first chunk, then rewind the file
# pointer so that #each_cons will have the correct prev and line values when
# it starts.
chunker << file.readline
file.rewind

# Use #each_cons(2) to process every line in the file one at a time, with the
# ability to review what the previous line was.
file.each_cons(2) do |prev, line|
  # Start a new chunk unless the line should be kept together (with the
  # previous line), or the previous line was a first-column comment. We
  # attach first-column comments to the data line that follows them.
  chunker.chunk unless Chunker.keep_together?(line) || Chunker.comment?(prev)

  # Add the line to the current chunk
  chunker << line
end

puts chunker.to_sorted_yaml
