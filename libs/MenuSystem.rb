require_relative '../devs/MatrixDisplay'
require_relative '../libs/MatrixBitmaps'
require_relative '../libs/Cell'
require_relative '../libs/Game'


class MenuSystem
  def initialize(display)
    @lcd = display
    setup
  end

  def run
    @running = true
    @lcd.clear
    @lcd.message("\x0" + @menu[@option][:entry] + "\n " + @menu[(@option + 1) % @menu.count][:entry])
    last = false
    while @running
      if pressed and !last
        @option = (@option + 1) % @menu.count if pressed == AdafruitRGBCharPlate::Down 
        @option = (@option - 1 + @menu.count) % @menu.count if pressed == AdafruitRGBCharPlate::Up 
        self.send(@menu[@option][:handler]) if pressed == AdafruitRGBCharPlate::Right
        @lcd.clear
        @lcd.message("\x0" + @menu[@option][:entry] + "\n " + @menu[(@option + 1) % @menu.count][:entry])
        last = pressed
      else
        last = pressed
      end
      sleep(0.1)      
    end
  end

  Buttons = [
    AdafruitRGBCharPlate::Select,
    AdafruitRGBCharPlate::Up,
    AdafruitRGBCharPlate::Right,
    AdafruitRGBCharPlate::Down,
    AdafruitRGBCharPlate::Left ]

  def pressed
    bits = @lcd.buttons
    Buttons.each do |button|
      return button if ((bits >> button) & 1) > 0
    end
    nil
  end

private
  def setup
    @option = 0
    @menu = [
      { :entry => 'Clock', :handler => :clock }, 
      { :entry => 'Game of Life', :handler => :game_of_life }, 
      { :entry => 'Exit', :handler => :stop }]
    @lcd.createChar(0, CharIcons::Right)
  end

  def clock
    @lcd.clear
    while !@lcd.buttonPressed(AdafruitRGBCharPlate::Left)
      time = Time.now.localtime
      msg = time.strftime("%a, %d.%m.%Y\n%H:%M:%S")
      @lcd.home
      @lcd.message(msg)
    end
  end

  def stop
    @running = false
  end

  def game_of_life
    game = Game.new(16, 16, 0.25)
    game.play!(@lcd)
  end
end
