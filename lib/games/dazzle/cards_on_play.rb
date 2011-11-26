#! ruby -Ku
# -*- coding: utf-8 -*-
require 'pp'

COLORS =  ['Blue', 'Red', 'Green', 'Yellow'] #Fake It, ここにも書かなくてはならないとは、設計がおかしい

# カードが出ている場の状態を表すクラスです。
# Dazzleクラスにincludeして使います。
class Cards_On_Play
  def initialize
    @cards_on_play = []
    @winner = nil
    @loser = nil
  end
  attr_reader :cards_on_play

  # played_cardを、turn_playerの所有として場に出します。
  def put!(played_card, turn_player)
    @cards_on_play << played_card.controled_by!(turn_player)
    return self
  end

  # 場に出ているカードをリセットします。
  def clear!
    @cards_on_play.each{|card| card.controled_by!(nil)}
    @cards_on_play.clear
    return self
  end

  # ゲームプレイの状況を表示します。
  def view
    message = ""
    COLORS.each do |color|
      cards_of_this_color = @cards_on_play.select{|card| color == card.suit}
      common_points =  cards_of_this_color.select{|card| card.controler.nil?}.inject(0){|sum, card| sum += card.number}
      message += "  #{color}: #{common_points} points now.("
      controlers = cards_of_this_color.map{|card| card.controler}.uniq
      
      controlers.compact.each_with_index do |controler,i |
        owning_points = cards_of_this_color.select{|card| controler == card.controler}.inject(0){|sum, card| sum += card.number}
        message += " vs " if i > 0
        message += " #{controler.name} owns #{owning_points}"
      end
      message += ")\n"

    end
    return message
  end

  # 双方のプレイヤ（players，playerのArrayを期待）の現在の獲得点を，
  # points（プレイヤをキーとしたハッシュ）の形で返します。
  # 返り値points：プレイヤをキーとした得点のハッシュ
  # 返り値message：獲得点状況を読みやすくした文字列
  def calc_points(players)
    message = "\n"
    players.each do |player|
      cards_owned_by_player = @cards_on_play.select { |card|  player == card.controler}
      player.own_cards!(cards_owned_by_player)
    end
    points = {players[0] => 0, players[1] => 0} # Fake It

    COLORS.each do |color|
      cards_played_with_this_color = @cards_on_play.select{ |card| card.controler.nil? and color == card.suit}
      players.each do |player|
        owning_points = player.owned_cards.select{|card| color == card.suit}.inject(0){|sum, card| sum + card.number}
        message +=  "#{player.name}の#{color}所有権は#{owning_points}, "
        player.set_owning_points!({color => owning_points})#Fake It
      end

      points_of_color = cards_played_with_this_color.inject(0){|sum, card| sum + card.number}
      if players[0].owning_points[color] == players[1].owning_points[color] then
        message += "#{color}は獲得者なし，#{points_of_color}点あった\n"
      else
        winner = players.sort_by{|player| player.owning_points[color]}.last
        message += "#{winner.name}が#{color}を獲得，+#{points_of_color}点\n"
        points[winner] += points_of_color
        # 所有権獲得プレイヤが総取り
      end
      
    end 
    return points, message
  end

  # 勝者を判定・表示します。
  def get_winner(players)
    # players.each {|player| puts "#{player.name}の現在得点：#{player.points}"}
    return 'no' if players[0].points == players[1].points
    return players.sort_by{|player| player.points}.last
  end

end
