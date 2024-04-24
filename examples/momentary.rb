require 'lgpio'

GPIO_CHIP = 0
BUTTON    = 258
LED       = 260

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.gpio_claim_input(chip_handle, LGPIO::SET_PULL_UP, BUTTON)
LGPIO.gpio_claim_output(chip_handle, LGPIO::SET_PULL_NONE, LED, LGPIO::LOW)

loop do
  if LGPIO.gpio_read(chip_handle, BUTTON) == 0
    LGPIO.gpio_write(chip_handle, LED, 1)
  else
    LGPIO.gpio_write(chip_handle, LED, 0)
  end
  sleep 0.001
end
