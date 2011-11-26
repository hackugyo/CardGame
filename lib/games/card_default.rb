# To change this template, choose Tools | Templates
# and open the template in the editor.

class Card_Default
  def initialize(suit, number)
    @suit = suit
    @number = number
    @controler = nil
  end
  attr_reader :suit, :number, :controler

  def to_s
    return "#{@number} of #{@suit}"
  end

  def <=>(other) # sort_byなどでの比較に使われます
    # 左が弱ければ負，左が強ければ正を返す
    if @number == other.number then
      if @suit.eql?(other.suit) then
        return 0
      else
        return ([@suit, other.suit].sort.first == @suit ? -1 : 1)
        # Spade, Heart, Dia, Cloverは辞書順の逆順になっている
      end
    else
      return (@number < other.number ? -1 : 1)
    end
  end

  def is_stronger_than?(other)
    (self <=> other) > 0 ? true : false
  end

  def controled_by!(player_or_play)
    @controler = player_or_play
    return self
  end

end
