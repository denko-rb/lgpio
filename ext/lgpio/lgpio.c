#include <lgpio.h>
#include <ruby.h>

static VALUE chip_open(VALUE self, VALUE gpio_dev) {
  int result = lgGpiochipOpen(NUM2INT(gpio_dev));
  return INT2NUM(result);
}

static VALUE chip_close(VALUE self, VALUE handle) {
  int result = lgGpiochipClose(NUM2INT(handle));
  return INT2NUM(result);
}

static VALUE gpio_claim_output(VALUE self, VALUE handle, VALUE flags, VALUE gpio, VALUE level) {
  int result = lgGpioClaimOutput(NUM2INT(handle), NUM2INT(flags), NUM2INT(gpio), NUM2INT(level));
  return INT2NUM(result);
}

static VALUE gpio_claim_input(VALUE self, VALUE handle, VALUE flags, VALUE gpio) {
  int result = lgGpioClaimInput(NUM2INT(handle), NUM2INT(flags), NUM2INT(gpio));
  return INT2NUM(result);
}

static VALUE gpio_free(VALUE self, VALUE handle, VALUE gpio) {
  int result = lgGpioFree(NUM2INT(handle), NUM2INT(gpio));
  return INT2NUM(result);
}

static VALUE gpio_read(VALUE self, VALUE handle, VALUE gpio) {
  int result = lgGpioRead(NUM2INT(handle), NUM2INT(gpio));
  return INT2NUM(result);
}

static VALUE gpio_write(VALUE self, VALUE handle, VALUE gpio, VALUE level) {
  int result = lgGpioWrite(NUM2INT(handle), NUM2INT(gpio), NUM2INT(level));
  return INT2NUM(result);
}

static VALUE group_claim_input(VALUE self, VALUE handle, VALUE flags, VALUE gpios) {
  int count = rb_array_len(gpios);
  int lgGpios[count];
  int i;
  for(i=0; i<count; i++) {
    lgGpios[i] = NUM2INT(rb_ary_entry(gpios, i));
  }
  int result = lgGroupClaimInput(NUM2INT(handle), NUM2INT(flags), count, lgGpios);
  return INT2NUM(result);
}

static VALUE group_claim_output(VALUE self, VALUE handle, VALUE flags, VALUE gpios, VALUE levels) {
  int count = rb_array_len(gpios);
  int lgGpios[count];
  int lgLevels[count];
  int i;
  for(i=0; i<count; i++) {
    lgGpios[i]  = NUM2INT(rb_ary_entry(gpios, i));
    lgLevels[i] = NUM2INT(rb_ary_entry(levels, i));
  }
  int result = lgGroupClaimOutput(NUM2INT(handle), NUM2INT(flags), count, lgGpios, lgLevels);
  return INT2NUM(result);
}

static VALUE group_free(VALUE self, VALUE handle, VALUE gpio) {
  int result = lgGroupFree(NUM2INT(handle), NUM2INT(gpio));
  return INT2NUM(result);
}

static VALUE group_read(VALUE self, VALUE handle, VALUE gpio) {
  uint64_t result;
  lgGroupRead(NUM2INT(handle), NUM2INT(gpio), &result);
  return UINT2NUM(result);
}

static VALUE group_write(VALUE self, VALUE handle, VALUE gpio, VALUE bits, VALUE mask) {
  int result = lgGroupWrite(NUM2INT(handle), NUM2INT(gpio), NUM2UINT(bits), NUM2UINT(mask));
  return INT2NUM(result);
}

static VALUE tx_busy(VALUE self, VALUE handle, VALUE gpio, VALUE kind) {
  int result = lgTxBusy(NUM2INT(handle), NUM2INT(gpio), NUM2INT(kind));
  return INT2NUM(result);
}

static VALUE tx_room(VALUE self, VALUE handle, VALUE gpio, VALUE kind) {
  int result = lgTxRoom(NUM2INT(handle), NUM2INT(gpio), NUM2INT(kind));
  return INT2NUM(result);
}

static VALUE tx_pulse(VALUE self, VALUE handle, VALUE gpio, VALUE on, VALUE off, VALUE offset, VALUE cycles) {
  int result = lgTxPulse(NUM2INT(handle), NUM2INT(gpio), NUM2INT(on), NUM2INT(off), NUM2INT(offset), NUM2INT(cycles));
  return INT2NUM(result);
}

