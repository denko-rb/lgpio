module LGPIO
  class Infrared < HardwarePWM
    FREQUENCY = 38_000
    DUTY = 33.333

    def initialize(*args, **kwargs)
      new_kwargs = {frequency: FREQUENCY}.merge(kwargs)
      super(*args, **new_kwargs)
      # Avoid needing to call #enable and #disable, before and after each #transmit call.
      # disable
    end

    def transmit(pulses, duty: DUTY)
      self.duty_percent = duty
      tx_wave_ook(duty_path, @duty.to_s, pulses)
    end
  end
end
