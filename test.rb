#! /usr/bin/env ruby
require_relative 'devs/AdafruitRGBCharPlate'
require_relative 'libs/CharIcons'

display = AdafruitRGBCharPlate.new

display.createChar(0, CharIcons::Bell)
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

sleep(1)

display.clear
#display.message("Hello World! \n0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
display.setCursor(1,1)
display.message("Test: \x0\x1\x2\x3\x4\x5\x6\x7 \x44\xe1")

1.upto(25) do
  display.scrollDisplayLeft
  sleep(0.25)
end

display.clear

sleep(1)


while !display.buttonPressed(AdafruitRGBCharPlate::Select)
  message = ""
  message += "LEFT " if display.buttonPressed(AdafruitRGBCharPlate::Left)
  message += "RIGHT " if display.buttonPressed(AdafruitRGBCharPlate::Right)
  message += "UP " if display.buttonPressed(AdafruitRGBCharPlate::Up)
  message += "DOWN " if display.buttonPressed(AdafruitRGBCharPlate::Down)
  display.home
  display.message(message)
end
display.clear
sleep(0.5)
while !display.buttonPressed(AdafruitRGBCharPlate::Select)
  time = Time.now
  msg = time.strftime("%a, %d.%m.%Y\n%H:%M:%S")
  display.home
  display.message(msg)
end

display.clear
display.stop
