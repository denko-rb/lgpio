require 'lgpio'

GPIO_CHIP   = 0
CLOCK_PIN   = 22
INPUT_PIN   = 17
OUTPUT_PIN  = 27

# Emulate data sent over I2C to a SSD1306 OLED, prepending its write address.
START_ARRAY = [0x3C << 1] + [0, 33, 0, 127, 34, 0, 7]
PATTERN_1   = [0x3C << 1] + [64] + Array.new(1024) { 0b00110011 }
PATTERN_2   = [0x3C << 1] + [64] + Array.new(1024) { 0b11001100 }
FRAME_COUNT = 400

chip_handle = LGPIO.chip_open(GPIO_CHIP)
spi_bb      = LGPIO::SPIBitBang.new(handle: chip_handle, clock: CLOCK_PIN, input: INPUT_PIN, output: OUTPUT_PIN)

start = Time.now
(FRAME_COUNT / 2).times do
  spi_bb.transfer(write: START_ARRAY)
  spi_bb.transfer(write: PATTERN_1)
  spi_bb.transfer(write: START_ARRAY)
  spi_bb.transfer(write: PATTERN_2)
end
finish = Time.now

LGPIO.chip_close(chip_handle)

# We need to scale the SPI result down because:
#  - SPI bytes are 8 bits on the wire, while I2C are 9 (8 data bits + ACK bit).
#  - The I2C ACK should use 4 GPIO calls to C, while data bits on both buses need 3 calls.
#  - So the scaling factor should theoretically b (8 * 3) / ((8 * 3) + 4) = 24/28
#  - This isn't correct. Because of the "lazy" optimization when setting the data pin
#    (in both protocols), and the line pattern being used, where the first bit of
#    each byte is the opposite of the last bit of the previous byte, two things change:
#    - Each I2C ACK is always effecitvely 3 C calls
#    - For both buses, the 8 data bits only need 20 C calls in total.
#  - So... finally, we scale by a factor of 20/23.
#  - This WILL NOT BE CORRECT if you change the line pattern.
#  - This neglects I2C start and stop calls, and bit changes in the address and start bytes.
fps = (FRAME_COUNT / (finish - start)) * (20.0 / 23.0)
puts "SSD1306 equivalent result: #{fps.round(2)} fps"
