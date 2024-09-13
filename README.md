# lgpio

Ruby bindings for the [lgpio (lg)](https://github.com/joan2937/lg) Linux library, running on single board computers (SBCs), like Raspberry Pi.

## Mapped LGPIO Features
- [x] GPIO Read/Write
- [x] GPIO Group Read/Write
- [x] GPIO Alerts
  - lg generates alerts in a separate thread, which are read from a queue in Ruby.
  - No true "callback" functionality.
- [x] Software PWM Out
  - Software timed on any pin. Timing not 100% precise.
  - Not recommended for servo motors.
- [x] Wave
  - Software timed on any pin, as with PWM.
- [x] I2C
- [x] SPI

## Extra Features, based on LGPIO
- [x] `LGPIO.gpio_read_ultrasonic` sends a pulse on a trigger pin, then measures a single pulse on a separate (echo) pin. Used for HC-SR04 or similar sensors. See `examples/hcsr04.rb`.
- [x] `LGPIO.gpio_read_pulses_us` rapidly polls for a sequence of input pulses, with an optional (output) reset pulse at the start. Used for DHT-class or similar sensors. See `examples/dht.rb`.
- [x] WS2812 addressable LEDs over SPI
  - Only outputs on a SPI MOSI pin. Must be able to set SPI clock frequency to 2.4 MHz.
- [x] Bit Bang I2C
- [ ] Bit Bang SPI
- [x] Bit Bang 1-Wire (Basic)
  - Reset, reading, and writing work.
  - Example for a connected (not-parasite) DS18B20 temperature sensor provided.
  - `one_wire_search` isn't a true search. It's a partial, called by [denko/piboard](https://github.com/denko-rb/denko-piboard).
  - If you need search, CRC, or multiples on a bus, use `denko/piboard`, or copy from [denko](https://github.com/denko-rb/denko).

## Sysfs PWM Interface Features
**Note:** If the hardware PWM channel for a pin is started, it can only be used as PWM until rebooting. The associated GPIO for that pin will not work.
- [x] Hardware PWM Out (specific pins, depending on board)
- [x] Servo
- [x] On-off keying (OOK) modulated waves
  - Useful for sending infrared signals at 38kHz, for example.
  - Carrier generated by hardware PWM. Modulated in software with monotonic clock.

## Installation
On Debian-based Linuxes (RaspberryPi OS, Armbian, DietPi etc.):
```bash
sudo apt install swig python3-dev python3-setuptools

# Temporary fork of: wget https://github.com/joan2937/lg/archive/master.zip
wget https://github.com/vickash/lg/archive/refs/heads/master.zip

unzip master.zip
cd lg-master
make
sudo make install

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
- See examples folder for demos of every implemented interface.
  - Development was done on an Orange Pi Zero 2W. Your GPIO numbers may be different, so change them.
- For more info, see the [lgpio C API docs.](https://abyz.me.uk/lg/lgpio.html)
- As much as possible, the Ruby methods closely follow the C API functions, except:
  - Snake case instead of camel case names for methods.
  - Method names have the leading `lg` removed, since inside the `LGPIO` class.
  - Constants have leading `LG_` removed, as above.
  - "count" or "length" arguments associated with array args are not needed.
- Check the return values of your method calls. On failure, they return negative values, matching the `LG_` error codes at the bottom of the C API doc page.
