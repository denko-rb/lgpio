require 'lgpio'

GPIO_CHIP   = 0
CLOCK_PIN   = 22
INPUT_PIN   = 17
OUTPUT_PIN  = 27

# Emulate data sent over I2C to a SSD1306 OLED, prepending its write address.
START_ARRAY = [0x3C << 1] + [0, 33, 0, 127, 34, 0, 7]
PATTERN_1   = [0x3C << 1] + [64] + Array.new(1024) { 0b00110011 }
PATTERN_2   = [0x3C << 1] + [64] + Array.new(1024) { 0b11001100 }
LOOPS       = 400

chip_handle = LGPIO.chip_open(GPIO_CHIP)
spi_bb      = LGPIO::SPIBitBang.new(handle: chip_handle, clock: CLOCK_PIN, input: INPUT_PIN, output: OUTPUT_PIN)

start = Time.now
(LOOPS / 2).times do
  spi_bb.transfer(write: START_ARRAY)
  spi_bb.transfer(write: PATTERN_1)
  spi_bb.transfer(write: START_ARRAY)
  spi_bb.transfer(write: PATTERN_2)
end
finish = Time.now

LGPIO.chip_close(chip_handle)

# We need to scale the SPI result down because:
#  - SPI bytes are 8 bits on the wire, while I2C are 9 (8 data bits + ACK bit)
#  - The I2C ACK needs 4 GPIO calls to C, while data bits on both buses need 3.
#  - Therefore, scaling factor is (8 * 3) / ((8 * 3) + 4) = 6/7
fps = (LOOPS / (finish - start)) * (6.0 / 7.0)
puts "SSD1306 equivalent result: #{fps.round(2)} fps"
