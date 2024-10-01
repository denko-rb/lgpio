# lgpio

Ruby gem with bindings for the [lgpio (lg)](https://github.com/joan2937/lg) C library. This is for single-board-computers (SBCs) running Linux, such as Orange Pi, Raspberry Pi, etc. It provides low-level access to the GPIO, I2C, SPI, and PWM subsytems.

## Standard LGPIO Features

- [x] GPIO Read/Write
- [x] GPIO Group Read/Write
- [x] GPIO Alerts
  - Alerts are generated by a separate thread, and can be read from a queue in Ruby.
  - No real "callback" functionality.
- [x] Software PWM Output
  - Timing not 100% precise, but works on any GPIO.
  - Not recommended for servo motors, will jitter.
- [x] Wave
  - Software timed on any pin(s), as with PWM.
- [x] Hardware I2C
- [x] Hardware SPI

## Extra Features (Built on LGPIO)

- [x] `LGPIO.gpio_read_ultrasonic` sends a pulse on a `trigger` pin, then measures a single pulse on a separate `echo` pin. Used for HC-SR04 or similar. See `examples/hcsr04.rb`.
- [x] `LGPIO.gpio_read_pulses_us` outputs a reset pulse on a pin, then polls for a sequence of input pulses. Used for DHT enviro sensors or similar. See `examples/dht.rb`.
- [x] Bit Bang I2C
- [x] Bit Bang SPI
- [x] Bit Bang 1-Wire
- [x] WS2812 addressable LEDs over hardware SPI
  - Outputs on MOSI/PICO pin
  - Must be able to set SPI clock frequency to 2.4 MHz

## Hardware PWM Features

These use the sysfs PWM interface, not lgpio C, but are a good fit for this gem.

- [x] Hardware PWM Output
- [x] Servo (based on hardware PWM)
- [x] On-off Keying (OOK) Modulated Waves
  - Carrier generated by hardware PWM. Software modulated with monotonic clock timing.
  - Useful for sending infrared signals at 38kHz, for example.

**Note:** Once a pin is bound to hardware PWM in the device tree, it shouldn't be used as regular GPIO. Behavior is inconsistent across different hardware.

## Installation
On Debian-based Linuxes (RaspberryPi OS, Armbian, DietPi etc.):
```bash
# Requirements to install lgpio C
sudo apt install swig python3-dev python3-setuptools gcc make

# Temporary fork of: wget https://github.com/joan2937/lg/archive/master.zip
wget https://github.com/vickash/lg/archive/refs/heads/master.zip

# Install lgpio C
unzip master.zip
cd lg-master
make
sudo make install

# The latest Ruby 3 + YJIT is recommended, but you can use the system Ruby from apt too.
# sudo apt install ruby ruby-dev

gem install lgpio
```

## Enabling Hardware & Permissions
Depending on your SBC and Linux distro/version, you may need to manually enable hardware I2C, SPI, and PWM. You should use the config tool that came with your distro for that, if possible.

Even when these are enabled, you may not have permission to access them. To run without `sudo`, you need read+write permission to some or all of the following:
```
/dev/gpiochip*          (For GPIO, example: /dev/gpiochip0)
/dev/i2c-*              (For I2C,  example: /dev/i2c-1)
/dev/spidev*            (For SPI,  example: /dev/spidev0.1)
/sys/class/pwm/pwmchip* (For PWM,  example: /sys/class/pwm/pwmchip0)
```

## Documentation
- See examples folder for demos of everything implemented.
  - Development was done on an Orange Pi Zero 2W. Your GPIO numbers may be different, so change them.
- For more info, see the [lgpio C API docs.](https://abyz.me.uk/lg/lgpio.html)
- As much as possible, the Ruby methods closely follow the C API functions, except:
  - Snake case instead of camel case names for methods.
  - Method names have the leading `lg` removed, since inside the `LGPIO` class.
  - Constants have leading `LG_` removed, as above.
  - "count" or "length" arguments associated with array args are not needed.
  - Arg order for `_claim_` methods varies from lgpio C, so that gpio number always follows handle. The general pattern is `handle, gpio, flags, state`. This affects:
    - `gpio_claim_input`
    - `gpio_claim_output`
    - `gpio_claim_alert`
    - `group_claim_input`
    - `group_claim_output`
- Check the return values of your method calls. On failure, they return negative values, matching the `LG_` error codes at the bottom of the C API doc page.
