class MathVector(T) < Array(T)
  def +(a) self.map_with_index{|x,k| x+a[k]}.to_mathv end
  def -(a) self.map_with_index{|x,k| x-a[k]}.to_mathv end
  def -() self.map{|x| -x}.to_mathv  end
  def +() self end
  def *(a) self.map{|x| x*a}.to_mathv end
end

struct Float
  def *(a : MathVector(T))  a*self end
end

class Array(T)
  def to_mathv
    x=MathVector(T).new
    self.each{|v| x.push v}
    x
  end
end
