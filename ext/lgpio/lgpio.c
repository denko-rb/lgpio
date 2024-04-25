#include <lgpio.h>
#include <ruby.h>

static VALUE chip_open(VALUE self, VALUE gpio_dev) {
  int result = lgGpiochipOpen(NUM2INT(gpio_dev));
  return INT2NUM(result);
}

static VALUE chip_close(VALUE self, VALUE gpio_dev) {
  int result = lgGpiochipClose(NUM2INT(gpio_dev));
  return INT2NUM(result);
}

static VALUE gpio_free(VALUE self, VALUE handle, VALUE gpio) {
  int result = lgGpioFree(NUM2INT(handle), NUM2INT(gpio));
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

static VALUE gpio_read(VALUE self, VALUE handle, VALUE gpio) {
  int result = lgGpioRead(NUM2INT(handle), NUM2INT(gpio));
  return INT2NUM(result);
}

static VALUE gpio_write(VALUE self, VALUE handle, VALUE gpio, VALUE level) {
  int result = lgGpioWrite(NUM2INT(handle), NUM2INT(gpio), NUM2INT(level));
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

  // PWM / Servo / Wave
  rb_define_const(mLGPIO, "TX_PWM", INT2NUM(LG_TX_PWM));
  rb_define_const(mLGPIO, "TX_WAVE",INT2NUM(LG_TX_WAVE));
  rb_define_singleton_method(mLGPIO, "tx_busy",  tx_busy,  3);
  rb_define_singleton_method(mLGPIO, "tx_room",  tx_room,  3);
  rb_define_singleton_method(mLGPIO, "tx_pulse", tx_pulse, 6);
  rb_define_singleton_method(mLGPIO, "tx_pwm",   tx_pwm,   6);
  rb_define_singleton_method(mLGPIO, "tx_servo", tx_servo, 6);
}
