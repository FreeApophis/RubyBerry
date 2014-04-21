require_relative 'RaspberryPiTools'
require 'i2c'

class AdafruitRGBCharPlate

  # Port expander registers
  MCP23017_IOCON_BANK0 = 0x0A # IOCON when Bank 0 active
  MCP23017_IOCON_BANK1 = 0x15 # IOCON when Bank 1 active

  # These are register addresses when in Bank 1 only:
  MCP23017_GPIOA = 0x09
  MCP23017_IODIRB = 0x10
  MCP23017_GPIOB = 0x19

  # Port expander input pin definitions
  SELECT = 0
  RIGHT = 1
  DOWN = 2
  UP = 3
  LEFT = 4

  # LED colors
  OFF = 0x00
  RED = 0x01
  GREEN = 0x02
  BLUE = 0x04
  YELLOW = RED + GREEN
  TEAL = GREEN + BLUE
  VIOLET = RED + BLUE
  WHITE = RED + GREEN + BLUE
  ON = RED + GREEN + BLUE

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


  def initialize
    i2c = I2C::Dev.create("/dev/i2c-#{RaspberryPiTools.getPiI2CBusNumber}")
    i2c.write(0x20, MCP23017_IOCON_BANK1)
  end
end
