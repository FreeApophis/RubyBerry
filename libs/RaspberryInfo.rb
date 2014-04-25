require 'sysinfo'

class RaspberryInfo
  def initialize
    @sysinfo = SysInfo.new
  end

  def ip_address 
    @sysinfo.ipaddress_internal
    #Socket.ip_address_list.detect{|intf| !intf.ipv4_loopback? }.getnameinfo[0]
  end

  def uptime
    @sysinfo.uptime
  end

  def human_uptime
    IO.popen('uptime').each do |line|
      return line.split[2] + ' ' + line.split[3]
    end
  end
end
