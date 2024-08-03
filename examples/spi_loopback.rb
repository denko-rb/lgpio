require 'lgpio'

SPI_DEV  = 1
SPI_CHAN = 0
SPI_MODE = 0
SPI_BAUD = 1_000_000

spi_handle = LGPIO.spi_open(SPI_DEV, SPI_CHAN, SPI_BAUD, SPI_MODE)

tx_bytes = [0, 1, 2, 3, 4, 5, 6, 7]
puts "TX bytes: #{tx_bytes.inspect}"

# rx_bytes == tx_bytes if MOSI looped back to MISO.
# rx_byte all 255 when MOSI and MISO not connected.
rx_bytes = LGPIO.spi_xfer(spi_handle, tx_bytes)
puts "RX bytes: #{rx_bytes.inspect}"

LGPIO.spi_close(spi_handle)
