import spidev
import time
import sys
from PIL import Image
from PIL import ImageFont
from PIL import ImageDraw
from PIL import ImageChops
import LEDMatrix

matrix = LEDMatrix.LEDMatrix()
    
im = Image.open("Christmas-Tree-icon.png").convert("RGB")

w = im.size[0]
h = im.size[1]
matrix.DisplayImage(h, w, im)

