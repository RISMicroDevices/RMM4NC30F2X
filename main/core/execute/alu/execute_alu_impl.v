
module execute_alu_impl (
    //
    input   wire            i_valid,

    input   wire [31:0]     i_src0_value,
    input   wire [31:0]     i_src1_value,

    input   wire [3:0]      i_dst_rob,

    input   wire [25:0]     i_imm,

    input   wire [7:0]      i_fid,

    input   wire [1:0]      i_alu_math_imm,
    input   wire [2:0]      i_alu_math_func,

    input   wire [0:0]      i_alu_shift_sa_sel,
    input   wire [1:0]      i_alu_shift_func,

    input   wire [1:0]      i_alu_mux,

    //
    output  wire            o_valid,
    output  wire [3:0]      o_dst_rob,
    output  wire [7:0]      o_fid,

    output  wire [31:0]     o_result,
    output  wire [3:0]      o_cmtdelay
);

    // General Math (Including SLT)
    wire [31:0] src0_gmath;
    wire [31:0] src1_gmath;

    wire [32:0] s0_gmath;
    wire [32:0] s1_gmath;

    wire [32:0] s_gmath;

    wire        sub;

    assign src0_gmath = i_src0_value;

    execute_alu_impl_lut6opt_imm execute_alu_impl_lut6opt_imm_INST (
        //
        .d0     (i_src1_value),
        .d1     (i_imm[15:0]),

        .sel    (i_alu_math_imm),

        //
        .s0     (src1_gmath)
    );

    execute_alu_impl_lut6opt_math execute_alu_impl_lut6opt_math_INST (
        //
        .d0     (src0_gmath),
        .d1     (src1_gmath),

        .sel    (i_alu_math_func),

        //
        .s0     (s0_gmath),
        .s1     (s1_gmath),

        .sub    (sub)
    );

    assign s_gmath = ({ s0_gmath, 1'b1 } + { s1_gmath, sub }) >> 1;

    // Shift
    wire [31:0] s_shift;

    execute_alu_impl_shift execute_alu_impl_shift_INST (
        //
        .d0     (i_src1_value),
        
        .sa0    (i_src0_value[4:0]),
        .sa1    (i_imm[4:0]),
        .sa_sel (i_alu_shift_sa_sel),

        .sel    (i_alu_shift_func),

        //
        .s0     (s_shift)
    );

    // Output MUX
    wire [31:0] mux_result;

    execute_alu_mux execute_alu_mux_INST (
        //
        .d_gmath(s_gmath),
        .d_shift(s_shift),
        
        .sel    (i_alu_mux),

        //
        .s0     (mux_result)
    );

    //
    assign o_valid      = i_valid;
    assign o_dst_rob    = i_valid ? i_dst_rob  : 'b0;
    assign o_fid        = i_valid ? i_fid      : 'b0;
    assign o_result     = i_valid ? mux_result : 'b0;

    assign o_cmtdelay   = 'b0;

    //

endmodule
