require 'lgpio'

GPIO_CHIP = 0
PIN       = 256

chip_handle = LGPIO.chip_open(GPIO_CHIP)
one_wire = LGPIO::OneWire.new(chip_handle, PIN)
one_wire.search

puts; puts "Found these 1-wire addresss (HEX) on the bus:"; puts

one_wire.found_addresses.each do |address|
  puts address.to_s(16)
end
puts
