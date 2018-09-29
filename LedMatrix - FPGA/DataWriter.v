module DataWriter(clk, dataReady, reset, data, ramAddress, ramData, ramWriteEN);
	input wire clk;
	input wire [7:0] data;
	inout wire dataReady;
	input wire reset;
		
	output reg [15:0] ramData;
	output reg [12:0] ramAddress;
	output reg ramWriteEN;
	
	reg [15:0] buffData;
	
	reg [3:0] stage;			// Our current state	
	
	
	// sync dataReady to the clock using a 3-bits shift register
	reg [2:0] dataReadyr;  
	always @(posedge clk) 
	begin
		dataReadyr <= {dataReadyr[1:0], dataReady};	
	end
		
	wire dataReady_risingedge = (dataReadyr[2:1]==2'b01);  // now we can detect dataReady rising edges
	
	
	// sync reset to the clock using a 3-bits shift register
	reg [2:0] resetr;  
	always @(posedge clk) 
	begin
		resetr <= {resetr[1:0], reset};	
	end
		
	wire reset_risingedge = (resetr[2:1]==2'b01);  // now we can detect dataReady rising edges
	
	
	always @(posedge clk) 
	begin		
		if (reset_risingedge)
		begin
			ramAddress = 0;
			ramWriteEN = 0;
			ramData = 0;
			stage = 0;		// Restart
		end
		else
		begin
			case (stage)
				0: begin				// 1st byte
						if (dataReady_risingedge)
						begin
							stage = 1;		// Go to next stage
							buffData[4:0] = data[4:0];
						end
					end
				1: begin				// 2nd byte
						if (dataReady_risingedge)
						begin
							stage = 2;		// Go to next stage
							buffData[9:5] = data[4:0];
							ramData = buffData;
						end
					end
				2: begin				// 3nd byte
						if (dataReady_risingedge)
						begin
							stage = 3;		// Go to next stage
							buffData[15:10] = data[4:0];
							ramData = buffData;
						end
					end
				3: begin				// Write Data
						stage = 4;		// Update address
						ramWriteEN = 1;
					end
				4: begin
						stage = 0;		// Restart
						ramWriteEN = 0;
						ramAddress = ramAddress + 1;	// Add 1 to address
					end
			endcase
		end
	end
	
endmodule