module issue_pick_mux_data (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire            bco_valid,

    // 
    input   wire [3:0]      i_valid,

    input   wire [15:0]     i_src0_rob,
    input   wire [3:0]      i_src0_rdy,
    input   wire [127:0]    i_src0_value,

    input   wire [15:0]     i_src1_rob,
    input   wire [3:0]      i_src1_rdy,
    input   wire [127:0]    i_src1_value,

    input   wire [15:0]     i_dst_rob,

    input   wire [3:0]      i_branch,
    input   wire [3:0]      i_load,
    input   wire [3:0]      i_store,

    input   wire [3:0]      i_pipe_alu,
    input   wire [3:0]      i_pipe_mul,
    input   wire [3:0]      i_pipe_mem,
    input   wire [3:0]      i_pipe_bru,

    input   wire [7:0]      i_bp_pattern,
    input   wire [3:0]      i_bp_taken,
    input   wire [3:0]      i_bp_hit,
    input   wire [127:0]    i_bp_target,

    //
    output  wire [3:0]      o_en,
    output  wire [1:0]      o_pick,

    //
    output  wire            o_valid,

    output  wire [3:0]      o_dst_rob,

    output  wire [1:0]      o_bp_pattern,
    output  wire            o_bp_taken,
    output  wire            o_bp_hit,
    output  wire [31:0]     o_bp_target,

    output  wire [31:0]     o_src0_value,
    output  wire            o_src0_forward_alu,

    output  wire [31:0]     o_src1_value,
    output  wire            o_src1_forward_alu
);

    //
    wire        o_pipe_alu;
    wire        o_pipe_mul;
    wire        o_pipe_mem;
    wire        o_pipe_bru;

    wire [3:0]  prepick_forward_src0;
    wire [3:0]  prepick_forward_src1;

    issue_pick_core issue_pick_core_data0_INST (
        .clk        (clk),
        .resetn     (resetn),

        //
        .snoop_hit  (snoop_hit),

        //
        .bco_valid  (bco_valid),

        //
        .i_valid    (i_valid),

        .i_src0_rob (i_src0_rob),
        .i_src0_rdy (i_src0_rdy),

        .i_src1_rob (i_src1_rob),
        .i_src1_rdy (i_src1_rdy),

        .i_dst_rob  (i_dst_rob),

        .i_branch   (i_branch),
        .i_load     (i_load),
        .i_store    (i_store),

        .i_pipe_alu (i_pipe_alu),
        .i_pipe_mul (i_pipe_mul),
        .i_pipe_mem (i_pipe_mem),
        .i_pipe_bru (i_pipe_bru),

        //
        .o_en       (o_en),
        .o_pick     (o_pick),

        .o_prepick_forward_src0(prepick_forward_src0),
        .o_prepick_forward_src1(prepick_forward_src1),

        //
        .o_valid    (o_valid),
        
        .o_dst_rob  (o_dst_rob),

        .o_pipe_alu (o_pipe_alu),
        .o_pipe_mul (o_pipe_mul),
        .o_pipe_mem (o_pipe_mem),
        .o_pipe_bru (o_pipe_bru)
    );

    //
    reg  [1:0]  o_bp_pattern_comb;
    reg         o_bp_taken_comb;
    reg         o_bp_hit_comb;
    reg  [31:0] o_bp_target_comb;

    reg  [31:0] o_src0_value_comb;
    reg         o_src0_forward_alu_comb;

    reg  [31:0] o_src1_value_comb;
    reg         o_src1_forward_alu_comb;

    integer i;
    always @(*) begin

        // Pick MUXs
        o_bp_pattern_comb       = i_bp_pattern        [o_pick * 2  +:  2];
        o_bp_taken_comb         = i_bp_taken          [o_pick * 1  +:  1];
        o_bp_hit_comb           = i_bp_hit            [o_pick * 1  +:  1];
        o_bp_target_comb        = i_bp_target         [o_pick * 32 +: 32];

        o_src0_value_comb       = i_src0_value        [o_pick * 32 +: 32];
        o_src0_forward_alu_comb = prepick_forward_src0[o_pick];

        o_src1_value_comb       = i_src1_value        [o_pick * 32 +: 32];
        o_src1_forward_alu_comb = prepick_forward_src1[o_pick];
    end

    //
    assign o_bp_pattern       = o_bp_pattern_comb;
    assign o_bp_taken         = o_bp_taken_comb;
    assign o_bp_hit           = o_bp_hit_comb;
    assign o_bp_target        = o_bp_target_comb;

    assign o_src0_value       = o_src0_value_comb;
    assign o_src0_forward_alu = o_src0_forward_alu_comb;

    assign o_src1_value       = o_src1_value_comb;
    assign o_src1_forward_alu = o_src1_forward_alu_comb;

    //

endmodule