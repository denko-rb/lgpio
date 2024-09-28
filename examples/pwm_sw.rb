require 'lgpio'

GPIO_CHIP   = 0
LED         = 272
PWM_FREQ    = 500
PWM_OFFSET  = 0
PWM_CYCLES  = 0    # 0 = infinite

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.gpio_claim_output(chip_handle, LED, LGPIO::SET_PULL_NONE, LGPIO::LOW)

# Seamless loop from 0-100 and back.
duty_cycles = (0..100).to_a + (1..99).to_a.reverse

# Pulse the LED up and down.
duty_cycles.cycle do |d|
  LGPIO.tx_pwm(chip_handle, LED, PWM_FREQ, d, PWM_OFFSET, PWM_CYCLES)
  sleep 0.020
end
