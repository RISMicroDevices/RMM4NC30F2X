
module execute_bru_idffs (
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

    output  wire [6:0]      o_bru_cmd,
    output  wire [1:0]      o_bagu_cmd
);

    //
    reg [1:0]   bp_pattern_R;
    reg         bp_taken_R;
    reg         bp_hit_R;
    reg [31:0]  bp_target_R;

    always @(posedge clk) begin

        bp_pattern_R<= i_bp_pattern;
        bp_taken_R  <= i_bp_taken;
        bp_hit_R    <= i_bp_hit;
        bp_target_R <= i_bp_target;
    end

    //
    reg         valid_R;

    reg [31:0]  pc_R;

    reg [31:0]  src0_value_R;
    reg [31:0]  src1_value_R;

    reg [3:0]   dst_rob_R;

    reg [25:0]  imm_R;

    reg [7:0]   fid_R;

    reg [6:0]   bru_cmd_R;
    reg [1:0]   bagu_cmd_R;

    always @(posedge clk) begin

        if (~resetn) begin
            valid_R <= 'b0;
        end
        else begin
            valid_R <= i_valid;
        end

        pc_R            <= i_pc;

        src0_value_R    <= i_src0_value;
        src1_value_R    <= i_src1_value;

        dst_rob_R       <= i_dst_rob;

        imm_R           <= i_imm;

        fid_R           <= i_fid;

        bru_cmd_R       <= i_bru_cmd;
        bagu_cmd_R      <= i_bagu_cmd;
    end

    //
    assign o_bp_pattern = bp_pattern_R;
    assign o_bp_taken   = bp_taken_R;
    assign o_bp_hit     = bp_hit_R;
    assign o_bp_target  = bp_target_R;

    //
    assign o_valid      = valid_R;

    assign o_pc         = pc_R;

    assign o_src0_value = src0_value_R;
    assign o_src1_value = src1_value_R;

    assign o_dst_rob    = dst_rob_R;

    assign o_imm        = imm_R;

    assign o_fid        = fid_R;

    assign o_bru_cmd    = bru_cmd_R;
    assign o_bagu_cmd   = bagu_cmd_R;

    //

endmodule
