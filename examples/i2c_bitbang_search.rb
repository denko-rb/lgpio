require 'lgpio'

GPIO_CHIP = 0
SCL_PIN   = 228
SDA_PIN   = 270

chip_handle = LGPIO.chip_open(GPIO_CHIP)
devices = LGPIO.i2c_bb_search(chip_handle, SCL_PIN, SDA_PIN)


if devices.empty?
  puts "No devices found on I2C bus"
else
  puts "I2C device addresses found:"
  devices.each do |address|
    # Print as hexadecimal.
    puts "0x#{address.to_s(16).upcase}"
  end
end
