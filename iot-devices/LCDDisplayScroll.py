import RPi.GPIO as GPIO

from RPLCD.gpio import CharLCD

import time

GPIO.setwarnings(False)

framebuffer = ['Hello!','',]

def write_to_lcd(lcd, framebuffer, num_cols):
    lcd.home()
    for row in framebuffer:
        lcd.write_string(row.ljust(num_cols)[:num_cols])
        lcd.write_string('\r\n')

lcd = CharLCD(pin_rs=15,pin_rw=18, pin_e=16, pins_data=[21, 22, 23, 24],
numbering_mode=GPIO.BOARD,cols=16, rows=2, dotsize=8,auto_linebreaks=True, compat_mode=True)

write_to_lcd(lcd, framebuffer, 16)

long_string = 'Welcome to the LinuxHint'

def loop_string(string, lcd, framebuffer, row, num_cols, delay=0.5):

    padding = ' ' * num_cols
    s = padding + string + padding
    for i in range(len(s) - num_cols + 1):
        framebuffer[row] = s[i:i+num_cols]
        
write_to_lcd(lcd, framebuffer, 16)
time.sleep(0.5)

while True:

    loop_string(long_string, lcd, framebuffer, 1, 16)