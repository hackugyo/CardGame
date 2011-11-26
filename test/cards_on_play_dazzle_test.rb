# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'game'
require 'turn_result'
require 'player'
require 'games/dazzle/cards_on_play'
require 'games/dazzle/cards_pile'
require 'games/card_default'

BLUE = 'Blue'
class Cards_On_Play_Dazzle_Test < Test::Unit::TestCase
  def setup
    @cards_on_play = Cards_On_Play.new
    @players = [Player.new, Player.new]
    @pile = Cards_Pile_American_Card.new.shuffle!
  end

  def test_get_winner_if_drawn
    # 所有カードの設定
    played_card = Card_Default.new(BLUE, 3)
    @cards_on_play.put(played_card, @players[1])

    played_card = Card_Default.new(BLUE, 1)
    3.times do
      @cards_on_play.put(played_card, @players[0])
    end

    # 共通得点カードの設定
    played_card = Card_Default.new(BLUE, 2)
    @cards_on_play.put(played_card, nil)

    points, message = @cards_on_play.calc_points(@players)
    @players.each{|player| player.get_points(points[player])}

    assert_equal('no', @cards_on_play.get_winner(@players))
  end

  def test_get_winner
    # 所有カード
    played_card = Card_Default.new(BLUE, 3)
    @cards_on_play.put(played_card, @players[1])

    played_card = Card_Default.new(BLUE, 1)
    2.times do
      @cards_on_play.put(played_card, @players[0])
    end

    # 得点カード
    played_card = Card_Default.new(BLUE, 2)
    @cards_on_play.put(played_card, nil)
    
    points, message = @cards_on_play.calc_points(@players)
    @players.each{|player| player.get_points(points[player])}
    assert_equal(@players[1], @cards_on_play.get_winner(@players))

  end
end
