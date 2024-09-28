require 'lgpio'

SCL_CHIP  = 0
SCL_PIN   = 228
SDA_CHIP  = 0
SDA_PIN   = 270

scl_handle = LGPIO.chip_open(SCL_CHIP)
sda_handle = (SCL_CHIP == SDA_CHIP) ? scl_handle : LGPIO.chip_open(SDA_CHIP)
pin_hash =  {
              scl: { handle: scl_handle, line: SCL_PIN },
              sda: { handle: sda_handle, line: SDA_PIN },
            }
i2c_bb = LGPIO::I2CBitBang.new(pin_hash)

devices = i2c_bb.search

LGPIO.chip_close(scl_handle)
LGPIO.chip_close(sda_handle) unless (scl_handle == sda_handle)

if devices.empty?
  puts "No devices found on I2C bus"
else
  puts "I2C device addresses found:"
  devices.each do |address|
    # Print as hexadecimal.
    puts "0x#{address.to_s(16).upcase}"
  end
end
