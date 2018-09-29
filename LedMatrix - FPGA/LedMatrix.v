module LEDMatrix(clk, address, data, R1, G1, B1, R2, G2, B2, A, B, C, D, led_lat, led_oe, led_clk); //, s_r1, s_r2, s_r3, s_r4);
	input wire clk;
	input wire [15:0] data;
	//input wire s_r1, s_r2, s_r3, s_r4;
	
	output reg A, B, C, D;
	output reg R1, G1, B1, R2, G2, B2, led_lat, led_oe;
	output reg led_clk;
	output reg [12:0] address;
	
	reg [3:0] row;			// 16 Rows
	reg [8:0] col; 		// 64 Cols (Extra Cycles for latching)
	reg [2:0] stage;		// Stage for Pixel
	reg [3:0] plane;		// plane we are displaying	
	reg [15:0] Tdata;
	reg [15:0] Bdata;	
	reg [4:0] endRowDelay;	
	reg [8:0] pwmCount;
	
	parameter  MAX_LEDS_PER_LINE 	= 256;
	parameter  BRIGHTNESS 			= 15;
		
	wire onScreen = (col < MAX_LEDS_PER_LINE);
	wire offScreen = (col >= MAX_LEDS_PER_LINE);
		
	always @(posedge clk) 
	begin			
		case (stage)
			0: begin
					stage = 1;
					// Fetch Data For next Clock Cycle if the col is visible
					if (onScreen)
					begin			
						address = col + row * MAX_LEDS_PER_LINE;
					end
				end
			1: begin	// Delay to get data from Ram
					stage = 2;
				end
			2: begin	// Load Top half data
					stage = 3;
					// Fetch Data For next Clock Cycle if the col is visible
					if (onScreen)
					begin		
						Tdata = data;	
						address = col + 1 + (row + 16) * MAX_LEDS_PER_LINE;
					end
				end
			3: begin	// Delay to get data from Ram
					stage = 4;
				end
			4: begin // Update Values (Data is ready except on first pixel of first run)
					stage = 5;
					
					if (onScreen)
					begin		
						Bdata = data;	// Load Bottom Half Data
							
						// Bottom half Red
						R1 = (Bdata >> plane);
						G1 = (Bdata >> (plane + 5));
						B1 = (Bdata >> (plane + 10));
						// Top half Green
						R2 = (Tdata >> plane);
						G2 = (Tdata >> (plane + 5));
						B2 = (Tdata >> (plane + 10));
					end			
				end
			5: begin // Update Clock and Latch Row
			
					stage <= 6;
			
					// From 64 on we do not want to clock the output
					if (offScreen == 0)
					begin
						led_clk = 1;	// HIGH
					end
					else
					begin
						led_clk = 0;
					end
					
					led_lat = (col == MAX_LEDS_PER_LINE);		// Strobe Latch once we are over 256 pixels
				end
				
			6: begin // Update Clock and Row/Col/Plane
			
					led_clk = 0;		// LOW
					led_lat = 0;		// Set Latch Low					
					
					
					if (col == MAX_LEDS_PER_LINE)
					begin
						led_oe = 0;				// Turn On Display
					end
					
					// Update row if we are at the end of a column
					if (col >= MAX_LEDS_PER_LINE + BRIGHTNESS)
					begin
						stage = 7;				// Burn an extra cycle because we are turning off display
						led_oe = 1;				// Turn Off Display
						col = 8'b0;
						row = row + 4'b1;
						
						if (row == 4'd0)		// If we are back to Row 0 then we can start with the new plane
						begin
							if (pwmCount == (1 << plane))
							begin
								pwmCount = 8'b0;
								if (plane == 3'd4)
								begin
									plane = 3'd0;
								end
								else
								begin
									plane = plane + 3'd1;
								end
							end
							else
							begin
								pwmCount = pwmCount + 8'b1;
							end
						end						
					end
					else
					begin					
						stage = 0;				// Restart pixel stage to 0
						col = col + 8'b1;
					end					
				end
			7: begin		// This is to burn an extra cycle IF we are turning off a display row			
					if (endRowDelay == 25)
					begin
						stage = 0;				// Restart pixel
						endRowDelay = 0;

						// Set the new row
						A = row;
						B = row >> 1;
						C = row >> 2;
						D = row >> 3;						
					end
					else
					begin
						endRowDelay = endRowDelay + 1;		
						stage = 7;				// Delay longer
					end
				end
		endcase
	end
	
endmodule
