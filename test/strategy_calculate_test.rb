# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'games/dazzle/strategies/strategy_calculate'
require 'test/putter_silent_mock'
require 'Kconv'

class Strategy_Calculate_Test < Test::Unit::TestCase

  def setup
    game_rule = Dazzle.new
    players = game_rule.get_players
    if players.empty? then
      exit
    end
    players[0].name = 'QB'
    players[0].set_strategy(Strategy_Calculate.new(Putter_Silent_Mock))

    players[1].be_manual!(game_rule)  # players[1].set_strategy(Strategy_First2.new)
    players[1].set_strategy(Strategy_Random.new)
    players[1].name = 'YOU'

    # setup_piles!(game_rule, players[0], players[1])

    players.each do |player|
      player.dealt!(game_rule.deal_first_hands!(player)) # プレイヤに初手を配る，何が破壊されるのか明確にしたい
    end

    @strategy = Strategy_Calculate.new(Putter_Silent_Mock)
    @player = players[0]
    @opponent = players[1]
    @game_board = game_rule.instance_variable_get(:@game_board)
    @game_board[:of_me] = @player

    @sample_pile = Cards_Pile.new([
        Card_Default.new('Blue', 1),
        Card_Default.new('Red', 1),
        Card_Default.new('Red', 1),
        Card_Default.new('Green', 1),
        Card_Default.new('Blue', 2),
        Card_Default.new('Blue', 2),
        Card_Default.new('Yellow', 2),
        Card_Default.new('Yellow', 3)
      ])
    @player.instance_variable_set(:@hands, @sample_pile.instance_variable_get(:@cards))

    @game_board[:cards_on_play] = Cards_On_Play.new()
    @game_board[:cards_on_play].instance_variable_set(:@cards_on_play,
      [
        Card_Default.new('Yellow', 3).controled_by!(@player),
        Card_Default.new('Yellow', 2).controled_by!(@player)
      ])

  end

  def test_select
    hands_size = @sample_pile.size
    first = @strategy.select_card_from_hands(@game_board, @player)
    assert_not_nil first
    second = @strategy.select_card_from_hands(@game_board, @player)
    assert_equal(hands_size, @sample_pile.size)
    assert_equal('Yellow', first.suit)
    assert_equal(3, first.number)
    assert_equal('Blue', second.suit)
    assert_equal(2, second.number)

  end

  def test_get_cards_of
    my_pile = @sample_pile
    assert_equal false, my_pile.opened?
    assert_equal my_pile.cards.size, @strategy.get_cards_of(my_pile).size # queryがないのですべてのカードが戻る
    assert_equal 4, @strategy.get_cards_of(my_pile, {:number => 1}).size
    assert_equal 4, @strategy.get_cards_of(my_pile, {:color => 'Red', :number => 1}).size # openedでないのでcolorのqueryは無視される
    assert_equal my_pile.cards.size, @strategy.get_cards_of(my_pile, {:color => 'Red'}).size # openedでないのでcolorのqueryは無視される
    assert_equal my_pile.cards.size, @strategy.get_cards_of(my_pile, {:color => 'NonExistence'}).size # openedでないのでcolorのqueryは無視される
    assert_equal 0, @strategy.get_cards_of(my_pile, {:color => 'NonExistence', :number => 5}).size # openedでないのでcolorのqueryは無視される

    my_pile.set_opened!
    assert_equal 2, @strategy.get_cards_of(my_pile, {:color => 'Red', :number => 1}).size # openedなのでcolorのqueryも有効
    assert_equal 0, @strategy.get_cards_of(my_pile, {:color => 'NonExistence', :number => 1}).size # openedなのでcolorのqueryも有効
  end

  def test_get_total_points_of
    assert_equal 13, @strategy.get_total_points_of(@sample_pile)
    assert_equal 6, @strategy.get_total_points_of(@sample_pile, {:number => 2})
    assert_equal 0, @strategy.get_total_points_of(@sample_pile, {:number => 100})

    @sample_pile.set_opened!
    assert_equal 5, @strategy.get_total_points_of(@sample_pile, {:color => 'Yellow'})
    assert_equal 0, @strategy.get_total_points_of(@sample_pile, {:color => 'NonExistence'})
  end

  def test_get_the_card_to_play
    card = @strategy.get_the_card_to_play(@sample_pile, @game_board)
    assert_equal('Yellow', card.suit)
    assert_equal(3, card.number)
    card = @strategy.get_the_card_to_play(@sample_pile, @game_board)
    assert_equal('Yellow', card.suit)
    assert_equal(3, card.number)
  end

  def test_choose_card_from_cards
    100.times do
      setup
      first = Card_Default.new(['Red', 'Blue', 'Green'].sort_by { |color|  rand}.first, rand(3) + 1)
      second = Card_Default.new('Yellow', rand(2) + 1)
      cards = [first, second]
      selected = @strategy.choose_card_from_cards(@game_board, cards, @player)
      assert_not_equal 'Yellow', selected.suit, "#{cards.inspect}"

      @game_board[:cards_on_play].put!(Card_Default.new('Yellow', 3), @opponent).put!(Card_Default.new('Yellow', 2), @opponent)
      selected = @strategy.choose_card_from_cards(@game_board, cards, @player)
      assert_equal [first, second].size, [first, second, selected].uniq.size
    end
  end


end
