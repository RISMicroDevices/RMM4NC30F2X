`define     ENABLE_WRITEBACK_DFF

module issue_idffs (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire            bco_valid,

    //
    input   wire [1:0]      i_bp_pattern,
    input   wire            i_bp_taken,
    input   wire            i_bp_hit,
    input   wire [31:0]     i_bp_target,

    //
    input   wire            i_wb_en,
    input   wire [3:0]      i_wb_dst_rob,
    input   wire [31:0]     i_wb_value,
    input   wire            i_wb_lsmiss,
    
    // From Decode Stage
    input   wire            i_valid,

    input   wire [31:0]     i_pc,

    input   wire [3:0]      i_src0_rob,
    input   wire            i_src0_rdy,
    input   wire [31:0]     i_src0_value,

    input   wire [3:0]      i_src1_rob,
    input   wire            i_src1_rdy,
    input   wire [31:0]     i_src1_value,

    input   wire [3:0]      i_dst_rob,

    input   wire [25:0]     i_imm,

    input   wire [7:0]      i_fid,

    input   wire            i_branch,
    input   wire            i_load,
    input   wire            i_store,

    input   wire            i_pipe_alu,
    input   wire            i_pipe_mul,
    input   wire            i_pipe_mem,
    input   wire            i_pipe_bru,

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
    output  wire            o_wb_en,
    output  wire [3:0]      o_wb_dst_rob,
    output  wire [31:0]     o_wb_value,
    output  wire            o_wb_lsmiss,

    //
    output  wire            o_valid,

    output  wire [31:0]     o_pc,

    output  wire [3:0]      o_src0_rob,
    output  wire            o_src0_rdy,
    output  wire [31:0]     o_src0_value,

    output  wire [3:0]      o_src1_rob,
    output  wire            o_src1_rdy,
    output  wire [31:0]     o_src1_value,

    output  wire [3:0]      o_dst_rob,

    output  wire [25:0]     o_imm,

    output  wire [7:0]      o_fid,

    output  wire            o_branch,
    output  wire            o_load,
    output  wire            o_store,

    output  wire            o_pipe_alu,
    output  wire            o_pipe_mul,
    output  wire            o_pipe_mem,
    output  wire            o_pipe_bru,

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

    reg  [31:0] pc_R;

    reg         valid_R;

    reg  [3:0]  src0_rob_R;
    reg         src0_rdy_R;
    reg  [31:0] src0_value_R;

    reg  [3:0]  src1_rob_R;
    reg         src1_rdy_R;
    reg  [31:0] src1_value_R;

    reg  [3:0]  dst_rob_R;

    reg  [25:0] imm_R;

    reg  [7:0]  fid_R;

    reg         branch_R;
    reg         load_R;
    reg         store_R;

    reg         pipe_alu_R;
    reg         pipe_mul_R;
    reg         pipe_mem_R;
    reg         pipe_bru_R;

    reg  [4:0]  alu_cmd_R;
    reg  [0:0]  mul_cmd_R;
    reg  [4:0]  mem_cmd_R;
    reg  [6:0]  bru_cmd_R;
    reg  [1:0]  bagu_cmd_R;

    always @(posedge clk) begin

        if (~resetn) begin
            valid_R         <= 'b0;
        end
        else begin

            if (snoop_hit) begin
                valid_R <= 'b0;
            end
            else if (bco_valid) begin
                valid_R <= 'b0;
            end
            else begin
                valid_R <= i_valid;
            end
        end

        bp_pattern_R    <= i_bp_pattern;
        bp_taken_R      <= i_bp_taken;
        bp_hit_R        <= i_bp_hit;
        bp_target_R     <= i_bp_target;

        pc_R            <= i_pc;

        src0_rob_R      <= i_src0_rob;
        src0_rdy_R      <= i_src0_rdy;
        src0_value_R    <= i_src0_value;

        src1_rob_R      <= i_src1_rob;
        src1_rdy_R      <= i_src1_rdy;
        src1_value_R    <= i_src1_value;

        dst_rob_R       <= i_dst_rob;

        imm_R           <= i_imm;

        fid_R           <= i_fid;

        branch_R        <= i_branch;
        load_R          <= i_load;
        store_R         <= i_store;

        pipe_alu_R      <= i_pipe_alu;
        pipe_mul_R      <= i_pipe_mul;
        pipe_mem_R      <= i_pipe_mem;
        pipe_bru_R      <= i_pipe_bru;
        
        alu_cmd_R       <= i_alu_cmd;
        mul_cmd_R       <= i_mul_cmd;
        mem_cmd_R       <= i_mem_cmd;
        bru_cmd_R       <= i_bru_cmd;
        bagu_cmd_R      <= i_bagu_cmd;
    end

    //
    assign o_bp_pattern     = bp_pattern_R;
    assign o_bp_taken       = bp_taken_R;
    assign o_bp_hit         = bp_hit_R;
    assign o_bp_target      = bp_target_R;

    //
    assign o_valid      = valid_R;

    assign o_pc         = pc_R;

    assign o_src0_rob   = src0_rob_R;
    assign o_src0_rdy   = src0_rdy_R;
    assign o_src0_value = src0_value_R;

    assign o_src1_rob   = src1_rob_R;
    assign o_src1_rdy   = src1_rdy_R;
    assign o_src1_value = src1_value_R;

    assign o_dst_rob    = dst_rob_R;

    assign o_imm        = imm_R;

    assign o_fid        = fid_R;

    assign o_branch     = branch_R;
    assign o_load       = load_R;
    assign o_store      = store_R;

    assign o_pipe_alu   = pipe_alu_R;
    assign o_pipe_mul   = pipe_mul_R;
    assign o_pipe_mem   = pipe_mem_R;
    assign o_pipe_bru   = pipe_bru_R;

    assign o_alu_cmd    = alu_cmd_R;
    assign o_mul_cmd    = mul_cmd_R;
    assign o_mem_cmd    = mem_cmd_R;
    assign o_bru_cmd    = bru_cmd_R;
    assign o_bagu_cmd   = bagu_cmd_R;

    //
`ifdef ENABLE_WRITEBACK_DFF
    
    reg         wb_en_R;
    reg [3:0]   wb_dst_rob_R;
    reg [31:0]  wb_value_R;
    reg         wb_lsmiss_R;

    always @(posedge clk) begin

        if (~resetn) begin
            wb_en_R <= 1'b0;
        end
        else begin
            wb_en_R <= i_wb_en;
        end

        wb_dst_rob_R    <= i_wb_dst_rob;
        wb_value_R      <= i_wb_value;
        wb_lsmiss_R     <= i_wb_lsmiss;
    end

    assign o_wb_en      = wb_en_R;
    assign o_wb_dst_rob = wb_dst_rob_R;
    assign o_wb_value   = wb_value_R;
    assign o_wb_lsmiss  = wb_lsmiss_R;
`else

    assign o_wb_en      = i_wb_en;
    assign o_wb_dst_rob = i_wb_dst_rob;
    assign o_wb_value   = i_wb_value;
    assign o_wb_lsmiss  = i_wb_lsmiss;
`endif

    //

endmodule
