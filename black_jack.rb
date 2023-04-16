# frozen_string_literal: true

require 'debug'

class Blackjack
  def initialize
    # カードオブジェクトの生成
    @cards = Card.new

    # 引いたカードの種類
    @type = ''

    # 引いたカードの数字
    @number = 0

    # 全プレイヤーの引いたカードの合計結果
    @result_of_dealing_cards = {}

    # 掛け金に関する特殊ルール
    @doubling = []
    @splitting = []

    # 掛け金の額
    @betting_chips = 0
  end

  def start
    ### CPUの数を設定
    puts '対戦したいCPUの数(0~2人)を指定してください'
    number_of_opponents = gets.chomp.to_i
    cpu_players = []
    number_of_opponents.times do |i|
      i += 1
      cpu_player = Cpu.new("CPU#{i}")
      cpu_players << cpu_player
    end

    ### プレイヤーとディーラーを作成
    player = Player.new
    dealer = Dealer.new

    puts 'ブラックジャックを開始します'

    ### カードを各プレイヤーに2枚配布
    2.times do
      ### プレイヤーへのカードを配布
      player.drawing_cards(@cards.drew)
      puts "#{player.name}の引いたカードは#{@cards.type}の#{@cards.number}です"

      ### CPUへのカードを配布
      cpu_players.each do |cpu_player|
        cpu_player.drawing_cards(@cards.drew)
      end
    end

    ### いくら掛けるかをプレイヤーに聞く
    loop do
      puts '掛け金を設定してください'
      puts "現在の#{player.name}の所持チップ数は#{player.having_chips}です。"
      @betting_chips = gets.chomp.to_i
      break if @betting_chips.positive?
    end

    ### プレイヤーが特殊ルールを選択するか判定
    loop do
      puts "特殊ルールを選択しますか？(1:ダブリング, 2:スプリット, 3:サレンダー, 4:選択しない) 所持チップ数: #{player.having_chips}, 掛け金: #{@betting_chips}"
      number_of_rule = gets.chomp.to_i

      ## ダブリングが選択された場合
      case number_of_rule
      when 1
        doubling(player)
        puts "ダブリングを選択しました。#{@betting_chips}枚まで上乗せすることができます。"
        added_betting_chips = gets.chomp.to_i

        if added_betting_chips > player.having_chips # プレイヤーが最初の賭け金を超えて設定した場合はエラーを出す
          puts '所持チップ数を超えて設定することはできません。'
          redo
        end

        @betting_chips += added_betting_chips # 掛け金を上乗せする
        break

      ## スプリットが選択された場合
      when 2
        if player.having_cards.map(&:values).flatten.uniq.length == 1 # 2枚のカードの値が同様であれば、uniqで重複を削除した配列の長さは1になる
          split(player)
          puts "スプリットを選択しました。掛け金は2倍され#{@betting_chips}枚になります。"
          break
        else
          puts 'あなたの手札ではスプリットが出来ません。'
          redo
        end

      ## サレンダーが選択された場合
      when 3
        puts 'サレンダーを選択しました。掛け金の半分を返却します。'
        puts "返却されるチップ数は#{@betting_chips / 2}です。　"
        player.decrease_chips(@betting_chips)
        player.increase_chips(@betting_chips / 2)
        puts "所持チップ数: #{player.having_chips}"
        exit

      when 1..4
        break
      end
    end

    ### 引いたカードをディーラークラスのデータとして保存(以下流れは同様)
    dealer.drawing_cards(@cards.drew)
    puts "#{dealer.name}の引いたカードは#{@cards.type}の#{@cards.number}です"

    dealer.drawing_cards(@cards.drew)
    puts "#{dealer.name}の引いた2枚目のカードはわかりません。"

    ### ディーラーの2枚目のカードはゲーム投了時に表示するために保存
    type_at_second_by_dealer = @cards.type
    number_at_second_by_dealer = @cards.number

    ### プレイヤーがカードを引くか選択肢を与える
    loop do
      if @splitting.include?(player.name)
        puts "#{player.name}の現在の得点は#{player.having_points(player.cards_doublet1)}点です。カードを引きますか？（Y/N）"
      else
        puts "#{player.name}の現在の得点は#{player.having_points}点です。カードを引きますか？（Y/N）"
      end
      answer = gets.chomp

      break unless answer == 'Y' # プレイヤーがYesと答えた場合

      player.drawing_cards(@cards.drew)
      puts "#{player.name}の引いたカードは#{@cards.type}の#{@cards.number}です。"

      if @doubling.include?(player.name) # プレイヤーがダブリングしている場合は追加カードは一回しか引けない
        puts "#{player.name}はダブリングしているためここで終了します。"
        break
      end

      if @splitting.include?(player.name) && player.having_points == 11 # プレイヤーがスプリットしているかつAのスプリットの場合は追加カードは一回しか引けない
        puts "#{player.name}はAのスプリットをしているためここで終了します。"
        break
      end

      if @splitting.include?(player.name) # プレイヤーがスプリットしている場合は2枚目の手札を引く
        puts "#{player.name}はスプリットをしているため2枚目の手札を引くことができます。"
        puts "2枚目の#{player.name}の現在の得点は#{player.having_points(player.cards_doublet2)}点です。カードを引きますか？（Y/N）"
        answer = gets.chomp
        break unless answer == 'Y' # プレイヤーがYesと答えた場合

        player.drawing_cards_in_split(nil, @cards.drew)
        puts "#{player.name}の引いたカードは#{@cards.type}の#{@cards.number}です。"
        redo
      end

      next unless player.having_points > 21 # 合計が21を超えたらループを抜けて終了

      puts "#{player.name}の現在の得点は#{player.cards1}です。"
      puts "#{player.name}の負けです。"
      player.decrease_chips(@betting_chips)
      puts "#{player.name}の所持金は#{player.having_chips}枚です。"
      puts 'ブラックジャックを終了します'
      exit

      # プレイヤーがNOと答えた場合
    end

    ### プレイヤーがスプリットしている場合は1枚目か2枚目のどちらかを選択する
    player_having_points = 0
    loop do
      if @splitting.include?(player.name)
        puts "#{player.name}の現在の得点は1枚目が#{player.having_points(player.cards_doublet1)}点、2枚目が#{player.having_points(player.cards_doublet2)}点です。"
        puts '1枚目か2枚目のどちらかを選んでください。(1か2を入力してください)'
        answer = gets.chomp.to_i
        redo if answer != 1 && answer != 2
        player_having_points = player.having_points(player.cards_doublet2) if answer == 2
        player_having_points = player.having_points(player.cards_doublet1) if answer == 1
      else
        player_having_points = player.having_points
      end
      break
    end
    @result_of_dealing_cards[player.name] = player_having_points

    ### CPUがカードを引くか選択肢を与える
    cpu_players.each do |cpu_player|
      next unless cpu_player.having_points < 21

      puts "#{cpu_player.name}のターンです。もう少しお待ちください。"
      sleep(3)
      rand(0..2).times do
        cpu_player.drawing_cards(@cards.drew)
        puts "#{cpu_player.name}の引いたカードは#{@cards.type}の#{@cards.number}です。"

        break if cpu_player.having_points > 21 # 合計が21を超えたらループを抜けて終了
      end
      if cpu_player.having_points <= 21
        @result_of_dealing_cards[cpu_player.name] = cpu_player.having_points
      else
        @result_of_dealing_cards.delete(cpu_player.name)
      end
    end

    ### ディーターの引いた２枚目のカードをプレイヤーに告示
    puts "ディーラーの引いた2枚目のカードは#{type_at_second_by_dealer}の#{number_at_second_by_dealer}でした。"
    puts "ディーラーの現在の得点は#{dealer.having_points}です。"

    ### ディーラーがカードを引くか選択肢を与える
    if dealer.having_points < 17
      loop do
        dealer.drawing_cards(@cards.drew)
        puts "ディーラーの引いたカードは#{@cards.type}の#{@cards.number}です。"

        if dealer.having_points > 21 # 合計が21を超えたらゲーム終了
          puts 'プレイヤー全員の勝ちです'
          player.increase_chips(@betting_chips * 2)
          puts "#{player.name}の所持金は#{player.having_chips}枚です。"
          puts 'ブラックジャックを終了します'
          exit
        end
        break if dealer.having_points >= 17 # 合計が17を超えたらディーラーはカードを引き終える
      end
    end
    @result_of_dealing_cards[dealer.name] = dealer.having_points

    ### プレイヤー、ディーラー、CPUの結果を表示
    winners = winners(dealer)
    drawers = drawers(dealer)

    if winners.any?
      puts "#{winners.keys.join('と')}の勝ちです。"
      puts "#{player.name}の負けです。" unless winners.keys.include?(player.name) || drawers.keys.include?(player.name)
      puts "#{player.name}は引き分けです。" if drawers.keys.include?(player.name)
    elsif drawers.any?
      puts "#{drawers.keys.join('と')}は引き分けです。" if drawers.keys.any?
      puts "#{player.name}の負けです。" unless winners.keys.include?(player.name) || drawers.keys.include?(player.name)
    elsif winners.empty? && drawers.empty?
      puts "#{dealer.name}の勝ちです。"
    end

    ### 掛け金の変動を示す
    if winners.keys.include?(player.name)
      player.increase_chips(@betting_chips * 2)
    elsif drawers.keys.include?(player.name)
      player.increase_chips(0)
    else
      player.decrease_chips(@betting_chips)
    end

    puts "#{player.name}の所持金は#{player.having_chips}枚です。"
    puts 'ブラックジャックを終了します'
  end

  ### ここからはゲーム内のアクションとしてメソッドを定義 ###
  private

  ### プレイヤーに勝者がいる場合(ディーラーよりも点数が高い)
  def winners(dealer)
    @result_of_dealing_cards.select { |_key, value| value > @result_of_dealing_cards[dealer.name] }
  end

  ### プレイヤーに引き分けがいる場合(ディーラーと同点)
  def drawers(dealer)
    # ディーラーに対しての比較なので要素からディーラーは削除
    @result_of_dealing_cards.select do |_key, value|
      value == @result_of_dealing_cards[dealer.name]
    end.reject { |key, _value| key == dealer.name }
  end

  # ダブリングが選択された時のメソッド
  def doubling(player)
    @doubling << player.name
  end

  # スプリットが選択された時のメソッド
  def split(player)
    @splitting << player.name
    @betting_chips *= 2
    having_cards1 = player.having_cards[0]
    having_cards2 = player.having_cards[1]
    player.drawing_cards_in_split(having_cards1, having_cards2)
  end
