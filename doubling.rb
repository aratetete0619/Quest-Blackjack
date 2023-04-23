# frozen_string_literal: true

class Doubling
  attr_reader :doubling

  def initialize(player)
    @player = player
    @doubling = []
    @doubling << @player.name
  end

  def start
    puts "ダブリングを選択しました。#{@player.betting_chips}枚まで上乗せすることができます。"
    loop do
      added_betting_chips = gets.chomp.to_i
      if added_betting_chips > @player.betting_chips
        puts '所持チップ数を超えて設定することはできません。'
        redo
      end
      @player.betting_chips += added_betting_chips
      break
    end
  end

  def dealing_card
    loop do
      puts "#{@player.name}の現在の得点は#{@player.having_points}点です。カードを引きますか？（Y/N）"
      answer = gets.chomp
      break unless answer == 'Y'

      @player.drawing_cards(@cards.drew)
      puts "#{@player.name}の引いたカードは#{@cards.type}の#{@cards.number}です。"
      break puts "#{@player.name}はダブリングしているためここで終了します。"
    end
  end
end
