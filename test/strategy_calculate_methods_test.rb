# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test/putter_silent_mock'
require 'games/dazzle/strategies/strategy_calculate'
require 'games/dazzle/strategies/strategy_first2'
require 'games/card_default'
require 'pp'
require 'rubygems'
require 'rspec'

class Strategy_Calculate_Methods_Test < Test::Unit::TestCase
  def setup
    game_rule = Dazzle.new
    players = game_rule.get_players
    if players.empty? then
      exit
    end
    players[0].name = 'QB'
    players[0].set_strategy(Strategy_Calculate.new(Putter_Silent_Mock))

    players[1].set_strategy(Strategy_First2.new)
    players[1].name = 'YOU'

    @game_board = game_rule.instance_variable_get(:@game_board)

    setup_piles!(game_rule, players[0], players[1])

    players.each do |player|
      player.dealt!(game_rule.deal_first_hands!(player)) # プレイヤに初手を配る，何が破壊されるのか明確にしたい
    end

    @strategy = Strategy_Calculate.new(Putter_Silent_Mock)
    @player = players[0]
    @opponent = players[1]
    

  end


  def test_guess_unopened_cards_distribution
    assert_equal(8, @player.hands.size)
    i_may_have, opponent_may_have,  maybe_unused = @strategy.guess_unopened_cards_distribution(@game_board)
    # このハッシュのvalueたちそれぞれについて，そのvalueたちを合計したい

    assert_equal 6 * 8 - 8, @strategy.guess_unopened_cards_distribution(@game_board).inject(0){|sum, hash_major|
      sum += hash_major.values.inject(0){|sum_major, hash_minor | # 個々の色について足し算
        sum_major += hash_minor.values.inject(0){|sum_minor, j | # 個々の数について足し算
          sum_minor += j }}}

    assert_equal (3 * 1 + 2 * 3 + 1 * 2) * 8 - (3 * 2 + 2 * 4 + 1 * 2), @strategy.guess_unopened_cards_distribution(@game_board).inject(0){|sum, hash_major|
      sum += hash_major.values.inject(0){|sum_major, hash_minor | # 個々の色について足し算
        number = 0
        sum_major += hash_minor.values.inject(0){|sum_minor, j | # 個々の数について足し算
          number += 1
          sum_minor += number * j }}}
  end

  def setup_piles!(game_rule, player1, player2)
    extracted_piles = game_rule.instance_variable_get(:@piles_of_cards)
    extracted_piles[player1] = Cards_Pile.new([
        Card_Default.new('Blue', 3),
        Card_Default.new('Blue', 2),
        Card_Default.new('Blue', 2),
        Card_Default.new('Blue', 2),
        Card_Default.new('Blue', 1),
        Card_Default.new('Blue', 1),
        Card_Default.new('Blue', 3),
        Card_Default.new('Blue', 2),
        Card_Default.new('Blue', 2),
        Card_Default.new('Blue', 2),
        Card_Default.new('Blue', 1),
        Card_Default.new('Blue', 1),
        Card_Default.new('Green', 3),
        Card_Default.new('Green', 2),
        Card_Default.new('Green', 2),
        Card_Default.new('Green', 2),
        Card_Default.new('Green', 1),
        Card_Default.new('Green', 1)
      ])
    @game_board[:my_pile] = extracted_piles[player1]
    assert_equal(18, extracted_piles[player1].size)

    extracted_piles[player2] = Cards_Pile.new([
        Card_Default.new('Red', 3),
        Card_Default.new('Red', 2),
        Card_Default.new('Red', 2),
        Card_Default.new('Red', 2),
        Card_Default.new('Red', 1),
        Card_Default.new('Red', 1),
        Card_Default.new('Yellow', 3),
        Card_Default.new('Yellow', 2),
        Card_Default.new('Yellow', 2),
        Card_Default.new('Yellow', 2),
        Card_Default.new('Yellow', 1),
        Card_Default.new('Yellow', 1),
        Card_Default.new('Green', 3),
        Card_Default.new('Green', 2),
        Card_Default.new('Green', 2),
        Card_Default.new('Green', 2),
        Card_Default.new('Green', 1),
        Card_Default.new('Green', 1)
      ])
    assert_equal(18, extracted_piles[player2].size)
    @game_board[:opponent_pile] = extracted_piles[player2]

    @game_board[:unused_cards_pile] = Cards_Pile.new([
        Card_Default.new('Red', 3),
        Card_Default.new('Red', 2),
        Card_Default.new('Red', 2),
        Card_Default.new('Red', 2),
        Card_Default.new('Red', 1),
        Card_Default.new('Red', 1),
        Card_Default.new('Yellow', 3),
        Card_Default.new('Yellow', 2),
        Card_Default.new('Yellow', 2),
        Card_Default.new('Yellow', 2),
        Card_Default.new('Yellow', 1),
        Card_Default.new('Yellow', 1)
      ])
  end
end
