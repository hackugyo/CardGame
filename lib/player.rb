#! ruby -Ku
# -*- coding: utf-8 -*-
require './games/strategy_random'
require './games/strategy_manual'

# カードゲームの汎用プレイヤクラスです
# カードを手札に受け取り、それを何枚か手札から出す、というプレイ手順を持つカードゲームをすべてサポートします
class Player
  # プレイヤを初期化します。
  # 引数strategy：COMの取る戦略です
  # （人間による操作＝手動での決定も、strategyの一種として扱います）
  def initialize(strategy = Strategy_Random.new)
    @hands = []
    @points = 0 # Fake It
    rand_name = %w[Pochi Tama Mike Debu Buchi Kuro].sort_by{rand}.first
    @name = "#{rand_name}"
    @strategy = strategy
    @owned_cards = []
    @owning_points = {}
  end
  attr_reader :hands, :points, :owned_cards, :owning_points, :strategy
  attr_accessor :name

  # カードを配られたら手札に加えます
  def dealt!(cards)
    unless cards then
      return false
    end
    @hands.concat(cards)
  end

  # 点を得たら加算します
  def get_points(points)
    @points += points
  end

  def set_strategy(strategy)
    @strategy = strategy
  end

  # 特定のゲームルールのもとで、手動操作戦略をとる（人間プレイヤ）よう設定します
  def be_manual!(game_rule)
    @strategy = game_rule.get_strategy_manual
  end

  def manual?
    return @strategy.class == Strategy_Manual
  end

  # ゲームの状況を確認し、戦略に従って、カードを1枚場に出します。
  # 引数game_board：このプレイヤインスタンスに公開されている、ゲーム内の各種情報です。
  # 返り値selected_card：今回場に出し、手札からなくなったカードです。
  def play_cards!(game_board)
    if @hands.empty? then
      return false
    end
    selected_card = @strategy.select_card_from_hands(game_board, self)
    @hands.reject!{|card_in_hand| card_in_hand == selected_card}
    return selected_card
  end

  def own_cards!(cards)
    @owned_cards.concat(cards)
    return self
  end

  def set_owning_points!(hash)
    @owning_points = @owning_points.merge(hash)
    return self
  end


  def choose_cards(game_board, cards)
    return @strategy.choose_card_from_cards(game_board, cards, self)
  end


end
