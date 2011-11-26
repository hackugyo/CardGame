# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'games/cards_pile_american_card'
require 'games/card_default'

class CardsTest < Test::Unit::TestCase

  def test_sort
    cards_pile = Cards_Pile_American_Card.new.shuffle!.deal_cards!(52).sort!
    assert_equal('Clover', cards_pile.first.suit)
    assert_equal(1, cards_pile.first.number)
    assert_equal('Spade', cards_pile.last.suit)
    assert_equal(13, cards_pile.last.number)
    assert(cards_pile[1].is_stronger_than?(cards_pile[0]))
    assert(cards_pile[51].is_stronger_than?(cards_pile[50]))
    
    spade5 = Card_Default.new('Spade', 5)
    spade6 = Card_Default.new('Spade', 6)
    dia5 = Card_Default.new('Dia', 5)
    heart7 = Card_Default.new('Heart', 7)
    assert(spade5.is_stronger_than?(dia5))
    assert(spade6.is_stronger_than?(dia5))
    assert(spade6.is_stronger_than?(spade5))
    assert(heart7.is_stronger_than?(spade6))


  end
end
