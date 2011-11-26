# To change this template, choose Tools | Templates
# and open the template in the editor.

class Strategy_Random
  def initialize
    
  end
  
  def select_card_from_hands(game_board, player)
    selected_card = player.hands.at(rand(player.hands.size))
    return selected_card
  end
end
