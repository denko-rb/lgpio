require 'lgpio'

INIT_ARRAY  = [0, 168, 63, 211, 0, 64, 161, 200, 218, 18, 164, 166, 213, 128, 219, 32, 217, 241, 141, 20, 32, 0, 175]
START_ARRAY = [0, 33, 0, 127, 34, 0, 7]
PATTERN_1   = Array.new(1024) { 0b00110011 }
PATTERN_2   = Array.new(1024) { 0b11001100 }

GPIO_CHIP   = 0
CLOCK_PIN   = 17
OUTPUT_PIN  = 27
SELECT_PIN  = 22
RESET_PIN   = 5
DC_PIN      = 6

# Initialize
chip_handle = LGPIO.chip_open(GPIO_CHIP)
spi_bb      = LGPIO::SPIBitBang.new(handle: chip_handle, clock: CLOCK_PIN, output: OUTPUT_PIN)
LGPIO.gpio_claim_output(chip_handle, LGPIO::SET_PULL_NONE, SELECT_PIN, LGPIO::HIGH)
LGPIO.gpio_claim_output(chip_handle, LGPIO::SET_PULL_NONE, RESET_PIN, LGPIO::LOW)
LGPIO.gpio_claim_output(chip_handle, LGPIO::SET_PULL_NONE, DC_PIN, LGPIO::LOW)

# OLED STARTUP
LGPIO.gpio_write(chip_handle, RESET_PIN, 1)
LGPIO.gpio_write(chip_handle, DC_PIN, 0)
spi_bb.transfer(write: INIT_ARRAY, select: SELECT_PIN)

FRAME_COUNT = 400

start = Time.now
(FRAME_COUNT / 2).times do
  LGPIO.gpio_write(chip_handle, DC_PIN, 0)
  spi_bb.transfer(write: START_ARRAY, select: SELECT_PIN)
  LGPIO.gpio_write(chip_handle, DC_PIN, 1)
  spi_bb.transfer(write: PATTERN_1, select: SELECT_PIN)
  LGPIO.gpio_write(chip_handle, DC_PIN, 0)
  spi_bb.transfer(write: START_ARRAY, select: SELECT_PIN)
  LGPIO.gpio_write(chip_handle, DC_PIN, 1)
  spi_bb.transfer(write: PATTERN_2, select: SELECT_PIN)
end
finish = Time.now

LGPIO.chip_close(chip_handle)

fps = FRAME_COUNT / (finish - start)
# Also calculate C calls per second, using roughly 23 calls per byte written.
data_calls = START_ARRAY.length + ((PATTERN_1.length + PATTERN_2.length) / 2) * 20
# Add DC, SELECT and clock idle calls.
total_calls  = data_calls + 8
cps = ((total_calls * fps) / 1000.0).round

puts "SSD1306 benchmark result: #{fps.round(2)} fps | #{cps}k C calls/s"
