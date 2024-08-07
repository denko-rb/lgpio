#include <lgpio.h>
#include <ruby.h>

// Set up a queue for up to 2**16 GPIO reports.
static pthread_mutex_t queueLock;
#define QUEUE_LENGTH UINT16_MAX + 1
static lgGpioReport_t reportQueue[QUEUE_LENGTH];
static uint16_t qWritePos = 1;
static uint16_t qReadPos  = 0;

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

static VALUE gpio_set_debounce(VALUE self, VALUE handle, VALUE gpio, VALUE debounce) {
  int result =  lgGpioSetDebounce(NUM2INT(handle), NUM2INT(gpio), NUM2INT(debounce));
  return INT2NUM(result);
}

static VALUE gpio_claim_alert(VALUE self, VALUE handle, VALUE flags, VALUE eFlags, VALUE gpio) {
  int result = lgGpioClaimAlert(NUM2INT(handle), NUM2INT(flags), NUM2INT(eFlags), NUM2INT(gpio), -1);
  return INT2NUM(result);
}

void queue_gpio_reports(int count, lgGpioAlert_p events, void *data){
  pthread_mutex_lock(&queueLock);
  for(int i=0; i<count; i++) {
    memcpy(&reportQueue[qWritePos], &events[i].report, sizeof(lgGpioReport_t));
    qWritePos += 1;
    // qReadPos is the LAST report read. If passing by 1, increment it too. Lose oldest data first.
    if (qWritePos - qReadPos == 1) qReadPos += 1;
  }
  pthread_mutex_unlock(&queueLock);
}

static VALUE gpio_start_reporting(VALUE self) {
  lgGpioSetSamplesFunc(queue_gpio_reports, NULL);
  return Qnil;
}

