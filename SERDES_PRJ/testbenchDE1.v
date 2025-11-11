
`timescale 1ns / 1ps

module testbenchDE1 ( );

	parameter CLOCK_PERIOD = 10;

    reg [7:0] SW;
    reg CLOCK_50;
    reg [1:0] KEY;

	wire LEDR;
	initial begin
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
	KEY[1] = 1'b0;
 	#10 KEY[0] = 1'b0;
	SW = 8'b10101001;
	#100 KEY[0] = 1'b1;
	#50 KEY[1] = 1'b1;
	
	end // initial



	DE1soc DE1 (SW, LEDR, KEY, CLOCK_50);

endmodule