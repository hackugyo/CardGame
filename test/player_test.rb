# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'games/cards_pile_american_card'
require 'games/trick_taking/trick_taking'

class PlayerTest < Test::Unit::TestCase
  def test_foo
    player = Trick_Taking.new({:players => 1}).get_players.first
    dealts_count = 2
    player.dealt!(Cards_Pile_American_Card.new.shuffle!.deal_cards!(dealts_count))
    # puts "hands : #{player.hands.first}"
    assert_equal(dealts_count, player.hands.size)
  end
end
