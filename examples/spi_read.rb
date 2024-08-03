require 'lgpio'

SPI_DEV  = 1
SPI_CHAN = 0
SPI_MODE = 0
SPI_BAUD = 1_000_000

spi_handle = LGPIO.spi_open(SPI_DEV, SPI_CHAN, SPI_BAUD, SPI_MODE)

# Pull MISO high or low. High gives array of 255, low array of 0.
rx_bytes = LGPIO.spi_read(spi_handle, 8)
puts "RX bytes: #{rx_bytes.inspect}"

LGPIO.spi_close(spi_handle)
