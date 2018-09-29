import spidev
import time
import sys
from PIL import Image
import RPi.GPIO as GPIO
import numpy

class LEDMatrix:
    resetPin = 25
    cePin = 24
    
    print "Open SPI"
    
    spi = spidev.SpiDev()
    spi.open(0,0)
    spi.max_speed_hz = 150000000
    
    print "Opened SPI"
    
    GPIO.setwarnings(False)
    GPIO.setmode(GPIO.BCM) # Broadcom pin-numbering scheme
    GPIO.setup(resetPin, GPIO.OUT)
    GPIO.setup(cePin, GPIO.OUT)
    
    gamma = [
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
        0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,
        1,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,
        2,  3,  3,  3,  3,  3,  3,  3,  4,  4,  4,  4,  4,  5,  5,  5,
        5,  6,  6,  6,  6,  7,  7,  7,  7,  8,  8,  8,  9,  9,  9, 10,
       10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16,
       17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 24, 24, 25,
       25, 26, 27, 27, 28, 29, 29, 30, 31, 32, 32, 33, 34, 35, 35, 36,
       37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 50,
       51, 52, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68,
       69, 70, 72, 73, 74, 75, 77, 78, 79, 81, 82, 83, 85, 86, 87, 89,
       90, 92, 93, 95, 96, 98, 99,101,102,104,105,107,109,110,112,114,
      115,117,119,120,122,124,126,127,129,131,133,135,137,138,140,142,
      144,146,148,150,152,154,156,158,160,162,164,167,169,171,173,175,
      177,180,182,184,186,189,191,193,196,198,200,203,205,208,210,213,
      215,218,220,223,225,228,231,233,236,239,241,244,247,249,252,255 ]
    
    def ResetFrame(self):
        # Reset Frame
        GPIO.output(self.resetPin, GPIO.HIGH)
        GPIO.output(self.resetPin, GPIO.LOW)
        GPIO.output(self.cePin, GPIO.HIGH)
    
    def DeInit(self):
        GPIO.output(self.cePin, GPIO.LOW)
        GPIO.cleanup() # cleanup all GPIO

    def DisplayImage(self, h, w, im):
        
        self.ResetFrame()
        
        start = time.time() # What in other posts is described is
        
        newImg = Image.new("RGB", (256, 32))
        
        top = im.crop((0, 0, 128, 32))
        bottom = im.crop((0, 32, 128, 64)).rotate(180)
        
        newImg.paste(top, (128, 0))
        newImg.paste(bottom, (0, 0))
        
        newImg = Image.eval(newImg, lambda px: LEDMatrix.gamma[px] >> 3)
        
        pixData = numpy.array(newImg, dtype=int)
        #pixData = numpy.right_shift(pixData, 3)
        
        #print "Loading Data"
        #dataOut = []
        
        #for y in range(0, h/2):
            #for x in range(0, w):
                #r = self.gamma[pixData[63-y,127-x][0]]
                #g = self.gamma[pixData[63-y,127-x][1]]
                #b = self.gamma[pixData[63-y,127-x][2]]
                
                #dataOut.extend([r, g, b])
                #dataOut.extend(pixData[63-y,127-x])

            #for x in range(0, w):
                #r = self.gamma[pixData[y,x][0]]
                #g = self.gamma[pixData[y,x][1]]
                #b = self.gamma[pixData[y,x][2]]
                
                #dataOut.extend([r, g, b])
                #dataOut.extend(pixData[y,x])
                
        #dataOut = numpy.ndarray.tolist(numpy.right_shift(numpy.array(dataOut), 3))
        dataOut = numpy.ndarray.tolist(pixData.flatten('K'))
                
        for i in range(0, len(dataOut), 4095):
            resp = self.spi.xfer2(dataOut[i:i+4095])
            
        end = time.time()         
        print("FPS :" + str(1/(end-start)))
            