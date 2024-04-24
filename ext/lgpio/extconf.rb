require 'mkmf'

#
# Need lgpio installed.
# See: https://github.com/joan2937/lg for instructions.
#
$libs += " -llgpio"

create_makefile('lgpio/lgpio')
