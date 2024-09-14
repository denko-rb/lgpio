module LGPIO
  class I2CBitBang
    attr_reader :handle, :scl, :sda

    def initialize(handle, scl, sda)
      @handle = handle
      @scl    = scl
      @sda    = sda
      @sda_state = nil
      initialize_pins
    end

    def initialize_pins
      LGPIO.gpio_claim_output(handle, LGPIO::SET_PULL_NONE, scl, LGPIO::HIGH)
      LGPIO.gpio_claim_output(handle, LGPIO::SET_OPEN_DRAIN | LGPIO::SET_PULL_UP, sda, LGPIO::HIGH)
    end

    def set_sda(value)
      return if (@sda_state == value)
      LGPIO.gpio_write(handle, sda, @sda_state = value)
    end

    def write_form(address)
      (address << 1)
    end

    def read_form(address)
      (address << 1) | 0b00000001
    end

    def start
      LGPIO.gpio_write(handle, sda, 0)
      LGPIO.gpio_write(handle, scl, 0)
    end

    def stop
      LGPIO.gpio_write(handle, sda, 0)
      LGPIO.gpio_write(handle, scl, 1)
      LGPIO.gpio_write(handle, sda, 1)
    end

    def read_bit
      set_sda(1)
      LGPIO.gpio_write(handle, scl, 1)
      bit = LGPIO.gpio_read(handle, sda)
      LGPIO.gpio_write(handle, scl, 0)
      bit
    end

    def write_bit(bit)
      set_sda(bit)
      LGPIO.gpio_write(handle, scl, 1)
      LGPIO.gpio_write(handle, scl, 0)
    end

    def read_byte(ack)
      byte = 0
      i    = 0
      while i < 8
        byte = (byte << 1) | read_bit
        i = i + 1
      end
      write_bit(ack ? 0 : 1)
      byte
    end

    def write_byte(byte)
      i = 7
      while i >= 0
        write_bit (byte >> i) & 0b1
        i = i - 1
      end
      # Return ACK (SDA pulled low) or NACK (SDA stayed high).
      (read_bit == 0)
    end

    def read(address, count)
      start
      ack = write_byte(read_form(address))
      return nil unless ack

      # Read count bytes, and ACK for all but the last one.
      bytes = []
      (count-1).times { bytes << read_byte(true) }
      bytes << read_byte(false)
      stop

      bytes
    end

    def write(address, bytes)
      start
      write_byte(write_form(address))
      bytes.each { |byte| write_byte(byte) }
      stop
    end

    def search
      found = []
      (0x08..0x77).each do |address|
        start
        # Device present if ACK received when we write its address to the bus.
        found << address if write_byte(write_form(address))
        stop
      end
      found
    end
  end
end