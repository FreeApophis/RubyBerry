require_relative '../devs/MatrixDisplay'
require_relative '../libs/MatrixBitmaps'
require_relative '../libs/RaspberryInfo'
require_relative '../libs/Cell'
require_relative '../libs/Game'
require_relative '../libs/News'


class MenuSystem
  def initialize(display)
    @lcd = display
    @news = News.new
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
      { :entry => 'Radio', :handler => :radio }, 
      { :entry => 'Twitter', :handler => :twitter }, 
      { :entry => 'Weather', :handler => :weather }, 
      { :entry => 'News', :handler => :news }, 
      { :entry => 'Lights', :handler => :lights }, 
      { :entry => 'XBMC', :handler => :xbmc }, 
      { :entry => 'Info', :handler => :info },
      { :entry => 'Exit', :handler => :stop },
      { :entry => 'Game of Life', :handler => :game_of_life }] 
    @lcd.createChar(0, CharIcons::Right)
  end

  def clock
    @lcd.clear
    while !@lcd.buttonPressed(AdafruitRGBCharPlate::Left)
      time = Time.now.localtime
      msg = time.strftime("%a, %d.%m.%Y\n%H:%M:%S")
      @lcd.home
      @lcd.message(msg)
      sleep(0.2)
    end
  end

  def stop
    @running = false
  end

  def info
    @info = RaspberryInfo.new
    @lcd.clear
    @lcd.message("IP Address:\n#{@info.ip_address}")
    while !@lcd.buttonPressed(AdafruitRGBCharPlate::Left)
      sleep(0.1)
    end
  end

  def weather
    @lcd.clear
    @lcd.message("ITS FUCKING COLD")
    while !@lcd.buttonPressed(AdafruitRGBCharPlate::Left)
      sleep(0.1)
    end
  end

  def news
    @lcd.clear
    @lcd.message('Loading...')
    @lcd.home
    @lcd.message(@news.last)
    while !@lcd.buttonPressed(AdafruitRGBCharPlate::Left)
      sleep(0.25)
      @lcd.scrollDisplayLeft
    end
  end

  def game_of_life
    game = Game.new(16, 16, 0.25)
    game.play!(@lcd)
  end
end
