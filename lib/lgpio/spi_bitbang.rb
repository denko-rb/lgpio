module LGPIO
  class SPIBitBang
    attr_reader :handle, :clock, :input, :output

    def initialize(options={})
      @handle = options[:handle]
      @clock  = options[:clock]  || options[:sck]  || options[:clk]
      @input  = options[:input]  || options[:poci] || options[:miso]
      @output = options[:output] || options[:pico] || options[:mosi]

      raise ArgumentError, "a gpiochip :handle is required" unless @handle
      raise ArgumentError, "either input/:poci/:miso OR :output/:pico/:mosi pin required" unless (@input || @output)
      raise ArgumentError, ":clock/:sck/:clk pin required" unless @clock

      @output_state = nil
      initialize_pins
    end

    def initialize_pins
      LGPIO.gpio_claim_output(handle, LGPIO::SET_PULL_NONE, clock, LGPIO::LOW)
      LGPIO.gpio_claim_input(handle, LGPIO::SET_PULL_NONE, input) if input
      LGPIO.gpio_claim_output(handle, LGPIO::SET_PULL_NONE, output, LGPIO::LOW) if output
    end

    def set_output(level)
      return if (level == @output_state)
      LGPIO.gpio_write(handle, output, @output_state = level)
    end

    def transfer_bit(write_bit, reading: false, mode: 0)
      case mode
      when 0
        set_output(write_bit) if write_bit
        LGPIO.gpio_write(handle, clock, 1)
        read_bit = LGPIO.gpio_read(handle, input) if reading
        LGPIO.gpio_write(handle, clock, 0)
      when 1
        LGPIO.gpio_write(handle, clock, 1)
        set_output(write_bit) if write_bit
        LGPIO.gpio_write(handle, clock, 0)
        read_bit = LGPIO.gpio_read(handle, input) if reading
      when 2
        set_output(write_bit) if write_bit
        LGPIO.gpio_write(handle, clock, 0)
        read_bit = LGPIO.gpio_read(handle, input) if reading
        LGPIO.gpio_write(handle, clock, 1)
      when 3
        LGPIO.gpio_write(handle, clock, 0)
        set_output(write_bit) if write_bit
        LGPIO.gpio_write(handle, clock, 1)
        read_bit = LGPIO.gpio_read(handle, input) if reading
      else
        raise ArgumentError, "invalid SPI mode: #{mode} given"
      end
      return reading ? read_bit : nil
    end

    def transfer_byte(byte, reading: false, order: :msbfirst, mode: 0)
      read_byte = reading ? 0 : nil

      if (order == :msbfirst)
        i = 7
        while i >= 0
          write_bit = byte ? (byte >> i) & 0b1 : nil
          read_bit  = transfer_bit(write_bit, mode: mode, reading: reading)
          read_byte = (read_byte << 1) | read_bit if reading
          i = i - 1
        end
      else
        i = 0
        while i < 8
          write_bit = byte ? (byte >> i) : nil
          read_bit  = transfer_bit(write_bit, mode: mode, reading: reading)
          read_byte = read_byte | (read_bit << i) if reading
          i = i + 1
        end
      end

      read_byte
    end

    def transfer(write: [], read: 0, select: nil, order: :msbfirst, mode: 0)
      # Idle clock state depends on SPI mode.
      case mode
      when 0..1
        LGPIO.gpio_write(handle, clock, 0)
      when 2..3
        LGPIO.gpio_write(handle, clock, 1)
      else
        raise ArgumentError, "invalid SPI mode: #{mode} given"
      end
      raise ArgumentError, "invalid Array for write: #{write}" unless write.kind_of?(Array)
      raise ArgumentError, "invalid Integer for read: #{read}" unless read.kind_of?(Integer)

      read_bytes = (read > 0) ? [] : nil
      LGPIO.gpio_write(handle, select, 0) if select

      i = 0
      while (i < read) || (i < write.length)
        read_byte = transfer_byte(write[i], reading: (i < read), order: order, mode: mode)
        read_bytes << read_byte if read_byte
        i = i + 1
      end

      LGPIO.gpio_write(handle, select, 1) if select
      read_bytes
    end
  end
end
