# frozen_string_literal: true

# playerがsurrenderを選択した場合の処理を行うclass
class Surrender
  def initialize(player)
    @player = player
  end

  def start
    puts 'サレンダーを選択しました。掛け金の半分を返却します。'
    puts "返却されるチップ数は#{@player.betting_chips / 2}です。　"
    @player.decrease_chips(@player.betting_chips)
    @player.increase_chips(@player.betting_chips / 2)
    puts "所持チップ数: #{@player.having_chips}"
    exit
  end
end
