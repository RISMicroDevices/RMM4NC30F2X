
module execute_mem_idffs (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            bco_valid,

    //
    input   wire            i_valid,

    input   wire [31:0]     i_src0_value,
    input   wire [31:0]     i_src1_value,

    input   wire [3:0]      i_dst_rob,

    input   wire [25:0]     i_imm,

    input   wire [7:0]      i_fid,

    input   wire [4:0]      i_mem_cmd,

    //
    output  wire            o_valid,

    output  wire [31:0]     o_src0_value,
    output  wire [31:0]     o_src1_value,

    output  wire [3:0]      o_dst_rob,

    output  wire [25:0]     o_imm,

    output  wire [7:0]      o_fid,

    output  wire [4:0]      o_mem_cmd
);

    //
    reg         valid_R;

    reg [31:0]  src0_value_R;
    reg [31:0]  src1_value_R;

    reg [3:0]   dst_rob_R;

    reg [25:0]  imm_R;

    reg [7:0]   fid_R;

    reg [4:0]   mem_cmd_R;

    always @(posedge clk) begin

        if (~resetn) begin
            valid_R <= 'b0;
        end
        else if (bco_valid) begin
            valid_R <= 'b0;
        end
        else begin
            valid_R <= i_valid;
        end

        src0_value_R    <= i_src0_value;
        src1_value_R    <= i_src1_value;

        dst_rob_R       <= i_dst_rob;

        imm_R           <= i_imm;

        fid_R           <= i_fid;

        mem_cmd_R       <= i_mem_cmd;
    end

    //
    assign o_valid      = valid_R;
    
    assign o_src0_value = src0_value_R;
    assign o_src1_value = src1_value_R;

    assign o_dst_rob    = dst_rob_R;

    assign o_imm        = imm_R;

    assign o_fid        = fid_R;
    
    assign o_mem_cmd    = mem_cmd_R;

    //

endmodule
