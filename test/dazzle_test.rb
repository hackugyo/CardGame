# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'games/dazzle/dazzle'

class Dazzle_Test < Test::Unit::TestCase
  def test_foo
    game_rule = Dazzle.new

    players = game_rule.get_players
    if players.empty? then
      exit
    end
    players[0].name = 'QB'
    # players[1].be_manual!
    players[1].name = 'YOU'
    players.each do |player|
      player.dealt!(game_rule.deal_first_hands!(player)) # プレイヤに初手を配る，何が破壊されるのか明確にしたい
    end
    players.each do |player|
      assert_equal(8, player.hands.size)
      assert_equal(10, game_rule.piles_of_cards[player].size)
    end
  end

  def test_dazzle_sort
    game_rule = Dazzle.new
    pile_for_a_player =  game_rule.piles_of_cards.values.first
    assert_equal "3, 2, 2, 2, 1, 1, 3, 2, 2, 2, 1, 1, 3, 2, 2, 2, 1, 1", pile_for_a_player.rest_cards.join(', ')
    assert_equal(33,  pile_for_a_player.rest_cards.inject(0){|sum, number| sum += number})
    assert_equal(
      [3,2,2,2,1,1,3,2], 
       pile_for_a_player.deal_cards!(8).map{|card| card.number}
    )
  end
end
