module variableBaudeR (Clk, ResetN, tick, ctrl);
	//need 26 bit counter
	input Clk, ResetN;
    input [1:0] ctrl;
	output reg tick;
	reg [25:0] Q;
    reg [25:0] PERIOD;

    parameter A = 26'd49999999, B = 26'd499999, C = 26'd49999, D = 26'd49;

    always @ (*)
        begin
            case (ctrl)
                2'b00: PERIOD = A;
                2'b01: PERIOD = B;
                2'b10: PERIOD = C;
                2'b11: PERIOD = D;                
            endcase
        end

	always @ (posedge Clk, negedge ResetN)
		begin
		if (ResetN == 0)
		begin
			Q <= 26'b0;
			tick <= 1'b0;
		end
		else if (Q == PERIOD)
		begin
			Q <= 26'b0;
			tick <= 1'b1;
		end
		else
		begin
			Q <= Q + 1;
			tick <= 1'b0;
		end
		end
endmodule
