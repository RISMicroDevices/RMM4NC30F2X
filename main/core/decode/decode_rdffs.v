//`define         DECODE_REG_N_RENAME_DFFS_ENABLED

module decode_rdffs (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire            bco_valid,

    //
    input   wire [31:0]     i_regfs_data0,
    input   wire [31:0]     i_regfs_data1,

    input   wire            i_rat_src0_valid,
    input   wire [3:0]      i_rat_src0_rob,

    input   wire            i_rat_src1_valid,
    input   wire [3:0]      i_rat_src1_rob,

    //
    output  wire [31:0]     o_regfs_data0,
    output  wire [31:0]     o_regfs_data1,

    output  wire            o_rat_src0_valid,
    output  wire [3:0]      o_rat_src0_rob,

    output  wire            o_rat_src1_valid,
    output  wire [3:0]      o_rat_src1_rob
);

`ifdef DECODE_REG_N_RENAME_DFFS_ENABLED
    //
    reg  [31:0] regfs_data0_R;
    reg  [31:0] regfs_data1_R;

    reg         rat_src0_valid_R;
    reg  [3:0]  rat_src0_rob_R;

    reg         rat_src1_valid_R;
    reg  [3:0]  rat_src1_rob_R;

    always @(posedge clk) begin

        regfs_data0_R       <= i_regfs_data0;
        regfs_data1_R       <= i_regfs_data1;

        rat_src0_valid_R    <= i_rat_src0_valid;
        rat_src0_rob_R      <= i_rat_src0_rob;

        rat_src1_valid_R    <= i_rat_src1_valid;
        rat_src1_rob_R      <= i_rat_src1_rob;
    end

    //
    assign o_regfs_data0    = regfs_data0_R;
    assign o_regfs_data1    = regfs_data1_R;

    assign o_rat_src0_valid = rat_src0_valid_R;
    assign o_rat_src0_rob   = rat_src0_rob_R;

    assign o_rat_src1_valid = rat_src1_valid_R;
    assign o_rat_src1_rob   = rat_src1_rob_R;

`else
    //
    assign o_regfs_data0    = i_regfs_data0;
    assign o_regfs_data1    = i_regfs_data1;

    assign o_rat_src0_valid = i_rat_src0_valid;
    assign o_rat_src0_rob   = i_rat_src0_rob;

    assign o_rat_src1_valid = i_rat_src1_valid;
    assign o_rat_src1_rob   = i_rat_src1_rob;

`endif

endmodule
