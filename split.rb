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

    split1_turn

    split2_turn

    if @splitting && @player.having_points == 11
      puts "#{@player.name}はAのスプリットをしているためここで終了します。"
    end

  end

  def select_cards_from_hand
    loop do
      points1 = @player.having_points(@player.cards_split1) if @player.having_points(@player.cards_split1) <= 21
      points2 = @player.having_points(@player.cards_split2) if @player.having_points(@player.cards_split2) <= 21
      points = []
      points << points1 if points1
      points << points2 if points2
      puts "#{@player.name}の現在の得点は#{points.join("点と")}点です。"
      if points.length > 1
        puts '1枚目か2枚目のどちらかを選んでください。(1か2を入力してください)'
        answer = gets.chomp.to_i
      end

      break points.pop if points.length == 1
      break @player.having_points(@player.cards_split1) if answer == 1
      break @player.having_points(@player.cards_split2) if answer == 2
    end
  end

  def player_lose(cycle)
    puts 'バーストしてしまいました。'
    cycle = false
    exit if @cycle1 == false && @cycle2 == false
  end

  def split1_turn
    @cycle1 = true
    loop do
      if @player.busted?(@player.cards_split1)
        @cycle1 = player_lose(@cycle1)
        break if !@cycle1
      end
      puts "#{@player.name}の現在の得点は#{@player.having_points(@player.cards_split1)}点です。カードを引きますか？（Y/N）"
      answer = gets.chomp
      break @cycle1 = false unless answer == 'Y'


      @player.drawing_cards_at_first_in_splitting
      puts "#{@player.name}の引いたカードは#{@player.cards_split1_suits}の#{@player.cards_split1_number}です。"
    end
  end

  def split2_turn
    @cycle2 = true
    loop do
      if @player.busted?(@player.cards_split2)
        @cycle2 = player_lose(@cycle2)
        break if !@cycle2
      end
      puts "#{@player.name}はスプリットをしているため2枚目の手札を引くことができます。"
      puts "2枚目の#{@player.name}の現在の得点は#{@player.having_points(@player.cards_split2)}点です。カードを引きますか？（Y/N）"
      answer = gets.chomp
      break @cycle2 = false unless answer == 'Y'


      @player.drawing_cards_at_second_in_splitting
      puts "#{@player.name}の引いたカードは#{@player.cards_split2_suits}の#{@player.cards_split2_number}です。"
    end
  end
end
