#! ruby -Ku
# -*- coding: utf-8 -*-
class Strategy_Random
  def initialize
    
  end
  
  def select_card_from_hands(game_board, player)
    hands = player.hands
    selected_card = hands.at(rand(hands.size))
    return selected_card
  end

  def choose_card_from_cards(game_board, cards, player)
    return cards.sort_by{rand}.first
  end
end
