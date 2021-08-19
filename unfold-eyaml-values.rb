#!/opt/puppetlabs/puppet/bin/ruby

# Usage:
#
#   ./unfold-eyaml-values.rb < common.yaml > common-unfolded.yaml
#

file = ARGF.file

until file.eof?
  # Read a line
  line = file.readline

  # Folded strings *might* be eyaml values
  if line =~ %r{: >$}
    # If it is an eyaml value, continue reading lines (save them in an array)
    # until reaching the end of it
    if (nextline = file.readline) =~ %r{^\s*ENC\[}
      enc = [nextline]
      until nextline =~ %r{\]$}
        enc << nextline = file.readline
      end

      # Unfold the value
      value = enc.map(&:strip).join('')

      # Print the unfolded key and eyaml value
      puts line.chomp(">\n") + value
    else
      # It wasn't an eyaml value; print the lines we've read and move on
      puts line
      puts nextline
    end
  else
    # Print lines of non-interest and move on
    puts line
  end
end
