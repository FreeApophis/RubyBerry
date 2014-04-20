class Cell
  attr_writer :neighbors
  
  def initialize(seed_probability)
    @alive = seed_probability > rand
  end
  
  def next!
    @alive = @alive ? (2..3) === @neighbors : 3 == @neighbors
  end
  
  def alive?
    @alive
  end  

  def to_i
    @alive ? 1 : 0
  end
  
  def to_s
    @alive ? 'o' : ' '
  end
end

