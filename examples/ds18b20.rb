require 'lgpio'

GPIO_CHIP = 0
PIN       = 256
PARASITE  = false

chip_handle = LGPIO.chip_open(GPIO_CHIP)
one_wire = LGPIO::OneWire.new(chip_handle, PIN)

one_wire.reset
# Skip ROM
one_wire.write([0xCC], parasite: PARASITE)
# Start conversion
one_wire.write([0x44], parasite: PARASITE)
# Wait for conversion
sleep(1)
# Reset
one_wire.reset
# Skip ROM
one_wire.write([0xCC], parasite: PARASITE)
# Read 9 bytes from scratchpad
one_wire.write([0xBE], parasite: PARASITE)
bytes = one_wire.read(9)

# Temperature is the first 16 bits (2 bytes of 9 read).
# It's a signed, 2's complement, little-endian decimal. LSB = 2 ^ -4.
#
temperature = bytes[0..1].pack('C*').unpack('s<')[0] * (2.0 ** -4)

puts "DS18B20 reading: #{temperature} \xC2\xB0C"
