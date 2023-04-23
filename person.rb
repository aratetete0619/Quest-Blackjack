# frozen_string_literal: true

require_relative 'chip'
require_relative 'deck'
require_relative 'card'

# 全てのプレイヤーの基底クラス
class Person
  attr_accessor :name, :chip, :deck

  def initialize(_num = nil)
    @chip = Chip.new
    @deck = Deck.new
  end

  def having_cards
    @deck.cards
  end

  def drawing_cards
    @deck.drew
  end

  def card_suit
    @deck.cards.last.keys.first
  end

  def card_number
    @deck.cards.last.values.first
  end

  def having_points(cards = @deck.cards)
    points = 0
    cards.each do |card|
      card.each do |_suits, num|
        points += case num
                  when :A
                    if points <= 10
                      11
                    else
                      1
                    end
                  when :J, :Q, :K
                    10
                  else
                    num
                  end
      end
    end
    points
  end

  def busted?(cards = @deck.cards)
    having_points(cards) > 21
  end
end
