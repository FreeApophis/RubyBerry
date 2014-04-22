require_relative 'RaspberryPiTools'
require 'i2c'

class AdafruitRGBCharPlate

  # Port expander registers
  MCP23017_IOCON_BANK0 = 0x0A # IOCON when Bank 0 active
  MCP23017_IOCON_BANK1 = 0x15 # IOCON when Bank 1 active

  # These are register addresses when in Bank 1 only:
  MCP23017_GPIOA       = 0x09
  MCP23017_IODIRB      = 0x10
  MCP23017_GPIOB       = 0x19

  # Port expander input pin definitions
  Select               = 0
  Right                = 1
  Down                 = 2
  Up                   = 3
  Left                 = 4

  # LED colors
  Off                  = 0x00
  Red                  = 0x01
  Green                = 0x02
  Blue                 = 0x04
  Yellow               = Red + Green
  Teal                 = Green + Blue
  Violet               = Red + Blue
  White                = Red + Green + Blue
  ON                   = Red + Green + Blue

  # LCD Commands
  LCD_CLEARDISPLAY = 0x01
  LCD_RETURNHOME = 0x02
  LCD_ENTRYMODESET = 0x04
  LCD_DISPLAYCONTROL = 0x08
  LCD_CURSORSHIFT = 0x10
  LCD_FUNCTIONSET = 0x20
  LCD_SETCGRAMADDR = 0x40
  LCD_SETDDRAMADDR = 0x80

  # Flags for display on/off control
  LCD_DISPLAYON = 0x04
  LCD_DISPLAYOFF = 0x00
  LCD_CURSORON = 0x02
  LCD_CURSOROFF = 0x00
  LCD_BLINKON = 0x01
  LCD_BLINKOFF = 0x00

  # Flags for display entry mode
  LCD_ENTRYRIGHT = 0x00
  LCD_ENTRYLEFT = 0x02
  LCD_ENTRYSHIFTINCREMENT = 0x01
  LCD_ENTRYSHIFTDECREMENT = 0x00

  # Flags for display/cursor shift
  LCD_DISPLAYMOVE = 0x08
  LCD_CURSORMOVE = 0x00
  LCD_MOVERIGHT = 0x04
  LCD_MOVELEFT = 0x00

  def initialize(addr = 0x20)
    @i2c = I2C::create("/dev/i2c-#{RaspberryPiTools.getPiI2CBusNumber}")

    # I2C is relatively slow. MCP output port states are cached
    # so we don't need to constantly poll-and-change bit states.
    @porta, @portb, @ddrb = 0, 0, 0b00010000
    @addr = addr
    
    # Set MCP23017 IOCON register to Bank 0 with sequential operation.
    # If chip is already set for Bank 0, this will just write to OLATB,
    # which won't seriously bother anything on the plate right now
    # (Blue backlight LED will come on, but that's done in the next
    # step anyway).
    @i2c.write(@addr, MCP23017_IOCON_BANK1, 0)

    # Brute force reload ALL registers to known state. This also
    # sets up all the input pins, pull-ups, etc. for the Pi Plate.
    @i2c.write(@addr,
        0,          # 
        0b00111111, # IODIRA R+G LEDs=outputs, buttons=inputs
        @ddrb ,     # IODIRB LCD D7=input, Blue LED=output
        0b00111111, # IPOLA Invert polarity on button inputs
        0b00000000, # IPOLB
        0b00000000, # GPINTENA Disable interrupt-on-change
        0b00000000, # GPINTENB
        0b00000000, # DEFVALA
        0b00000000, # DEFVALB
        0b00000000, # INTCONA
        0b00000000, # INTCONB
        0b00000000, # IOCON
        0b00000000, # IOCON
        0b00111111, # GPPUA Enable pull-ups on buttons
        0b00000000, # GPPUB
        0b00000000, # INTFA
        0b00000000, # INTFB
        0b00000000, # INTCAPA
        0b00000000, # INTCAPB
        @porta,     # GPIOA
        @portb,     # GPIOB
        @porta,     # OLATA 0 on all outputs; side effect of
        @portb )    # OLATB turning on R+G+B backlight LEDs.
    

    # Switch to Bank 1 and disable sequential operation.
    # From this point forward, the register addresses do NOT match
    # the list immediately above. Instead, use the constants defined
    # at the start of the class. Also, the address register will no
    # longer increment automatically after this -- multi-byte
    # operations must be broken down into single-byte calls.
    @i2c.write(@addr, MCP23017_IOCON_BANK0, 0b10100000)

    @displayshift = (LCD_CURSORMOVE | LCD_MOVERIGHT)
    @displaymode = (LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT)
    @displaycontrol = (LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF)

    write(0x33) # Init
    write(0x32) # Init
    write(0x28) # 2 line 5x8 matrix
    write(LCD_CLEARDISPLAY)
    write(LCD_CURSORSHIFT | @displayshift)
    write(LCD_ENTRYMODESET | @displaymode)
    write(LCD_DISPLAYCONTROL | @displaycontrol)
    write(LCD_RETURNHOME)
  end

  def start(cols, lines)
    @currline = 0
    @numlines = lines
    clear
  end

  # Puts the MCP23017 back in Bank 0 + sequential write mode so
  # that other code using the 'classic' library can still work.
  # Any code using this newer version of the library should
  # consider adding an atexit() handler that calls this.
  def stop
    @porta = 0b11000000 # Turn off LEDs on the way out
    @portb = 0b00000001
    sleep(0.0015)
    @i2c.write(@addr, MCP23017_IOCON_BANK1, 0)
    @i2c.write(@addr, 
        0,
        0b00111111, # IODIRA
        @ddrb ,     # IODIRB
        0b00000000, # IPOLA
        0b00000000, # IPOLB
        0b00000000, # GPINTENA
        0b00000000, # GPINTENB
        0b00000000, # DEFVALA
        0b00000000, # DEFVALB
        0b00000000, # INTCONA
        0b00000000, # INTCONB
        0b00000000, # IOCON
        0b00000000, # IOCON
        0b00111111, # GPPUA
        0b00000000, # GPPUB
        0b00000000, # INTFA
        0b00000000, # INTFB
        0b00000000, # INTCAPA
        0b00000000, # INTCAPB
        @porta,     # GPIOA
        @portb,     # GPIOB
        @porta,     # OLATA
        @portb )    # OLATB
  end

  def clear
    write(LCD_CLEARDISPLAY)
  end

  def home
    write(LCD_RETURNHOME)
  end

  def setCursor(col, row)
    if (row > @numlines)
      row = @numlines - 1
    elsif row < 0
      row = 0
      write(LCD_SETDDRAMADDR | (col + row_offsets[row]))
    end
  end

  # Turn the display on (quickly)
  def display
    @displaycontrol |= LCD_DISPLAYON
    write(LCD_DISPLAYCONTROL | @displaycontrol)
  end

  # Turn the display off (quickly)
  def noDisplay
    @displaycontrol &= ~LCD_DISPLAYON
    write(LCD_DISPLAYCONTROL | @displaycontrol)    
  end

  # Underline cursor on
  def cursor
    @displaycontrol |= LCD_CURSORON
    write(LCD_DISPLAYCONTROL | @displaycontrol)
  end

  # Underline cursor off
  def noCursor
    @displaycontrol &= ~LCD_CURSORON
    write(LCD_DISPLAYCONTROL | @displaycontrol)
  end

  # Toggles the underline cursor On/Off
  def toggleCursor
    @displaycontrol ^= LCD_CURSORON
    write(LCD_DISPLAYCONTROL | @displaycontrol)
  end

  # Turn on the blinking cursor
  def blink
    @displaycontrol |= LCD_BLINKON
    write(LCD_DISPLAYCONTROL | @displaycontrol)
  end

  # Turn off the blinking cursor
  def noBlink
    @displaycontrol &= ~LCD_BLINKON
    write(LCD_DISPLAYCONTROL | @displaycontrol)
  end

  # Toggles the blinking cursor
  def toggleBlink
    @displaycontrol ^= LCD_BLINKON
    write(LCD_DISPLAYCONTROL | @displaycontrol)
  end

  # These commands scroll the display without changing the RAM
  def scrollDisplayLeft
    @displayshift = LCD_DISPLAYMOVE | LCD_MOVELEFT
    write(LCD_CURSORSHIFT | @displayshift)
  end

  # These commands scroll the display without changing the RAM
  def scrollDisplayRight
    @displayshift = LCD_DISPLAYMOVE | LCD_MOVERIGHT
    write(LCD_CURSORSHIFT | @displayshift)
  end

  # This is for text that flows left to right
  def leftToRight
    @displaymode |= LCD_ENTRYLEFT
    write(LCD_ENTRYMODESET | @displaymode)
  end

  # This is for text that flows right to left
  def rightToLeft
    @displaymode &= ~LCD_ENTRYLEFT
    write(LCD_ENTRYMODESET | @displaymode)
  end

  # This will 'right justify' text from the cursor
  def autoscroll
    @displaymode |= LCD_ENTRYSHIFTINCREMENT
    write(LCD_ENTRYMODESET | @displaymode)
  end

  def noAutoscroll
    @displaymode &= ~LCD_ENTRYSHIFTINCREMENT
    write(LCD_ENTRYMODESET | @displaymode)
  end

  def createChar(location, bitmap)
    write(LCD_SETCGRAMADDR | ((location & 7) << 3))
    write(bitmap, true)
    write(LCD_SETDDRAMADDR)
  end

  # Send string to LCD. Newline wraps to second line
  def message(text)
    lines = text.split("\n")              # Split at newline(s)
    lines.each_with_index do |line, i|    # For each substring...
      if (i > 0)                          # If newline(s),
        write(0xC0)                       # set DDRAM address to 2nd line
      end
      write(line, true)                   # Issue substring
    end
  end

  def backlight(color)
    c = ~color
    @porta = (@porta & 0b00111111) | ((c & 0b011) << 6)
    @portb = (@portb & 0b11111110) | ((c & 0b100) >> 2)

    # Has to be done as two writes because sequential operation is off.
    @i2c.write(@addr, MCP23017_GPIOA, @porta)
    @i2c.write(@addr, MCP23017_GPIOB, @portb)
  end

  def buttonPressed(button)
    bits = @i2c.read(@addr, 1, MCP23017_GPIOA).unpack("C").first
    ((bits >> button) & 1) > 0  
  end

  def buttons
    bits = @i2c.read(@addr, 1, MCP23017_GPIOA).unpack("C").first
    bits & 0b11111
  end

