require 'lgpio'

INIT_ARRAY  = [0, 168, 63, 211, 0, 64, 161, 200, 218, 18, 164, 166, 213, 128, 219, 32, 217, 241, 141, 20, 32, 0, 175]
START_ARRAY = [0, 33, 0, 127, 34, 0, 7]
PATTERN_1   = [64] + Array.new(1024) { 0b00110011 }
PATTERN_2   = [64] + Array.new(1024) { 0b11001100 }

SCL_CHIP  = 0
SCL_PIN   = 228
SDA_CHIP  = 0
SDA_PIN   = 270
ADDRESS   = 0x3C

scl_handle = LGPIO.chip_open(SCL_CHIP)
sda_handle = (SCL_CHIP == SDA_CHIP) ? scl_handle : LGPIO.chip_open(SDA_CHIP)
pin_hash =  {
              scl: { handle: scl_handle, line: SCL_PIN },
              sda: { handle: sda_handle, line: SDA_PIN },
            }
i2c_bb = LGPIO::I2CBitBang.new(pin_hash)

i2c_bb.write(ADDRESS, INIT_ARRAY)
FRAME_COUNT = 400

start = Time.now
(FRAME_COUNT / 2).times do
  i2c_bb.write(ADDRESS, START_ARRAY)
  i2c_bb.write(ADDRESS, PATTERN_1)
  i2c_bb.write(ADDRESS, START_ARRAY)
  i2c_bb.write(ADDRESS, PATTERN_2)
end
finish = Time.now

LGPIO.chip_close(scl_handle)
LGPIO.chip_close(sda_handle) unless (scl_handle == sda_handle)

fps = FRAME_COUNT / (finish - start)
# Also calculate C calls per second, using roughly 24.5 GPIO calls per byte written.
cps = (START_ARRAY.length + ((PATTERN_1.length + PATTERN_2.length) / 2) + 2) * 24.5 * fps
cps = (cps / 1000.0).round

puts "SSD1306 benchmark result: #{fps.round(2)} fps | #{cps}k C calls/s"
