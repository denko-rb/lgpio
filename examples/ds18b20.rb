require 'lgpio'

GPIO_CHIP = 0
PIN       = 256
PARASITE  = 0

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.one_wire_reset(chip_handle, PIN)
# Skip ROM
LGPIO.one_wire_write(chip_handle, PIN, PARASITE, [0xCC])
# Start conversion
LGPIO.one_wire_write(chip_handle, PIN, PARASITE, [0x44])
# Wait for conversion
sleep(1)
# Reset
LGPIO.one_wire_reset(chip_handle, PIN)
# Skip ROM
LGPIO.one_wire_write(chip_handle, PIN, PARASITE, [0xCC])
# Read 9 bytes from scratchpad
LGPIO.one_wire_write(chip_handle, PIN, PARASITE, [0xBE])
bytes = LGPIO.one_wire_read(chip_handle, PIN, 9)

# Temperature is the first 16 bits (2 bytes of 9 read).
# It's a signed, 2's complement, little-endian decimal. LSB = 2 ^ -4.
#
temperature = bytes[0..1].pack('C*').unpack('s<')[0] * (2.0 ** -4)

puts "DS18B20 reading: #{temperature} \xC2\xB0C"
