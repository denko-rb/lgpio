#
# Example showing an HC-S04 ultrasonic distance sensor.
#
# NOTE: Some versions of this sensor require 5V power to function properly.
# If using one of these, use a 5V to 3.3V level shifter between your board and
# the sensor, at least on the echo pin.
#
require 'lgpio'

GPIO_CHIP       = 0
ECHO_PIN        = 228
TRIGGER_PIN     = 270
SPEED_OF_SOUND  = 343.0

chip_handle = LGPIO.chip_open(GPIO_CHIP)

loop do
  # Arguments in order are:
  #   chip handle, trigger pin, echo pin, trigger time (us)
  #
  # HC-SR04 uses 10 microseconds for trigger. Some others use 20us.
  #
  microseconds = LGPIO.gpio_read_ultrasonic(chip_handle, TRIGGER_PIN, ECHO_PIN, 10)

  if microseconds
    mm = (microseconds / 2000.0) * SPEED_OF_SOUND
    puts "Distance: #{mm.round} mm"
  else
    puts "Cound not read HC-SR04 sensor"
  end
  sleep 0.5
end
