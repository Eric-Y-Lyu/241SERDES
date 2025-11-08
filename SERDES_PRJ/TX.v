
module TX(Pin, Sout, resetN, send, Clk, err);
	input [7:0] Pin;
	input resetN, send, Clk;
	output Sout, err;

	wire tick10, RDout;
	wire [9:0] data, dataSROut;
	reg RDin;

	reg [1:0] state;
	parameter A = 2'b00, B = 2'b01, C = 2'b10, D = 2'b11;

	//generate a pulse every 10 Clk cycles
	downCount10 DC10_1 (Clk, resetN, tick10);

	//Encode message
	encoder EN1 (Pin, data, RDin, commEn, RDout, err);
	//Feedback Running disparity
	always @ (posedge tick10, negedge resetN) 
		if(~resetN)
			RDin <= 1'b0;
		else
			RDin <= RDout;

	//constant shift reg, load command is tick10 thus new data is loaded in the CLOCK_50 cycle after the tick10 is triggered, thus having a lag effect on the SR.
	//however this doesn't matter because the RX does not get our tick10 pulse and just gets Clk.
	shiftReg10 SR1 (Clk, 1'b0, Sout, 1'b1, tick10, resetN, data, dataSROut);


	//FSM 	A - reset, B - sync, C - send data, D - send commas
	always @ (posedge tick10, negedge resetN)
	begin
		if (~resetN)
			state <= A;
		else 
		case (state)
		A:	state <= B;
		B:	if (send) state <= C;
		C:	if (~send) state <= D;
		D:	if (send) state <= C;
		endcase
	end

	assign commEn = (~state[1]&state[0])|(state[1]&state[0]);

endmodule

	