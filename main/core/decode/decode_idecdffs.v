`define             DECODE_IDECDFFS_ENABLED

module decode_idecdffs (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire            bco_valid,

    //
    input   wire [31:0]     i_pc,

    input   wire [4:0]      i_src0,
    input   wire [4:0]      i_src1,
    input   wire [4:0]      i_dst,

    input   wire [25:0]     i_imm,

    input   wire [7:0]      i_fid,

    input   wire            i_branch,
    input   wire            i_load,
    input   wire            i_store,
    input   wire [1:0]      i_lswidth,

    input   wire            i_pipe_alu,
    input   wire            i_pipe_mul,
    input   wire            i_pipe_mem,
    input   wire            i_pipe_bru,

    input   wire [4:0]      i_alu_cmd,
    input   wire [0:0]      i_mul_cmd,
    input   wire [4:0]      i_mem_cmd,
    input   wire [6:0]      i_bru_cmd,
    input   wire [1:0]      i_bagu_cmd,

    input   wire [1:0]      i_bp_pattern,
    input   wire            i_bp_taken,
    input   wire            i_bp_hit,
    input   wire [31:0]     i_bp_target,

    input   wire            i_next_wen,

    //
    output  wire [31:0]     o_pc,

    output  wire [4:0]      o_src0,
    output  wire [4:0]      o_src1,
    output  wire [4:0]      o_dst,

    output  wire [25:0]     o_imm,

    output  wire [7:0]      o_fid,

    output  wire            o_branch,
    output  wire            o_load,
    output  wire            o_store,
    output  wire [1:0]      o_lswidth,

    output  wire            o_pipe_alu,
    output  wire            o_pipe_mul,
    output  wire            o_pipe_mem,
    output  wire            o_pipe_bru,

    output  wire [4:0]      o_alu_cmd,
    output  wire [0:0]      o_mul_cmd,
    output  wire [4:0]      o_mem_cmd,
    output  wire [6:0]      o_bru_cmd,
    output  wire [1:0]      o_bagu_cmd,

    output  wire [1:0]      o_bp_pattern,
    output  wire            o_bp_taken,
    output  wire            o_bp_hit,
    output  wire [31:0]     o_bp_target,

    output  wire            o_next_wen
);

`ifdef DECODE_IDECDFFS_ENABLED
    //
    reg  [31:0] pc_OR;

    reg  [4:0]  src0_OR;
    reg  [4:0]  src1_OR;
    reg  [4:0]  dst_OR;

    reg  [25:0] imm_OR;

    reg  [7:0]  fid_OR;

    reg         branch_OR;
    reg         load_OR;
    reg         store_OR;
    reg  [1:0]  lswidth_OR;

    reg         pipe_alu_OR;
    reg         pipe_mul_OR;
    reg         pipe_mem_OR;
    reg         pipe_bru_OR;

    reg  [4:0]  alu_cmd_OR;
    reg  [0:0]  mul_cmd_OR;
    reg  [4:0]  mem_cmd_OR;
    reg  [6:0]  bru_cmd_OR;
    reg  [1:0]  bagu_cmd_OR;

    reg  [1:0]  bp_pattern_OR;
    reg         bp_taken_OR;
    reg         bp_hit_OR;
    reg  [31:0] bp_target_OR;

    reg         next_wen_OR;

    always @(posedge clk) begin

        //
        if (~resetn) begin
            next_wen_OR <= 'b0;
        end
        else if (snoop_hit) begin
            next_wen_OR <= 'b0;
        end
        else if (bco_valid) begin
            next_wen_OR <= 'b0;
        end
        else begin
            next_wen_OR <= i_next_wen;
        end

        //
        pc_OR           <= i_pc;

        src0_OR         <= i_src0;
        src1_OR         <= i_src1;
        dst_OR          <= i_dst;

        imm_OR          <= i_imm;

        fid_OR          <= i_fid;

        branch_OR       <= i_branch;
        load_OR         <= i_load;
        store_OR        <= i_store;
        lswidth_OR      <= i_lswidth;

        pipe_alu_OR     <= i_pipe_alu;
        pipe_mul_OR     <= i_pipe_mul;
        pipe_mem_OR     <= i_pipe_mem;
        pipe_bru_OR     <= i_pipe_bru;

        alu_cmd_OR      <= i_alu_cmd;
        mul_cmd_OR      <= i_mul_cmd;
        mem_cmd_OR      <= i_mem_cmd;
        bru_cmd_OR      <= i_bru_cmd;
        bagu_cmd_OR     <= i_bagu_cmd;

        bp_pattern_OR   <= i_bp_pattern;
        bp_taken_OR     <= i_bp_taken;
        bp_hit_OR       <= i_bp_hit;
        bp_target_OR    <= i_bp_target;
    end

    //
    assign o_pc         = pc_OR;

    assign o_src0       = src0_OR;
    assign o_src1       = src1_OR;
    assign o_dst        = dst_OR;

    assign o_imm        = imm_OR;

    assign o_fid        = fid_OR;

    assign o_branch     = branch_OR;
    assign o_load       = load_OR;
    assign o_store      = store_OR;
    assign o_lswidth    = lswidth_OR;

    assign o_pipe_alu   = pipe_alu_OR;
    assign o_pipe_mul   = pipe_mul_OR;
    assign o_pipe_mem   = pipe_mem_OR;
    assign o_pipe_bru   = pipe_bru_OR;

    assign o_alu_cmd    = alu_cmd_OR;
    assign o_mul_cmd    = mul_cmd_OR;
    assign o_mem_cmd    = mem_cmd_OR;
    assign o_bru_cmd    = bru_cmd_OR;
    assign o_bagu_cmd   = bagu_cmd_OR;

    assign o_bp_pattern = bp_pattern_OR;
    assign o_bp_taken   = bp_taken_OR;
    assign o_bp_hit     = bp_hit_OR;
    assign o_bp_target  = bp_target_OR;
    assign o_next_wen   = next_wen_OR;

`else
    //
    assign o_pc         = i_pc;

    assign o_src0       = i_src0;
    assign o_src1       = i_src1;
    assign o_dst        = i_dst;

    assign o_imm        = i_imm;

    assign o_fid        = i_fid;
    
    assign o_branch     = i_branch;
    assign o_load       = i_load;
    assign o_store      = i_store;
    assign o_lswidth    = i_lswidth;

    assign o_pipe_alu   = i_pipe_alu;
    assign o_pipe_mul   = i_pipe_mul;
    assign o_pipe_mem   = i_pipe_mem;
    assign o_pipe_bru   = i_pipe_bru;

    assign o_alu_cmd    = i_alu_cmd;
    assign o_mul_cmd    = i_mul_cmd;
    assign o_mem_cmd    = i_mem_cmd;
    assign o_bru_cmd    = i_bru_cmd;
    assign o_bagu_cmd   = i_bagu_cmd;

    assign o_bp_pattern = i_bp_pattern;
    assign o_bp_taken   = i_bp_taken;
    assign o_bp_hit     = i_bp_hit;
    assign o_bp_target  = i_bp_target;
    
    assign o_next_wen   = i_next_wen;

`endif

endmodule