static VALUE tx_pwm(VALUE self, VALUE handle, VALUE gpio, VALUE freq, VALUE duty, VALUE offset, VALUE cycles) {
  int result = lgTxPwm(NUM2INT(handle), NUM2INT(gpio), NUM2INT(freq), NUM2INT(duty), NUM2INT(offset), NUM2INT(cycles));
  return INT2NUM(result);
}

static VALUE tx_servo(VALUE self, VALUE handle, VALUE gpio, VALUE width, VALUE freq, VALUE offset, VALUE cycles) {
  int result = lgTxServo(NUM2INT(handle), NUM2INT(gpio), NUM2INT(width), NUM2INT(freq), NUM2INT(offset), NUM2INT(cycles));
  return INT2NUM(result);
}

static VALUE tx_wave(VALUE self, VALUE handle, VALUE lead_gpio, VALUE pulses) {
  // Copy Ruby array to array of lgPulse_t.
  int       pulseCount = rb_array_len(pulses);
  lgPulse_t pulsesOut[pulseCount];
  VALUE     rbPulse;
  int       i;
  for(i=0; i<pulseCount; i++) {
    rbPulse            = rb_ary_entry(pulses, i);
    pulsesOut[i].bits  = NUM2UINT(rb_ary_entry(rbPulse, 0));
    pulsesOut[i].mask  = NUM2UINT(rb_ary_entry(rbPulse, 1));
    pulsesOut[i].delay = NUM2INT (rb_ary_entry(rbPulse, 2));
  }

  // Add it to wave queue.
  int result = lgTxWave(NUM2INT(handle), NUM2INT(lead_gpio), pulseCount, pulsesOut);
  return INT2NUM(result);
}

void Init_lgpio(void) {
  // Modules
  VALUE mLGPIO = rb_define_module("LGPIO");

  // Basics
  rb_define_const(mLGPIO, "SET_ACTIVE_LOW",   INT2NUM(LG_SET_ACTIVE_LOW));
  rb_define_const(mLGPIO, "SET_OPEN_DRAIN",   INT2NUM(LG_SET_OPEN_DRAIN));
  rb_define_const(mLGPIO, "SET_OPEN_SOURCE",  INT2NUM(LG_SET_OPEN_SOURCE));
  rb_define_const(mLGPIO, "SET_PULL_UP",      INT2NUM(LG_SET_PULL_UP));
  rb_define_const(mLGPIO, "SET_PULL_DOWN",    INT2NUM(LG_SET_PULL_DOWN));
  rb_define_const(mLGPIO, "SET_PULL_NONE",    INT2NUM(LG_SET_PULL_NONE));
  rb_define_singleton_method(mLGPIO, "chip_open",          chip_open,         1);
  rb_define_singleton_method(mLGPIO, "chip_close",         chip_close,        1);
  rb_define_singleton_method(mLGPIO, "gpio_free",          gpio_free,         2);
  rb_define_singleton_method(mLGPIO, "gpio_claim_input",   gpio_claim_input,  3);
  rb_define_singleton_method(mLGPIO, "gpio_claim_output",  gpio_claim_output, 4);
  rb_define_singleton_method(mLGPIO, "gpio_read",          gpio_read,         2);
  rb_define_singleton_method(mLGPIO, "gpio_write",         gpio_write,        3);

  // Grouped
  rb_define_singleton_method(mLGPIO, "group_claim_input",   group_claim_input,  3);
  rb_define_singleton_method(mLGPIO, "group_claim_output",  group_claim_output, 4);
  rb_define_singleton_method(mLGPIO, "group_free",          group_free,         2);
  rb_define_singleton_method(mLGPIO, "group_read",          group_read,         2);
  rb_define_singleton_method(mLGPIO, "group_write",         group_write,        4);

  // PWM / Servo / Wave
  rb_define_const(mLGPIO, "TX_PWM", INT2NUM(LG_TX_PWM));
  rb_define_const(mLGPIO, "TX_WAVE",INT2NUM(LG_TX_WAVE));
  rb_define_singleton_method(mLGPIO, "tx_busy",  tx_busy,  3);
  rb_define_singleton_method(mLGPIO, "tx_room",  tx_room,  3);
  rb_define_singleton_method(mLGPIO, "tx_pulse", tx_pulse, 6);
  rb_define_singleton_method(mLGPIO, "tx_pwm",   tx_pwm,   6);
  rb_define_singleton_method(mLGPIO, "tx_servo", tx_servo, 6);
  rb_define_singleton_method(mLGPIO, "tx_wave",  tx_wave,  3);
}