end

# 継承元のクラス(クラス名がしっくりこないので変えた方がいいかもしれない、、、)
# 継承先は、ディーラー、プレイヤー、CPUを想定
class Person
  attr_accessor :name, :chip, :cards_doublet1, :cards_doublet2

  def initialize(_num = nil)
    @chip = Chip.new
  end

  def having_chips
    @chip.chips
  end

  # 引いたカードのデータを保存
  def drawing_cards(dealing_card)
    # @cardsがnilであれば空の配列を作る
    @cards ||= []

    # @cardsにカードを追加
    @cards << dealing_card
  end

  def drawing_cards_in_split(dealing_card1, dealing_card2 = nil)
    @cards_doublet1 ||= []
    @cards_doublet2 ||= []
    @cards_doublet1 << dealing_card1 unless dealing_card1.nil?
    @cards = @cards_doublet1
    @cards_doublet2 << dealing_card2
  end

  # 持っているカードが読み取れるメソッド
  def having_cards
    @cards
  end

  # 所持しているカードからポイントを算出
  def having_points(cards = @cards)
    points = 0

    # A、J、Q、Kなどの特殊点数のための場合分け
    cards.each do |card|
      card.each do |_type, num|
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

  # プレイヤーの所持チップを増やす
  def increase_chips(bet)
    @chip.chips += bet
  end

  # プレイヤーの所持チップを減らす
  def decrease_chips(bet)
    @chip.chips -= bet
  end
