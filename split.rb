require_relative 'card'

# frozen_string_literal: true

class Split
  attr_reader :splitting

  def initialize(player)
    @player = player
    @splitting = []
    @splitting << @player.name
  end

  def start
    @player.betting_chips *= 2
    puts "スプリットを選択しました。掛け金は2倍され#{@player.betting_chips}枚になります。"
    @player.cards_split1 << @player.having_cards[0]
    @player.cards_split2 << @player.having_cards[1]
  end

  def to_deal_card
    @cycle1 = :on
    @cycle2 = :on

    split1_turn if @cycle1 == :on

    split2_turn if @cycle2 == :on

    if @splitting && @player.having_points == 11
      puts "#{@player.name}はAのスプリットをしているためここで終了します。"
    end
  end

  def select_cards_from_hand
    loop do
      points1 = @player.having_points(@player.cards_split1)
      points2 = @player.having_points(@player.cards_split2)
      puts "#{@player.name}の現在の得点は1枚目が#{points1}点、2枚目が#{points2}点です。"
      puts '1枚目か2枚目のどちらかを選んでください。(1か2を入力してください)'
      answer = gets.chomp.to_i

      break @player.having_points(@player.cards_doublet2) if answer == 2
      break @player.having_points(@player.cards_doublet1) if answer == 1
    end
  end

  def player_lose(_cycle)
    puts 'バーストしてしまいました。'
    _cycle = :off
    exit  if @cycle1 == :off && @cycle2 == :off
  end

  def split1_turn
    loop do
      puts "#{@player.name}の現在の得点は#{@player.having_points(@player.cards_split1)}点です。カードを引きますか？（Y/N）"
      answer = gets.chomp
      @cycle1 = :off unless answer == 'Y'
      break if @cycle1 == :off && @cycle2 == :off

      player_lose(@cycle1) if @player.busted?(@player.cards_split1)

      @player.drawing_cards_at_first_in_splitting
      puts "#{@player.name}の引いたカードは#{@player.cards_split1_suits}の#{@player.cards_split1_number}です。"
    end
  end

  def split2_turn
    loop do
      puts "#{@player.name}はスプリットをしているため2枚目の手札を引くことができます。"
      puts "2枚目の#{@player.name}の現在の得点は#{@player.having_points(@player.cards_split2)}点です。カードを引きますか？（Y/N）"
      answer = gets.chomp
      @cycle2 = :off unless answer == 'Y'
      break if @cycle1 == :off && @cycle2 == :off

      player_lose(@cycle2) if @player.busted?(@player.cards_split2)

      @player.drawing_cards_at_second_in_splitting
      puts "#{@player.name}の引いたカードは#{@player.cards_split2_suits}の#{@player.cards_split2_number}です。"
      redo
    end
  end
end
