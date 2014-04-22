#! /usr/bin/env ruby
require_relative '../devs/AdafruitRGBCharPlate'
require_relative '../libs/CharIcons'
require_relative '../libs/MenuSystem'

display = AdafruitRGBCharPlate.new
display.start(16, 2)

display.message("RubyBerry Radio\n")
menu = MenuSystem.new(display)
menu.run

display.clear
display.stop
