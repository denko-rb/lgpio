require 'lgpio'

GPIO_CHIP   = 0
LEDS        = [272, 258]
INIT_STATE  = [0, 0]
INTERVAL    = 250_000 # 250ms
TIMES       = 10

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.group_claim_output(chip_handle, LGPIO::SET_PULL_NONE, LEDS, INIT_STATE)

# Convert us interval to seconds.
interval = INTERVAL.to_f / 1_000_000

# Alternate the LEDs each INTERVAL.
TIMES.times do
  # Last 2 args are bits to write, and write mask respectively.
  LGPIO.group_write(chip_handle, LEDS[0], 0b01, 0b11)
  sleep interval
  LGPIO.group_write(chip_handle, LEDS[0], 0b10, 0b11)
  sleep interval
end

# Turn them off and cleanup.
LGPIO.group_write(chip_handle, LEDS[0], 0b00, 0b11)
LGPIO.group_free(chip_handle, LEDS[0])
LGPIO.chip_close(chip_handle)
