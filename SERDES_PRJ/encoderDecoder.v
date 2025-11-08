module encoder (dataIn, dataOut, RDin, commEn, RDout, err);
	input RDin, commEn; //RD=1 -- real RD = +1, RD=0 -- real RD = -1
	input [7:0] dataIn;
	output [9:0] dataOut;
	output reg RDout, err;
	
	reg RDmid;
	wire [3:0] sum; 
	wire [2:0] sumMid;
	reg [3:0] D4b;
	reg [5:0] D6b; 

//conversion table sourced from https://electronics.stackexchange.com/questions/396946/is-the-wikipedia-article-on-3b4b-encoding-in-8b10b-encoding-correct

//Only implemented one comma K-code to reduce complexity

	//convert the lowest 3 bits
	always @ (*)	
	begin
	if (commEn)
		begin
		if (~RDin)
			D4b = 4'b1010;
		else 
			D4b = 4'b0101;
		end
	else if(~RDin)
		case (dataIn[7:5])
		3'b000: D4b = 4'b1011;
		3'b001: D4b = 4'b1001;
		3'b010: D4b = 4'b0101;
		3'b011: D4b = 4'b1100;
		3'b100: D4b = 4'b1101;
		3'b101: D4b = 4'b1010;
		3'b110: D4b = 4'b0110;
		3'b111: D4b = 4'b1110;
		default: D4b = 4'b0000;
		endcase
	else 
		case (dataIn[7:5])
		3'b000: D4b = 4'b0100;
		3'b001: D4b = 4'b1001;
		3'b010: D4b = 4'b0101;
		3'b011: D4b = 4'b0011;
		3'b100: D4b = 4'b0010;
		3'b101: D4b = 4'b1010;
		3'b110: D4b = 4'b0110;
		3'b111: D4b = 4'b0001;
		default: D4b = 4'b0000;
		endcase
	end 


	//produce intermediate RDmid

	assign sumMid = 3'b000 + D4b[0] + D4b[1] + D4b[2] + D4b[3];
	always @(*)
	begin
	if ((sumMid == 3'b010))
		begin
		RDmid = RDin;
		err = 1'b0;
		end
	else if ((sumMid == 3'b011)&(~RDin))
		begin
		RDmid = 1'b1;
		err = 1'b0;
		end
	else if ((sumMid == 3'b001)&(RDin))
		begin
		RDmid = 1'b0;
		err = 1'b0;
		end
	else 
		begin
		RDmid = RDin;
		err = 1'b1;
		end
	end



	//convert the upper 8 bits
	always @ (*)	
	begin
	if (commEn)
		begin
		if (~RDmid)
			D6b = 6'b001111;
		else 
			D6b = 6'b110000;
		end
	else if(~RDmid)
		case (dataIn[4:0])
		5'b00000: D6b = 6'b_100111;
		5'b00001: D6b = 6'b_011101;
		5'b00010: D6b = 6'b_101101;
		5'b00011: D6b = 6'b_110001;
		5'b00100: D6b = 6'b_110101;
		5'b00101: D6b = 6'b_101001;
		5'b00110: D6b = 6'b_011001;
		5'b00111: D6b = 6'b_111000;
		5'b01000: D6b = 6'b_111001;
		5'b01001: D6b = 6'b_100101;
		5'b01010: D6b = 6'b_010101;
		5'b01011: D6b = 6'b_110100;
		5'b01100: D6b = 6'b_001101;
		5'b01101: D6b = 6'b_101100;
		5'b01110: D6b = 6'b_011100;
		5'b01111: D6b = 6'b_010111;

		5'b10000: D6b = 6'b_011011;
		5'b10001: D6b = 6'b_100011;
		5'b10010: D6b = 6'b_010011;
		5'b10011: D6b = 6'b_110010;
		5'b10100: D6b = 6'b_001011;
		5'b10101: D6b = 6'b_101010;
		5'b10110: D6b = 6'b_011010;
		5'b10111: D6b = 6'b_111010;
		5'b11000: D6b = 6'b_110011;
		5'b11001: D6b = 6'b_100110;
		5'b11010: D6b = 6'b_010110;
		5'b11011: D6b = 6'b_110110;
		5'b11100: D6b = 6'b_001110;
		5'b11101: D6b = 6'b_101110;
		5'b11110: D6b = 6'b_011110;
		5'b11111: D6b = 6'b_101011;
		default: D6b = 6'b_000000;
		endcase
	else 
		case (dataIn[4:0])
		5'b00000: D6b = 6'b_011000;
		5'b00001: D6b = 6'b_100010;
		5'b00010: D6b = 6'b_010010;
		5'b00011: D6b = 6'b_110001;
		5'b00100: D6b = 6'b_001010;
		5'b00101: D6b = 6'b_101001;
		5'b00110: D6b = 6'b_011001;
		5'b00111: D6b = 6'b_000111;
		5'b01000: D6b = 6'b_000110;
		5'b01001: D6b = 6'b_100101;
		5'b01010: D6b = 6'b_010101;
		5'b01011: D6b = 6'b_110100;
		5'b01100: D6b = 6'b_001101;
		5'b01101: D6b = 6'b_101100;
		5'b01110: D6b = 6'b_011100;
		5'b01111: D6b = 6'b_101000;

		5'b10000: D6b = 6'b_100100;
		5'b10001: D6b = 6'b_100011;
		5'b10010: D6b = 6'b_010011;
		5'b10011: D6b = 6'b_110010;
		5'b10100: D6b = 6'b_001011;
		5'b10101: D6b = 6'b_101010;
		5'b10110: D6b = 6'b_011010;
		5'b10111: D6b = 6'b_000101;
		5'b11000: D6b = 6'b_001100;
		5'b11001: D6b = 6'b_100110;
		5'b11010: D6b = 6'b_010110;
		5'b11011: D6b = 6'b_001001;
		5'b11100: D6b = 6'b_001110;
		5'b11101: D6b = 6'b_010001;
		5'b11110: D6b = 6'b_100001;
		5'b11111: D6b = 6'b_010100;
		default: D6b = 6'b_000000;
		endcase
	end 
	
	assign dataOut = {D6b, D4b};
	
	assign sum = 	4'b0000 + dataOut[0] + dataOut[1] + 
			dataOut[2]  + dataOut[3] + dataOut[4] + 
			dataOut[5] + dataOut[6] + dataOut[7] + 
			dataOut[8] + dataOut[9];


	always @(*)
	begin
	if ((sum == 4'b0101))
		begin
		RDout = RDin;
		err = 1'b0;
		end
	else if ((sum == 4'b0110)&(~RDin))
		begin
		RDout = 1'b1;
		err = 1'b0;
		end
	else if ((sum == 4'b0100)&(RDin))
		begin
		RDout = 1'b0;
		err = 1'b0;
		end
	else 
		begin
		RDout = RDin;
		err = 1'b1;
		end
	end

endmodule

	