# To change this template, choose Tools | Templates
# and open the template in the editor.

class Strategy_Strongest
  def initialize
    
  end

    def select_card_from_hands(game_board, player)
    #selected_card = hands.sort_by{|card_in_hand| card_in_hand.number}.reverse.first
    selected_card = nil
    hands = palyer.hands
    hands.sort! # 弱い順に並べた
    selected_card = hands.first
    if game_board[:cards_on_play].get_the_strongest then
        hands.each do |card_in_hand|
          # Fake It, 汚い
          # 弱い順に見ていって，いま確認しているカードがそいつより強ければ，そいつを出すことに決定
          return card_in_hand if card_in_hand.is_stronger_than?(game_board[:cards_on_play].get_the_strongest)
        end
    else
      selected_card = hands.last
    end

    return selected_card
  end

end
