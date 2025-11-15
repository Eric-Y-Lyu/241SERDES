module VGA_TEST (KEY, CLOCK_50, SW, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, VGA_R, VGA_G, VGA_B);

    input CLOCK_50;
    input [9:0] SW;
    input KEY[1:0];
    output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;
    output [7:0] VGA_R, VGA_G, VGA_B;

    reg [7:0] dataFromMem;

    reg beginPrint;
    wire donePrint;
    wire resetN;
    assign resetN = ~KEY[0];
    assign beginPrint = ~KEY[1];

print8x8 VGAp (sw[9:2], {6'b0, sw[3:0]}, {5'b0, sw[3:0]}, CLOCK_50, beginPrint, donePrint, resetN
                VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, VGA_R, VGA_G, VGA_B;);


endmodule