require 'lgpio'
#
# Writing directly to a hardware PWM channel.
# Arguments in order are:
#   pwmchip index (X in /sys/class/pwm/pwmchipX/)
#   PWM channel on the chip (Y in /sys/class/pwm/pwmchipX/pwmY)
#   period: given in nanoseconds
#   OR frequency: given in Hz
#
pwm_out = LGPIO::HardwarePWM.new(0, 1, period: 20_000_000)

RUNS = 250_000
start = Time.now
RUNS.times do
  pwm_out.duty_us = 1000
end
finish = Time.now

wps = RUNS / (finish - start)
puts "Hardware PWM writes per second: #{wps.round(2)}"
