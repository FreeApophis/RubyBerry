require 'wiringpi'

class MatrixDisplay
  def initialize
    @latch_pin = 0 # Latch-Pin "LT" 
    @clock_pin = 1 # Clock-Pin "SK"
    @data_pin  = 3 # Data-Pin  "R1I"

    @rows = [[127, 255],[191, 255],[223, 255],[239, 255],[247, 255],[251, 255],[253, 255],[254, 255],[255, 127],[255, 191],[255, 223],[255, 239],[255, 247],[255, 251],[255, 253],[255, 254]]

    @io = WiringPi::GPIO.new

    @io.mode(@latch_pin, OUTPUT)
    @io.mode(@clock_pin, OUTPUT)
    @io.mode(@data_pin, OUTPUT)
    
    @buffer = Array.new(32, 0)
  end
  
  def clear
      @io.write(@latch_pin, LOW)
      @io.shiftOut(@data_pin, @clock_pin, MSBFIRST, 0)
      @io.shiftOut(@data_pin, @clock_pin, MSBFIRST, 0)
      @io.shiftOut(@data_pin, @clock_pin, MSBFIRST, 0)
      @io.shiftOut(@data_pin, @clock_pin, MSBFIRST, 0)
      @io.write(@latch_pin, HIGH)
  end

  def full
      @io.write(@latch_pin, LOW)
      @io.shiftOut(@data_pin, @clock_pin, MSBFIRST, 255)
      @io.shiftOut(@data_pin, @clock_pin, MSBFIRST, 255)
      @io.shiftOut(@data_pin, @clock_pin, MSBFIRST, 0)
      @io.shiftOut(@data_pin, @clock_pin, MSBFIRST, 0)
      @io.write(@latch_pin, HIGH)
  end

  def set_pixel(x, y)
   bitmask = 128 >> (x & 0x7)
   n = y * 2 + (x / 8)
   @buffer[n] |= bitmask
  end

  def set_all
    @buffer = Array.new(32, 255)
  end
  
  def reset_pixel(x, y)
   bitmask = (128 >> (x & 0x7))
   n = y * 2 + (x / 8)
   @buffer[n] &&= 255 ^ bitmask
  end

  def reset_all
     @buffer = Array.new(32, 0)
  end

  def draw_buffer
    paint @buffer, 0
  end

  def paint image, offset
    @rows.each_with_index do |row, index|
      @io.write(@latch_pin, LOW)
      @io.shiftOut(@data_pin, @clock_pin, MSBFIRST, image[2 * index + 2 * offset])
      @io.shiftOut(@data_pin, @clock_pin, MSBFIRST, image[2 * index + 2 * offset + 1])
      @io.shiftOut(@data_pin, @clock_pin, MSBFIRST, row[0])
      @io.shiftOut(@data_pin, @clock_pin, MSBFIRST, row[1])
      @io.write(@latch_pin, HIGH)
      sleep 0.0008
    end
    clear
  end
end

