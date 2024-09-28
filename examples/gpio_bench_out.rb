require 'lgpio'

GPIO_CHIP = 0
PIN       = 272
COUNT     = 1000000

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.gpio_claim_output(chip_handle, PIN, LGPIO::SET_PULL_NONE, LGPIO::LOW)

t1 = Time.now
COUNT.times do
  LGPIO.gpio_write(chip_handle, PIN, 1)
  LGPIO.gpio_write(chip_handle, PIN, 0)
end
t2 = Time.now

puts "Toggles per second: #{COUNT.to_f / (t2 - t1).to_f}"

LGPIO.gpio_free(chip_handle, PIN)
LGPIO.chip_close(chip_handle)
