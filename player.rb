# frozen_string_literal: true

require_relative 'person'
require_relative 'chip'
require_relative 'deck'

# プレイヤークラス
class Player < Person
  attr_accessor :betting_chips

  def initialize(name = nil)
    super
    @name = name || ' あなた'
    @betting_chips = 0
  end

  def drawing_cards_at_first_in_splitting
    @deck.drew_at_first_in_splitting
  end

  def drawing_cards_at_second_in_splitting
    @deck.drew_at_second_in_splitting
  end

  def cards_split1
    @deck.cards_split1
  end

  def cards_split2
    @deck.cards_split2
  end

  def cards_split1_suits
    @deck.cards_split1.last.keys.first
  end

  def cards_split1_number
    @deck.cards_split1.last.values.first
  end

  def cards_split2_suits
    @deck.cards_split2.last.keys.first
  end

  def cards_split2_number
    @deck.cards_split1.last.values.first
  end

  def having_chips
    @chip.chips
  end

  def increase_chips(bet)
    @chip.chips += bet
  end

  def decrease_chips(bet)
    @chip.chips -= bet
  end
end
