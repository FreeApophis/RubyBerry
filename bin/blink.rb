#!/usr/bin/ruby

require 'wiringpi'

button1_pin  = 4
button2_pin  = 5
red_led_pin  = 6

io = WiringPi::GPIO.new
io.mode(button1_pin, INPUT)
io.mode(button2_pin, INPUT)
io.mode(red_led_pin, OUTPUT)

was_active = false
blink = false
while io.read(button2_pin) == 1
  if (io.read(button1_pin) == 0) and !was_active
    was_active = true
    blink = !blink
  end
  if io.read(button1_pin) == 1
    was_active = false
  end
  sleep 0.1
  if blink
    io.write(red_led_pin, 1)
    sleep 0.1
    io.write(red_led_pin, 0)
  end
end
