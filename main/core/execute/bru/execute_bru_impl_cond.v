
module execute_bru_impl_cond (
    //
    input   wire [31:0]     i_src0_value,
    input   wire [31:0]     i_src1_value,

    input   wire [6:0]      i_bru_cmd,

    //
    output  wire            o_taken
);

    //
    wire    s_eq;

    wire    s_gtz;
    wire    s_ltz;
    wire    s_ez;

    assign s_eq     = i_src0_value == i_src1_value;

    assign s_gtz    = $signed(i_src0_value) > 0;
    assign s_ltz    = $signed(i_src0_value) < 0;
    assign s_ez     = i_src0_value == 0;

    //
    assign o_taken = (i_bru_cmd[6])
                   | (i_bru_cmd[4] &  s_gtz)
                   | (i_bru_cmd[3] &  s_ez)
                   | (i_bru_cmd[2] &  s_ltz)
                   | (i_bru_cmd[1] &  s_eq)
                   | (i_bru_cmd[0] & ~s_eq);
    //

endmodule
