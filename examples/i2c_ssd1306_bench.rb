require 'lgpio'

I2C_DEV     = 3
INIT_ARRAY  = [0, 168, 63, 211, 0, 64, 161, 200, 218, 18, 164, 166, 213, 128, 219, 32, 217, 241, 141, 20, 32, 0, 175]
START_ARRAY = [0, 33, 0, 127, 34, 0, 7]
BLANK_ARRAY = [64] + Array.new(1024) { 0 }
FILL_ARRAY  = [64] + Array.new(1024) { 255 }

ssd1306_handle = LGPIO.i2c_open(I2C_DEV, 0x3C, 0)
LGPIO.i2c_write_device(ssd1306_handle, INIT_ARRAY)
FRAME_COUNT = 100

start = Time.now
(FRAME_COUNT / 2).times do
  LGPIO.i2c_write_device(ssd1306_handle, START_ARRAY)
  LGPIO.i2c_write_device(ssd1306_handle, FILL_ARRAY)
  LGPIO.i2c_write_device(ssd1306_handle, START_ARRAY)
  LGPIO.i2c_write_device(ssd1306_handle, BLANK_ARRAY)
end
finish = Time.now

LGPIO.i2c_close(ssd1306_handle)

fps = FRAME_COUNT / (finish - start)
puts "SSD1306 benchmark result: #{fps.round(2)} fps"
