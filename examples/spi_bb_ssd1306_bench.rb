require 'lgpio'

INIT_ARRAY  = [0, 168, 63, 211, 0, 64, 161, 200, 218, 18, 164, 166, 213, 128, 219, 32, 217, 241, 141, 20, 32, 0, 175]
START_ARRAY = [0, 33, 0, 127, 34, 0, 7]
PATTERN_1   = Array.new(1024) { 0b00110011 }
PATTERN_2   = Array.new(1024) { 0b11001100 }

# Pins for Radxa Zero 3W
# Demonstration of how to use GPIOs across multiple /dev/gpiochip devices.
pins = {
  clock:  { chip: 1, line: 4 },
  output: { chip: 3, line: 4 },
  reset:  { chip: 3, line: 5 },
  dc:     { chip: 3, line: 6 },
  cs:     { chip: 3, line: 7 },
}

# Open chip handles without duplicating.
open_handles = []
pins.each_value do |hash|
  if hash[:handle] = open_handles[hash[:chip]]
  else
    hash[:handle] = LGPIO.chip_open(hash[:chip])
    open_handles[hash[:chip]] = hash[:handle]
  end
end

spi_bb = LGPIO::SPIBitBang.new(clock: pins[:clock], output: pins[:output])
LGPIO.gpio_claim_output(pins[:reset][:handle], pins[:reset][:line], LGPIO::SET_PULL_NONE, LGPIO::LOW)
LGPIO.gpio_claim_output(pins[:dc][:handle], pins[:dc][:line], LGPIO::SET_PULL_NONE, LGPIO::LOW)
LGPIO.gpio_claim_output(pins[:cs][:handle], pins[:cs][:line], LGPIO::SET_PULL_NONE, LGPIO::HIGH)

# OLED STARTUP
LGPIO.gpio_write(pins[:reset][:handle], pins[:reset][:line], 1)
LGPIO.gpio_write(pins[:dc][:handle], pins[:dc][:line], 0)
spi_bb.transfer(write: INIT_ARRAY, select: pins[:cs])

FRAME_COUNT = 400

start = Time.now
(FRAME_COUNT / 2).times do
  LGPIO.gpio_write(pins[:dc][:handle], pins[:dc][:line], 0)
  spi_bb.transfer(write: START_ARRAY, select: pins[:cs])
  LGPIO.gpio_write(pins[:dc][:handle], pins[:dc][:line], 1)
  spi_bb.transfer(write: PATTERN_1, select: pins[:cs])
  LGPIO.gpio_write(pins[:dc][:handle], pins[:dc][:line], 0)
  spi_bb.transfer(write: START_ARRAY, select: pins[:cs])
  LGPIO.gpio_write(pins[:dc][:handle], pins[:dc][:line], 1)
  spi_bb.transfer(write: PATTERN_2, select: pins[:cs])
end
finish = Time.now

# Close all handles.
open_handles.compact.each { |h| LGPIO.chip_close(h) }

fps = FRAME_COUNT / (finish - start)
# Also calculate C calls per second, using roughly 20 calls per byte written.
data_calls = (START_ARRAY.length + (PATTERN_1.length + PATTERN_2.length) / 2) * 20
# Add DC, SELECT and clock idle calls.
total_calls  = data_calls + 8
cps = ((total_calls * fps) / 1000.0).round

puts "SSD1306 benchmark result: #{fps.round(2)} fps | #{cps}k C calls/s"
