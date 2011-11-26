#! ruby -Ku
# -*- coding: utf-8 -*-
require 'pp'
require './games/dazzle/dazzle'


# ゲーム状況から最善手を判断するAIです。
#
class Strategy_Calculate
  def initialize(class_for_io = Kernel)
    @cards_to_play = []
    set_choose_conditons!
    @class_for_io = class_for_io
  end

  def select_card_from_hands(game_board, player)
    unless @cards_to_play.empty? then
      return @cards_to_play.shift
    end

    game_board[:of_me] = player # Fake It, 選択するプレイヤの変更はここでよい？
    game_board = analyze_game_board(game_board)
    guess_unopened_cards(game_board) # Fake It, 戻り値を利用したい
    my_hand_pile = game_board[:my_hand_pile]

    2.times do
      the_first_card_to_play = get_the_card_to_play(my_hand_pile, game_board)
      my_hand_pile.cards.delete(the_first_card_to_play)

      # my_hand_pileから取得したカードはコピーであるから，手札から本物を選択して返す
      @cards_to_play << player.hands.select { |card|
        card.suit == the_first_card_to_play.suit and
          card.number == the_first_card_to_play.number and
          @cards_to_play.index(card).nil? # 2つの選ばれたカードが同じ内容だった場合に備え，まだ選ばれてないカードを選ぶ
      }.first
    end

    return @cards_to_play.shift

  end

  def choose_card_from_cards(game_board, cards, player)
    game_board[:of_me] = player # Fake It, 選択するプレイヤの変更はここでよい？
    game_board =  analyze_game_board(game_board)
    # guess_unopened_cards(game_board) # Fake It
    candidates_for_owning = []

    @class_for_io::puts "私は#{game_board[:of_me].name}"
    cards.each do |card|
      @class_for_io::print "#{card.to_s}について考えます..."
      other_card = cards.select { |card_playing_for_owning|  card_playing_for_owning != card}.first
      color = card.suit

      game_board[:card] = card
      game_board[:my_power] = get_total_points_of(game_board[:my_power_cards_pile], {:color => color})
      game_board[:opponent_power] = get_total_points_of(game_board[:opponent_power_cards_pile], {:color => color})
      game_board[:point] = get_total_points_of(game_board[:point_cards_pile], {:color => color})
      @class_for_io::print "#{game_board[:my_power]} : #{game_board[:point]} : #{game_board[:opponent_power]}"

      @class_for_io::print "投資判断：#{@conditions_to_invest.map { |cond| candidates_for_owning << other_card  if cond.call(game_board, card, other_card) }.compact.size} ，"
      # mapの結果は[配列 または nil]なので，compactしてからsizeを調べれば条件クリアした回数がわかる

      @class_for_io::print "領有判断：#{@conditions_to_own.map { |cond| candidates_for_owning << card  if cond.call(game_board, card, other_card) }.compact.size} \n"

    end
    candidates_for_owning =  cards.select{|card| card.number == cards.sort_by{|c| c.number}.last.number} if candidates_for_owning.empty?


    selected_card_for_owning = candidates_for_owning.uniq.sort_by { |card|
      [candidates_for_owning.select{|candidate| candidate == card}.size,  # 領有判断の多いほうを領有
        rand]}.last # もっとも高く評価されたものを選ぶ
    
    @class_for_io::puts "こちらを領有に使います：#{selected_card_for_owning.to_s}"
    return selected_card_for_owning
  end

  def set_choose_conditons!
    # AI実装方針：
    # 局面的に自分の領有が確定したところは投資
    # # 手札と盤面から確定できる
    #
    # 自分が5点未満の色なら領有に動く
    # 変数：現在の自分の領有色
    # 変数：現在の山札（局面）
    # 変数：現在の各色の領有状況（相手，自分，相手＋自分が今後与える最大値）
    # 変数：自分が今後与える最大値：高いほうからペアをつくって高い側を加算したもの
    @conditions_to_invest = []
    @conditions_to_invest << lambda {|gb, card, other_card|
      gb[:point] >= 5 and gb[:my_power] > gb[:opponent_power]}  # 条件：自分が5点以上で領有している色なら投資 Fake It
    @conditions_to_invest << lambda {|gb, card, other_card|
      ( gb[:point] + gb[:my_power] + gb[:opponent_power]  >= (3 * 2 + 2 * 6 * 1 * 4) / 2 ) and
        gb[:my_power] > gb[:opponent_power]}  # 条件：自分が領有していて，かつ，見えているカードの合計を考えて領有確定ならば，投資 Fake It
    @conditions_to_invest << lambda {|gb, card, other_card|
      gb[:my_power] > gb[:opponent_power] and
        get_total_points_of(gb[:my_power_cards_pile], {:color =>  other_card.suit}) + other_card.number >
        get_total_points_of(gb[:opponent_power_cards_pile], {:color =>  other_card.suit}) and
        get_total_points_of(gb[:point_cards_pile], {:color => card.suit}) + card.number >
        get_total_points_of(gb[:point_cards_pile], {:color => other_card.suit}) + other_card.number
    } # 条件：自分が領有していて，別のカードで領有すればそちらを領有でき，かつ，cardのほうをとったほうが合計得点が高くなるならば，投資
    @conditions_to_invest << lambda {|gb, card, other_card|
      gb[:point] + gb[:my_power] + gb[:opponent_power]  >= (3 * 2 + 2 * 6 * 1 * 4) / 2  and # ほぼ状況が確定しており，
      gb[:my_power] < gb[:opponent_power] and # 領有で負けていて，
      (gb[:point] + card.number) -  get_total_points_of(gb[:point_cards_pile], {:color => other_card.suit}) < 
        # cardを投資にした場合の損失(相手の得る点 - 自分の得る点)が
      gb[:point] -  (get_total_points_of(gb[:point_cards_pile], {:color => other_card.suit}) + other_card.number)
      # 条件：cardを領有にした場合の損失（相手の得る点 - 自分の得る点）より少なければ，投資にしたほうがまし
    }
    # Fake It もうその色の領有不可能が確定している段階では，その色を投資にまわす判断もありえる
    # 相手に 6 + 1点与えても，自分が6点とる場合と，相手に6点のみ与えて，自分は0点しか得られない場合
    # cardを投資した際に相手に与える点 - other_cardを領有にした際に相手が失う点，の場合，cardを投資

    @conditions_to_own = []
    @conditions_to_own << lambda {|gb, card, other_card|
      gb[:point] >= (8 - gb[:card].number) and gb[:my_power] <= gb[:opponent_power]
    } # 条件：これを投資にすると8点の山ができてしまうのに負けているなら領有
    @conditions_to_own << lambda {|gb, card, other_card|
      ( gb[:point] + gb[:my_power] + gb[:opponent_power]  >= (3 * 2 + 2 * 6 + 1 * 4) / 2 ) and
        gb[:my_power] <= gb[:opponent_power]}  # 条件：自分が領有しておらず，かつ，見えているカードの合計を考えて領有できないならば，領有 Fake It
    @conditions_to_own << lambda {|gb, card, other_card|
      ( gb[:point] + gb[:my_power] + gb[:opponent_power]  < (3 * 2 + 2 * 6 + 1 * 4) / 2 ) and
        gb[:my_power] < 5}  # 条件：自分の領有が5以下で，逆転される恐れがあるうちは，領有 Fake It
    @conditions_to_own << lambda {|gb, card, other_card|
      gb[:my_power] < gb[:opponent_power]} # 条件：自分の領有が負けているうちは，領有
    @conditions_to_own << lambda {|gb, card, other_card|
      card.number > other_card.number} # 条件：大きいほうを領有に使う
  end

  def analyze_game_board(game_board)
    of_me          = game_board[:of_me]
    of_opponent = game_board[:players].reject{|player| player == game_board[:of_me]}.first

    # 得点：
    # ある色のうち得点領域にはなにが置かれているか(合計何点？合計何枚？）
    # 除外された札：
    # ある点は何枚あるか
    # 見えていない札：（除外された札＋相手の手札＋相手の山札＋自分の山札
    # ある点は合計何枚か
    # 見えていない札の配分はどうなっているか

    game_board = game_board.merge(
      {
        :of_opponent  => of_opponent,
        :my_hand_pile => Cards_Pile.new(Marshal::load(Marshal::dump(of_me.hands))).set_opened!, # 自分の手札
        :opponent_hand_pile => Cards_Pile.new(of_opponent.hands),
        :my_pile          => game_board[:piles_of_cards][of_me], # 自分の山札
        :opponent_pile => game_board[:piles_of_cards][of_opponent],  # 相手の山札
        :my_power_cards_pile          => get_played_cards(of_me, game_board),  # 自分の支配札
        :opponent_power_cards_pile => get_played_cards(of_opponent, game_board), # 相手の支配札
        :point_cards_pile                  => get_played_cards(nil, game_board) # 得点
      }
    )

    return game_board
    # これをgame_boardを破壊するメソッドに変えるにはgame_board[]を使って参照先を変更する必要があります
  end

  # cards_pileを受け取り，queryにあてはまるカードを配列に入れて返す
  # cards_pileにopenedフラグが立っていない場合，色queryは無視する
  def get_cards_of(a_pile_of_cards, query = {})
    query = {:color => Any.instance, :number => Any.instance}.merge(query)
    cards = a_pile_of_cards.cards
    # closedな場合queryを変更して:color = Any.instanceとしたい
    query[:color] = Any.instance unless a_pile_of_cards.opened?
    cards_in_such_condition = cards.select{ |card| (query[:color] == card.suit) and (query[:number] == card.number) }
    cards_in_such_condition = cards_in_such_condition.sort_by{|card| [card.suit, card.number]}
    return cards_in_such_condition
  end

  def get_total_points_of(a_pile_of_cards, query = {})
    cards = get_cards_of(a_pile_of_cards, query)
    return cards.inject(0){|sum, card| sum += card.number}
  end

  def get_count_of(a_pile_of_cards, query = {})
    return  get_cards_of(a_pile_of_cards, query).size
  end

  # 2. 色Cとは，手札内でもっとも，その色の合計点数が大きい色
  # 3. もっとも大きい色が1つ決まらない場合は，それらのうち3が多い色
  # 4. それでも決まらない場合は，それらのうち1が多い色
  def get_the_color_to_play(hands_pile)
    colors = Dazzle::COLORS.sort_by do |color|
      [
        get_total_points_of(hands_pile, {:color => color}),
        get_count_of(hands_pile, {:color => color, :number => 3}),
        get_count_of(hands_pile, {:color => color, :number => 1}),
        rand
      ]
    end
    return colors.last
  end

  # 知りたいのは，
  # 1. 手札内で，色Cのうち，もっとも数が大きいカード
  def get_the_card_to_play(hands_pile, game_board)
    cards_of_selected_color = get_cards_of(hands_pile, {:color => get_the_color_to_play(hands_pile)})

    return cards_of_selected_color.sort_by{|card| [card.number, rand]}.last
    # もっとも少ない色：出さない
    # もっとも多い色と2番めに多い色との組み合わせで出す
    # 得点が8点以上の色：ほしい
    # 66 / 4 = 16点なので得点8 : 領有8
    # つまり相手の領有カードが5点になると困るからそうなるような組み合わせは避ける
    # 逆に相手の領有カードが一気に6点になる場合は出す（もともと3 + さらに3など）
    # 最終局面では自分の領有する色については点の高い順に2枚まとめて出す
    # 変数：現在の自分の領有色
    # 変数：現在の山札（局面）
  end

  def guess_unopened_cards(game_board)

    i_may_have, opponent_may_have,  maybe_unused =  guess_unopened_cards_distribution(game_board)
    # ここまでで解析完了
    # 相手の手札の1つ1つにつき，"opponentの3のカード = x%でBlue, y%でGreen, z%でRed, p%でYellowですね\n"という形で表示したい
    # それには，見えていない3のカードのうち，青が何枚，緑が何枚，赤が何枚，黄色が何枚あるかを調べればよい
    how_many_cards_of_a_color_and_a_number_unopened = get_unopened_cards_counts_array(game_board, i_may_have, opponent_may_have,  maybe_unused)

    guessed_probability_array = how_many_cards_of_a_color_and_a_number_unopened.map { |array|
      sum = array.inject(0){|sum, count| sum += count}
      array.map{|closed_cards_count_of_color| closed_cards_count_of_color.quo(sum) * 100}
    }
    view_probability_of_each_card(game_board, guessed_probability_array)
    guessed_final_points_of_each_players = guess_final_points(game_board, i_may_have, opponent_may_have)
    @class_for_io::puts(
      "#{game_board[:of_me].name}の推定得点は#{guessed_final_points_of_each_players[game_board[:of_me]]}, " +
        "#{game_board[:of_opponent].name}の推定得点は#{guessed_final_points_of_each_players[game_board[:of_opponent]]}"
    )
    @class_for_io::puts "#{game_board[:of_me].name}が勝つでしょう" if guessed_final_points_of_each_players[game_board[:of_me]] > guessed_final_points_of_each_players[game_board[:of_opponent]]
    #これが仮想の最終結果。これで勝っていれば、同じ色のペアを出す。負けていれば、負けそうな色の高い点カードと勝てそうな色の低い点カードとをペアで出す。
    return true # Fake It， guess_unopened_cards()は何を返そうか？
  end

  def guess_unopened_cards_distribution(game_board)
    opened_cards_count = {}
    closed_cards_count = {}
    i_may_have = {}
    opponent_may_have = {}
    maybe_unused = {}
    COLORS.each {|color|
      opened_cards_count[color] = {1 => 0, 2 => 0, 3 => 0}
      closed_cards_count[color] = {1 => 0, 2 => 0, 3 => 0}
      i_may_have[color] = {1 => 0, 2 => 0, 3 => 0}
      opponent_may_have[color] = {1 => 0, 2 => 0, 3 => 0}
      maybe_unused[color] = {1 => 0, 2 => 0, 3 => 0}
    }

    opened_cards = Cards_Pile.new(game_board[:my_hand_pile].cards + game_board[:cards_on_play].cards_on_play).set_opened!
    COLORS.each do |color|
      opened_numbers = get_cards_of(opened_cards, {:color => color}).map{|card| card.number} #いま見えている#{color}のカード
      [1, 2, 3].each do |target_number|
        all_cards_count = case target_number # Fake It, 汚い
        when 1 then 4
        when 2 then 6
        when 3 then 2
        else 0
        end
        opened_cards_count[color][target_number] = opened_numbers.select{|number| number == target_number}.size # いまこの値のカードが何枚見えているか
        closed_cards_count[color][target_number] = all_cards_count - opened_cards_count[color][target_number]
      end
    end

    [1, 2, 3].each do |target_number|
      query = {:number => target_number}
      a = get_cards_of(game_board[:opponent_hand_pile], query).size
      b = get_cards_of(game_board[:my_pile], query).size
      c = get_cards_of(game_board[:opponent_pile], query).size
      d = get_cards_of(game_board[:unused_cards_pile], query).size

      # 内訳推定
      unopened_cards_count = {}
      COLORS.each {|color| unopened_cards_count[color] = closed_cards_count[color][target_number]}
      unopened_cards = []
      COLORS.each {|color| unopened_cards_count[color].times {unopened_cards << Card_Default.new(color, target_number)}}
      unopened_cards = unopened_cards.sort_by{rand}
      @class_for_io::puts "相手の持っている#{target_number}のカードの内訳は" + 
        "#{(1..(a + c)).map {|card_order| unopened_cards.shift}.map{|card| card.suit}.join(', ')}と推定します" unless (a + c) <= 0
      @class_for_io::puts "自分の持っている#{target_number}のカードの内訳は" +
        "#{(1..b).map {|card_order| unopened_cards.shift}.map{|card| card.suit}.join(', ')}と推定します" unless b <= 0

      # 得点推定
      COLORS.each do |color|
        e =  closed_cards_count[color][target_number] # これをa, b, c, dに配分する
        # puts "#{color} - #{target_number}の残り枚数は#{e}枚で，これを相手：自分：不使用で#{a + c}：#{b}：#{d}に分配します" if b == 0
        i_may_have[color][target_number] = e * b.quo(a + c + b + d) # 時文の持っている枚数期待値
        opponent_may_have[color][target_number] = e * (a + c).quo(a + c + b + d) # 相手の持っている枚数期待値
        maybe_unused[color][target_number] = e * d.quo(a + c + b + d)
      end
    end
    return i_may_have, opponent_may_have, maybe_unused
  end

  def get_unopened_cards_counts_array(game_board, i_may_have, opponent_may_have,  maybe_unused)
    @class_for_io.print "  #{game_board[:of_me].name}にとって，"
    return [1,2,3].map{|target_number|
      #COLORS.map{|color| closed_cards_count[color][target_number] }
      COLORS.map{|color| i_may_have[color][target_number] + opponent_may_have[color][target_number] + maybe_unused[color][target_number] }
    }.each_with_index{|color, i|
      @class_for_io.print "裏向きの#{i +1}は#{color.join(',')}枚，"
    }
  end

  def view_probability_of_each_card(game_board, guessed_probability_array)
    game_board[:opponent_hand_pile].cards.sort_by{|card| card.number}.each do |card_in_opponent_hand|
      @class_for_io.print "\n  #{game_board[:of_me].name}の予想では，#{game_board[:of_opponent].name}の裏向きカード#{card_in_opponent_hand.number}について，それは"
      guessed_probability_array[card_in_opponent_hand.number - 1].each_with_index do |probability_of_a_color, j|
        @class_for_io.print "#{probability_of_a_color.round}%で#{COLORS[j]}，"
      end
    end
    @class_for_io.print "\n"
    return true
  end

  def guess_final_points(game_board, i_may_have, opponent_may_have)
    guessed_final_points_of_each_players = {game_board[:of_me] => 0, game_board[:of_opponent] => 0}
    COLORS.each do |color|
      # まだプレイしていないカードの点数を推定
      calculated_remained_sum_of_me =  i_may_have[color].keys.inject(0){|sum, target_number| sum += target_number * i_may_have[color][target_number]} +
        get_total_points_of(game_board[:my_hand_pile], {:color => color})
      calculated_remained_sum_of_opponent = opponent_may_have[color].keys.inject(0){|sum, target_number| sum += target_number * opponent_may_have[color][target_number]}

      # すでにプレイされたカードと合計し最終領有点を推定
      # Fake It, 単に2で割ってよいかどうかは微妙
      guessed_my_total =  get_total_points_of(game_board[:my_power_cards_pile], {:color => color}) + calculated_remained_sum_of_opponent.quo(2)
      guessed_opponent_total =  get_total_points_of(game_board[:opponent_power_cards_pile], {:color => color}) + calculated_remained_sum_of_me.quo(2)
      # 所有点と手札との入れ替わりに注意

      # 最終得点を推定
      guessed_final_points =
        get_total_points_of(game_board[:point_cards_pile], {:color => color}) +
        (calculated_remained_sum_of_me + calculated_remained_sum_of_opponent) / 2

      # 最終領有点で勝りそうならば点数を表示
      if  guessed_my_total > guessed_opponent_total then
        @class_for_io::print(
          "#{color}のカード(最終的には#{guessed_my_total.round} :" +
            " #{guessed_final_points.round} :" +
            " #{guessed_opponent_total.round})，"
        )
        guessed_final_points_of_each_players[game_board[:of_me]] += guessed_final_points.round
      elsif guessed_my_total < guessed_opponent_total then
        guessed_final_points_of_each_players[game_board[:of_opponent]] += guessed_final_points.round
      end
    end
    @class_for_io::print "これらは#{game_board[:of_me].name}がいただきます\n" # Fake It
    return guessed_final_points_of_each_players
  end

  def get_played_cards(player, game_board)
    # Fake It, なんで毎回newしてるのか．
    # 毎回入れ替わるのがいけない
    return Cards_Pile.new(game_board[:cards_on_play].cards_on_play.select{|card| card.controler == player}).set_opened!

  end


  class Any
    @@singleton = Any.new
    def initialize

    end

    def Any.instance
      return @@singleton
    end

    def ==(other)
      return other.nil? ? false : true
    end
  end

end
