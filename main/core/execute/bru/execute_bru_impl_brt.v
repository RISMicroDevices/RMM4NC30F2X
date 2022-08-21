
module execute_bru_impl_brt (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            i_bp_valid,
    input   wire [3:0]      i_bp_bid,
    input   wire            i_bp_taken,
    input   wire            i_bp_hit,
    input   wire [31:0]     i_bp_target,

    //
    input   wire            i_bc_valid,
    input   wire [3:0]      i_bc_bid,
    input   wire [31:0]     i_bc_pc,
    input   wire [1:0]      i_bc_oldpattern,
    input   wire            i_bc_taken,
    input   wire [31:0]     i_bc_target,

    //
    output  wire            o_bco_valid,
    output  wire            o_bco_cooldown
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
        end
        else begin
            bp_valid_IR  <= i_bp_valid;
        end

        bp_bid_IR    <= i_bp_bid;
        bp_taken_IR  <= i_bp_taken;
        bp_hit_IR    <= i_bp_hit;
        bp_target_IR <= i_bp_target;
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

    assign bc_mismatch_taken  = (i_bc_taken  != brt_taken_R [i_bc_bid[2:0]]);
    assign bc_mismatch_target = (i_bc_target != brt_target_R[i_bc_bid[2:0]]) & i_bc_taken;

    assign bc_override = i_bc_valid & (bc_mismatch_taken | bc_mismatch_target);

    
    // Cooldown register
    (*MARK_DEBUG = "true" *) reg [3:0]   cooldown_R;

    always @(posedge clk) begin

        if (~resetn) begin
            cooldown_R <= 'b0;
        end
        else begin
            cooldown_R <= { cooldown_R[2:0], bc_override };
        end
    end


    //
    assign o_bco_valid = bc_override;

    assign o_bco_cooldown = |(cooldown_R);

    //

endmodule
