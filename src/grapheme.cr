require "./grapheme/*"

module Grapheme
  extend self

  def run
    w = Window.new
    w.clear

    buffer = Array(String).new
    buffer << ""

    lastkey = -1

    y = 0
    x = 0

    STDIN.raw!

    print "\033[?25h"

    while true
      while y > buffer.size - 1
        buffer << ""
      end

      sz = buffer.size

      w.draw(buffer, y, x, lastkey)

      b = STDIN.read_char

      if b == '\e'
        z = STDIN.read_char
        if z && z.ord == 79
          z = STDIN.read_char
          zo = z && z.ord
          if zo == 65
            # up arrow
            y = ((y - 1) % sz)
            x = x % (buffer[y].size + 1)
          elsif zo == 66
            # down arrow
            y = ((y + 1) % sz)
            x = x % (buffer[y].size + 1)
          elsif zo == 68
            # left arrow
            nx = x - 1
            if nx == -1
              next if y == 0
              y = (y - 1) % sz
              x = buffer[y].size
            else
              x = nx
            end
          elsif zo == 67
            # right arrow
            nx = x + 1
            if nx > buffer[y].size
              next if y + 1 == sz
              y = (y + 1) % sz
              x = 0
            else
              x = nx
            end
          else
            buffer[y] += zo.inspect
          end
        else
          zo = z && z.ord
          buffer[y] += zo.inspect
          z = STDIN.read_char
          zo = z && z.ord
          buffer[y] += zo.inspect
        end

        next
      end

      bo = b && b.ord

      if b == '\u{3}'
        leave
        # elsif ord == 27
        #   ln = (ln - 1) % sz
      elsif b && (b.alphanumeric? || bo == 32)
        buffer[y] += b
        x += 1
      elsif b == '\r'
        y += 1
        x = 0
      elsif bo == 127
        # buffer[y]
      else
        lastkey = b && b.ord
      end
    end
  end

  def leave
    STDIN.cooked!
    puts "bye"
    exit
  end
end

Grapheme.run
