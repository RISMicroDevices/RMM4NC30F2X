
module dispatch (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            bco_valid,

    //
    input   wire [1:0]      i_bp_pattern,
    input   wire            i_bp_taken,
    input   wire            i_bp_hit,
    input   wire [31:0]     i_bp_target,

    //
    input   wire            i_valid,

    input   wire [31:0]     i_pc,

    input   wire [31:0]     i_src0_value,
    input   wire            i_src0_forward_alu,

    input   wire [31:0]     i_src1_value,
    input   wire            i_src1_forward_alu,

    input   wire [3:0]      i_dst_rob,

    input   wire [25:0]     i_imm,

    input   wire [7:0]      i_fid,

    input   wire            i_pipe_alu,
    input   wire            i_pipe_mul,
    input   wire            i_pipe_mem,
    input   wire            i_pipe_bru,

    input   wire [4:0]      i_alu_cmd,
    input   wire [0:0]      i_mul_cmd,
    input   wire [4:0]      i_mem_cmd,
    input   wire [6:0]      i_bru_cmd,
    input   wire [1:0]      i_bagu_cmd,

    //
    input   wire [31:0]     i_forward_alu_value,

    //
    output  wire [1:0]      o_bp_pattern,
    output  wire            o_bp_taken,
    output  wire            o_bp_hit,
    output  wire [31:0]     o_bp_target,

    //
    output  wire            o_valid,

    output  wire [31:0]     o_pc,

    output  wire [31:0]     o_src0_value,
    output  wire [31:0]     o_src1_value,

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
    wire [1:0]      idffs_bp_pattern;
    wire            idffs_bp_taken;
    wire            idffs_bp_hit;
    wire [31:0]     idffs_bp_target;

    //
    wire            idffs_valid;

    wire [31:0]     idffs_pc;

    wire [31:0]     idffs_src0_value;
    wire            idffs_src0_forward_alu;

    wire [31:0]     idffs_src1_value;
    wire            idffs_src1_forward_alu;

    wire [3:0]      idffs_dst_rob;

    wire [25:0]     idffs_imm;

    wire [7:0]      idffs_fid;

    wire            idffs_pipe_alu;
    wire            idffs_pipe_bru;
    wire            idffs_pipe_mul;
    wire            idffs_pipe_mem;

    wire [4:0]      idffs_alu_cmd;
    wire [0:0]      idffs_mul_cmd;
    wire [4:0]      idffs_mem_cmd;
    wire [6:0]      idffs_bru_cmd;
    wire [1:0]      idffs_bagu_cmd;

    dispatch_idffs dispatch_idffs_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .i_bp_pattern       (i_bp_pattern),
        .i_bp_taken         (i_bp_taken),
        .i_bp_hit           (i_bp_hit),
        .i_bp_target        (i_bp_target),

        //
        .i_valid            (i_valid),
        
        .i_pc               (i_pc),

        .i_src0_value       (i_src0_value),
        .i_src0_forward_alu (i_src0_forward_alu),

        .i_src1_value       (i_src1_value),
        .i_src1_forward_alu (i_src1_forward_alu),

        .i_dst_rob          (i_dst_rob),

        .i_imm              (i_imm),

        .i_fid              (i_fid),

        .i_pipe_alu         (i_pipe_alu),
        .i_pipe_bru         (i_pipe_bru),
        .i_pipe_mul         (i_pipe_mul),
        .i_pipe_mem         (i_pipe_mem),

        .i_alu_cmd          (i_alu_cmd),
        .i_mul_cmd          (i_mul_cmd),
        .i_mem_cmd          (i_mem_cmd),
        .i_bru_cmd          (i_bru_cmd),
        .i_bagu_cmd         (i_bagu_cmd),

        //
        .o_bp_pattern       (idffs_bp_pattern),
        .o_bp_taken         (idffs_bp_taken),
        .o_bp_hit           (idffs_bp_hit),
        .o_bp_target        (idffs_bp_target),

        //
        .o_valid            (idffs_valid),
        
        .o_pc               (idffs_pc),

        .o_src0_value       (idffs_src0_value),
        .o_src0_forward_alu (idffs_src0_forward_alu),

        .o_src1_value       (idffs_src1_value),
        .o_src1_forward_alu (idffs_src1_forward_alu),

        .o_dst_rob          (idffs_dst_rob),

        .o_imm              (idffs_imm),
        
        .o_fid              (idffs_fid),

        .o_pipe_alu         (idffs_pipe_alu),
        .o_pipe_bru         (idffs_pipe_bru),
        .o_pipe_mul         (idffs_pipe_mul),
        .o_pipe_mem         (idffs_pipe_mem),

        .o_alu_cmd          (idffs_alu_cmd),
        .o_mul_cmd          (idffs_mul_cmd),
        .o_mem_cmd          (idffs_mem_cmd),
        .o_bru_cmd          (idffs_bru_cmd),
        .o_bagu_cmd         (idffs_bagu_cmd)
    );

    //
    assign o_bp_pattern     = idffs_bp_pattern;
    assign o_bp_taken       = idffs_bp_taken;
    assign o_bp_hit         = idffs_bp_hit;
    assign o_bp_target      = idffs_bp_target;

    //
    assign o_valid          = idffs_valid;

    assign o_pc             = idffs_pc;

    assign o_src0_value     = idffs_src0_forward_alu ? i_forward_alu_value : idffs_src0_value;
    assign o_src1_value     = idffs_src1_forward_alu ? i_forward_alu_value : idffs_src1_value;

    assign o_dst_rob        = idffs_dst_rob;

    assign o_imm            = idffs_imm;

    assign o_fid            = idffs_fid;

    assign o_pipe_alu       = idffs_pipe_alu;
    assign o_pipe_mul       = idffs_pipe_mul;
    assign o_pipe_mem       = idffs_pipe_mem;
    assign o_pipe_bru       = idffs_pipe_bru;

    assign o_alu_cmd        = idffs_alu_cmd;
    assign o_mul_cmd        = idffs_mul_cmd;
    assign o_mem_cmd        = idffs_mem_cmd;
    assign o_bru_cmd        = idffs_bru_cmd;
    assign o_bagu_cmd       = idffs_bagu_cmd;

    //

endmodule
