# frozen_string_literal: true

# プレイヤーの所持チップ数を管理するclass
class Chip
  attr_accessor :chips

  def initialize
    @chips = 100
  end
end
