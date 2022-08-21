
module dispatch_idffs (
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
    input   wire            i_pipe_bru,
    input   wire            i_pipe_mul,
    input   wire            i_pipe_mem,

    input   wire [4:0]      i_alu_cmd,
    input   wire [0:0]      i_mul_cmd,
    input   wire [4:0]      i_mem_cmd,
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
    output  wire            o_src0_forward_alu,

    output  wire [31:0]     o_src1_value,
    output  wire            o_src1_forward_alu,

    output  wire [3:0]      o_dst_rob,

    output  wire [25:0]     o_imm,

    output  wire [7:0]      o_fid,

    output  wire            o_pipe_alu,
    output  wire            o_pipe_bru,
    output  wire            o_pipe_mul,
    output  wire            o_pipe_mem,

    output  wire [4:0]      o_alu_cmd,
    output  wire [0:0]      o_mul_cmd,
    output  wire [4:0]      o_mem_cmd,
    output  wire [6:0]      o_bru_cmd,
    output  wire [1:0]      o_bagu_cmd
);

    //
    reg  [1:0]  bp_pattern_R;
    reg         bp_taken_R;
    reg         bp_hit_R;
    reg  [31:0] bp_target_R;

    always @(posedge clk) begin

        bp_pattern_R    <= i_bp_pattern;
        bp_taken_R      <= i_bp_taken;
        bp_hit_R        <= i_bp_hit;
        bp_target_R     <= i_bp_target;
    end


    //
    reg         valid_R;

    reg  [31:0] pc_R;

    reg  [31:0] src0_value_R;
    reg         src0_forward_alu_R;

    reg  [31:0] src1_value_R;
    reg         src1_forward_alu_R;

    reg  [3:0]  dst_rob_R;

    reg  [7:0]  fid_R;

    reg  [25:0] imm_R;

    reg         pipe_alu_R;
    reg         pipe_bru_R;
    reg         pipe_mul_R;
    reg         pipe_mem_R;

    reg  [4:0]  alu_cmd_R;
    reg  [0:0]  mul_cmd_R;
    reg  [4:0]  mem_cmd_R;
    reg  [6:0]  bru_cmd_R;
    reg  [1:0]  bagu_cmd_R;

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

        pc_R                <= i_pc;

        src0_value_R        <= i_src0_value;
        src0_forward_alu_R  <= i_src0_forward_alu;

        src1_value_R        <= i_src1_value;
        src1_forward_alu_R  <= i_src1_forward_alu;

        dst_rob_R           <= i_dst_rob;

        imm_R               <= i_imm;

        fid_R               <= i_fid;

        pipe_alu_R          <= i_pipe_alu;
        pipe_bru_R          <= i_pipe_bru;
        pipe_mul_R          <= i_pipe_mul;
        pipe_mem_R          <= i_pipe_mem;

        alu_cmd_R           <= i_alu_cmd;
        mul_cmd_R           <= i_mul_cmd;
        mem_cmd_R           <= i_mem_cmd;
        bru_cmd_R           <= i_bru_cmd;
        bagu_cmd_R          <= i_bagu_cmd;
    end


    //
    assign o_bp_pattern         = bp_pattern_R;
    assign o_bp_taken           = bp_taken_R;
    assign o_bp_hit             = bp_hit_R;
    assign o_bp_target          = bp_target_R;

    //
    assign o_valid              = valid_R;

    assign o_pc                 = pc_R;

    assign o_src0_value         = src0_value_R;
    assign o_src0_forward_alu   = src0_forward_alu_R;

    assign o_src1_value         = src1_value_R;
    assign o_src1_forward_alu   = src1_forward_alu_R;

    assign o_dst_rob            = dst_rob_R;

    assign o_imm                = imm_R;

    assign o_fid                = fid_R;

    assign o_pipe_alu           = pipe_alu_R;
    assign o_pipe_bru           = pipe_bru_R;
    assign o_pipe_mul           = pipe_mul_R;
    assign o_pipe_mem           = pipe_mem_R;

    assign o_alu_cmd            = alu_cmd_R;
    assign o_mul_cmd            = mul_cmd_R;
    assign o_mem_cmd            = mem_cmd_R;
    assign o_bru_cmd            = bru_cmd_R;
    assign o_bagu_cmd           = bagu_cmd_R;

    //

endmodule
