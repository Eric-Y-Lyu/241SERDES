//receiver module in a SERDES system


module RX(SerialIn, clkTX, clkRX, resetN, vgaData, err, invalidData, wrongRD);

    input SerialIn, clkTX, clkRX, resetN; //clkTX - from TX, clkRX - local clock
    output reg [7:0] vgaData;
    output err;
    output invalidData;
    output wrongRD;
    wire tick10, RDout, Q, clk, comma, ncomma, RDcheck, dataValid, count10en;
    reg RDin;
    wire [9:0] data;
    wire [7:0] dataOut;
    reg [2:0] state;


    parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, E = 3'b100, Ready_ = 3'b101, F = 3'b110;
    // A = reset, B = receive data, C = recieve commas, D = valid data, E = invalidData, F = wrong RD, Ready = ready to recieve data
    assign clk = clkTX & clkRX; // sync the clocks


    //generate a pulse every 10 clk cycles, but will get reset when a neg comma is detected in state A
    downCount10RX DC10_1 (clk, resetN, count10en, tick10);

    downCount9RX DC9_1 (clk, resetN, count9en, tick9);

    //convert the serial data to parallel data
    shiftReg10 sr (clk, SerialIn, Q, 1'b1, 1'b0, resetN, 10'b0, data);
    
    //decode the data from 10b to 8b
    decoder d1 (data, dataOut, RDin, comma, RDout, RDcheck, dataValid);
    always @ (posedge tick10, negedge resetN) 
        if (~resetN)
            RDin <= 1'b0;
        else if(ncomma&&state==A) //keep RDin = 0 when detecting first comma
            RDin <= 1'b0;
        else
            RDin <= RDout;
    assign ncomma = (data == 10'b1100000101); //RD -1 comma


    //FSM

    always @ (posedge clk, negedge resetN)
    begin
        if (~resetN)
        begin
            state <= A;
            vgaData <= 8'b0;
        end
        else 
        case (state)
        A:  if(ncomma) //State reciever once negative comma is detected
            begin
            state <= B;
            end
            else state <= A;
        //Ready_: if (tick10) state <= B; //ready to read
        B:  if (dataValid&tick10) state <= D; //check if data is valid, comma, or if it has consistent RD
            else if (comma&tick10) state <= C;
            else if (~RDcheck&tick10) state <= F;
            else if (tick10) state <= E;
        C:  if (dataValid&tick10) 
            begin
            state <= D; //gets comma, then checks next data
            vgaData <= dataOut;
            end
            else if (comma&tick10) state <= C;
            else if (~RDcheck&tick10) state <= F;
            else if (tick10) state <= E;
        D:  
            begin                 
            if (dataValid&tick10) 
            begin
            state <= D;
            vgaData <= dataOut;
            end
            else if (comma&tick10) state <= C;
            else if (~RDcheck&tick10) state <= F;
            else if (tick10) state <= E;
            end
        E:  state <= B; //invalid data
        F:  state <= B; //wrong RD
        default: state <= A;
        endcase
    end

    assign invalidData = (state == E);
    assign wrongRD = (state == C) & ~RDcheck;
    assign count10en = (tick9) | (state == B) | (state == C) | (state == D) | (state == E) | (state == F);
    assign count9en = (state == A)&ncomma;

    assign err = invalidData | wrongRD;

endmodule