private

  # The LCD data pins (D4-D7) connect to MCP pins 12-9 (PORTB4-1), in
  # that order. Because this sequence is 'reversed,' a direct shift
  # won't work. This table remaps 4-bit data values to MCP PORTB
  # outputs, incorporating both the reverse and shift.
  def flip
    [ 0b00000000, 0b00010000, 0b00001000, 0b00011000,
      0b00000100, 0b00010100, 0b00001100, 0b00011100,
      0b00000010, 0b00010010, 0b00001010, 0b00011010,
      0b00000110, 0b00010110, 0b00001110, 0b00011110 ]
  end

  # The speed of LCD accesses is inherently limited by I2C through the
  # port expander. A 'well behaved program' is expected to poll the
  # LCD to know that a prior instruction completed. But the timing of
  # most instructions is a known uniform 37 mS. The enable strobe
  # can't even be twiddled that fast through I2C, so it's a safe bet
  # with these instructions to not waste time polling (which requires
  # several I2C transfers for reconfiguring the port direction).
  # The D7 pin is set as input when a potentially time-consuming
  # instruction has been issued (e.g. screen clear), as well as on
  # startup, and polling will then occur before more commands or data
  # are issued.
  def pollables
    [ LCD_CLEARDISPLAY, LCD_RETURNHOME ]
  end

  def row_offsets
    [ 0x00, 0x40, 0x14, 0x54 ]
  end

  # Low-level 4-bit interface for LCD output. This doesn't actually
  # write data, just returns a byte array of the PORTB state over time.
  # Can concatenate the output of multiple calls (up to 8) for more
  # efficient batch write.
  def out4(bitmask, value)
    hi = bitmask | flip[value >> 4]
    lo = bitmask | flip[value & 0x0F]
    return [hi | 0b00100000, hi, lo | 0b00100000, lo]
  end

  # Send command/data to LCD
  def write(value, char_mode = false)
    # If pin D7 is in input state, poll LCD busy flag until clear.
    if (@ddrb & 0b00010000) > 0 
      lo = (@portb & 0b00000001) | 0b01000000
      hi = lo | 0b00100000                          # E=1 (strobe)
      @i2c.write(@addr, MCP23017_GPIOB, lo)
      while true
        # Strobe high (enable)
        @i2c.write(@addr, hi)
        # First nybble contains busy state
        bits = @i2c.read(@addr, 1).unpack("C").first
        # Strobe low, high, low. Second nybble (A3) is ignoRed.
        @i2c.write(@addr, MCP23017_GPIOB, lo, hi, lo)
        break if (bits & 0b00000010) # D7=0, not busy
      end
      @portb = lo

      # Polling complete, change D7 pin to output
      @ddrb &= 0b11101111
      @i2c.write(@addr, MCP23017_IODIRB, @ddrb)
    end

    bitmask = @portb & 0b00000001                   # Mask out PORTB LCD control bits
    bitmask |= 0b10000000 if char_mode              # Set data bit if not a command

    if value.is_a?(String)
      value = value.unpack("C*")
    end

    if value.is_a?(Array)
      last = value.count - 1                        # Last byte
      data = []                                     
      value.each_with_index do |v, i|               
        data += out4(bitmask, v)
        if (data.count >= 32) or (i == last)
          @i2c.write(@addr, MCP23017_GPIOB, *data)
          @portb = data[-1]                         # Save state of last byte out
          data = []                                 # Clear list for next iteration
        end
      end
    else
      data = out4(bitmask, value)
      @i2c.write(@addr, MCP23017_GPIOB, *data)
      @portb = data[-1]
    end

    if (!char_mode) and (pollables.include?(value))
      @ddrb |= 0b00010000
      @i2c.write(@addr, MCP23017_IODIRB, @ddrb)
    end
  end
end
