
module execute_mem_odffs (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            i_valid,
    input   wire [3:0]      i_dst_rob,
    input   wire [7:0]      i_fid,

    input   wire [31:0]     i_result,
    input   wire [3:0]      i_cmtdelay,
    input   wire            i_lsmiss,

    //
    output  wire            o_valid,
    output  wire [3:0]      o_dst_rob,
    output  wire [7:0]      o_fid,

    output  wire [31:0]     o_result,
    output  wire [3:0]      o_cmtdelay,
    output  wire            o_lsmiss
);

    //
    reg         valid_R;
    reg [3:0]   dst_rob_R;
    reg [7:0]   fid_R;

    reg [31:0]  result_R;
    reg [3:0]   cmtdelay_R;
    reg         lsmiss_R;

    always @(posedge clk) begin

        if (~resetn) begin
            valid_R <= 'b0;
        end
        else begin
            valid_R <= i_valid;
        end

        dst_rob_R   <= i_dst_rob;
        fid_R       <= i_fid;

        result_R    <= i_result;
        cmtdelay_R  <= i_cmtdelay;
        lsmiss_R    <= i_lsmiss;
    end

    //
    assign o_valid      = valid_R;
    assign o_dst_rob    = dst_rob_R;
    assign o_fid        = fid_R;

    assign o_result     = result_R;
    assign o_cmtdelay   = cmtdelay_R;
    assign o_lsmiss     = lsmiss_R;

    //

endmodule
