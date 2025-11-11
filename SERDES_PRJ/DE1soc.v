module DE1soc (SW, LEDR, KEY, CLOCK_50);

    input [9:0] SW;
	input [1:0] KEY;
	output [9:0] LEDR;
	input CLOCK_50;

    wire Sout, resetN, send, errTX, errRX. invalidData, wrongRD;

    assign resetN = KEY[0];
    assign send = KEY [1];

    assign LEDR[9] = errTX|errRX;

    assign LEDR[7:0] = vgaData;

    TX U1 (SW[7:0], Sout, resetN, send, CLOCK_50, errTX);
	RX U2 (Sout, CLOCK_50, CLOCK_50, resetN, vgaData, errRX, invalidData, wrongRD);
endmodule