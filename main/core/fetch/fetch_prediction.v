

`define BTB_STATE_STRONG_TAKEN              2'b01
`define BTB_STATE_WEAK_TAKEN                2'b00
`define BTB_STATE_WEAK_NOT_TAKEN            2'b10
`define BTB_STATE_STRONG_NOT_TAKEN          2'b11


module fetch_prediction (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire [31:0]     pc,

    //
    input   wire            pht_update_en,
    input   wire [31:0]     pht_update_pc,
    input   wire [1:0]      pht_update_oldpattern,
    input   wire            pht_update_taken,

    //
    input   wire            btb_update_en,
    input   wire [31:0]     btb_update_pc,
    input   wire [31:0]     btb_update_target,

    //
    output  wire [1:0]      bp_pattern,
    output  wire            bp_taken,
    output  wire            bp_target_valid,
    output  wire [31:0]     bp_target,

    //
    input   wire [7:0]      GHR_rdata,

    output  wire            GHR_wen,
    output  wire [7:0]      GHR_wdata
);

    //
    wire [12:0]     pht_line;

    assign pht_line = { pc[12:11] ^ GHR_rdata[3:2], pc[10:2], GHR_rdata[1:0] };

    //
    wire [9:0]      btb_line;
    wire [4:0]      btb_tag;

    assign btb_line = pc[9:0];
    assign btb_tag  = pc[14:10];

    
    //
    assign GHR_wen   =   pht_update_en;
    assign GHR_wdata = { pht_update_taken, GHR_rdata[3:1] };

    //
    wire [7:0]      GHR;

    assign GHR = GHR_wen ? GHR_wdata : GHR_rdata;


    // PHT addressing & update logic
    wire [12:0]     pht_update_line;
    wire [1:0]      pht_update_data;

    assign pht_update_line = { pht_update_pc[12:11] ^ GHR[3:2], pht_update_pc[10:2], GHR[1:0] };
    assign pht_update_data = pht_update_oldpattern == `BTB_STATE_STRONG_TAKEN ? 
                                (pht_update_taken ? `BTB_STATE_STRONG_TAKEN   : `BTB_STATE_WEAK_TAKEN) : 
                             pht_update_oldpattern == `BTB_STATE_WEAK_TAKEN ? 
                                (pht_update_taken ? `BTB_STATE_STRONG_TAKEN   : `BTB_STATE_WEAK_NOT_TAKEN) :
                             pht_update_oldpattern == `BTB_STATE_WEAK_NOT_TAKEN ?
                                (pht_update_taken ? `BTB_STATE_WEAK_TAKEN     : `BTB_STATE_STRONG_NOT_TAKEN) :
                             pht_update_oldpattern == `BTB_STATE_STRONG_NOT_TAKEN ?
                                (pht_update_taken ? `BTB_STATE_WEAK_NOT_TAKEN : `BTB_STATE_STRONG_NOT_TAKEN) :
                             2'b0;

    // PHTs
    wire [1:0]  pht_out;

    bram_pht2k bram_pht2k_INST0 (
        .clka   (clk),
        .wea    (pht_update_en),
        .addra  (pht_update_line),
        .dina   (pht_update_data),
        
        .clkb   (clk),
        .addrb  (pht_line),
        .doutb  (pht_out)
    );

    // PHT out
    assign bp_pattern = pht_out;
    assign bp_taken   = bp_pattern == `BTB_STATE_STRONG_TAKEN || bp_pattern == `BTB_STATE_WEAK_TAKEN;


    // BTB addressing & data construction
    wire [9:0]     btb_update_line;
    wire [4:0]      btb_update_tag;
    wire [35:0]     btb_update_data;

    assign btb_update_line =   btb_update_pc[9:0];
    assign btb_update_tag  =   btb_update_pc[14:10];
    assign btb_update_data = { 1'b1, btb_update_tag, btb_update_target[31:2] };

    // BTBs
    wire [35:0]     btb_dout;

    bram_btb2k bram_btb2k_INST0 (
        .clka   (clk),
        .wea    (btb_update_en),
        .addra  (btb_update_line),
        .dina   (btb_update_data),

        .clkb   (clk),
        .addrb  (btb_line),
        .doutb  (btb_dout)
    );

    // BTB output
    assign bp_target_valid =   btb_dout[35] && (btb_dout[34:30] == btb_tag);
    assign bp_target       = { btb_dout[29:0], 2'b0 };


endmodule
