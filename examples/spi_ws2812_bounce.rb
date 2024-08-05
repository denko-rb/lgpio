#
# 2.4 MHz SPI method for writing WS2812 addressable LEDs.
# Based on: https://learn.adafruit.com/dma-driven-neopixels/overview
#
require 'lgpio'

# SPI config
SPI_DEV  = 1
SPI_CHAN = 0
SPI_MODE = 0
SPI_BAUD = 2_400_000

PIXEL_COUNT = 8
COLORS = [
  [255, 255, 255],
  [0, 255, 0],
  [255, 0, 0],
  [0, 0, 255],
  [255, 255, 0],
  [255, 0, 255],
  [0, 255, 255]
]

# Move along the strip and back, one pixel at a time.
POSITIONS = (0..PIXEL_COUNT-1).to_a + (1..PIXEL_COUNT-2).to_a.reverse

pixels = Array.new(PIXEL_COUNT) { [0, 0, 0] }
spi_handle = LGPIO.spi_open(SPI_DEV, SPI_CHAN, SPI_BAUD, SPI_MODE)

loop do
  COLORS.each do |color|
    POSITIONS.each do |index|
      # Clear and write.
      (0..PIXEL_COUNT-1).each { |i| pixels[i] = [0, 0, 0] }
      LGPIO.spi_ws2812_write(spi_handle, pixels.flatten)

      # Set one pixel and write.
      pixels[index] = color
      LGPIO.spi_ws2812_write(spi_handle, pixels.flatten)

      sleep 0.05
    end
  end
end
