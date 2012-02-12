module Hadley::Utils
  extend self

  def camelize(word, uc_first=true)
    parts = word.split('_')
    assemble = lambda { |head, tail| head + tail.capitalize }
    uc_first ? parts.inject('', &assemble) : parts.inject(&assemble)
  end

end
