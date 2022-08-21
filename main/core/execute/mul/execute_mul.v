
module execute_mul (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            i_valid,

    input   wire [31:0]     i_src0_value,
    input   wire [31:0]     i_src1_value,

    input   wire [3:0]      i_dst_rob,

    input   wire [7:0]      i_fid,

    input   wire [0:0]      i_mul_cmd,

    //
    output  wire            o_valid,
    output  wire [3:0]      o_dst_rob,
    output  wire [7:0]      o_fid,

    output  wire [31:0]     o_result,
    output  wire [3:0]      o_cmtdelay
);

    //
    wire        idffs_valid;

    wire [31:0] idffs_src0_value;
    wire [31:0] idffs_src1_value;

    wire [3:0]  idffs_dst_rob;

    wire [7:0]  idffs_fid;

    wire [0:0]  idffs_mul_cmd;

    execute_mul_idffs execute_mul_idffs_INST (
        .clk            (clk),
        .resetn         (resetn),

        //
        .i_valid        (i_valid),

        .i_src0_value   (i_src0_value),
        .i_src1_value   (i_src1_value),

        .i_dst_rob      (i_dst_rob),

        .i_fid          (i_fid),

        .i_mul_cmd      (i_mul_cmd),

        //
        .o_valid        (idffs_valid),

        .o_src0_value   (idffs_src0_value),
        .o_src1_value   (idffs_src1_value),

        .o_dst_rob      (idffs_dst_rob),

        .o_fid          (idffs_fid),

        .o_mul_cmd      (idffs_mul_cmd)
    );

    //
    wire        sdffs_valid;
    wire [3:0]  sdffs_dst_rob;
    wire [7:0]  sdffs_fid;

    wire [31:0] sdffs_result;

    execute_mul_impl_xip execute_mul_impl_xip_INST (
        .CLK    (clk),
        .SCLR   (~resetn),

        .A      (idffs_src0_value),
        .B      (idffs_src1_value),

        .P      (sdffs_result)
    );

    execute_mul_sdffs execute_mul_sdffs_INST (
        .clk        (clk),
        .resetn     (resetn),
        
        .i_valid    (idffs_valid),
        .i_dst_rob  (idffs_dst_rob),
        .i_fid      (idffs_fid),

        .o_valid    (sdffs_valid),
        .o_dst_rob  (sdffs_dst_rob),
        .o_fid      (sdffs_fid)
    );

    //
    assign o_valid      = sdffs_valid;

    assign o_dst_rob    = sdffs_valid ? sdffs_dst_rob : 'b0;
    assign o_fid        = sdffs_valid ? sdffs_fid     : 'b0;
    assign o_result     = sdffs_valid ? sdffs_result  : 'b0;

    assign o_cmtdelay   = 'b0;

    //

endmodule
