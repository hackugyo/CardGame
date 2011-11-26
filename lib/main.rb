#! ruby -Ku
# -*- coding: utf-8 -*-
require 'kconv'
require './putter'
require './game'
require './turn_result'
require './player'
require './games/dazzle/dazzle'
require './games/dazzle/strategies/strategy_calculate'

CLASS_FOR_IO = Putter
#CLASS_FOR_IO = Kernel
$stdout.sync = true

def main
  game_rule = setup_game
  game_rule.play_a_game(CLASS_FOR_IO)
end

def setup_game
  game_rule = Dazzle.new
  #game_rule = Trick_Taking.new

  players = game_rule.get_players
  if players.empty? then
    exit
  end
  players[0].name = 'ENEMY'
  players[0].set_strategy(Strategy_Calculate.new(CLASS_FOR_IO))

  # players[1].be_manual!(game_rule)
  players[1].set_strategy(Strategy_Manual.new(CLASS_FOR_IO))
  #players[1].set_strategy(Strategy_Calculate.new(CLASS_FOR_IO))
  players[1].name = 'YOU'

  players.each do |player|
    player.dealt!(game_rule.deal_first_hands!(player)) # プレイヤに初手を配る，何が破壊されるのか明確にしたい
  end
  return game_rule
end

main

