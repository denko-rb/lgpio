require 'lgpio'

GPIO_CHIP = 0
BUTTON    = 259
LED       = 272

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.gpio_claim_input(chip_handle, BUTTON, LGPIO::SET_PULL_UP)
LGPIO.gpio_claim_output(chip_handle, LED, LGPIO::SET_PULL_NONE, LGPIO::LOW)

loop do
  if LGPIO.gpio_read(chip_handle, BUTTON) == 0
    LGPIO.gpio_write(chip_handle, LED, 1)
  else
    LGPIO.gpio_write(chip_handle, LED, 0)
  end
  sleep 0.001
end
