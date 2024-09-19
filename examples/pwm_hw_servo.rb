require 'lgpio'
#
# Writing directly to a hardware PWM channel to control a servo.
# Arguments in order are:
#   pwmchip index (X in /sys/class/pwm/pwmchipX/)
#   PWM channel on the chip (Y in /sys/class/pwm/pwmchipX/pwmY)
#   period: given in nanoseconds
#   OR frequency: given in Hz
#
servo = LGPIO::HardwarePWM.new(0, 1, period: 20_000_000)
#
# Duty cycle is given in nanoseconds by default. Extra setter methods
# are provided for microseconds, and percent.
#
# servo.duty_percent = 2.5
# servo.duty_us = 500
servo.duty = 500_000

#
# Using the Servo class instead.
# Arguments in order are:
#   pwmchip index (X in /sys/class/pwm/pwmchipX/)
#   PWM channel on the chip (Y in /sys/class/pwm/pwmchipX/pwmY)
#   Minimum servo duty cycle in microseconds
#   Maximum servo duty cicle in microseconds
#   Minimum servo angle
#   Maximum servo angle
#
servo = LGPIO::PositionalServo.new(0, 1, 500, 2500, 0, 180)

angles = [0, 30, 60, 90, 120, 150, 180, 150, 120, 90, 60, 30]

angles.cycle do |angle|
  servo.angle = angle
  sleep 1
end
