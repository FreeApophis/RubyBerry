#
# Conway's Game of Life in Ruby
# http://en.wikipedia.org/wiki/Conway's_Game_of_Life
# 
# Some code from this excellent article:
# http://rubyquiz.strd6.com/quizzes/193-game-of-life
#

class Game
  def initialize(width, height, seed_probability)
    @width, @height = width, height
    @cells = Array.new(height) { Array.new(width) { Cell.new(seed_probability) } }
    @display = MatrixDisplay.new

    #@button1_pin  = 4
    #@button2_pin  = 5

    @io = WiringPi::GPIO.new
    #@io.mode(@button1_pin, INPUT)
    #@io.mode(@button2_pin, INPUT)
  end
  
  def play!
    #while true
    1.upto(10000).each do
      #break if @io.read(@button1_pin) == 0
      #exit if @io.read(@button2_pin) == 0
      next!
      matrix_plot
      matrix_plot
      matrix_plot
    end
  end

  def matrix_plot
    @display.reset_all
    @cells.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        @display.set_pixel(x,y) if cell.alive?
      end
    end
    (1..2).each do 
      @display.draw_buffer
    end
  end
  
  def next!
    @cells.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        cell.neighbors = alive_neighbours(y, x)
      end
    end
    @cells.each { |row| row.each { |cell| cell.next! } }
  end
  
  def alive_neighbours(y, x)
    [[-1, 0], [1, 0], # sides
     [-1, 1], [0, 1], [1, 1], # over
     [-1, -1], [0, -1], [1, -1] # under
    ].inject(0) do |sum, pos|
      sum + @cells[(y + pos[0]) % @height][(x + pos[1]) % @width].to_i
    end
  end
  
  def to_s
    @cells.map { |row| row.join }.join("\n")
  end
end
