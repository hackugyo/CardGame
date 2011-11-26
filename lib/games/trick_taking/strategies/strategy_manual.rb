# To change this template, choose Tools | Templates
# and open the template in the editor.

class Strategy_Manual
  def initialize(class_for_puts = Kernel, cards_to_be_chosen = 1)
    @cards_to_be_chosen = cards_to_be_chosen
  end

  def select_card_from_hands(game_board, player)
    hands = player.hands
    puts "On Play : #{game_board[:cards_on_play].view}"
    selected_card = []
    @cards_to_be_chosen.times do
      puts "In your hand : #{hands.join(', ')}"
      puts "Which card do you play? 1..#{hands.size}"
      select_number = gets.to_i
      unless (1..(hands.size)).include?(select_number)
        redo
      end
      selected_card << hands.at(select_number - 1)
      hands.delete_at(select_number - 1)
    end
    return selected_card.size == 1 ? selected_card.first : selected_card
  end
end
