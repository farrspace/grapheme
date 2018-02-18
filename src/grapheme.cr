require "./grapheme/*"

module Grapheme
  extend self

  def run
    Editor.new.run
  end
end

Grapheme.run
