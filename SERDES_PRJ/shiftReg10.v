module shiftReg10 (Clk, D, Q, enable, load, resetN, loadData, data);
	input [9:0] loadData;
	input load, resetN, Clk, D, enable;
	output reg [9:0] data;
	output Q;

	always @ (posedge Clk, negedge resetN)
		begin
		if (~resetN)
			data <= 10'b0;
		else if (load)
			data <= loadData;
		else if (enable)
			data <= {D, data[9:1]};
		end
	
	assign Q = data[0];
endmodule