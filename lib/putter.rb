#! ruby -Ku
# -*- coding: utf-8 -*-

# I/Oを制御します。
# デフォルトでは、表示文字列をsjisに変換し、Windowsコマンドプロンプトなどで見やすくします。
class Putter
  def initialize
    
  end

  def Putter.puts(string)
    Kernel::puts(Kconv::tosjis(string))
  end

  def Putter.gets
    return Kernel::gets
  end

  def Putter.print(string)
    Kernel::print(Kconv::tosjis(string))
  end
end
