require 'lgpio'

GPIO_CHIP   = 0
CLOCK_PIN   = 22
INPUT_PIN   = 17
OUTPUT_PIN  = 27

MODES       = [0, 1, 2, 3]
ORDERS      = [:msbfirst, :lsbfirst]
TX_BYTES    = [0, 1, 2, 3, 4, 5, 6, 7]

chip_handle = LGPIO.chip_open(GPIO_CHIP)
spi_bb      = LGPIO::SPIBitBang.new(handle: chip_handle, clock: CLOCK_PIN, input: INPUT_PIN, output: OUTPUT_PIN)

puts "TX bytes => #{TX_BYTES.inspect}"

# Connect (loop back) INPUT_PIN to OUTPUT_PIN to see received bytes.
ORDERS.each do |order|
  MODES.each do |mode|
    rx_bytes = spi_bb.transfer(write: TX_BYTES, read: TX_BYTES.length, order: order, mode: mode)
    puts "RX (order: #{order}, mode: #{mode}) => #{rx_bytes.inspect}"
  end
end

LGPIO.chip_close(chip_handle)
