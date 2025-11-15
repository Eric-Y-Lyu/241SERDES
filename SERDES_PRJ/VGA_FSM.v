module VGA_FSM (dataFromMem, MCC, resetN, Clk50, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);

    input [7:0] dataFromMem;
    input [4:0] MCC;
    input resetN, Clk50, syncState;

    //ouputs for the VGA pheripheral
    output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
    output [7:0] VGA_R, VGA_G, VGA_B;

    reg oneSec, oneSecFlag, doneAction, VGACC, write;
    reg [9:0] coordX;
    reg [8:0] coordY;
    reg [2:0] color;

    parameter A = 3'b000, B = 3'b001, C = 3'b010, D = 3'b011, SYNC = 3'b100;
    reg [2:0] state;


    Clk50Mto1Hz C1Hz (Clk50, resetN, oneSec);


    //flag for errPerSer to be updated and printed
    always @ (posedge oneSec, negedge resetN)
    begin
        if (~resetN)
            oneSecFlag <= 0;
        else
        oneSecFlag <= 1;
    end


    //FSM states logic
    always @ (posedge Clk50, negedge resetN)
    begin
        if (~resetN)
            state <= A;
        else
        case (state)
            A: begin
                doneAction <= 0;
                if (doneAction == 1)
                begin
                    state <= B;
                    oneSecFlag <= 0;
                end
            end
            B: begin
                if (syncState == 1)
                begin
                    state <= SYNC;
                end
                else if (oneSecFlag)
                begin
                    state <= C;
                end
                else if ((MCC != VGACC)) 
                begin
                    state <= D;
                end
            end
            C: begin
                if (doneAction == 1)
                begin
                    doneAction <= 0;
                    oneSecFlag <= 0;
                    if (oneSecFlag)
                        state <= C;
                    else if (MCC != VGACC)
                        state <= D;
                    else
                        state <= B;
                end
            end
            D: begin
                if (doneAction == 1)
                begin
                    doneAction <= 0;
                    if (oneSecFlag)
                        state <= C;
                    else if (MCC != VGACC)
                        state <= D;
                    else
                        state <= B;
                end
            end
            SYNC: begin
                if (syncState == 0)
                    state <= B;
            end
            default: state <= A;
        endcase
    end

    //FSM output logic
    always @ (posedge Clk50)
    begin
        case (state)
            A: begin
                //Do this later, print starting UI

            end
            B: begin
                //do nothing, wait for next state
            end
            C: begin
                
            end
            D: begin
                if (MCC>VGACC) begin
                    
                end
                else if (MCC<VGACC) begin
                    if(firstCycle ==1) begin
                        coordX = (MCC*8)%60+10; //8 pixels per char, 60 chars per row, 10 pixel offset
                        coordY = (MCC*8)/60*8+20; //8 pixels per char height, 8 rows per char, 20 pixel offset (verilog / rounds down)
                        rowOfChar = 0;
                        firstCycle <= 0;
                    end
                    else begin
                        if ((rowOfChar < 7)&& (X < (MCC*8)%60+10+7)) begin //if within bounds of char sprite

                            //if row did nt end yet
                            if (coordX < (MCC*8)%60+10+7) begin
                                if (pixelInRow[7 - (X - ((MCC*8)%60+10))]) //pixel in verilog left to right is big endian
                                    color = 3'b111; //white
                                else
                                    color = 3'b000; //black
                                write = 1;
                                coordX = coordX + 1;
                            end
                            //if row ended, update to next row
                            else begin
                                write = 0;
                                coordX = (MCC*8)%60+10; //reset X to start of char
                                rowOfChar = rowOfChar + 1;
                            end
                        //if ouside bounds of char sprite    
                        end
                        else begin
                            doneAction <= 1;
                            VGACC = VGACC + 1;
                        end
                    end
                end
            end
            SYNC: begin
                //do this later: print "SYNCING..." on the screen
            end
        endcase
    end



endmodule


module print8x8 (dataFromMem, inX, inY, Clk50, beginPrint, donePrint, resetN
                VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, VGA_R, VGA_G, VGA_B;);
    input [7:0] dataFromMem;
    input [9:0] inX,
    input [8:0] inY;
    reg [9:0] coordX;
    reg [8:0] coordY;
    input resetN, beginPrint;
    output reg [2:0] color;
    output reg donePrint;
    input Clk50;

    wire [7:0] pixelInRow;
    reg firstCycle, write;
    reg [2:0] rowOfChar;

    output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;
    output [7:0] VGA_R, VGA_G, VGA_B;

    //copied from vga_demo.v
    // Specify VGA resolution.
    parameter RESOLUTION = "640x480"; // "640x480" "320x240" "160x120"

    // default color depth. Specify a color in top.v
    parameter COLOR_DEPTH = 9; // 9 6 3

    // specify the number of bits needed for an X (column) pixel coordinate on the VGA display
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8);
    // specify the number of bits needed for a Y (row) pixel coordinate on the VGA display
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7);


    font8x8_set2 FONT1 (dataFromMem, rowOfChar, pixelInRow);
    vga_adapter VGA (resetN, Clk50, color, coordX, coordY, write,
                VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);


    //donePrint latch
    always @ (posedge beginPrint, negedge resetN)
    begin
        if (~resetN)
            donePrint <= 1;
        else if (beginPrint == 1)
        begin
            donePrint <= 0;
            firstCycle <= 1;
            write <= 0;
        end
        //else stay in same state
    end

    always @ (posedge Clk50)
    begin
        if (donePrint == 0) begin
            if(firstCycle == 1) begin
                coordX <= inX; //8 pixels per char, 60 chars per row, 10 pixel offset
                coordY <= inY; //8 pixels per char height, 8 rows per char, 20 pixel offset (verilog / rounds down)
                rowOfChar <= 0;
                firstCycle <= 0;
            end
            else begin
                if ((rowOfChar < 7 + 1)) begin //if within bounds of char sprite
                    //if row did nt end yet
                    if (coordX < inX + 7 + 1) begin
                        if (pixelInRow[7 - (coordX-inX)]) //pixel in verilog left to right is big endian
                            color <= 3'b111; //white
                        else
                        color <= 3'b000; //black
                        coordX <= coordX + 1;
                        write <= 1;
                    end
        
                    //if row ended, update to next row
                    else begin
                        write <= 0;
                        coordX <= inX; //reset X to start of char
                        coordY <= coordY + 1;
                        rowOfChar <= rowOfChar + 1;
                    end
                //if ouside bounds of char sprite    
                end
                else begin
                    write <= 0;
                    donePrint <= 1;
                end
            end
        end
    end


endmodule