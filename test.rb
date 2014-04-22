#! /usr/bin/env ruby
require_relative 'devs/AdafruitRGBCharPlate'

display = AdafruitRGBCharPlate.new

display.start(16, 2)
display.clear
display.message("Adafruit RGB LCD\nPlate w/Keypad!")

sleep(5)

display.clear
display.message("Hello World!\n0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")

1.upto(250) do
  display.scrollDisplayLeft
  sleep(0.25)
end

display.stop
