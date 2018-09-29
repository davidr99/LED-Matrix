This project is an LED Matrix FPGA Driver with any SPI interface.  The sample code is for the Raspberry PI.

For the FPGA I am using the DE10-Lite.
The LED Matrix is a 128x64 4 Panel Chain (64x32).  You can change the code for other Pannel layouts.  Mine is a chain like this:


   |--------|    |--------|
 --|   2    |-<--|    1   |----<
|  |--------|    |--------|     
|                               
|  |--------|    |--------|     
|--|   3    |->--|    4   |---->
   |--------|    |--------|    


The Rapsberry Pi using SPI and connects to the FPGA and the FPGA drives the LED Matrix.  The max FPS I could get was about 75fps, but most of that limit
is because of the processing on the Rapsberry Pi