require 'lgpio'

POWER_ON_DELAY      = 0.100
RESET_DELAY         = 0.020
COMMAND_DELAY       = 0.010
MEASURE_DELAY       = 0.080
DATA_LENGTH         = 6
SOFT_RESET          = [0xBA]
INIT_AND_CALIBRATE  = [0xE1, 0x08, 0x00]
START_MEASUREMENT   = [0xAC, 0x33, 0x00]

GPIO_CHIP = 0
SCL_PIN   = 228
SDA_PIN   = 270
ADDRESS   = 0x38

chip_handle = LGPIO.chip_open(GPIO_CHIP)
LGPIO.i2c_bb_claim(chip_handle, SCL_PIN, SDA_PIN)

# Startup sequence
sleep(POWER_ON_DELAY)
LGPIO.i2c_bb_write(chip_handle, SCL_PIN, SDA_PIN, ADDRESS, SOFT_RESET)
sleep(RESET_DELAY)
LGPIO.i2c_bb_write(chip_handle, SCL_PIN, SDA_PIN, ADDRESS, INIT_AND_CALIBRATE)
sleep(COMMAND_DELAY)

# Read and close
LGPIO.i2c_bb_write(chip_handle, SCL_PIN, SDA_PIN, ADDRESS, START_MEASUREMENT)
sleep(MEASURE_DELAY)
bytes = LGPIO.i2c_bb_read(chip_handle, SCL_PIN, SDA_PIN, ADDRESS, DATA_LENGTH)

# Humidity uses the upper 4 bits of the shared byte as its lowest 4 bits.
h_raw = ((bytes[1] << 16) | (bytes[2] << 8) | (bytes[3])) >> 4
humidity = (h_raw.to_f / 2**20) * 100

# Temperature uses the lower 4 bits of the shared byte as its highest 4 bits.
t_raw = ((bytes[3] & 0x0F) << 16) | (bytes[4] << 8) | bytes[5]
temperature = (t_raw.to_f / 2**20) * 200 - 50

puts "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'} - Temperature: #{temperature.round(2)} \xC2\xB0C | Humidity: #{humidity.round(2)} %"
