require 'mkmf'

#
# Need lgpio installed.
# See: https://github.com/joan2937/lg for instructions.
#
$libs += " -llgpio"

$CFLAGS += " -Werror=implicit-function-declaration"

create_makefile('lgpio/lgpio')
