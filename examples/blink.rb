require 'lgpio'

GPIO_CHIP = 0
LED = 260
INTERVAL = 0.25

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.gpio_claim_output(chip_handle, LGPIO::SET_PULL_NONE, LED, LGPIO::LOW)

loop do
  LGPIO.gpio_write(chip_handle, LED, 1)
  sleep INTERVAL
  LGPIO.gpio_write(chip_handle, LED, 0)
  sleep INTERVAL
end
