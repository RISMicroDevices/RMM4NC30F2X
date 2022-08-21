
// Branch Recovery Table 

module fetch_brt (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            bp_valid,
    input   wire [3:0]      bp_bid,
    input   wire            bp_taken,
    input   wire            bp_hit,
    input   wire [31:0]     bp_target,

    //
    input   wire            bc_valid,   // branch commit valid
    input   wire [3:0]      bc_bid,
    input   wire [31:0]     bc_pc,
    input   wire [1:0]      bc_oldpattern,
    input   wire            bc_taken,
    input   wire [31:0]     bc_target,

    //
    output  wire            bco_valid,
    output  wire [31:0]     bco_pc,
    output  wire [3:0]      bco_bid,
    output  wire [1:0]      bco_oldpattern,
    output  wire            bco_taken,
    output  wire [31:0]     bco_target
);

    // Input registers
    reg         bp_valid_IR;
    reg [3:0]   bp_bid_IR;
    reg         bp_taken_IR;
    reg         bp_hit_IR;
    reg [31:0]  bp_target_IR;

    always @(posedge clk) begin

        if (~resetn) begin

            bp_valid_IR  <= 'b0;
            bp_bid_IR    <= 'b0;
            bp_taken_IR  <= 'b0;
            bp_hit_IR    <= 'b0;
            bp_target_IR <= 'b0;
        end
        else begin

            bp_valid_IR  <= bp_valid;
            bp_bid_IR    <= bp_bid;
            bp_taken_IR  <= bp_taken;
            bp_hit_IR    <= bp_hit;
            bp_target_IR <= bp_target;
        end
    end


    // Table entries
    reg         brt_taken_R [7:0];
    reg [31:0]  brt_target_R[7:0];

    always @(posedge clk) begin

        if (bp_valid_IR) begin

            brt_taken_R [bp_bid_IR[2:0]] <= bp_taken_IR & bp_hit_IR;
            brt_target_R[bp_bid_IR[2:0]] <= bp_target_IR;
        end
    end

    // Query & output logic
    wire    bc_mismatch_taken;
    wire    bc_mismatch_target;

    wire    bc_override;

    assign bc_mismatch_taken  = (bc_taken  != brt_taken_R [bc_bid[2:0]]);
    assign bc_mismatch_target = (bc_target != brt_target_R[bc_bid[2:0]]) & bc_taken;

    assign bc_override = bc_valid & (bc_mismatch_taken | bc_mismatch_target);

    
    // Output register
    reg         bco_valid_R;
    reg [3:0]   bco_bid_R;
    reg [31:0]  bco_pc_R;
    reg [1:0]   bco_oldpattern_R;
    reg         bco_taken_R;
    reg [31:0]  bco_target_R;

    always @(posedge clk) begin

        if (~resetn) begin
            bco_valid_R      <= 'b0;
        end
        else begin
            bco_valid_R      <= bc_override;
        end

        bco_bid_R        <= bc_bid;
        bco_pc_R         <= bc_pc;
        bco_oldpattern_R <= bc_oldpattern;
        bco_taken_R      <= bc_taken;
        bco_target_R     <= bc_target;
    end

    assign bco_valid      = bco_valid_R;
    assign bco_pc         = bco_pc_R;
    assign bco_bid        = bco_bid_R;
    assign bco_oldpattern = bco_oldpattern_R;
    assign bco_taken      = bco_taken_R;
    assign bco_target     = bco_target_R;

    //
    /* ** critical path **
    assign bco_valid      = bc_override;
    assign bco_pc         = bc_pc;
    assign bco_bid        = bc_bid;
    assign bco_oldpattern = bc_oldpattern;
    assign bco_taken      = bc_taken;
    assign bco_target     = bc_target;
    */

    //

endmodule
