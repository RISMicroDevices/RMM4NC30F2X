
module execute_bru (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire [1:0]      i_bp_pattern,
    input   wire            i_bp_taken,
    input   wire            i_bp_hit,
    input   wire [31:0]     i_bp_target,

    //
    input   wire            i_valid,

    input   wire [31:0]     i_pc,

    input   wire [31:0]     i_src0_value,
    input   wire [31:0]     i_src1_value,

    input   wire [3:0]      i_dst_rob,

    input   wire [25:0]     i_imm,

    input   wire [7:0]      i_fid,

    input   wire [6:0]      i_bru_cmd,
    input   wire [1:0]      i_bagu_cmd,

    //
    output  wire            o_valid,
    output  wire [3:0]      o_dst_rob,    
    output  wire [7:0]      o_fid,

    output  wire [31:0]     o_result,
    output  wire [3:0]      o_cmtdelay,

    //
    output  wire            o_bco_valid,
    output  wire [31:0]     o_bco_pc,
    output  wire [1:0]      o_bco_oldpattern,
    output  wire            o_bco_taken,
    output  wire [31:0]     o_bco_target
);

    //
    wire [1:0]  idffs_bp_pattern;
    wire        idffs_bp_taken;
    wire        idffs_bp_hit;
    wire [31:0] idffs_bp_target;

    wire        idffs_valid;

    wire [31:0] idffs_pc;

    wire [31:0] idffs_src0_value;
    wire [31:0] idffs_src1_value;

    wire [3:0]  idffs_dst_rob;

    wire [25:0] idffs_imm;

    wire [7:0]  idffs_fid;

    wire [6:0]  idffs_bru_cmd;
    wire [1:0]  idffs_bagu_cmd;

    execute_bru_idffs execute_bru_idffs_INST (
        .clk            (clk),
        .resetn         (resetn),

        //
        .i_bp_pattern   (i_bp_pattern),
        .i_bp_taken     (i_bp_taken),
        .i_bp_hit       (i_bp_hit),
        .i_bp_target    (i_bp_target),

        //
        .i_valid        (i_valid),

        .i_pc           (i_pc),

        .i_src0_value   (i_src0_value),
        .i_src1_value   (i_src1_value),

        .i_dst_rob      (i_dst_rob),

        .i_imm          (i_imm),

        .i_fid          (i_fid),
        
        .i_bru_cmd      (i_bru_cmd),
        .i_bagu_cmd     (i_bagu_cmd),

        //
        .o_bp_pattern   (idffs_bp_pattern),
        .o_bp_taken     (idffs_bp_taken),
        .o_bp_hit       (idffs_bp_hit),
        .o_bp_target    (idffs_bp_target),

        //
        .o_valid        (idffs_valid),

        .o_pc           (idffs_pc),

        .o_src0_value   (idffs_src0_value),
        .o_src1_value   (idffs_src1_value),

        .o_dst_rob      (idffs_dst_rob),

        .o_imm          (idffs_imm),

        .o_fid          (idffs_fid),

        .o_bru_cmd      (idffs_bru_cmd),
        .o_bagu_cmd     (idffs_bagu_cmd)
    );

    //
    wire        impl_valid;
    wire [3:0]  impl_dst_rob;
    wire [7:0]  impl_fid;

    wire [31:0] impl_result;

    wire        impl_bco_valid;
    wire [31:0] impl_bco_pc;
    wire [1:0]  impl_bco_oldpattern;
    wire        impl_bco_taken;
    wire [31:0] impl_bco_target;

    execute_bru_impl execute_bru_impl_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .i_bp_pattern       (idffs_bp_pattern),
        .i_bp_taken         (idffs_bp_taken),
        .i_bp_hit           (idffs_bp_hit),
        .i_bp_target        (idffs_bp_target),

        //
        .i_valid            (idffs_valid),

        .i_pc               (idffs_pc),
        
        .i_src0_value       (idffs_src0_value),
        .i_src1_value       (idffs_src1_value),

        .i_dst_rob          (idffs_dst_rob),

        .i_imm              (idffs_imm),

        .i_fid              (idffs_fid),

        .i_bru_cmd          (idffs_bru_cmd),
        .i_bagu_cmd         (idffs_bagu_cmd),

        //
        .o_valid            (impl_valid),
        .o_dst_rob          (impl_dst_rob),
        .o_fid              (impl_fid),

        .o_result           (impl_result),

        //
        .o_bco_valid        (impl_bco_valid),
        .o_bco_pc           (impl_bco_pc),
        .o_bco_oldpattern   (impl_bco_oldpattern),
        .o_bco_taken        (impl_bco_taken),
        .o_bco_target       (impl_bco_target)
    );

    //
    execute_bru_odffs execute_bru_odffs_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .i_valid            (impl_valid),
        .i_dst_rob          (impl_dst_rob),
        .i_fid              (impl_fid),

        .i_result           (impl_result),

        .i_bco_valid        (impl_bco_valid),
        .i_bco_pc           (impl_bco_pc),
        .i_bco_oldpattern   (impl_bco_oldpattern),
        .i_bco_taken        (impl_bco_taken),
        .i_bco_target       (impl_bco_target),

        // 
        .o_valid            (o_valid),
        .o_dst_rob          (o_dst_rob),
        .o_fid              (o_fid),

        .o_result           (o_result),

        .o_bco_valid        (o_bco_valid),
        .o_bco_pc           (o_bco_pc),
        .o_bco_oldpattern   (o_bco_oldpattern),
        .o_bco_taken        (o_bco_taken),
        .o_bco_target       (o_bco_target)
    );

    //
    assign o_cmtdelay = 'd0;

    //

endmodule
