class Editor
  @lastkey : (Int32 | Nil)

  def initialize
    @w = Window.new
    @y = 0
    @x = 0
    @buffer = Array(String).new
    @buffer << ""

    @message = ""

    @w.clear
    STDIN.raw!
    print "\033[?25h"
  end

  def leave
    STDIN.cooked!
    puts "bye"
    exit
  end

  def run
    while true
      while @y > @buffer.size - 1
        @buffer << ""
      end

      sz = @buffer.size

      @w.draw(@buffer, @y, @x, @lastkey, @message)

      b = STDIN.read_char

      if b == '\e'
        z = STDIN.read_char
        if z && z.ord == 79
          z = STDIN.read_char
          zo = z && z.ord
          if zo == 65
            # up arrow
            arrow_up
          elsif zo == 66
            # down arrow
            arrow_down
          elsif zo == 68
            arrow_left
          elsif zo == 67
            # right arrow
            arrow_right
          else
            @buffer[@y] += zo.inspect
          end
        else
          zo = z && z.ord
          @buffer[@y] += zo.inspect
          z = STDIN.read_char
          zo = z && z.ord
          @buffer[@y] += zo.inspect
        end

        next
      end

      bo = b && b.ord

      if b == '\u{3}'
        leave
      elsif bo == 19
        File.write("/tmp/grapheme_tmp.txt", @buffer.join("\n"))
        @message = "saved"
      elsif b && (b.alphanumeric? || bo == 32)
        @buffer[@y] += b
        @x += 1
      elsif b == '\r'
        @y += 1
        @x = 0
      elsif bo == 127
        backspace_at
      else
        @lastkey = b && b.ord
      end
    end
  end

  def sub_lim_0(a : Int32, b : Int32)
    result = a - b
    if result < 0
      result = 0
    end
    result
  end

  def add_lim_max(a : Int32, b : Int32, m : Int32)
    result = a + b
    if result > m
      result = m
    end
    result
  end

  def backspace_at
    s = @buffer[@y]

    if s == ""
      return if @y == 0
      @buffer.delete_at(@y)
      move_left
      return
    end

    if @x == 1
      left = ""
    else
      left = s[0..sub_lim_0(@x, 2)]
    end
    right = s[@x..@buffer.size]

    @buffer[@y] = left + right
    move_left
  end

  def arrow_left
    @x = sub_lim_0(@x, 1)
  end

  def arrow_right
    @x = add_lim_max(@x, 1, @buffer[@y].size)
  end

  def arrow_up
    @y = sub_lim_0(@y, 1)
    move_to_end_of_line_or_less
  end

  def arrow_down
    # stop at end
    @y = add_lim_max(@y, 1, sub_lim_0(@buffer.size, 1))

    # add new lines at end
    # @y = add_lim_max(@y, 1, @buffer.size)
    move_to_end_of_line_or_less
  end

  def move_to_end_of_line_or_less
    sz = @buffer[@y].size
    @x = sz if @x > sz
  end

  def move_up
    @y = sub_lim_0(@y, 1)
    move_to_end_of_line_or_less
  end

  def move_left
    return if @y == 0 && @x == 0

    nx = @x - 1
    if nx < 0
      @y = sub_lim_0(@y, 1)
      @x = @buffer[@y].size
    else
      @x = nx
    end
  end

  def move_right
  end
end
