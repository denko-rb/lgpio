module LGPIO
  class HardwarePWM
    NS_PER_S  = 1_000_000_000
    NS_PER_US = 1_000
    SYS_FS_PWM_PATH = "/sys/class/pwm/"

    attr_reader :polarity, :period, :duty, :enabled

    def initialize(chip, channel, frequency: nil, period: nil)
      @chip    = chip
      @channel = channel

      # Accept either frequency (in Hz) or period in nanoseconds.
      if (frequency && period) || (!frequency && !period)
        raise "either period: or frequency: is required, but not both"
      end

      period ? self.period = period : self.frequency = frequency

      # Default to with 0 duty cycle and normal polarity.
      self.duty = 0
      self.polarity = :normal

      enable
    end

    def path
      @path ||= "#{SYS_FS_PWM_PATH}pwmchip#{@chip}/pwm#{@channel}/"
    end

    def polarity_path
      @polarity_path ||= "#{path}polarity"
    end

    def period_path
      @period_path ||= "#{path}period"
    end

    def duty_path
      @duty_path ||= "#{path}duty_cycle"
    end

    def enable_path
      @enable_path ||= "#{path}enable"
    end

    def polarity=(p=:normal)
      if p == :inversed
        File.open(polarity_path, 'w') { |f| f.write("inversed") }
        @polarity = :inversed
      else
        File.open(polarity_path, 'w') { |f| f.write("normal") }
        @polarity = :normal
      end
    end

    def frequency=(freq)
      self.period = (NS_PER_S / freq.to_f).round
      @frequency = freq
    end

    def frequency
      # If not set explicitly, calculate from period, rounded to nearest Hz.
      @frequency ||= (1_000_000_000.0 / period).round
    end

    def period=(p)
      old_period = File.read("#{path}period").strip.to_i
      unless (old_period == 0)
        File.open(duty_path, 'w') { |f| f.write("0") }
      end
      File.open(period_path, 'w') { |f| f.write(p) }
      @frequency = nil
      @period = p
    end

    def duty_percent
      return 0.0 if (!duty || !period) || (duty == 0)
      (duty / period.to_f) * 100.0
    end

    def duty_percent=(d)
      raise "duty_cycle: #{d} % cannot be more than 100%" if d > 100
      d_ns = ((d / 100.0) * @period.to_i).round
      self.duty = d_ns
    end

    def duty_us=(d_us)
      d_ns = (d_us * NS_PER_US).round
      self.duty = d_ns
    end

    def duty=(d_ns)
      raise "duty cycle: #{d_ns} ns cannot be longer than period: #{period} ns" if d_ns > period
      File.open(duty_path, 'w') { |f| f.write(d_ns) }
      @duty = d_ns
    end

    def disable
      File.open(enable_path, 'w') { |f| f.write("0") }
      @enabled = false
    end

    def enable
      File.open(enable_path, 'w') { |f| f.write("1") }
      @enabled = true
    end
  end
end
