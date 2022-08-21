
module execute_alu (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            i_valid,

    input   wire [31:0]     i_src0_value,
    input   wire [31:0]     i_src1_value,

    input   wire [3:0]      i_dst_rob,

    input   wire [25:0]     i_imm,

    input   wire [7:0]      i_fid,

    input   wire [4:0]      i_alu_cmd,

    //
    output  wire            o_valid,
    output  wire [3:0]      o_dst_rob,
    output  wire [7:0]      o_fid,

    output  wire [31:0]     o_result,
    output  wire [3:0]      o_cmtdelay,

    output  wire [31:0]     o_forward_value
);

    //
    wire [1:0]  rdec_alu_math_imm;
    wire [2:0]  rdec_alu_math_func;

    wire [0:0]  rdec_alu_shift_sa_sel;
    wire [1:0]  rdec_alu_shift_func;

    wire [1:0]  rdec_alu_mux;

    execute_alu_redecode execute_alu_redecode_INST (
        //
        .i_valid            (i_valid),
        .i_alu_cmd          (i_alu_cmd),

        //
        .o_alu_math_imm     (rdec_alu_math_imm),
        .o_alu_math_func    (rdec_alu_math_func),

        .o_alu_shift_sa_sel (rdec_alu_shift_sa_sel),
        .o_alu_shift_func   (rdec_alu_shift_func),

        .o_alu_mux          (rdec_alu_mux)
    );

    //
    wire        idffs_valid;

    wire [31:0] idffs_src0_value;
    wire [31:0] idffs_src1_value;

    wire [3:0]  idffs_dst_rob;

    wire [25:0] idffs_imm;

    wire [7:0]  idffs_fid;

    wire [1:0]  idffs_alu_math_imm;
    wire [2:0]  idffs_alu_math_func;

    wire [0:0]  idffs_alu_shift_sa_sel;
    wire [1:0]  idffs_alu_shift_func;

    wire [1:0]  idffs_alu_mux;

    execute_alu_idffs execute_alu_idffs_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .i_valid            (i_valid),
        
        .i_src0_value       (i_src0_value),
        .i_src1_value       (i_src1_value),

        .i_dst_rob          (i_dst_rob),

        .i_imm              (i_imm),

        .i_fid              (i_fid),

        .i_alu_math_imm     (rdec_alu_math_imm),
        .i_alu_math_func    (rdec_alu_math_func),

        .i_alu_shift_sa_sel (rdec_alu_shift_sa_sel),
        .i_alu_shift_func   (rdec_alu_shift_func),

        .i_alu_mux          (rdec_alu_mux),

        //
        .o_valid            (idffs_valid),
        
        .o_src0_value       (idffs_src0_value),
        .o_src1_value       (idffs_src1_value),

        .o_dst_rob          (idffs_dst_rob),

        .o_imm              (idffs_imm),

        .o_fid              (idffs_fid),

        .o_alu_math_imm     (idffs_alu_math_imm),
        .o_alu_math_func    (idffs_alu_math_func),

        .o_alu_shift_sa_sel (idffs_alu_shift_sa_sel),
        .o_alu_shift_func   (idffs_alu_shift_func),

        .o_alu_mux          (idffs_alu_mux)
    );

    //
    wire        impl_valid;
    wire [3:0]  impl_dst_rob;
    wire [7:0]  impl_fid;

    wire [31:0] impl_result;
    wire [3:0]  impl_cmtdelay;

    execute_alu_impl execute_alu_impl_INST (
        //
        .i_valid            (idffs_valid),

        .i_src0_value       (idffs_src0_value),
        .i_src1_value       (idffs_src1_value),

        .i_dst_rob          (idffs_dst_rob),

        .i_imm              (idffs_imm),

        .i_fid              (idffs_fid),

        .i_alu_math_imm     (idffs_alu_math_imm),
        .i_alu_math_func    (idffs_alu_math_func),

        .i_alu_shift_sa_sel (idffs_alu_shift_sa_sel),
        .i_alu_shift_func   (idffs_alu_shift_func),

        .i_alu_mux          (idffs_alu_mux),

        //
        .o_valid            (impl_valid),
        .o_dst_rob          (impl_dst_rob),
        .o_fid              (impl_fid),

        .o_result           (impl_result),
        .o_cmtdelay         (impl_cmtdelay)
    );

    //
    execute_alu_odffs execute_alu_odffs_INST (
        .clk        (clk),
        .resetn     (resetn),

        //
        .i_valid    (impl_valid),
        .i_dst_rob  (impl_dst_rob),
        .i_fid      (impl_fid),

        .i_result   (impl_result),
        .i_cmtdelay (impl_cmtdelay),

        //
        .o_valid    (o_valid),
        .o_dst_rob  (o_dst_rob),
        .o_fid      (o_fid),
        
        .o_result   (o_result),
        .o_cmtdelay (o_cmtdelay)
    );

    //
    assign o_forward_value = impl_result;

    //

endmodule
