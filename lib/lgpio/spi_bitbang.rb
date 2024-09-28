module LGPIO
  class SPIBitBang
    attr_reader :clock_handle, :input_handle, :output_handle
    attr_reader :clock_line, :input_line, :output_line

    def initialize(options={})
      clock  = options[:clock]
      input  = options[:input]
      output = options[:output]

      @clock_handle   = clock[:handle] if clock
      @clock_line     = clock[:line]   if clock
      raise ArgumentError, ":clock pin required as Hash, with :handle and :line required" unless (@clock_handle && @clock_line)

      @input_handle   = input[:handle]  if input
      @input_line     = input[:line]    if input
      @output_handle  = output[:handle] if output
      @output_line    = output[:line]   if output
      unless ((@input_handle && @input_line) || (@output_handle && @output_line))
        raise ArgumentError, "either :input or :output pin required as Hash, with :handle and :line required"
      end

      @output_state = nil
      initialize_pins
    end

    def config
      @config ||= { handle: handle, clock: clock, input: input, output: output }
    end

    def initialize_pins
      LGPIO.gpio_claim_output(clock_handle,  clock_line,  LGPIO::SET_PULL_NONE, LGPIO::LOW)
      LGPIO.gpio_claim_input(input_handle,   input_line,  LGPIO::SET_PULL_NONE)             if input_line
      LGPIO.gpio_claim_output(output_handle, output_line, LGPIO::SET_PULL_NONE, LGPIO::LOW) if output_line
    end

    def set_output(level)
      return if (level == @output_state)
      LGPIO.gpio_write(output_handle, output_line, @output_state = level)
    end

    def transfer_bit(write_bit, reading: false, mode: 0)
      case mode
      when 0
        set_output(write_bit) if write_bit
        LGPIO.gpio_write(clock_handle, clock_line, 1)
        read_bit = LGPIO.gpio_read(input_handle, input_line) if reading
        LGPIO.gpio_write(clock_handle, clock_line, 0)
      when 1
        LGPIO.gpio_write(clock_handle, clock_line, 1)
        set_output(write_bit) if write_bit
        LGPIO.gpio_write(clock_handle, clock_line, 0)
        read_bit = LGPIO.gpio_read(input_handle, input_line) if reading
      when 2
        set_output(write_bit) if write_bit
        LGPIO.gpio_write(clock_handle, clock_line, 0)
        read_bit = LGPIO.gpio_read(input_handle, input_line) if reading
        LGPIO.gpio_write(clock_handle, clock_line, 1)
      when 3
        LGPIO.gpio_write(clock_handle, clock_line, 0)
        set_output(write_bit) if write_bit
        LGPIO.gpio_write(clock_handle, clock_line, 1)
        read_bit = LGPIO.gpio_read(input_handle, input_line) if reading
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
        LGPIO.gpio_write(clock_handle, clock_line, 0)
      when 2..3
        LGPIO.gpio_write(clock_handle, clock_line, 1)
      else
        raise ArgumentError, "invalid SPI mode: #{mode} given"
      end
      raise ArgumentError, "invalid Array for write: #{write}" unless write.kind_of?(Array)
      raise ArgumentError, "invalid Integer for read: #{read}" unless read.kind_of?(Integer)

      read_bytes = (read > 0) ? [] : nil
      LGPIO.gpio_write(select[:handle], select[:line], 0) if select

      i = 0
      while (i < read) || (i < write.length)
        read_byte = transfer_byte(write[i], reading: (i < read), order: order, mode: mode)
        read_bytes << read_byte if read_byte
        i = i + 1
      end

      LGPIO.gpio_write(select[:handle], select[:line], 1) if select
      read_bytes
    end
  end
end
