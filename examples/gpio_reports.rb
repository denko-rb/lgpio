require 'lgpio'

GPIO_CHIP = 0
PIN       = 259

chip_handle = LGPIO.chip_open(GPIO_CHIP)

LGPIO.gpio_claim_input(chip_handle, PIN, LGPIO::SET_PULL_NONE)
LGPIO.gpio_set_debounce(chip_handle, PIN, 1)
LGPIO.gpio_claim_alert(chip_handle, PIN, 0, LGPIO::BOTH_EDGES)
LGPIO.gpio_start_reporting

loop do
  report = LGPIO.gpio_get_report
  report ? puts(report) : sleep(0.001)
end

LGPIO.gpio_free(chip_handle, PIN)
LGPIO.chip_close(chip_handle)
