require_relative 'person'
require_relative 'dealer'
require_relative 'player'
require_relative 'cpu'
require_relative 'card'
require_relative 'chip'
require_relative 'special_rule'

# frozen_string_literal: true

require 'debug'

class Game
  def initialize
    @player = Player.new

    @dealer = Dealer.new

    @cpu_players = []

    @result_of_dealing_cards = {}
  end

  def start
    setting_cpu_count

    puts 'ブラックジャックを開始します'
    2.times do
      take_turn(@player)
      @cpu_players.each(&:drawing_cards)
    end

    setting_stake

    setting_special_rule

    take_turn(@dealer)

    @dealer.drawing_cards_at_second_time
    puts "#{@dealer.name}の引いた2枚目のカードはわかりません。"

    if @special_rule.includes_splitting?
      take_turn_in_split
      exit if @player.having_points(@player.cards_split1) >21 && @player.having_points(@player.cards_split2) > 21
    end

    additional_player_turn unless @special_rule.includes_splitting?

    player_lose if @player.busted?

    pick_up_cards_for_win

    additional_cpu_turn

    puts "ディーラーの引いた2枚目のカードは#{@dealer.type_at_second}の#{@dealer.number_at_second}でした。"
    puts "ディーラーの現在の得点は#{@dealer.having_points}です。"

    additional_dealer_turn

    final_judgment

    result_of_game

    transfer_chips

    puts '最終結果'
    puts "#{@player.name}の所持金は#{@player.having_chips}枚です。"
    puts @result_of_dealing_cards.map { |key, value| "#{key}: #{value}点" }.join('、')
    puts 'ブラックジャックを終了します'
  end

  private

  def setting_cpu_count
    puts '対戦したいCPUの数(0~2人)を指定してください'
    number_of_cpu = gets.chomp.to_i
    number_of_cpu.times { |i| @cpu_players << Cpu.new(i + 1) }
  end

  def take_turn(player)
    player.drawing_cards
    puts "#{player.name}の引いたカードは#{player.card_suit}の#{player.card_number}です"
  end

  def setting_stake
    loop do
      puts '掛け金を設定してください'
      puts "現在の#{@player.name}の所持チップ数は#{@player.having_chips}です。"
      @player.betting_chips = gets.chomp.to_i
      puts 'エラー：0以下の数字、もしくは数字以外の値が入力されました。' unless @player.betting_chips > 0
      break if @player.betting_chips > 0
    end
  end

  def setting_special_rule
    puts "特殊ルールを選択しますか？(1:ダブリング, 2:スプリット, 3:サレンダー, 4:選択しない)
    所持チップ数: #{@player.having_chips}, 掛け金: #{@player.betting_chips}"
    loop do
      number_of_rule = gets.chomp.to_i
      if @player.having_cards.map(&:values).flatten.uniq.length != 1 && number_of_rule == 2
        puts 'あなたの手札ではスプリットが出来ません。もう一度選択して下さい'
        redo
      elsif number_of_rule == 1 || number_of_rule == 2 || number_of_rule == 3
        @special_rule = SpecialRule.new(number_of_rule, @player)
        break
      end
    end
  end

  def additional_player_turn
    loop do
      puts "#{@player.name}の現在の得点は#{@player.having_points}点です。カードを引きますか？（Y/N）"
      answer = gets.chomp
      break unless answer == 'Y'

      take_turn(@player)
      player_lose if @player.busted?
    end
  end

  def player_lose
    puts "#{@player.name}の現在の得点は#{@player.having_points}です。"
    puts "#{@player.name}の負けです。"
    @player.decrease_chips(@player.betting_chips)
    puts "#{@player.name}の所持金は#{@player.having_chips}枚です。"
    puts 'ブラックジャックを終了します'
    exit
  end

  def dealer_lose
    puts 'ディーラーが21点を超えたためプレイヤー全員の勝ちです'
    @player.increase_chips(@player.betting_chips * 2)
    puts "#{@player.name}の所持金は#{@player.having_chips}枚です。"
    puts 'ブラックジャックを終了します'
    exit
  end

  def pick_up_cards_for_win
    if @special_rule.includes_splitting?
      @result_of_dealing_cards[@player.name] = @special_rule.active.select_cards_from_hand
    else
      @result_of_dealing_cards[@player.name] = @player.having_points
    end
  end

  def additional_cpu_turn
    @cpu_players.each do |cpu_player|
      puts "#{cpu_player.name}のターンです。もう少しお待ちください。"
      sleep(3)
      rand(0..2).times do
        take_turn(cpu_player)
      end
      if cpu_player.busted?
        puts "#{cpu_player.name}は21点を超えたため失格です。"
        break
      end
      unless cpu_player.busted?
        @result_of_dealing_cards[cpu_player.name] = cpu_player.having_points
      end
    end
  end

  def additional_dealer_turn
    if @dealer.having_points < 17
      puts 'ディーラーは17点を超えるまでカードを引きます'
      loop do
        take_turn(@dealer)
        dealer_lose if @dealer.busted?
        break if @dealer.having_points >= 17
      end
    end
    @result_of_dealing_cards[@dealer.name] = @dealer.having_points
    puts "ディーラーの点数は、#{@result_of_dealing_cards[@dealer.name]}点となります。"
  end

  def take_turn_in_split
    @special_rule.active.to_deal_card
  end

  def final_judgment
    dealer_points = @result_of_dealing_cards[@dealer.name]
    @winners = @result_of_dealing_cards.select { |_key, value| value > dealer_points }
    @drawers = @result_of_dealing_cards.select { |key, value| value == dealer_points && key != @dealer.name }
  end

  def result_of_game
    winners_reports if @winners.any?
    drawers_reports if @drawers.any?
    dealer_win if @winners.empty? && @drawers.empty?
  end

  def winners_reports
    puts "#{@winners.keys.join('と')}の勝ちです。"
    puts @winners.map { |key, value| "#{key}: #{value}点" }.join('、').to_s
    unless @winners.keys.include?(@player.name) || @drawers.keys.include?(@player.name)
      puts "#{@player.name}の負けです。"
    end
    puts "#{@player.name}は引き分けです。" if @drawers.keys.include?(@player.name)
  end

  def drawers_reports
    puts "ディーラーは、#{@drawers.keys.join('と')}と引き分けです。"
    puts @drawers.map { |key, value| "#{key}: #{value}点" }.join('、').to_s
    unless @winners.keys.include?(@player.name) || @drawers.keys.include?(@player.name)
      puts "#{@player.name}の負けです。"
    end
  end

  def dealer_win
    puts "#{@player.name}の点は、#{@result_of_dealing_cards[@player.name]}点でした。"
    puts "#{@dealer.name}の勝ちです。"
    puts "#{@player.name}の負けです。"
  end

  def transfer_chips
    case @player.name
    when *@winners.keys
      @player.increase_chips(@player.betting_chips * 2)
    when *@drawers.keys
      @player.increase_chips(0)
    else
      @player.decrease_chips(@player.betting_chips)
    end
  end
end

game = Game.new
game.start
