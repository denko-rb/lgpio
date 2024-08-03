#
# 2.4 MHz SPI method for writing WS2812 addressable LEDs
# Based on:https://learn.adafruit.com/dma-driven-neopixels/overview
#
require 'lgpio'

# WS2812 Constants
NP_ONE   = 0b110
NP_ZERO  = 0b100
NP_START = [0]
NP_END   = Array.new(90) { 0 }
BITS     = (0..7).to_a.reverse

# SPI Config
SPI_DEV  = 1
SPI_CHAN = 0
SPI_MODE = 0
SPI_BAUD = 2_400_000

# Map array of pixel values (3 bytes each) to raw SPI bytes (1bit -> 3 bits).
def pixel_to_raw_spi_bytes(pixel_arr)
  raw_spi_bytes = []
  pixel_arr.flatten.each do |byte|
    long = 0b0
    for i in BITS do
      long = long << 3
      if byte[i] == 0
        long |= NP_ZERO
      else
        long |= NP_ONE
      end
    end
    # Pack as big-endian uint32, then unpack to bytes, taking lowest 24 bits only.
    long = [long].pack('L>')
    raw_spi_bytes << long.unpack('C*')[1..3]
  end
  return raw_spi_bytes.flatten
end

# 4 pixels: RGBW. Data order per pixel is GRB.
pixels_on = [
  0, 255, 0,
  255, 0, 0,
  0, 0, 255,
  255, 255, 255,
]
data_on = NP_START + pixel_to_raw_spi_bytes(pixels_on) + NP_END

# 4 pixels, all off.
pixels_off = Array.new(12) { 0 }
data_off = NP_START + pixel_to_raw_spi_bytes(pixels_off) + NP_END

spi_handle = LGPIO.spi_open(SPI_DEV, SPI_CHAN, SPI_BAUD, SPI_MODE)

loop do
  LGPIO.spi_write(spi_handle, data_on)
  sleep 0.5
  LGPIO.spi_write(spi_handle, data_off)
  sleep 0.5
end
