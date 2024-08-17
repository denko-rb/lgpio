module LGPIO
  class Infrared < HardwarePWM
    def transmit(pulses, duty: 33.333, inverted: false)
      duty_path = "#{path}duty_cycle"
      duty_ns = ((duty / 100.0) * period).round.to_s
      tx_wave_ook(duty_path, duty_ns, inverted, pulses)
    end
  end
end