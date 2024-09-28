require 'lgpio'

GPIO_CHIP = 0
PIN       = 260
COUNT     = 1000000

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.gpio_claim_input(chip_handle, PIN, LGPIO::SET_PULL_UP)

t1 = Time.now
COUNT.times do
  value = LGPIO.gpio_read(chip_handle, PIN)
end
t2 = Time.now

puts "Reads per second: #{COUNT.to_f / (t2 - t1).to_f}"

LGPIO.gpio_free(chip_handle, PIN)
LGPIO.chip_close(chip_handle)
