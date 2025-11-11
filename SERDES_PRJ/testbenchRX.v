`timescale 1ns / 1ps

module testbenchRX ( );

	parameter CLOCK_PERIOD = 10;

    reg [7:0] Pin;
    reg CLOCK_50, resetN, send;
    wire Sout, errTX, errRX;
    wire [7:0] vgaData;
    wire invalidData, wrongRD;
	initial begin
        CLOCK_50 <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
        resetN <= 1'b0;

	Pin <= 8'b00001111;
	send <= 1'b0;
        #10 resetN <= 1'b1;
    #1000 send <= 1'b1;
    #200 Pin <= 8'b11110000;
	end // initial


	initial begin
	#500 send <= 1'b0;
	

	end

	TX U1 (Pin, Sout, resetN, send, CLOCK_50, errTX);

	RX U2 (Sout, CLOCK_50, CLOCK_50, resetN, vgaData, errRX, invalidData, wrongRD);

endmodule
	