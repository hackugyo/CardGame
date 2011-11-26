# To change this template, choose Tools | Templates
# and open the template in the editor.
require './games/card_default'

class Cards_Pile_American_Card
  def initialize
    numbers = (1..13).to_a
    suit = ['Spade', 'Heart', 'Dia', 'Clover']
    @cards = suit.product(numbers).map! do |pair_of_number_and_suit|
      Card_Default.new(pair_of_number_and_suit[0], pair_of_number_and_suit[1])
    end
    @opened = false
  end
 attr_reader :cards # Fake It, 明かしたくないが

  def opened?
    return @opened
  end

  def shuffle!
    @cards = @cards.sort_by { rand }
    return self
  end
  
  def deal_cards!(count)
    if count > @cards.size then
      return false
    end

    dealt = []
    count.times do
      dealt << @cards.shift
    end
    return dealt
  end

  def product(other)
    self.inject([]){|ret, es|
      ret += other.map{|eo| [es, eo]}
    }
  end

  def size
    return @cards.size
  end

  def set_closed!
    @opened = false
    return self
  end

  def set_opened!
    @opened = true
    return self
  end

  def +(other)
    new =  self.class.new(@cards + other.cards) #Fake It, これでよい？
    return (@opened and other.opened?) ? new : new.set_closed!

  end

  def rest_cards
    return @opened ? @cards : @cards.map{|card| card.number}
  end

  def add_cards!(cards)
    @cards = @cards.concat(cards).uniq
  end
end
