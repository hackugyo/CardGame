# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test/putter_silent_mock'
require 'game'
require 'games/dazzle/dazzle'
require 'games/trick_taking/trick_taking'
CLASS_FOR_IO = Putter_Silent_Mock
class Game_Test < Test::Unit::TestCase
  def setup_game_rule(game_rule)
    #game_rule = Trick_Taking.new

    players = game_rule.get_players
    if players.empty? then
      exit
    end
    players[0].name = 'QB'
    players[0].set_strategy(Strategy_Random.new)

    players[1].be_manual!(game_rule)  # players[1].set_strategy(Strategy_First2.new)
    players[1].set_strategy(Strategy_Random.new)
    players[1].name = 'YOU'

    players.each do |player|
      player.dealt!(game_rule.deal_first_hands!(player)) # プレイヤに初手を配る，何が破壊されるのか明確にしたい
    end
    return game_rule
  end
  def test_dazzle
    game_rule = Dazzle.new
    setup_game_rule(game_rule) # 破壊的メソッド
    assert_equal(true, game_rule.play_a_game(CLASS_FOR_IO))
  end

  def test_trick_taking
    game_rule = Trick_Taking.new
    setup_game_rule(game_rule) # 破壊的メソッド
    assert_equal true, game_rule.play_a_game(CLASS_FOR_IO)
  end
end
