#
# Demo of a simple 30-detent rotary encoder.
# PIN_A = CLK/CLOCK, PIN_B = DT/DATA, PIN_SW = SWITCH
#
require 'lgpio'

GPIO_CHIP = 0
PIN_A     = 76
PIN_B     = 228

PIN_LED     = 260
PWM_FREQ    = 500
PWM_OFFSET  = 0
PWM_CYCLES  = 0    # 0 = infinite

# Encoder state
state_a  = 0
state_b  = 0
led_duty = 0

chip_handle = LGPIO.chip_open(GPIO_CHIP)

# LED pin setup
LGPIO.gpio_claim_output(chip_handle, LGPIO::SET_PULL_NONE, PIN_LED, LGPIO::LOW)

# Encoder pin setup
LGPIO.gpio_claim_input(chip_handle, LGPIO::SET_PULL_NONE, PIN_A)
LGPIO.gpio_claim_alert(chip_handle, 0, LGPIO::BOTH_EDGES, PIN_A)
LGPIO.gpio_claim_input(chip_handle, LGPIO::SET_PULL_NONE, PIN_B)
LGPIO.gpio_claim_alert(chip_handle, 0, LGPIO::BOTH_EDGES, PIN_B)

# Start generating reports for GPIO level changes.
LGPIO.gpio_start_reporting

# Get and reports to update state.
loop do
  report = LGPIO.gpio_get_report
  if report
    if report[:gpio] == PIN_A
      # Half quadrature, so we count every detent.
      state_a = report[:level]
    elsif report[:gpio] == PIN_B
      delta = (report[:level] == state_a) ? -1 : 1
      state_b = report[:level]
      
      led_duty += delta
      led_duty = 0 if led_duty < 0
      led_duty = 100 if led_duty > 100
      LGPIO.tx_pwm(chip_handle, PIN_LED, PWM_FREQ, led_duty, PWM_OFFSET, PWM_CYCLES)
    end
  else
    sleep(0.001)
  end
end
