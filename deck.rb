# frozen_string_literal: true

require_relative 'card'

class Deck
  attr_reader :cards, :cards_split1, :cards_split2

  def initialize
    @cards = []
    @cards_split1 = []
    @cards_split2 = []
  end

  def drew
    # @cards << { Card::SUITS.sample => Card::NUMBER.sample}
    @cards << { 'ハート' => 2 }
  end

  def drew_at_first_in_splitting
    @cards_split1 << { Card::SUITS.sample => Card::NUMBER.sample }
  end

  def drew_at_second_in_splitting
    @cards_split2 << { Card::SUITS.sample => Card::NUMBER.sample }
  end
end
