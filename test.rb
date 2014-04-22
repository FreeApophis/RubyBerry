#! /usr/bin/env ruby
require_relative 'devs/AdafruitRGBCharPlate'

display = AdafruitRGBCharPlate.new

display.start(16, 2)
display.clear
display.message("Adafruit RGB LCD\nPlate w/Keypad!")

sleep(5)

display.stop
