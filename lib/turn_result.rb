#! ruby -Ku
# -*- coding: utf-8 -*-

#
class Turn_Result
  def initialize
    @winner = nil
    @message = ''
  end
  attr_reader :winner, :message

  def drew!
    @winner = "no"
    @message = @message + ", drawn"
    return self
  end

  def win!(player)
    return self.drew! if player == 'no'
    
    @winner = player
    self.set_message!(" So, #{player.name} win!")
    return self
  end

  def set_message!(message)
    @message = @message + message
    return self
  end
end
