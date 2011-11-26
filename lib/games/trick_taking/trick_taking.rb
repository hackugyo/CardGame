# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'game'
require 'turn_result'
require 'games/trick_taking/cards_on_play'
require 'player'
require 'games/cards_pile_american_card'
require 'games/trick_taking/strategies/strategy_manual'

class Trick_Taking
  include Game_Templete
  def initialize(hash = {:players => 2})
    @players_count = hash[:players]
    @points_to_win = 10
    @cards_on_play = Cards_On_Play.new
    @points_for_an_winning = 1
    @cards_count_to_deal = 1
    @first_hands_count = 3
    @piles_of_cards =  Cards_Pile_American_Card.new().shuffle! # カードの山を生成してシャッフル
    @players = []
  end


  def get_a_pile_of_cards
    return @piles_of_cards
  end

  def deal_first_hands!(player)
    return @piles_of_cards.deal_cards!(@first_hands_count)
  end

  def play_turn_around(game_board = {})
    game_board = {
      :players => @players,
      :piles_of_cards => @piles_of_cards,
      :cards_on_play => @cards_on_play
    }.merge(game_board)    # デフォルトに引数のハッシュを上書き
    players = game_board[:players]
    pile_of_cards = game_board[:piles_of_cards]

    turn_result = Turn_Result.new
    if players.size != @players_count then
      return turn_result.set_message!(" Players are not for this game.").drew!
    elsif (pile_of_cards.size < @cards_count_to_deal * 2 ) then
      return  turn_result.set_message!(" Cards in the pile are not enough.").drew!
    end


    players.each do |turn_player|
      other_players = players.reject{|player| player == turn_player}
      turn_player.dealt!(pile_of_cards.deal_cards!(@cards_count_to_deal))
      # puts turn_player.hands.map{|card_in_hand| card_in_hand.number}.join(', ')
      played_card = turn_player.play_cards!(game_board)
      
      @cards_on_play.put(played_card, turn_player)
      turn_result.set_message!("#{turn_player.name} playes #{played_card.to_s}. ")
    end

    won_card = @cards_on_play.get_the_strongest
    winner_of_turn = won_card.controler
    winner_of_turn.get_points(@points_for_an_winning)
    turn_result.set_message!("#{winner_of_turn.name} won this turn(now #{winner_of_turn.points} points).")

    if winner_of_turn.points >= @points_to_win then
      turn_result.win!(winner_of_turn)
    end

    @cards_on_play.clear!
    @players.reverse! # 先攻後攻の交代

    return turn_result
  end

  def get_strategy_manual
    return Strategy_Manual.new
  end
end
