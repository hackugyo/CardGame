# To change this template, choose Tools | Templates
# and open the template in the editor.

class Strategy_First2
  def initialize(cards_to_be_chosen = 1)
    @cards_to_be_chosen = cards_to_be_chosen
  end

  def select_card_from_hands(game_board, player)
    hands = player.hands
    # puts "On Play : #{game_board[:cards_on_play].cards_on_play.join(', ')}"
    selected_card = []
    @cards_to_be_chosen.times do
      select_number = 0
      selected_card << hands.at(select_number)
      hands.delete_at(select_number)
    end
    return selected_card.size == 1 ? selected_card.first : selected_card
  end

  def choose_card_from_cards(game_board, cards, player)
    selected_card = []

    select_number = 0
    selected_card << cards.at(select_number)
    cards.delete_at(select_number)

    return selected_card.size == 1 ? selected_card.first : selected_card
  end

end
