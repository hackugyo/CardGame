# To change this template, choose Tools | Templates
# and open the template in the editor.

class Strategy_Manual
  def initialize(class_for_puts = Kernel, cards_to_be_chosen = 1)
    @cards_to_be_chosen = cards_to_be_chosen
    @class_for_puts = class_for_puts
  end

  def select_card_from_hands(game_board, player)
    hands = player.hands
    @class_for_puts.puts "On Play : \n#{game_board[:cards_on_play].view}"
    
    selected_card = []

    @cards_to_be_chosen.times do
      self.view_hand(hands) # Fake It, なんとかすべき？
      
      @class_for_puts.puts "  Which card do you play? [1]..[#{hands.size}]"
      select_number = @class_for_puts.gets.to_i
      redo unless (1..(hands.size)).include?(select_number)
      selected_card << hands.at(select_number - 1)
      hands.delete_at(select_number - 1)
    end
    @class_for_puts.puts "You played #{selected_card}. \n"
    return selected_card.size == 1 ? selected_card.first : selected_card
  end

  def choose_card_from_cards(game_board, cards, player)
    self.view_hand(player.hands) # Fake It, なんとかすべき？
    @class_for_puts.puts "On Play : \n#{game_board[:cards_on_play].view}"
    
    selected_card = []
    1.times do
      @class_for_puts.puts "  Your opponet presented : #{cards.join(', ')}"
      @class_for_puts.puts "  Which card do you own? [1]..[#{cards.size}]"
      select_number = @class_for_puts.gets.to_i
      redo unless (1..(cards.size)).include?(select_number)
      selected_card << cards.at(select_number - 1)
      cards.delete_at(select_number - 1)
    end
    @class_for_puts.puts "You owned #{selected_card}. \n"
    return selected_card.size == 1 ? selected_card.first : selected_card
  end

  def view_hand(cards_array) # 手札を番号付きで整形表示
    counter = 0
    @class_for_puts.puts(
      "  In your hand :\n  #{cards_array.map{|c|
      "#{counter == cards_array.size / 2 ? "\n  " : ""}[#{counter += 1}] #{c.to_s}"
      }.join(', ')}"
    )
    return true
  end
end
