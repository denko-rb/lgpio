module LGPIO
  class I2CBitBang
    VALID_ADDRESSES = (0x08..0x77).to_a

    attr_reader :scl_handle, :scl_line, :sda_handle, :sda_line

    def initialize(options={})
      scl  = options[:scl]
      sda  = options[:sda]

      @scl_handle = scl[:handle] if scl
      @scl_line   = scl[:line]   if scl
      raise ArgumentError, ":scl pin required as Hash, with :handle and :line required" unless (@scl_handle && @scl_line)

      @sda_handle = sda[:handle] if sda
      @sda_line   = sda[:line]   if sda
      raise ArgumentError, ":sda pin required as Hash, with :handle and :line required" unless (@sda_handle && @sda_line)

      @sda_state  = nil
      initialize_pins
    end

    def config
      @config ||= [scl_handle, scl_line, sda_handle, scl_line]
    end

    def initialize_pins
      LGPIO.gpio_claim_output(scl_handle, scl_line, LGPIO::SET_PULL_NONE, LGPIO::HIGH)
      LGPIO.gpio_claim_output(sda_handle, sda_line, LGPIO::SET_OPEN_DRAIN | LGPIO::SET_PULL_UP, LGPIO::HIGH)
    end

    def set_sda(value)
      return if (@sda_state == value)
      LGPIO.gpio_write(sda_handle, sda_line, @sda_state = value)
    end

    def write_form(address)
      (address << 1)
    end

    def read_form(address)
      (address << 1) | 0b00000001
    end

    def start
      LGPIO.gpio_write(sda_handle, sda_line, 0)
      LGPIO.gpio_write(scl_handle, scl_line, 0)
    end

    def stop
      LGPIO.gpio_write(sda_handle, sda_line, 0)
      LGPIO.gpio_write(scl_handle, scl_line, 1)
      LGPIO.gpio_write(sda_handle, sda_line, 1)
    end

    def read_bit
      set_sda(1)
      LGPIO.gpio_write(scl_handle, scl_line, 1)
      bit = LGPIO.gpio_read(sda_handle, sda_line)
      LGPIO.gpio_write(scl_handle, scl_line, 0)
      bit
    end

    def write_bit(bit)
      set_sda(bit)
      LGPIO.gpio_write(scl_handle, scl_line, 1)
      LGPIO.gpio_write(scl_handle, scl_line, 0)
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

    def read_byte_c(ack)
      LGPIO.i2c_bb_read_byte(@scl_handle, @scl_line, @sda_handle, @sda_line, ack)
    end

    def write_byte_c(byte)
      LGPIO.i2c_bb_write_byte(@scl_handle, @scl_line, @sda_handle, @sda_line, byte)
    end

    def read(address, length)
      raise ArgumentError, "invalid I2C address: #{address}. Range is 0x08..0x77" unless VALID_ADDRESSES.include?(address)
      raise ArgumentError, "invalid Integer for read length: #{length}" unless length.kind_of?(Integer)

      start
      ack = write_byte(read_form(address))
      return nil unless ack

      # Read length bytes, and ACK for all but the last one.
      bytes = []

      # Bit-bang per-byte in Ruby.
      # (length-1).times { bytes << read_byte(true) }
      # bytes << read_byte(false)

      # Bit-bang per-byte in C.
      (length-1).times { bytes << read_byte_c(true) }
      bytes << read_byte_c(false)

      stop
      bytes
    end

    def write(address, bytes)
      raise ArgumentError, "invalid I2C address: #{address}. Range is 0x08..0x77" unless VALID_ADDRESSES.include?(address)
      raise ArgumentError, "invalid byte Array to write: #{bytes}" unless bytes.kind_of?(Array)

      start
      write_byte(write_form(address))

      # Bit-bang per-byte in Ruby.
      # bytes.each { |byte| write_byte(byte) }

      # Bit-bang per-byte in C.
      bytes.each { |byte| write_byte_c(byte) }

      stop
    end

    def search
      found = []
      VALID_ADDRESSES.each do |address|
        start
        # Device present if ACK received when we write its address to the bus.
        found << address if write_byte(write_form(address))
        stop
      end
      found
    end
  end
end
