#! ruby -Ku
# -*- coding: utf-8 -*-

require './games/dazzle/cards_on_play'
require './games/dazzle/cards_pile'
require './games/dazzle/strategies/strategy_manual'

CARDS_COUNT_FOR_FIRST_HANDS = 8
CARDS_COUNT_TO_BE_DEALT = 2
CARDS_COUNT_TO_BE_PLAYED = 2

# "Dazzle"のゲームルールを表すクラスです。
class Dazzle
  include Game_Templete
  COLORS = ['Blue', 'Green', 'Red', 'Yellow']

  def initialize(hash = {:players => 2, :dazzle_sort => true})
    @players_count = hash[:players]
    @cards_on_play = Cards_On_Play.new
    @first_hands_count = 8
    a_pile_of_cards =  (hash[:dazzle_sort] ? Cards_Pile.new.dazzle_sort! : Cards_Pile.new.shuffle!)
    # カードの山を生成してシャッフル
    @players = []
    @players = self.get_players
    @piles_of_cards = {@players[0] => Cards_Pile.new(a_pile_of_cards.deal_cards!(18)), @players[1] => Cards_Pile.new(a_pile_of_cards.deal_cards!(18))}
    @turn = 0
    @game_board = {
      :players => @players,
      :piles_of_cards => @piles_of_cards,
      :cards_on_play => @cards_on_play,
      :of_me => @players[0],
      :of_opponent  => @players[1],
      :my_hand_pile => Cards_Pile.new(@players[0].hands), # 自分の手札
      :opponent_hand_pile => Cards_Pile.new(@players[1].hands),
      :my_pile          => @piles_of_cards[@players[0]], # 自分の山札
      :opponent_pile => @piles_of_cards[@players[1]],
      :my_power_cards_pile          => Cards_Pile.new([]),  # 自分の支配札
      :opponent_power_cards_pile => Cards_Pile.new([]), # 相手の支配札
      :point_cards_pile                  => Cards_Pile.new([]), # 得点
      :unused_cards_pile => a_pile_of_cards # 今回は使わないで残されたカード
    }
    @turn_result = nil
  end
  attr_reader :cards_on_play, :piles_of_cards

  def deal_first_hands!(player)
    return @piles_of_cards[player].deal_cards!(@first_hands_count)
  end

  def play_turn_around(game_board = {})
    @game_board = @game_board.merge(game_board)    # デフォルトに引数のハッシュを上書き

    self.clear_previous_turn!
    self.deal_cards!     # カードを配る
    @players.each do |turn_player|
      opponent_player =@players.reject{|player| player == turn_player}.first
      played_cards = get_played_cards!(turn_player)
      # なぜturn_player.play_cards!ではないのかというと，dazzleクラスだけを知っているやつからも呼ばせたいから
      choose_cards!(opponent_player, played_cards)
      # なぜopponent_player.choose_cards(played_cards)ではないかというと，dazzleクラスだけを知っているやつからも呼ばせたいから
    end

    @turn_result = check_winner!
    return @turn_result
  end
  
  def get_strategy_manual #Fake It, 紛らわしい名前
    return Strategy_Manual.new
  end

  ###########
  # 外側主導の場合

  def get_played_cards!(turn_player)
    played_cards = (1..CARDS_COUNT_TO_BE_PLAYED).map {|time|  turn_player.play_cards!(@game_board)}
    @turn_result.set_message!("#{turn_player.name} played [#{ played_cards.join('], [') }]. ")
    return played_cards
  end

  def deal_cards!
    unless @players.any?{|player| player.hands.size == CARDS_COUNT_FOR_FIRST_HANDS} then #  or piles_of_cards[@players[0]].empty? は不要？
      @players.each do |player|
        # player.dealt!(piles_of_cards.deal_cards!(CARDS_COUNT_TO_BE_DEALT))# Fake It
        player.dealt!(@piles_of_cards[player].deal_cards!(CARDS_COUNT_TO_BE_DEALT))
      end
    end
    @players.each do |player|
      @turn_result.set_message! "#{player.name}の手札はこのターン[ #{player.hands.map{|card| card.number}.join(', ')}  ]の#{player.hands.size}枚でした\n"
    end
    return @players
  end

  def view
    return @turn_result.message # Fake It, もっと場の細かい情報も知りたい
  end


  def choose_cards!(player, played_cards)
    card_for_owning = player.choose_cards(@game_board, played_cards)
    card_for_point = played_cards.select{|card| card != card_for_owning}.first # Fake It, 汚い
    @cards_on_play.put!(card_for_owning, player)
    @cards_on_play.put!(card_for_point, nil)
    @turn_result.set_message!("#{player.name} choise [#{card_for_owning}] to own.\n")
    return card_for_owning, card_for_point
  end

  def check_winner!
    if @players.all?{|player| player.hands.empty?} then # 決着
      hash_of_points, message = @cards_on_play.calc_points(@players) #Fake It, 何を破壊してるのかわからない
      @turn_result.set_message!(message)
      @players.each do |player|
        player.get_points(hash_of_points[player])
        @turn_result.set_message!(" #{player.name} gained #{player.points}. ")
      end

      @turn_result.win!(@cards_on_play.get_winner(@players))
    end
    return @turn_result
  end

  def clear_previous_turn!
    @turn_result = Turn_Result.new
    @turn_result.set_message! "#{@turn += 1}ターンめの結果です\n"
    return @turn_result
  end
end
