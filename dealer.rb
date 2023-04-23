# frozen_string_literal: true

require_relative 'person'

class Dealer < Person
  attr_reader :type_at_second, :number_at_second

  def initialize
    super
    @name = 'ディーラー'
  end

  def drawing_cards_at_second_time
    @type_at_second = @deck.cards.last.keys.first
    @number_at_second = @deck.cards.last.values.first
  end
end
