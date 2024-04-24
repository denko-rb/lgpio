require 'lgpio'

GPIO_CHIP = 0
PIN = 258
COUNT = 1000000

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.gpio_claim_input(chip_handle, LGPIO::SET_PULL_UP, PIN)

t1 = Time.now
COUNT.times do
  value = LGPIO.gpio_read(chip_handle, PIN)
end
t2 = Time.now

puts "Reads per second: #{COUNT.to_f / (t2 - t1).to_f}"