static VALUE gpio_get_report(VALUE self){
  VALUE hash = rb_hash_new();
  bool popped = false;

  pthread_mutex_lock(&queueLock);
  // qWritePos is where the NEXT report will go. Always trail it by 1.
  if (qWritePos - qReadPos != 1){
    qReadPos += 1;
    rb_hash_aset(hash, ID2SYM(rb_intern("timestamp")), ULL2NUM(reportQueue[qReadPos].timestamp));
    rb_hash_aset(hash, ID2SYM(rb_intern("chip")),      UINT2NUM(reportQueue[qReadPos].chip));
    rb_hash_aset(hash, ID2SYM(rb_intern("gpio")),      UINT2NUM(reportQueue[qReadPos].gpio));
    rb_hash_aset(hash, ID2SYM(rb_intern("level")),     UINT2NUM(reportQueue[qReadPos].level));
    rb_hash_aset(hash, ID2SYM(rb_intern("flags")),     UINT2NUM(reportQueue[qReadPos].flags));
    popped = true;
  }
  pthread_mutex_unlock(&queueLock);

  if (popped){
    return hash;
  } else {
    return Qnil;
  }
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

static VALUE i2c_open(VALUE self, VALUE i2cDev, VALUE i2cAddr, VALUE i2cFlags){
  int handle = lgI2cOpen(NUM2INT(i2cDev), NUM2INT(i2cAddr), NUM2INT(i2cFlags));
  return INT2NUM(handle);
}

static VALUE i2c_close(VALUE self, VALUE handle){
  int result = lgI2cClose(NUM2INT(handle));
  return INT2NUM(result);
}

static VALUE i2c_write_device(VALUE self, VALUE handle, VALUE byteArray){
  int count = RARRAY_LEN(byteArray);
  uint8_t txBuf[count];
  VALUE currentByte;
  for(int i=0; i<count; i++){
    currentByte = rb_ary_entry(byteArray, i);
    Check_Type(currentByte, T_FIXNUM);
    txBuf[i] = NUM2CHR(currentByte);
  }

  int result = lgI2cWriteDevice(NUM2INT(handle), txBuf, count);
  return INT2NUM(result);
}

static VALUE i2c_read_device(VALUE self, VALUE handle, VALUE count){
  int rxCount = NUM2INT(count);
  uint8_t rxBuf[rxCount];

  int result = lgI2cReadDevice(NUM2INT(handle), rxBuf, rxCount);
  if(result < 0) return INT2NUM(result);

  VALUE retArray = rb_ary_new2(rxCount);
  for(int i=0; i<rxCount; i++){
    rb_ary_store(retArray, i, UINT2NUM(rxBuf[i]));
  }
  return retArray;
}

static VALUE i2c_zip(VALUE self, VALUE handle, VALUE txArray, VALUE rb_rxCount){
  int txCount = RARRAY_LEN(txArray);
  uint8_t txBuf[txCount];
  VALUE currentByte;
  for(int i=0; i<txCount; i++){
    currentByte = rb_ary_entry(txArray, i);
    Check_Type(currentByte, T_FIXNUM);
    txBuf[i] = NUM2CHR(currentByte);
  }

  int rxCount = NUM2INT(rb_rxCount);
  uint8_t rxBuf[rxCount+1];

  // Buffer size must be rxCount+1 or result is LG_BAD_I2C_RLEN
  int result = lgI2cZip(NUM2INT(handle), txBuf, txCount, rxBuf, rxCount+1);
  if(result < 0) return INT2NUM(result);

  if (rxCount == 0) return Qnil;
  VALUE retArray = rb_ary_new2(rxCount);
  for(int i=0; i<rxCount; i++){
    rb_ary_store(retArray, i, UINT2NUM(rxBuf[i]));
  }
  return retArray;
}

static VALUE spi_open(VALUE self, VALUE spiDev, VALUE spiChan, VALUE spiBaud, VALUE spiFlags){
  int handle = lgSpiOpen(NUM2INT(spiDev), NUM2INT(spiChan), NUM2INT(spiBaud), NUM2INT(spiFlags));
  return INT2NUM(handle);
}

static VALUE spi_close(VALUE self, VALUE handle){
  int result = lgSpiClose(NUM2INT(handle));
  return INT2NUM(result);
}

static VALUE spi_read(VALUE self, VALUE handle, VALUE rxCount){
  int count = NUM2INT(rxCount);

  // Not sure if this needs null termination like I2C. +1 won't hurt.
  uint8_t rxBuf[count+1];

  int result = lgSpiRead(NUM2INT(handle), rxBuf, count);
  if(result < 0) return INT2NUM(result);

  VALUE retArray = rb_ary_new2(count);
  for(int i=0; i<count; i++){
    rb_ary_store(retArray, i, UINT2NUM(rxBuf[i]));
  }
  return retArray;
}

static VALUE spi_write(VALUE self, VALUE handle, VALUE txArray){
  int count = RARRAY_LEN(txArray);
  uint8_t txBuf[count];
  VALUE currentByte;
  for(int i=0; i<count; i++){
    currentByte = rb_ary_entry(txArray, i);
    Check_Type(currentByte, T_FIXNUM);
    txBuf[i] = NUM2CHR(currentByte);
  }

  int result = lgSpiWrite(NUM2INT(handle), txBuf, count);
  return INT2NUM(result);
}

static VALUE spi_xfer(VALUE self, VALUE handle, VALUE txArray){
  int count = RARRAY_LEN(txArray);
  uint8_t txBuf[count];
  VALUE currentByte;
  for(int i=0; i<count; i++){
    currentByte = rb_ary_entry(txArray, i);
    Check_Type(currentByte, T_FIXNUM);
    txBuf[i] = NUM2CHR(currentByte);
  }

  // Not sure if this needs null termination like I2C. +1 won't hurt.
  uint8_t rxBuf[count+1];

  int result = lgSpiXfer(NUM2INT(handle), txBuf, rxBuf, count);
  if(result < 0) return INT2NUM(result);

  VALUE retArray = rb_ary_new2(count);
  for(int i=0; i<count; i++){
    rb_ary_store(retArray, i, UINT2NUM(rxBuf[i]));
  }
  return retArray;
}

static VALUE spi_ws2812_write(VALUE self, VALUE handle, VALUE pixelArray){
  int count = RARRAY_LEN(pixelArray);

  // Pull low for at least one byte at 2.4 Mhz before data, and 90 after.
  int zeroesBefore = 1;
  int zeroesAfter  = 90;
  int txBufLength  = zeroesBefore + (count*3) + zeroesAfter;
  uint8_t txBuf[txBufLength];
  for (int i=0; i<txBufLength; i++) { txBuf[i] = 0; }

  VALUE    currentByte_rb;
  uint8_t  currentByte;
  uint8_t  currentBit;
  uint32_t temp;

  for (int i=0; i<count; i++){
    temp = 0;
    currentByte_rb = rb_ary_entry(pixelArray, i);
    Check_Type(currentByte_rb, T_FIXNUM);
    currentByte = NUM2CHR(currentByte_rb);

    for (int i=7; i>=0; i--) {
      currentBit = (currentByte & (1 << i));
      temp = temp << 3;
      temp = (currentBit == 0) ? (temp | 0b100) : (temp | 0b110);
    }

    txBuf[zeroesBefore+(i*3)]   = (temp >> 16) & 0xFF;
    txBuf[zeroesBefore+(i*3)+1] = (temp >> 8) & 0xFF;
    txBuf[zeroesBefore+(i*3)+2] = temp & 0xFF;
  }

  int result = lgSpiWrite(NUM2INT(handle), txBuf, txBufLength);
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
  rb_define_const(mLGPIO, "RISING_EDGE",      INT2NUM(LG_RISING_EDGE));
  rb_define_const(mLGPIO, "FALLING_EDGE",     INT2NUM(LG_FALLING_EDGE));
  rb_define_const(mLGPIO, "BOTH_EDGES",       INT2NUM(LG_BOTH_EDGES));
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

  // Alerts / Reports
  rb_define_singleton_method(mLGPIO, "gpio_set_debounce",     gpio_set_debounce,     3);
  rb_define_singleton_method(mLGPIO, "gpio_claim_alert",      gpio_claim_alert,      4);
  rb_define_singleton_method(mLGPIO, "gpio_start_reporting",  gpio_start_reporting,  0);
  rb_define_singleton_method(mLGPIO, "gpio_get_report",       gpio_get_report,       0);

  // PWM / Servo / Wave
  rb_define_const(mLGPIO, "TX_PWM", INT2NUM(LG_TX_PWM));
  rb_define_const(mLGPIO, "TX_WAVE",INT2NUM(LG_TX_WAVE));
  rb_define_singleton_method(mLGPIO, "tx_busy",  tx_busy,  3);
  rb_define_singleton_method(mLGPIO, "tx_room",  tx_room,  3);
  rb_define_singleton_method(mLGPIO, "tx_pulse", tx_pulse, 6);
  rb_define_singleton_method(mLGPIO, "tx_pwm",   tx_pwm,   6);
  rb_define_singleton_method(mLGPIO, "tx_servo", tx_servo, 6);
  rb_define_singleton_method(mLGPIO, "tx_wave",  tx_wave,  3);

  // I2C
  rb_define_singleton_method(mLGPIO, "i2c_open",           i2c_open,          3);
  rb_define_singleton_method(mLGPIO, "i2c_close",          i2c_close,         1);
  rb_define_singleton_method(mLGPIO, "i2c_write_device",   i2c_write_device,  2);
  rb_define_singleton_method(mLGPIO, "i2c_read_device",    i2c_read_device,   2);
  rb_define_singleton_method(mLGPIO, "i2c_zip",            i2c_zip,           3);

  // SPI
  rb_define_singleton_method(mLGPIO, "spi_open",           spi_open,          4);
  rb_define_singleton_method(mLGPIO, "spi_close",          spi_close,         1);
  rb_define_singleton_method(mLGPIO, "spi_read",           spi_read,          2);
  rb_define_singleton_method(mLGPIO, "spi_write",          spi_write,         2);
  rb_define_singleton_method(mLGPIO, "spi_xfer",           spi_xfer,          2);
  rb_define_singleton_method(mLGPIO, "spi_ws2812_write",   spi_ws2812_write,  2);
}
