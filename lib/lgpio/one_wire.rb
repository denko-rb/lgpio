module LGPIO
  class OneWire
    attr_reader :handle, :gpio

    def initialize(handle, gpio)
      @handle = handle
      @gpio   = gpio
      LGPIO.gpio_claim_output(handle, LGPIO::SET_OPEN_DRAIN | LGPIO::SET_PULL_UP, gpio, LGPIO::HIGH)
    end

    def reset
      # LGPIO.one_wire_reset returns 0 if device present on bus.
      return (LGPIO.one_wire_reset(handle, gpio) == 0)
    end

    def search
    end

    def read(byte_count)
      read_bytes = []
      byte_count.times do
        byte = 0b00000000
        8.times { |i| byte |= LGPIO.one_wire_bit_read(handle, gpio) << i }
        read_bytes << byte
      end
      read_bytes
    end

    def write(byte_array, parasite: nil)
      byte_array.each do |byte|
        8.times { |i| LGPIO.one_wire_bit_write(handle, gpio, (byte >> i) & 0b1) }
      end
      # Drive bus high to feed parasite capacitor after write.
      LGPIO.gpio_write(handle, gpio, LGPIO::HIGH) if parasite
    end
  end
end
