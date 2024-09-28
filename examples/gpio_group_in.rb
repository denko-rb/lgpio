
require 'lgpio'

GPIO_CHIP   = 0
BUTTONS     = [259, 267]
LEDS        = [272, 258]
INIT_STATE  = [0, 0]

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.group_claim_input(chip_handle, BUTTONS, LGPIO::SET_PULL_UP)
LGPIO.group_claim_output(chip_handle, LEDS, LGPIO::SET_PULL_NONE, INIT_STATE)

# The inverted (active-low) state of each button controls the corresponding LED.
loop do
  output_bits = LGPIO.group_read(chip_handle, BUTTONS[0]) ^ 0b11
  LGPIO.group_write(chip_handle, LEDS[0], output_bits, 0b11)
  sleep 0.001
end
