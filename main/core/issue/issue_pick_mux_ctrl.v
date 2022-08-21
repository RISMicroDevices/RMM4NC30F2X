
module issue_pick_mux_ctrl (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire            bco_valid,

    // 
    input   wire [3:0]      i_valid,

    input   wire [127:0]    i_pc,

    input   wire [15:0]     i_src0_rob,
    input   wire [3:0]      i_src0_rdy,

    input   wire [15:0]     i_src1_rob,
    input   wire [3:0]      i_src1_rdy,

    input   wire [15:0]     i_dst_rob,

    input   wire [103:0]    i_imm,

    input   wire [31:0]     i_fid,

    input   wire [3:0]      i_branch,
    input   wire [3:0]      i_load,
    input   wire [3:0]      i_store,

    input   wire [3:0]      i_pipe_alu,
    input   wire [3:0]      i_pipe_mul,
    input   wire [3:0]      i_pipe_mem,
    input   wire [3:0]      i_pipe_bru,

    input   wire [19:0]     i_alu_cmd,
    input   wire [3:0]      i_mul_cmd,
    input   wire [19:0]     i_mem_cmd,
    input   wire [27:0]     i_bru_cmd,
    input   wire [7:0]      i_bagu_cmd,

    //
    output  wire [3:0]      o_en,
    output  wire [1:0]      o_pick,

    //
    output  wire            o_valid,

    output  wire [31:0]     o_pc,

    output  wire [3:0]      o_dst_rob,

    output  wire [25:0]     o_imm,

    output  wire [7:0]      o_fid,

    output  wire            o_pipe_alu,
    output  wire            o_pipe_mul,
    output  wire            o_pipe_mem,
    output  wire            o_pipe_bru,

    output  wire [4:0]      o_alu_cmd,
    output  wire [0:0]      o_mul_cmd,
    output  wire [4:0]      o_mem_cmd,
    output  wire [6:0]      o_bru_cmd,
    output  wire [1:0]      o_bagu_cmd
);

    //
    issue_pick_core issue_pick_core_ctrl_INST (
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

        .o_prepick_forward_src0(),
        .o_prepick_forward_src1(),

        //
        .o_valid    (o_valid),
        
        .o_dst_rob  (o_dst_rob),

        .o_pipe_alu (o_pipe_alu),
        .o_pipe_mul (o_pipe_mul),
        .o_pipe_mem (o_pipe_mem),
        .o_pipe_bru (o_pipe_bru)
    );

    //
    reg  [31:0] o_pc_comb;

    reg  [3:0]  o_src0_rob_comb;
    reg         o_src0_rdy_comb;

    reg  [3:0]  o_src1_rob_comb;
    reg         o_src1_rdy_comb;

    reg  [25:0] o_imm_comb;

    reg  [7:0]  o_fid_comb;

    reg  [4:0]  o_alu_cmd_comb;
    reg  [0:0]  o_mul_cmd_comb;
    reg  [4:0]  o_mem_cmd_comb;
    reg  [6:0]  o_bru_cmd_comb;
    reg  [1:0]  o_bagu_cmd_comb;

    integer i;
    always @(*) begin

        // Pick MUXs
        o_pc_comb           = i_pc          [o_pick * 32 +: 32];

        o_src0_rob_comb     = i_src0_rob    [o_pick *  4 +:  4];
        o_src0_rdy_comb     = i_src0_rdy    [o_pick *  1 +:  1];

        o_src1_rob_comb     = i_src1_rob    [o_pick *  4 +:  4];
        o_src1_rdy_comb     = i_src1_rdy    [o_pick *  1 +:  1];

        o_imm_comb          = i_imm         [o_pick * 26 +: 26];

        o_fid_comb          = i_fid         [o_pick *  8 +:  8];

        o_alu_cmd_comb      = i_alu_cmd     [o_pick *  5 +:  5];
        o_mul_cmd_comb      = i_mul_cmd     [o_pick *  1 +:  1];
        o_mem_cmd_comb      = i_mem_cmd     [o_pick *  5 +:  5];
        o_bru_cmd_comb      = i_bru_cmd     [o_pick *  7 +:  7];
        o_bagu_cmd_comb     = i_bagu_cmd    [o_pick *  2 +:  2];
    end

    //
    assign o_pc         = o_pc_comb;

    assign o_src0_rob   = o_src0_rob_comb;
    assign o_src0_rdy   = o_src0_rdy_comb;

    assign o_src1_rob   = o_src1_rob_comb;
    assign o_src1_rdy   = o_src1_rdy_comb;

    assign o_imm        = o_imm_comb;

    assign o_fid        = o_fid_comb;

    assign o_alu_cmd    = o_alu_cmd_comb;
    assign o_mul_cmd    = o_mul_cmd_comb;
    assign o_mem_cmd    = o_mem_cmd_comb;
    assign o_bru_cmd    = o_bru_cmd_comb;
    assign o_bagu_cmd   = o_bagu_cmd_comb;

endmodule
