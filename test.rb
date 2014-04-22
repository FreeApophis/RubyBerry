#! /usr/bin/env ruby
require_relative 'devs/AdafruitRGBCharPlate'

display = AdafruitRGBCharPlate.new

display.createChar(0, [0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x1f])
display.createChar(1, [0x0,0x0,0x0,0x0,0x0,0x0,0x1f,0x1f])
display.createChar(2, [0x0,0x0,0x0,0x0,0x0,0x1f,0x1f,0x1f])
display.createChar(3, [0x0,0x0,0x0,0x0,0x1f,0x1f,0x1f,0x1f])
display.createChar(4, [0x0,0x0,0x0,0x1f,0x1f,0x1f,0x1f,0x1f])
display.createChar(5, [0x0,0x0,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f])
display.createChar(6, [0x0,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f])
display.createChar(7, [0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f,0x1f])

display.start(16, 2)
display.clear
display.message("Adafruit RGB LCD\nPlate w/Keypad!")

sleep(5)

display.clear
display.message("Hello World! \n0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
display.setCursor(1,1)
display.message("Test: \x0\x1\x2\x3\x4\x5\x6\x7")

1.upto(250) do
  display.scrollDisplayLeft
  sleep(0.25)
end

display.clear

sleep(1)


while !display.buttonPressed(AdafruitRGBCharPlate::SELECT)
  message = ""
  message += "LEFT " if display.buttonPressed(AdafruitRGBCharPlate::LEFT)
  message += "RIGHT " if display.buttonPressed(AdafruitRGBCharPlate::RIGHT)
  message += "UP " if display.buttonPressed(AdafruitRGBCharPlate::UP)
  message += "DOWN " if display.buttonPressed(AdafruitRGBCharPlate::DOWN)
  display.home
  display.message(message)
end

display.clear
display.stop