end

class Dealer < Person
  def initialize
    super
    @name = 'ディーラー'
  end
end

class Player < Person
  def initialize(name = nil)
    super
    @name = name || ' あなた'
  end
end

class Cpu < Person
  def initialize(name)
    super
    @name = name
  end
end

class Card
  attr_accessor :type, :number
  attr_reader :number_of_cards, :cards

  def initialize
    # カードの総数
    @number_of_cards = 52

    # カードの種類
    @cards = [{ 'ハート' => [:A, 2, 3, 4, 5, 6, 7, 8, 9, 10, :J, :Q, :K] },
              { 'ダイヤ' => [:A, 2, 3, 4, 5, 6, 7, 8, 9, 10, :J, :Q, :K] },
              { 'スペード' => [:A, 2, 3, 4, 5, 6, 7, 8, 9, 10, :J, :Q, :K] },
              { 'クローバー' => [:A, 2, 3, 4, 5, 6, 7, 8, 9, 10, :J, :Q, :K] }]
  end

  def drew
    card = @cards.sample
    @number_of_cards -= 1 # カードの総数から1枚引いたことにする
    @type = card.keys.flatten.sample # カードの種類を保存
    @number = card.values.flatten.sample # カードの数字を保存
    { @type => @number } # カードの種類と数字をセットにするためにハッシュ化
  end
end

class Chip
  attr_accessor :chips

  def initialize
    @chips = 100
  end
end

blackjack = Blackjack.new
blackjack.start
