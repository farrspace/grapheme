require "termbox"

module Terminal
  extend self
  include Termbox

  @@window = Window.new

  def width
    @@window.width
  end

  def height
    @@window.height
  end
end
