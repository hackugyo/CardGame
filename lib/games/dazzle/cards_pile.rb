#! ruby -Ku
# -*- coding: utf-8 -*-
require './games/cards_pile_american_card'

# "Dazzle"における山札です。
# 一般的な山札クラスの子クラスです。
# Dazzleクラスにrequireして使います。
class Cards_Pile < Cards_Pile_American_Card 
  def initialize(cards = nil)
    @opened = false
    if cards then
      @cards = cards
    else
      numbers = [1, 1, 2, 2, 2, 3] * 2
      suit = Dazzle::COLORS
      @cards = suit.product(numbers).map! do |pair_of_number_and_suit|
        Card_Default.new(pair_of_number_and_suit[0], pair_of_number_and_suit[1])
      end
    end
  end

  def shuffle!
    @cards = @cards.sort_by { rand }
    return self
  end

  def dazzle_sort!
    @cards = @cards.sort_by { rand }.sort_by{|card| card.number}.reverse
    piles = []
    (0..7).to_a.each do |pile_number|
      piles[pile_number] = []
    end
    while @cards.size > 0 do
      piles.each do |pile|
        pile << self.deal_cards!(1)
      end
    end
    @cards = piles.flatten
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

end