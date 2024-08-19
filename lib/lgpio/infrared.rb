module LGPIO
  class Infrared < HardwarePWM
    def transmit(pulses, duty: 33.333)
      self.duty_percent = duty
      tx_wave_ook(duty_path, @duty.to_s, pulses)
    end
  end
end
