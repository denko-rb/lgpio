require 'lgpio'

INIT_ARRAY  = [0, 168, 63, 211, 0, 64, 161, 200, 218, 18, 164, 166, 213, 128, 219, 32, 217, 241, 141, 20, 32, 0, 175]
START_ARRAY = [0, 33, 0, 127, 34, 0, 7]
PATTERN_1   = [64] + Array.new(1024) { 0b00110011 }
PATTERN_2   = [64] + Array.new(1024) { 0b11001100 }

GPIO_CHIP = 0
SCL_PIN   = 228
SDA_PIN   = 270
ADDRESS   = 0x3C

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.i2c_bb_claim(chip_handle, SCL_PIN, SDA_PIN)

LGPIO.i2c_bb_write(chip_handle, SCL_PIN, SDA_PIN, ADDRESS, INIT_ARRAY)
FRAME_COUNT = 400

start = Time.now
(FRAME_COUNT / 2).times do
  LGPIO.i2c_bb_write(chip_handle, SCL_PIN, SDA_PIN, ADDRESS, START_ARRAY)
  LGPIO.i2c_bb_write(chip_handle, SCL_PIN, SDA_PIN, ADDRESS, PATTERN_1)
  LGPIO.i2c_bb_write(chip_handle, SCL_PIN, SDA_PIN, ADDRESS, START_ARRAY)
  LGPIO.i2c_bb_write(chip_handle, SCL_PIN, SDA_PIN, ADDRESS, PATTERN_2)
end
finish = Time.now

LGPIO.chip_close(chip_handle)

fps = FRAME_COUNT / (finish - start)
puts "SSD1306 benchmark result: #{fps.round(2)} fps"