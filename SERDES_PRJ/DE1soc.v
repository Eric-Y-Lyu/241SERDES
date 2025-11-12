module DE1soc (SW, LEDR, KEY, CLOCK_50, GPIO_0, GPIO_1);

    input [9:0] SW;
	input [1:0] KEY;
	output [9:0] LEDR;
	input CLOCK_50;
    inout  wire [35:0] GPIO_0, GPIO_1;

    wire Sout, resetN, send, errTX, errRX, invalidData, wrongRD, varClk, comma;

    wire [7:0] vgaData;

    assign resetN = KEY[0];
    assign send = KEY [1];

    assign LEDR[9] = errTX|errRX;
    assign LEDR[8] = comma;
    assign LEDR[7:0] = vgaData;
    assign GPIO_0[34] = varClk;

    variableBaudeR BR1 (CLOCK_50, resetN, varClk, SW[9:8]);
    TX U1 (SW[7:0], GPIO_0[0], resetN, send, varClk, errTX);
	RX U2 (GPIO_1[0], GPIO_1[34], varClk, resetN, vgaData, errRX, invalidData, wrongRD, comma);
endmodule