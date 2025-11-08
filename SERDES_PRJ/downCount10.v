//shows number of bits left in transit (current-1)

module downCount10 (in, ResetN, tick);
	input in, ResetN;
	reg [3:0] count;
	output reg tick;

	always @ (posedge in, negedge ResetN)
	begin
		if (ResetN == 0)
			count <= 4'b1001;
		else if (count == 4'b0000)
			count <= 4'b1001;
		else if (in == 1)	
			count <= count - 1;
	end

	always @ (*)
	begin
		if (count == 4'b0000)
			tick = 1;
		else 
			tick = 0;
	end

endmodule