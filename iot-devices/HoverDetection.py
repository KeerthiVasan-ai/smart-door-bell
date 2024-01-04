#!/usr/bin/python
import RPi.GPIO as GPIO
import time
import Notification as requestAPI
import Utils

def hover_detection():
    count = 0
    while True:
        try:
            GPIO.setmode(GPIO.BOARD)

            GPIO.setwarnings(False)
            GPIO.setup(Utils.PIN_TRIGGER, GPIO.OUT)
            GPIO.setup(Utils.PIN_ECHO, GPIO.IN)
            GPIO.setup(Utils.PIN_LED, GPIO.OUT, initial=GPIO.LOW)
            GPIO.setup(Utils.PIN_BUZZER,GPIO.OUT,initial=GPIO.LOW)


            GPIO.output(Utils.PIN_TRIGGER, GPIO.LOW)

            print("Waiting for sensor to settle")

            time.sleep(2)

            GPIO.output(Utils.PIN_LED, GPIO.HIGH)

            print("Calculating distance")

            GPIO.output(Utils.PIN_TRIGGER, GPIO.HIGH)

            time.sleep(0.00001)

            GPIO.output(Utils.PIN_TRIGGER, GPIO.LOW)

            while GPIO.input(Utils.PIN_ECHO)==0:
                pulse_start_time = time.time()
            while GPIO.input(Utils.PIN_ECHO)==1:
                pulse_end_time = time.time()

            pulse_duration = pulse_end_time - pulse_start_time
            distance = round(pulse_duration * 17150, 2)

            print("Distance:",distance,"cm")
            if(distance < 12):
                GPIO.output(Utils.PIN_BUZZER,GPIO.HIGH)
                time.sleep(3) 
                count += 1
                if(count == 3):
                    requestAPI.request('Someone is Knocking the Door')
                    print('Notification Sent')
                    count=0

        finally:
            GPIO.cleanup()
        
