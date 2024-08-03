# lgpio

Ruby bindings for the [lgpio (lg)](https://github.com/joan2937/lg) C library, for Linux on single board computers (SBCs), like the Raspberry Pi and its competitors.

## Features
- GPIO Read/Write
- GPIO Group Read/Write
- GPIO Alerts / Callbacks
  - lg generates alerts at high speed, in a separate thread. In Ruby they can be read from a queue as part of your application loop.
- PWM Output
  - Software timed on any pin. No interface for hardware PWM yet.
- Wave
  - Software timed on any pin, as with PWM.
- I2C
- SPI

## Installation
On Debian-based Linuxes (RaspberryPi OS, Armbian, DietPi etc.):
```bash
sudo apt install swig python3-dev python3-setuptools

# NOTE: There's a bug with GPIO numbers > 255.
# If you need to use those, wget the second URL instead, until that fix is merged.
wget https://github.com/joan2937/lg/archive/master.zip
# wget https://github.com/vickash/lg/archive/refs/heads/master.zip

unzip master.zip
cd lg-master
make
sudo make install

gem install lgpio
```

## Enabling Hardware & Permissions
Depending on your SBC and Linux distro/version, you may need to manually enable I2C and SPI hardware. You may use the setup or config tool that came with your distro for that.

You may also not have permission to access some or all of the GPIO and peripherals. To run without `sudo`, you will need read+write permission to some or all of the following devices:
```
/dev/gpiochip* (For GPIO, example: /dev/gpiochip0)
/dev/i2c-*     (For I2C,  example: /dev/i2c-1)
/dev/spidev*   (For SPI,  example: /dev/spidev-0.1)
```

## Documentation
- See examples folder for demos of every implemented interface.
  - Development was done on an Orange Pi Zero 2W. Your GPIO numbers will be different, so change them.
- For more info, see the [lgpio C API docs.](https://abyz.me.uk/lg/lgpio.html)
- As much as possible, the Ruby methods closely follow the C API functions, except:
  - Snake case instead of camel case names for methods.
  - Method names have the leading `lg` removed, since inside the `LGPIO` class.
  - Constants have leading `LG_` removed, as above.
  - "count" or "length" arguments associated with array args are not needed.
- Check the return values of your method calls. On failure, they return negative values values, matching the `LG_` error codes at the bottom of the C API doc page.
