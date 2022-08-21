//`define         DECODE_IREGDFFS_ENABLED

module decode_iregdffs (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire            bco_valid,

    //
    input   wire            i_issue_valid,
    input   wire [31:0]     i_issue_pc,

    input   wire [3:0]      i_issue_rob,

    input   wire [25:0]     i_issue_imm,

    input   wire [7:0]      i_issue_fid,

    input   wire            i_issue_branch,
    input   wire            i_issue_load,
    input   wire            i_issue_store,

    input   wire            i_issue_pipe_alu,
    input   wire            i_issue_pipe_mul,
    input   wire            i_issue_pipe_mem,
    input   wire            i_issue_pipe_bru,

    input   wire [4:0]      i_issue_alu_cmd,
    input   wire [0:0]      i_issue_mul_cmd,
    input   wire [4:0]      i_issue_mem_cmd,
    input   wire [6:0]      i_issue_bru_cmd,
    input   wire [1:0]      i_issue_bagu_cmd,

    //
    output  wire            o_issue_valid,
    output  wire [31:0]     o_issue_pc,

    output  wire [3:0]      o_issue_rob,

    output  wire [25:0]     o_issue_imm,

    output  wire [7:0]      o_issue_fid,

    output  wire            o_issue_branch,
    output  wire            o_issue_load,
    output  wire            o_issue_store,

    output  wire            o_issue_pipe_alu,
    output  wire            o_issue_pipe_mul,
    output  wire            o_issue_pipe_mem,
    output  wire            o_issue_pipe_bru,

    output  wire [4:0]      o_issue_alu_cmd,
    output  wire [0:0]      o_issue_mul_cmd,
    output  wire [4:0]      o_issue_mem_cmd,
    output  wire [6:0]      o_issue_bru_cmd,
    output  wire [1:0]      o_issue_bagu_cmd
);

`ifdef DECODE_IREGDFFS_ENABLED
    //
    reg         issue_valid_R;
    reg  [31:0] issue_pc_R;
    
    reg  [3:0]  issue_rob_R;

    reg  [25:0] issue_imm_R;

    reg  [7:0]  issue_fid_R;

    reg         issue_branch_R;
    reg         issue_load_R;
    reg         issue_store_R;

    reg         issue_pipe_alu_R;
    reg         issue_pipe_mul_R;
    reg         issue_pipe_mem_R;
    reg         issue_pipe_bru_R;

    reg  [4:0]  issue_alu_cmd_R;
    reg  [0:0]  issue_mul_cmd_R;
    reg  [4:0]  issue_mem_cmd_R;
    reg  [6:0]  issue_bru_cmd_R;
    reg  [1:0]  issue_bagu_cmd_R;

    always @(posedge clk) begin

        if (~resetn) begin
            issue_valid_R <= 'b0;
        end
        else if (snoop_hit) begin
            issue_valid_R <= 'b0;
        end
        else if (bco_valid) begin
            issue_valid_R <= 'b0;
        end
        else begin
            issue_valid_R <= i_issue_valid;
        end

        issue_pc_R          <= i_issue_pc;

        issue_rob_R         <= i_issue_rob;

        issue_imm_R         <= i_issue_imm;

        issue_fid_R         <= i_issue_fid;

        issue_branch_R      <= i_issue_branch;
        issue_load_R        <= i_issue_load;
        issue_store_R       <= i_issue_store;

        issue_pipe_alu_R    <= i_issue_pipe_alu;
        issue_pipe_mul_R    <= i_issue_pipe_mul;
        issue_pipe_mem_R    <= i_issue_pipe_mem;
        issue_pipe_bru_R    <= i_issue_pipe_bru;

        issue_alu_cmd_R     <= i_issue_alu_cmd;
        issue_mul_cmd_R     <= i_issue_mul_cmd;
        issue_mem_cmd_R     <= i_issue_mem_cmd;
        issue_bru_cmd_R     <= i_issue_bru_cmd;
        issue_bagu_cmd_R    <= i_issue_bagu_cmd;

    end

    //
    assign o_issue_valid    = issue_valid_R;
    assign o_issue_pc       = issue_pc_R;

    assign o_issue_rob      = issue_rob_R;

    assign o_issue_imm      = issue_imm_R;

    assign o_issue_fid      = issue_fid_R;

    assign o_issue_branch   = issue_branch_R;
    assign o_issue_load     = issue_load_R;
    assign o_issue_store    = issue_store_R;

    assign o_issue_pipe_alu = issue_pipe_alu_R;
    assign o_issue_pipe_mul = issue_pipe_mul_R;
    assign o_issue_pipe_mem = issue_pipe_mem_R;
    assign o_issue_pipe_bru = issue_pipe_bru_R;

    assign o_issue_alu_cmd  = issue_alu_cmd_R;
    assign o_issue_mul_cmd  = issue_mul_cmd_R;
    assign o_issue_mem_cmd  = issue_mem_cmd_R;
    assign o_issue_bru_cmd  = issue_bru_cmd_R;
    assign o_issue_bagu_cmd = issue_bagu_cmd_R;

    //

`else
    //
    assign o_issue_valid    = i_issue_valid;
    assign o_issue_pc       = i_issue_pc;

    assign o_issue_rob      = i_issue_rob;

    assign o_issue_imm      = i_issue_imm;

    assign o_issue_fid      = i_issue_fid;

    assign o_issue_branch   = i_issue_branch;
    assign o_issue_load     = i_issue_load;
    assign o_issue_store    = i_issue_store;

    assign o_issue_pipe_alu = i_issue_pipe_alu;
    assign o_issue_pipe_mul = i_issue_pipe_mul;
    assign o_issue_pipe_mem = i_issue_pipe_mem;
    assign o_issue_pipe_bru = i_issue_pipe_bru;

    assign o_issue_alu_cmd  = i_issue_alu_cmd;
    assign o_issue_mul_cmd  = i_issue_mul_cmd;
    assign o_issue_mem_cmd  = i_issue_mem_cmd;
    assign o_issue_bru_cmd  = i_issue_bru_cmd;
    assign o_issue_bagu_cmd = i_issue_bagu_cmd;

`endif

endmodule
