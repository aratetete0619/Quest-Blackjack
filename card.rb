# frozen_string_literal: true

# カードのスートと数字を定数として定義するclass
class Card
  SUITS = %w[ハート ダイヤ スペード クローバー].freeze
  NUMBER = [:A, 2, 3, 4, 5, 6, 7, 8, 9, 10, :J, :Q, :K].freeze
end
