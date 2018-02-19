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
    # Take control of the terminal, so we can handle key presses and drawing.
    STDIN.raw!
  end

  # Exit the app
  def leave
    # Return the terminal to normal mode ("cooked" being the opposite of "raw".
    # This joke that took me about a day to get.)
    STDIN.cooked!
    puts "bye"
    exit
  end

  # Main loop of the app.
  def run
    while true
      # Draw our lovely editor
      @w.draw(@buffer, @y, @x, @lastkey, @message)

      # Get a key press.
      # I haven't decided if it would be better to read a char or a byte here,
      # but a char is convenient for now.
      b = STDIN.read_char

      # Branch for arrow keys
      if b == '\e'
        z = STDIN.read_char
        if z == '['
          z = STDIN.read_char
          if z == 'A'
            # up arrow
            arrow_up
          elsif z == 'B'
            # down arrow
            arrow_down
          elsif z == 'D'
            arrow_left
          elsif z == 'C'
            # right arrow
            arrow_right
          end
        else
          # Debugging output
          zo = z && z.ord
          @buffer[@y] += "unknown \\e < "
          @buffer[@y] += zo.inspect
          @buffer[@y] += " "
          z = STDIN.read_char
          zo = z && z.ord
          @buffer[@y] += zo.inspect
          @buffer[@y] += "> "
        end

        next
      end

      # I'm fuzzy on how to write some of the chars received from keystrokes as char literals, so ord, which gives the codepoint of the character has been useful.
      bo = b && b.ord

      if b == '\u{3}'
        # control + C
        leave
      elsif bo == 19
        # Control + S
        save_file
      elsif b == '\r'
        # return key
        return_at
      elsif bo == 127
        # backspace key
        backspace_at
      else
        # other key, so handle it as entered text
        @lastkey = b && b.ord
        insert_character(b) if b
        @x += 1
      end
    end
  end

  def insert_character(new_character : Char)
    chars = @buffer[@y].each_char.to_a
    chars.insert(@x, new_character)
    @buffer[@y] = chars.join
  end

  # Subtract, with a lower limit for the result of 0
  def sub_lim_0(a : Int32, b : Int32)
    result = a - b
    if result < 0
      result = 0
    end
    result
  end

  # Add, with an upper limit for the result of max
  def add_lim_max(a : Int32, b : Int32, max : Int32)
    result = a + b
    if result > max
      result = max
    end
    result
  end

  def save_file
    filename = "/tmp/grapheme_tmp.txt"
    File.write(filename, @buffer.join("\n"))
    @message = "saved to #{filename}"
  end

  # Handle return (enter) key
  def return_at
    if @x == 0
      # If we're at the beginning of the line, insert a new blank line here
      @buffer.insert(@y, "")
    elsif @x == @buffer[@y].size
      # If we're at the end of a line, add a blank line after
      @buffer.insert(@y + 1, "")
    else
      # Otherwise we're breaking the line at the cursor.
      left = @buffer[@y][0..sub_lim_0(@x, 1)]
      right = @buffer[@y][@x..@buffer[@y].size]

      # Add the broken line parts and then remove the current line
      @buffer.insert(@y + 1, right)
      @buffer.insert(@y + 1, left)
      @buffer.delete_at(@y)
    end

    @y += 1
    @x = 0
  end

  def backspace_at
    # Backspace at the beginning of the document does nothing
    if @x == 0 && @y == 0
      return
    end

    s = @buffer[@y]

    # Pressing backspace on an empty line
    if s == ""
      # If we're at the top do nothing
      return if @y == 0
      # Otherwise delete this line
      @buffer.delete_at(@y)
      move_left
      return
    end

    # Pressing backspace at the beginning of a line
    if @x == 0
      # Go to the end of the previous line
      move_left

      # If there are still lines after this one
      if @y + 1 < @buffer.size
        # combine the next line and this one
        @buffer[@y] = @buffer[@y] + @buffer[@y + 1]
        @buffer.delete_at(@y + 1)
        return
      end
    end

    # Otherwise convert line to array and remove backspaced character, then
    # adjust cursor.
    line_array = @buffer[@y].each_char.to_a
    line_array.delete_at(@x - 1)
    @buffer[@y] = line_array.join
    move_left
  end

  # Handle left arrow key. Since this is my editor, left and right arrow do not
  # leave the current line. I don't think I ever use it for that intentionally.
  def arrow_left
    @x = sub_lim_0(@x, 1)
  end

  # Handle right arrow key (but remain on this line)
  def arrow_right
    @x = add_lim_max(@x, 1, @buffer[@y].size)
  end

  # Handle up arrow key, moving left to the end of the line if needed
  def arrow_up
    @y = sub_lim_0(@y, 1)
    move_to_end_of_line_or_less
  end

  # Handle down arrow key, moving left to the end of the line if needed
  def arrow_down
    @y = add_lim_max(@y, 1, sub_lim_0(@buffer.size, 1))
    move_to_end_of_line_or_less
  end

  # Move the cursor to end of the line
  def move_to_end_of_line_or_less
    sz = @buffer[@y].size
    @x = sz if @x > sz
  end

  # Move the cursor leftward, possibly moving to the previous line.
  def move_left
    # Moving left does nothing at the beginning of the document
    return if @y == 0 && @x == 0

    nx = @x - 1

    # If we moved past the beginning of this line, go to the previous line
    if nx < 0
      @y = sub_lim_0(@y, 1)
      @x = @buffer[@y].size
    else
      @x = nx
    end
  end
end
