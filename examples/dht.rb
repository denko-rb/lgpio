require 'lgpio'

GPIO_CHIP = 0
DHT_PIN   = 267
chip_handle = LGPIO.chip_open(GPIO_CHIP)
#
# Read a series of pulses input to a GPIO, with an (optional) reset output pulse at start.
# Arguments in order are:
#   gpiochip handle
#   GPIO number
#   Starting (reset) output pulse time in microseconds (0 for no reset)
#   Reset pulse level (0 or 1)
#   Maximum number of pulses to read
#   Timeout in milliseconds
#
data = LGPIO.gpio_read_pulses_us(chip_handle, DHT_PIN, 10_000, 0, 84, 100)

# Handle errors.
raise "error: DHT sensor not connected" unless data
raise "LGPIO error: #{data}" if data.class == Integer

# Discard unneeded pulses
data = data.last(81)
raise "error: incomplete DHT data" unless data.length == 81
data = data.first(80)

# Convert to bytes
bytes = []
data.each_slice(16) do |b|
  byte = 0b00000000
  b.each_slice(2) do |x,y|
    bit = (y<x) ? 0 : 1
    byte = (byte << 1) | bit
  end
  bytes << byte
end

# CRC
crc = bytes[0..3].reduce(0, :+) & 0xFF == bytes[4]
raise "error: DHT CRC check failed" unless crc

# Convert and display
temperature = ((bytes[2] << 8) | bytes[3]).to_f / 10
humidity    = ((bytes[0] << 8) | bytes[1]).to_f / 10

puts "DHT Temperature: #{temperature} \xC2\xB0C"
puts "DHT Humidity:    #{humidity}  %"
