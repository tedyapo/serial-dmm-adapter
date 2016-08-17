#!/usr/bin/env python

import serial
import time

dmm_port = '/dev/ttyUSB2'

dmm = serial.Serial(port = dmm_port, timeout = 1)

# wait for arduino to reset upon connection
time.sleep(2)

# get battery status
dmm.write('b')
result = dmm.readline()
print 'Battery low = ', result

# read numeric value only
dmm.write('n')
result = dmm.readline()
print result

# read numeric value and units
dmm.write('u')
result = dmm.readline()
print result

