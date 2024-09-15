require 'lgpio'

GPIO_CHIP   = 0
CLOCK_PIN   = 22
INPUT_PIN   = 17
OUTPUT_PIN  = 27

# Emulate data sent over I2C to a SSD1306 OLED, prepending its write address.
START_ARRAY = [0x3C << 1] + [0, 33, 0, 127, 34, 0, 7]
PATTERN_1   = [0x3C << 1] + [64] + Array.new(1179) { 0b00110011 }
PATTERN_2   = [0x3C << 1] + [64] + Array.new(1179) { 0b11001100 }
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

fps = FRAME_COUNT / (finish - start)
#
# We want to calculate how many C calls were made per second, to compare with I2C:
#  - SPI bytes are 8 bits on the wire, while I2C are 9 (8 data bits + ACK bit).
#  - The I2C ACK should do 4 C API calls, while data bits on both buses need 3 calls.
#  - This isn't always true. Because of the "lazy" optimization when setting the data pin
#    in both protocols, and the line pattern being used, where the first bit of
#    each byte is the inverse of the last bit of the previous byte, two things change:
#    - Each I2C ACK is effecitvely 3 C calls. The data bit either before or after is always 1,
#      eliminating a write to SDA.
#    - For both buses, the "2 on, 2 off" patern means 8 data bits are only 20 C calls total.
#  - So SPI is 20 for all pixel bytes, and I2C is 23 for all pixel bytes.
#  - Ignores bit changes in the address and start bytes.
#  - Ignore 10 calls per frame for I2C start/stop, and 2 calls per frame for SPI clock idle.
#  - These are only 1% of total calls, so should be negligible.
#  - Changing the line pattern WILL break this calculation.
#
cps = (START_ARRAY.length + ((PATTERN_1.length + PATTERN_2.length) / 2)) * 20 * fps
cps = (cps / 1000.0).round

puts "SSD1306 sim result: #{fps.round(2)} fps | #{cps}k C calls/s"
