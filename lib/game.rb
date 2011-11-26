#! ruby -Ku
# -*- coding: utf-8 -*-
require './games/cards_pile_american_card'

# ゲームのひな形となるモジュールです。インタフェース定義のみしてあります。
module Game_Templete
  # ゲームインスタンスは、@players_count, @a_pile_of_cards, @first_hands_count, @playersを持つ必要があります．

  # プレイヤの取得・作成
  def get_players # シングルトンパターン
    unless @players.empty? then
      return @players
    end

    @players_count.times do
      @players << Player.new()
    end
    return @players
  end

  # カードセットの新規作成
  def get_a_pile_of_cards
    return @a_pile_of_cards = Cards_Pile_American_Card.new().shuffle! # カードの山を生成してシャッフル
  end

  # プレイヤへの初手配布
  def deal_first_hands!(player)
    raise NotImplementedError
  end

  def play_turn_around(game_board = {})
    raise NotImplementedError
  end

  def play_a_game(class_for_io = Kernel)
    begin
    loop do
      turn_result = play_turn_around # 1ターン（標準的には各プレイヤが1度ずつ行動）
      class_for_io.puts turn_result.message
      break if turn_result.winner # 勝者が決定すれば終了
    end
    rescue
      STDERR.puts "Warning: #$!"
      return false
    end
    return true
  end

  def play_turn_around(game_board = {})
    game_board = {
      :players => @players,
      :piles_of_cards => @a_pile_of_cards,
      :cards_on_play => @cards_on_play
    }.merge(game_board)    # デフォルトに引数のハッシュを上書き
    raise NotImplementedError
  end

  def get_strategy_manual #Fake It, 紛らわしい名前
    raise NotImplementedError
  end
end
