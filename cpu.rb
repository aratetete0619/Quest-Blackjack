require_relative 'person'

# frozen_string_literal: true

class Cpu < Person
  def initialize(num)
    super
    @name = "CPU#{num}"
  end
end
