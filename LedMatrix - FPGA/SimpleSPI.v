module readSPI(clk, ce, SCk, mosi, dataOut, dataReady, reset);
	input wire clk;
	input wire SCk;
	input wire mosi;
	inout wire ce;
	input wire reset;
	
	output reg [7:0] dataOut;
	output reg dataReady;
	
			
	// sync SCK to the FPGA clock using a 3-bits shift register
	reg [2:0] SCKr;  
	always @(posedge clk) 
	begin
		SCKr <= {SCKr[1:0], SCk};	
	end
		
	wire SCK_risingedge = (SCKr[2:1]==2'b01);  // now we can detect SCK rising edges
	wire SCK_fallingedge = (SCKr[2:1]==2'b10);  // and falling edges
		
	// and for MOSI
	reg [1:0] MOSIr;  
	always @(posedge clk) 
	begin
		MOSIr <= {MOSIr[0], mosi};
	end
	wire MOSI_data = MOSIr[1];
	
	// sync reset to the clock using a 3-bits shift register
	reg [2:0] resetr;  
	always @(posedge clk) 
	begin
		resetr <= {resetr[1:0], reset};	
	end
		
	wire reset_risingedge = (resetr[2:1]==2'b01);  // now we can detect dataReady rising edges
	
	// we handle SPI in 8-bits format, so we need a 3 bits counter to count the bits as they come in
	reg [2:0] bitcnt;

	reg byte_received;  // high when a byte has been received
	reg [7:0] byte_data_received;
	
	always @(posedge clk)
	begin
		if (reset_risingedge)
		begin
			bitcnt <= 0;
			byte_data_received <= 0;
		end

		if(SCK_risingedge && ce == 1)
		begin
		 bitcnt <= bitcnt + 3'b001;

		 // implement a shift-left register (since we receive the data MSB first)
		 byte_data_received <= {byte_data_received[6:0], MOSI_data};
		end

		byte_received <= SCK_risingedge && (bitcnt==3'b111);
		dataReady <= byte_received;

		if(byte_received) 
			dataOut <= byte_data_received;		
	end
		

	
endmodule