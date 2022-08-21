
module decode_brt (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            i_bp_valid,
    input   wire [3:0]      i_bp_bid,
    input   wire            i_bp_taken,
    input   wire            i_bp_hit,
    input   wire [31:0]     i_bp_target,
    input   wire [4:0]      i_bp_rob,         // currently allocated ROB address

    //
    input   wire            i_bc_valid,       // branch commit valid
    input   wire [3:0]      i_bc_bid,
    input   wire [31:0]     i_bc_pc,          // *unused here*
    input   wire [1:0]      i_bc_oldpattern,  // *unused here*
    input   wire            i_bc_taken,
    input   wire [31:0]     i_bc_target,

    //
    output  wire            o_bc_valid,
    output  wire [3:0]      o_bc_bid,

    output  wire            o_bco_valid,
    output  wire [3:0]      o_bco_bid,
    output  wire [4:0]      o_bco_rob         // recovery ROB address
);

    // Input registers, Eliminating critical path for ROB address 'bp_rob'
    reg         bp_valid_IR;
    reg [3:0]   bp_bid_IR;
    reg         bp_taken_IR;
    reg         bp_hit_IR;
    reg [31:0]  bp_target_IR;
    reg [4:0]   bp_rob_IR;

    always @(posedge clk) begin

        if (~resetn) begin

            bp_valid_IR  <= 'b0;
            bp_bid_IR    <= 'b0;
            bp_taken_IR  <= 'b0;
            bp_hit_IR    <= 'b0;
            bp_target_IR <= 'b0;
            bp_rob_IR    <= 'b0;
        end
        else begin
            
            bp_valid_IR  <= i_bp_valid;
            bp_bid_IR    <= i_bp_bid;
            bp_taken_IR  <= i_bp_taken;
            bp_hit_IR    <= i_bp_hit;
            bp_target_IR <= i_bp_target;
            bp_rob_IR    <= i_bp_rob;
        end
    end

    //

    // Table entries
    reg         brt_taken_R  [7:0];
    reg [31:0]  brt_target_R [7:0];
    reg [4:0]   brt_rob_R    [7:0];

    integer i;
    always @(posedge clk) begin

        if (bp_valid_IR) begin

            brt_taken_R [bp_bid_IR[2:0]] <= bp_taken_IR & bp_hit_IR;
            brt_target_R[bp_bid_IR[2:0]] <= bp_target_IR;
            brt_rob_R   [bp_bid_IR[2:0]] <= bp_rob_IR;
        end
    end

    //
    wire    bc_mismatch_taken;
    wire    bc_mismatch_target;

    assign bc_mismatch_taken  = (i_bc_taken  != brt_taken_R [i_bc_bid[2:0]]);
    assign bc_mismatch_target = (i_bc_target != brt_target_R[i_bc_bid[2:0]]) & i_bc_taken;

    assign bc_override = i_bc_valid & (bc_mismatch_taken | bc_mismatch_target);

    // Output registers
    reg         bc_valid_R;
    reg [3:0]   bc_bid_R;

    (*MARK_DEBUG = "true" *) reg         bco_valid_R;
    (*MARK_DEBUG = "true" *) reg [3:0]   bco_bid_R; 
    (*MARK_DEBUG = "true" *) reg [4:0]   bco_rob_R;

    always @(posedge clk) begin

        if (~resetn) begin

            bc_valid_R  <= 'b0;
            bc_bid_R    <= 'b0;

            bco_valid_R <= 'b0;
            bco_bid_R   <= 'b0;
            bco_rob_R   <= 'b0;
        end
        else begin

            bc_valid_R  <= i_bc_valid;
            bc_bid_R    <= i_bc_bid;

            bco_valid_R <= bc_override;
            bco_bid_R   <= i_bc_bid;
            bco_rob_R   <= brt_rob_R[i_bc_bid[2:0]];
        end
    end

    assign o_bc_valid  = bc_valid_R;
    assign o_bc_bid    = bc_bid_R;

    assign o_bco_valid = bco_valid_R;
    assign o_bco_bid   = bco_bid_R;
    assign o_bco_rob   = bco_rob_R;

    //

endmodule
