class Window
  @width : Int32
  @height : Int32

  # Commonly used ANSI escape codes
  CLEAR_SCREEN                          = "\e[H\e[2J"
  SHOW_CURSOR                           = "\033[?25h"
  MOVE_CURSOR_TO_ORIGIN                 = "\e[0;0H"
  MOVE_CURSOR_TO_BEGINNING_OF_NEXT_LINE = "\e[1E"

  SPACE = " "

  def initialize
    # I was originally using a library to get the window size, but it seemed to alter the way I received key codes, so until I find a better way I'm calling out to this small C program.
    winsize = `~/projects/grapheme/hack/winsize`.split

    @width = winsize.last.to_i
    @height = winsize.first.to_i
    print SHOW_CURSOR
  end

  def clear
    print CLEAR_SCREEN
  end

  # Set the font/foreground color, using 3 0-255 RGB values
  def color(r : Int32, g : Int32, b : Int32)
    print "\033[38;2;#{r};#{g};#{b}m"
  end

  # Set the background color, using 3 0-255 RGB values
  def bg_color(r : Int32, g : Int32, b : Int32)
    print "\033[48;2;#{r};#{g};#{b}m"
  end

  # Resets fg and bg color
  def reset_color
    print "\033[0m"
  end

  # Reset only the background color
  def reset_bg
    print "\033[49m"
  end

  # Pad a string with spaces so it takes up the whole line. This is useful if I want to use a background color for a while line.
  def pad_string(string : String)
    print SPACE
    print string
    print SPACE * (@width - string.size - 1)
  end

  # Put a string at the left and right side of the screen.
  def pad_2_strings(string1 : String, string2 : String)
    lw = string1.size
    rw = string2.size

    print SPACE
    print string1
    print SPACE * (@width - lw - rw - 2)
    print string2
    print SPACE
  end

  # Choose where the terminal cursor is drawn
  def move_cursor(y : Int32, x : Int32)
    print "\e[#{x + 1};#{y + 1}H"
  end

  # Draw the window.
  def draw(buffer, y, x, lastkey, message)
    # Clear and start in top left
    print CLEAR_SCREEN
    print MOVE_CURSOR_TO_ORIGIN

    buffer_height = buffer.size

    # Show as much of the buffer as fits on the screen (no scrolling yet!), reserving 2 lines for status output.
    0.upto(@height - 3) do |i|
      print buffer[i] if i < buffer_height
      # Have to go to the next line on our own
      print MOVE_CURSOR_TO_BEGINNING_OF_NEXT_LINE
    end

    # Status bar
    bg_color(50, 50, 50)
    # Show the user facing / 1 indexed line and column, and some debugging info for us.
    pad_2_strings("line #{y + 1}, column #{x + 1}", "#{y}, #{x} <#{message}> [#{lastkey.inspect}] ")
    # Inspect the buffer, for debugging
    pad_string buffer.inspect
    print MOVE_CURSOR_TO_BEGINNING_OF_NEXT_LINE
    reset_bg

    # Place the cursor back to the user's cursor position
    move_cursor(x, y)
  end
end
