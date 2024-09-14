require_relative 'lgpio/lgpio'
require_relative 'lgpio/version'

require_relative 'lgpio/i2c_bitbang'
require_relative 'lgpio/spi_bitbang'

require_relative 'lgpio/hardware_pwm'
require_relative 'lgpio/positional_servo'
require_relative 'lgpio/infrared'

module LGPIO
  LOW = 0
  HIGH = 1
end
