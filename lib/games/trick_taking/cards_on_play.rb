# To change this template, choose Tools | Templates
# and open the template in the editor.

class Cards_On_Play
  def initialize
    @cards_on_play = []
  end
  attr_reader :cards_on_play

  def put(played_card, turn_player)
    @cards_on_play << played_card.controled_by!(turn_player)
  end

  def get_the_strongest
    return false if @cards_on_play.empty?
    the_strongest_card = @cards_on_play.sort.last
    return the_strongest_card
  end

  def clear!
    @cards_on_play.each{|card| card.controled_by!(nil)}
    @cards_on_play.clear
  end

  def view
    return @cards_on_play.join(', ')
  end
end
