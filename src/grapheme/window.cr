class Window
  @width : Int32
  @height : Int32

  def initialize
    @width = Terminal.width
    @height = Terminal.height
  end

  def clear
    print "\e[H\e[2J"
  end

  def draw(buffer, y, x, lastkey, message)
    print "\e[H\e[2J"
    print "\e[0;0H"

    buffer_height = buffer.size

    0.upto(@height - 10) do |i|
      print buffer[i] if i < buffer.size
      print "\e[1E"
    end

    print "=" * @width
    print "\e[1E"

    print y
    print " "
    print x
    print " "
    print "<"
    print message
    print ">"
    print " "
    print "["
    print lastkey.inspect
    print "]"
    print " "

    print buffer.inspect

    print "\e[#{y + 1};#{x + 1}H"

    return
  end
end
