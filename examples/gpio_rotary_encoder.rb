#
# Demo of a simple 30-detent rotary encoder.
# PIN_A = CLK/CLOCK, PIN_B = DT/DATA, PIN_SW = SWITCH
#
require 'lgpio'

GPIO_CHIP = 0
PIN_A     = 260
PIN_B     = 76
PIN_SW    = 259

# Encoder state
position = 0
state_a  = 0
state_b  = 0

chip_handle = LGPIO.chip_open(GPIO_CHIP)

# Encoder pin setup
LGPIO.gpio_claim_input(chip_handle, PIN_A, LGPIO::SET_PULL_NONE)
LGPIO.gpio_set_debounce(chip_handle, PIN_A, 1)
LGPIO.gpio_claim_alert(chip_handle, PIN_A, 0, LGPIO::BOTH_EDGES)
LGPIO.gpio_claim_input(chip_handle, PIN_B, LGPIO::SET_PULL_NONE)
LGPIO.gpio_set_debounce(chip_handle, PIN_B, 1)
LGPIO.gpio_claim_alert(chip_handle, PIN_B, 0, LGPIO::BOTH_EDGES)

# Switch pin setup
LGPIO.gpio_claim_input(chip_handle, PIN_SW, LGPIO::SET_PULL_UP)
LGPIO.gpio_set_debounce(chip_handle, PIN_SW, 1)
LGPIO.gpio_claim_alert(chip_handle, PIN_SW, 0, LGPIO::FALLING_EDGE)

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
      position += delta
      state_b = report[:level]
      puts "Position: #{position}"
    elsif report[:gpio] == PIN_SW
      position = 0
      puts "Position: 0"
    end
  else
    sleep(0.001)
  end
end
