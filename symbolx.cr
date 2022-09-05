raise "SymbolX requires 64bit pointers - sorry, you can't use SymbolX and have to remove the shard" unless sizeof(Pointer(Symbol))==8
class SymbolX
  @@map= Array(String).new
  #actually, our own ones wouldn't need to have the same start, but if we use more than the last 32bits it would break Crystal's to_i so we can also jsut stay withinimplementation
  @@head : UInt64 = (:symbolX.unsafe_as(Pointer(Void)).address&0xffffffff00000000)+0xFFFFFFFF 
  def self.for (s : String)
    i= @@map.index(s)||(puts "You've reached a dangerous amount of runtime symbols - good luck! (sadly Crystal doesn't support symbols and requires such hacks)" if @@map.size>= 0xFFFFFFFF; @@map << s; @@map.size-1)
    return Pointer(Void).new(@@head-i).unsafe_as Symbol
  end

  def self.to_s (sym : Symbol)
    (j=sym.to_i)<0 ? @@map[(j*-1)-1] : nil  
  end
end

struct Symbol  
  def to_s
    (to_i<0 ? SymbolX.to_s(self) : previous_def).not_nil!
  end

  def == (other)
    return false unless other.is_a? Symbol
    to_s==other.to_s
  end

  def == (other : Symbol)
    (to_i*other.to_i) < 0 ? to_s==other.to_s : to_i==other.to_i
  end
end

class String
  def to_sym
    SymbolX.for self
  end
end
