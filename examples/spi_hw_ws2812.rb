#
# 2.4 MHz SPI method for writing WS2812 addressable LEDs.
# Based on: https://learn.adafruit.com/dma-driven-neopixels/overview
#
require 'lgpio'

# SPI Config
SPI_DEV  = 1
SPI_CHAN = 0
SPI_MODE = 0
SPI_BAUD = 2_400_000

# 4 pixels: RGBW. Data order per pixel is GRB.
pixels_on = [
  0, 255, 0,
  255, 0, 0,
  0, 0, 255,
  255, 255, 255,
]
# 4 pixels, all off.
pixels_off = Array.new(12) { 0 }

spi_handle = LGPIO.spi_open(SPI_DEV, SPI_CHAN, SPI_BAUD, SPI_MODE)

loop do
  LGPIO.spi_ws2812_write(spi_handle, pixels_on)
  sleep 0.5
  LGPIO.spi_ws2812_write(spi_handle, pixels_off)
  sleep 0.5
end
