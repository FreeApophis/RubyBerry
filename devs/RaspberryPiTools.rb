class RaspberryPiTools
  # Gets the version number of the Raspberry Pi board"
  # Courtesy quick2wire-python-api
  # https://github.com/quick2wire/quick2wire-python-api
  def self.getPiRevision()
    begin
      return 2
    rescue
      0
    end
  end

  # Gets the I2C bus number /dev/i2c#
  def self.getPiI2CBusNumber()
    (getPiRevision() > 1) ?  1 : 0
  end
end
