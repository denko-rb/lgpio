module LGPIO
  class OneWire
    # Constants
    READ_POWER_SUPPLY = 0xB4
    CONVERT_T         = 0x44
    SEARCH_ROM        = 0xF0
    READ_ROM          = 0x33
    SKIP_ROM          = 0xCC
    MATCH_ROM         = 0x55
    ALARM_SEARCH      = 0xEC
    READ_SCRATCH      = 0xBE
    WRITE_SCRATCH     = 0x4E
    COPY_SCRATCH      = 0x48
    RECALL_EEPROM     = 0xB8

    attr_reader :handle, :gpio, :found_addresses

    def initialize(handle, gpio)
      @handle = handle
      @gpio   = gpio
      @found_addresses = []
      LGPIO.gpio_claim_output(handle, gpio, LGPIO::SET_OPEN_DRAIN | LGPIO::SET_PULL_UP, LGPIO::HIGH)
    end

    def reset
      # LGPIO.one_wire_reset returns 0 if device present on bus.
      return (LGPIO.one_wire_reset(handle, gpio) == 0)
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

    def search
      branch_mask      = 0
      high_discrepancy = 0

      loop do
        reset
        write [SEARCH_ROM]
        result = search_pass(branch_mask)

        address, high_discrepancy = parse_search_result(result)
        @found_addresses << address

        # No unsearched discrepancies left.
        break if high_discrepancy == -1

        # Force highest new discrepancy to be a 1 on the next search.
        # i.e. Go as deep as possible into each branch found then back out.
        #
        branch_mask = branch_mask | (2 ** high_discrepancy)

        # Clear bits above high_discrepancy so we don't repeat branches.
        # When high_discrepancy < MSB of branch_mask, this moves us
        # one node out, closer to the root, and finishing the search.
        #
        unset_mask = 0xFFFFFFFFFFFFFFFF >> (63 - high_discrepancy)
        branch_mask = branch_mask & unset_mask
      end
    end

    # Read a single 64-bit address and complement from the bus.
    def search_pass(mask)
      bytes = []

      8.times do |i|
        addr = 0
        comp = 0
        8.times do |j|
          addr |= LGPIO.one_wire_bit_read(handle, gpio) << j
          comp |= LGPIO.one_wire_bit_read(handle, gpio) << j

          # A set (1) mask bit means we're searching a branch with that bit set.
          # Force it to be 1 on this pass. Write 1 to both the bus and address bit.
          #
          # Don't change the complement bit from 0, Even if the bus said 0/0,
          # send back 1/0, hiding known discrepancies, only sending new ones.
          #
          # Mask is a 64-bit number, not byte array.
          if ((mask >> (i*8 + j)) & 0b1) == 1
            LGPIO.one_wire_bit_write(handle, gpio, 1)
            addr |= 1 << j

          # Whether there was no "1-branch" marked for this bit, or there is no
          # discrepancy at all, just echo address bit to the bus. We will
          # compare addr/comp to find discrepancies for future passes.
          else
            LGPIO.one_wire_bit_write(handle, gpio, (addr >> j) & 0b1)
          end
        end
        bytes << addr
        bytes << comp
      end

      # 16 bytes, address and complement bytes interleaved LSByteFIRST.
      # DON'T CHANGE! #split_search_result deals with it. denko uses #search_pass
      # directly on Linux, but MCUs send it this format to save RAM. Always match it.
      return bytes
    end

    def parse_search_result(result)
      address, complement = split_search_result(result)

      raise "OneWire device not connected, or disconnected during search" if (address & complement) > 0
      raise "CRC error during OneWire search" unless OneWire.crc(address)

      # Gives 0 at every discrepancy we didn't write 1 for on this pass.
      new_discrepancies = address ^ complement

      high_discrepancy = -1
      (0..63).each { |i| high_discrepancy = i if ((new_discrepancies >> i) & 0b1 == 0) }

      [address, high_discrepancy]
    end

    # Result is 16 bytes, 8 byte address and complement interleaved LSByte first.
    def split_search_result(data)
      address    = 0
      complement = 0
      data.reverse.each_slice(2) do |comp_byte, addr_byte|
        address    = (address << 8)    | addr_byte
        complement = (complement << 8) | comp_byte
      end
      [address, complement]
    end

    # CRC Class Methods
    def self.crc(data)
      calculated, received = self.calculate_crc(data)
      calculated == received
    end

    def self.calculate_crc(data)
      if data.class == Integer
        bytes = address_to_bytes(data)
      else
        bytes = data
      end

      crc = 0b00000000
      bytes.take(bytes.length - 1).each do |byte|
        for bit in (0..7)
          xor = ((byte >> bit) & 0b1) ^ (crc & 0b1)
          crc = crc ^ ((xor * (2 ** 3)) | (xor * (2 ** 4)))
          crc = crc >> 1
          crc = crc | (xor * (2 ** 7))
        end
      end
      [crc, bytes.last]
    end

    def self.address_to_bytes(address)
      bytes = []
      8.times { |i| bytes[i] = address >> (8*i) & 0xFF }
      bytes
    end
  end
end
