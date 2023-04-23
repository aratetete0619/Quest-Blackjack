# frozen_string_literal: true

require_relative 'doubling'
require_relative 'split'
require_relative 'surrender'

class SpecialRule
  def initialize(number_of_rule, player)
    @selected_rule = case number_of_rule
                     when 1 then Doubling.new(player)
                     when 2 then Split.new(player)
                     when 3 then Surrender.new(player)
                     end
    @selected_rule.start
  end

  def active
    @selected_rule
  end

  def includes_splitting?
    @selected_rule.is_a?(Split)
  end
end
