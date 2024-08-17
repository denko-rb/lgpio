require 'lgpio'

GPIO_CHIP   = 0
LEDS        = [272, 258]
INIT_STATE  = [0, 0]
INTERVAL    = 250_000 # 250ms
TIMES       = 10

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.group_claim_output(chip_handle, LGPIO::SET_PULL_NONE, LEDS, INIT_STATE)

# Generic pulse that updates both LED states (first element) each INTERVAL.
generic_pulse = [ nil, 0b11, INTERVAL ]

# Alternate the LEDs each INTERVAL.
pulses = []
TIMES.times do
  pulses << generic_pulse.clone
  pulses.last[0] = 0b01
  pulses << generic_pulse.clone
  pulses.last[0] = 0b10
end
# Turn them off at the end.
pulses << [0b00, 0b11, 1000]

# Add to wave queue.
LGPIO.tx_wave(chip_handle, LEDS[0], pulses)

# Wait for it to complete, then cleanup.
sleep 0.010 while LGPIO.tx_busy(chip_handle, LEDS[0], LGPIO::TX_WAVE) == 1
LGPIO.group_free(chip_handle, LEDS[0])
LGPIO.chip_close(chip_handle)
