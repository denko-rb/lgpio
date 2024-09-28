require 'lgpio'

POWER_ON_DELAY      = 0.100
RESET_DELAY         = 0.020
COMMAND_DELAY       = 0.010
MEASURE_DELAY       = 0.080
DATA_LENGTH         = 6
SOFT_RESET          = [0xBA]
INIT_AND_CALIBRATE  = [0xE1, 0x08, 0x00]
START_MEASUREMENT   = [0xAC, 0x33, 0x00]

SCL_CHIP  = 0
SCL_PIN   = 228
SDA_CHIP  = 0
SDA_PIN   = 270
ADDRESS   = 0x38

scl_handle = LGPIO.chip_open(SCL_CHIP)
sda_handle = (SCL_CHIP == SDA_CHIP) ? scl_handle : LGPIO.chip_open(SDA_CHIP)
pin_hash =  {
              scl: { handle: scl_handle, line: SCL_PIN },
              sda: { handle: sda_handle, line: SDA_PIN },
            }
i2c_bb = LGPIO::I2CBitBang.new(pin_hash)

# Startup sequence
sleep(POWER_ON_DELAY)
i2c_bb.write(ADDRESS, SOFT_RESET)
sleep(RESET_DELAY)
i2c_bb.write(ADDRESS, INIT_AND_CALIBRATE)
sleep(COMMAND_DELAY)

# Read
i2c_bb.write(ADDRESS, START_MEASUREMENT)
sleep(MEASURE_DELAY)
bytes = i2c_bb.read(ADDRESS, DATA_LENGTH)

# Close
LGPIO.chip_close(scl_handle)
LGPIO.chip_close(sda_handle) unless (scl_handle == sda_handle)

# Humidity uses the upper 4 bits of the shared byte as its lowest 4 bits.
h_raw = ((bytes[1] << 16) | (bytes[2] << 8) | (bytes[3])) >> 4
humidity = (h_raw.to_f / 2**20) * 100

# Temperature uses the lower 4 bits of the shared byte as its highest 4 bits.
t_raw = ((bytes[3] & 0x0F) << 16) | (bytes[4] << 8) | bytes[5]
temperature = (t_raw.to_f / 2**20) * 200 - 50

puts "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - Temperature: #{temperature.round(2)} \xC2\xB0C | Humidity: #{humidity.round(2)} %"
