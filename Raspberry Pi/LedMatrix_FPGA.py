import spidev
import time
import sys
from PIL import Image
from PIL import ImageFont
from PIL import ImageDraw
from PIL import ImageChops
import LEDMatrix

matrix = LEDMatrix.LEDMatrix()
    
text = (("Raspberry Pi ", (255, 0, 0)), ("and ", (0, 255, 0)), ("Adafruit", (0, 0, 255)))
 
font = ImageFont.truetype("/usr/share/fonts/truetype/freefont/FreeSans.ttf", 16)
all_text = ""
for text_color_pair in text:
    t = text_color_pair[0]
    all_text = all_text + t
 
print(all_text)
width, ignore = font.getsize(all_text)
print(width)
 
 
im = Image.new("RGB", (width + 30, 64), "black")
draw = ImageDraw.Draw(im)
 
x = 0;
for text_color_pair in text:
    t = text_color_pair[0]
    c = text_color_pair[1]
    print("t=" + t + " " + str(c) + " " + str(x))
    draw.text((x, 0), t, c, font=font)
    x = x + font.getsize(t)[0]
    
    
for win in range(0, im.size[0]):
    imgDisp = ImageChops.offset(im, -win, 0)
    matrix.DisplayImage(64, 128, imgDisp)
    time.sleep(0.06)   # show display for 10 seconds before exit
        
time.sleep(3)   # show display for 10 seconds before exit

matrix.DeInit()