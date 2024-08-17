module LGPIO
  class PositionalServo < HardwarePWM
    FREQUENCY = 50

    attr_reader :angle

    def initialize(chip, channel, min_us, max_us, min_angle, max_angle)
      super(chip, channel, frequency: FREQUENCY)

      raise "min_us: #{min_us} cannot be lower than max_us: #{max_us}" if max_us < min_us
      @min_us = min_us
      @max_us = max_us
      @us_range = @max_us - @min_us

      @min_angle = min_angle
      @max_angle = max_angle
    end

    def angle=(a)
      ratio = (a - @min_angle).to_f / (@max_angle - @min_angle)
      raise "angle: #{a} outside servo range" if (ratio < 0) || (ratio > 1)

      d_us = (@us_range * ratio) + @min_us
      self.duty_us = d_us
      @angle = a
    end
  end
end
