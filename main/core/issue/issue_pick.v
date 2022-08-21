
module issue_pick (
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
    input   wire [127:0]    i_src0_value,

    input   wire [15:0]     i_src1_rob,
    input   wire [3:0]      i_src1_rdy,
    input   wire [127:0]    i_src1_value,

    input   wire [15:0]     i_dst_rob,

    input   wire [103:0]    i_imm,

    input   wire [7:0]      i_bp_pattern,
    input   wire [3:0]      i_bp_taken,
    input   wire [3:0]      i_bp_hit,
    input   wire [127:0]    i_bp_target,

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

    //
    output  wire            o_valid,

    output  wire [31:0]     o_pc,

    output  wire [31:0]     o_src0_value,
    output  wire            o_src0_forward_alu,

    output  wire [31:0]     o_src1_value,
    output  wire            o_src1_forward_alu,

    output  wire [3:0]      o_dst_rob,

    output  wire [25:0]     o_imm,

    output  wire [1:0]      o_bp_pattern,
    output  wire            o_bp_taken,
    output  wire            o_bp_hit,
    output  wire [31:0]     o_bp_target,

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
    issue_pick_mux_ctrl issue_pick_mux_ctrl_INST (
        .clk            (clk),
        .resetn         (resetn),

        .snoop_hit      (snoop_hit),

        .bco_valid      (bco_valid),

        //
        .i_valid        (i_valid),

        .i_pc           (i_pc),

        .i_src0_rob     (i_src0_rob),
        .i_src0_rdy     (i_src0_rdy),

        .i_src1_rob     (i_src1_rob),
        .i_src1_rdy     (i_src1_rdy),

        .i_dst_rob      (i_dst_rob),

        .i_imm          (i_imm),

        .i_fid          (i_fid),

        .i_branch       (i_branch),
        .i_load         (i_load),
        .i_store        (i_store),

        .i_pipe_alu     (i_pipe_alu),
        .i_pipe_mul     (i_pipe_mul),
        .i_pipe_mem     (i_pipe_mem),
        .i_pipe_bru     (i_pipe_bru),

        .i_alu_cmd      (i_alu_cmd),
        .i_mul_cmd      (i_mul_cmd),
        .i_mem_cmd      (i_mem_cmd),
        .i_bru_cmd      (i_bru_cmd),
        .i_bagu_cmd     (i_bagu_cmd),

        //
        .o_en           (o_en),
        .o_pick         (),

        .o_valid        (o_valid),

        .o_pc           (o_pc),

        .o_dst_rob      (o_dst_rob),

        .o_imm          (o_imm),

        .o_fid          (o_fid),

        .o_pipe_alu     (o_pipe_alu),
        .o_pipe_mul     (o_pipe_mul),
        .o_pipe_mem     (o_pipe_mem),
        .o_pipe_bru     (o_pipe_bru),

        .o_alu_cmd      (o_alu_cmd),
        .o_mul_cmd      (o_mul_cmd),
        .o_mem_cmd      (o_mem_cmd),
        .o_bru_cmd      (o_bru_cmd),
        .o_bagu_cmd     (o_bagu_cmd)
    );


    issue_pick_mux_data issue_pick_mux_data_INST (
        .clk                (clk),
        .resetn             (resetn),

        .snoop_hit          (snoop_hit),

        .bco_valid          (bco_valid),

        //
        .i_valid            (i_valid),

        .i_src0_rob         (i_src0_rob),
        .i_src0_rdy         (i_src0_rdy),
        .i_src0_value       (i_src0_value),

        .i_src1_rob         (i_src1_rob),
        .i_src1_rdy         (i_src1_rdy),
        .i_src1_value       (i_src1_value),

        .i_dst_rob          (i_dst_rob),

        .i_branch           (i_branch),
        .i_load             (i_load),
        .i_store            (i_store),

        .i_pipe_alu         (i_pipe_alu),
        .i_pipe_mul         (i_pipe_mul),
        .i_pipe_mem         (i_pipe_mem),
        .i_pipe_bru         (i_pipe_bru),

        //
        .i_bp_pattern       (i_bp_pattern),
        .i_bp_taken         (i_bp_taken),
        .i_bp_hit           (i_bp_hit),
        .i_bp_target        (i_bp_target),

        //
        .o_en               (),
        .o_pick             (),

        .o_valid            (),

        .o_dst_rob          (),

        .o_bp_pattern       (o_bp_pattern),
        .o_bp_taken         (o_bp_taken),
        .o_bp_hit           (o_bp_hit),
        .o_bp_target        (o_bp_target),

        .o_src0_value       (o_src0_value),
        .o_src0_forward_alu (o_src0_forward_alu),

        .o_src1_value       (o_src1_value),
        .o_src1_forward_alu (o_src1_forward_alu)
    );

    //

endmodule
