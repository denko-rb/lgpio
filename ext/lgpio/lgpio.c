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

void Init_lgpio(void) {
  // Modules
  VALUE mLGPIO = rb_define_module("LGPIO");

  // Constants
  rb_define_const(mLGPIO, "SET_ACTIVE_LOW",   INT2NUM(LG_SET_ACTIVE_LOW));
  rb_define_const(mLGPIO, "SET_OPEN_DRAIN",   INT2NUM(LG_SET_OPEN_DRAIN));
  rb_define_const(mLGPIO, "SET_OPEN_SOURCE",  INT2NUM(LG_SET_OPEN_SOURCE));
  rb_define_const(mLGPIO, "SET_PULL_UP",      INT2NUM(LG_SET_PULL_UP));
  rb_define_const(mLGPIO, "SET_PULL_DOWN",    INT2NUM(LG_SET_PULL_DOWN));
  rb_define_const(mLGPIO, "SET_PULL_NONE",    INT2NUM(LG_SET_PULL_NONE));

  // Methods
  rb_define_singleton_method(mLGPIO, "chip_open",          chip_open, 1);
  rb_define_singleton_method(mLGPIO, "chip_close",         chip_close, 1);
  rb_define_singleton_method(mLGPIO, "gpio_claim_input",   gpio_claim_input, 3);
  rb_define_singleton_method(mLGPIO, "gpio_claim_output",  gpio_claim_output, 4);
  rb_define_singleton_method(mLGPIO, "gpio_read",          gpio_read, 2);
  rb_define_singleton_method(mLGPIO, "gpio_write",         gpio_write, 3);
}
