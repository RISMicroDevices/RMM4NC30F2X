
module execute (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire            bco_valid,

    // LoadBuffer state query
    output  wire [31:0]     s_qaddr,
    input   wire            s_busy,

    // StoreBuffer state
    output  wire            s_o_busy_uncached,

    //
    input   wire [1:0]      i_bp_pattern,
    input   wire            i_bp_taken,
    input   wire            i_bp_hit,
    input   wire [31:0]     i_bp_target,

    //
    input   wire            i_mem_commit_en_store,

    output  wire            o_mem_commit_readyn,

    //
    input   wire            i_mem_wbmem_en,

    output  wire            o_mem_wbmem_valid,
    output  wire [31:0]     o_mem_wbmem_addr,
    output  wire [3:0]      o_mem_wbmem_strb,
    output  wire [1:0]      o_mem_wbmem_lswidth,
    output  wire [31:0]     o_mem_wbmem_data,
    output  wire            o_mem_wbmem_uncached,

    //
    input   wire            i_dcache_update_tag_en,
    input   wire [31:0]     i_dcache_update_tag_addr,
    input   wire            i_dcache_update_tag_valid,

    input   wire            i_dcache_update_data_valid,
    input   wire [31:0]     i_dcache_update_data_addr,
    input   wire [3:0]      i_dcache_update_data_strb,
    input   wire [31:0]     i_dcache_update_data,

    output  wire            o_dcache_update_data_ready,

    //
    input   wire            i_valid,

    input   wire [31:0]     i_pc,

    input   wire [31:0]     i_src0_value,
    input   wire [31:0]     i_src1_value,

    input   wire [3:0]      i_dst_rob,

    input   wire [25:0]     i_imm,

    input   wire [7:0]      i_fid,

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
    output  wire            o_bco_valid,
    output  wire [31:0]     o_bco_pc,
    output  wire [1:0]      o_bco_oldpattern,
    output  wire            o_bco_taken,
    output  wire [31:0]     o_bco_target,

    //
    output  wire [31:0]     o_forward_alu_value,

    //
    output  wire            o_valid,
    output  wire [3:0]      o_dst_rob,
    output  wire [7:0]      o_fid,

    output  wire [31:0]     o_result,
    output  wire [3:0]      o_cmtdelay,
    output  wire            o_lsmiss
);

    //
    wire        alu_valid;
    wire [3:0]  alu_dst_rob;
    wire [7:0]  alu_fid;

    wire [31:0] alu_result;
    wire [3:0]  alu_cmtdelay;

    execute_alu execute_alu_INST (
        .clk            (clk),
        .resetn         (resetn),

        //
        .i_valid        (i_valid & i_pipe_alu),

        .i_src0_value   (i_src0_value),
        .i_src1_value   (i_src1_value),

        .i_dst_rob      (i_dst_rob),

        .i_imm          (i_imm),

        .i_fid          (i_fid),

        .i_alu_cmd      (i_alu_cmd),

        //
        .o_valid        (alu_valid),
        .o_dst_rob      (alu_dst_rob),
        .o_fid          (alu_fid),

        .o_result       (alu_result),
        .o_cmtdelay     (alu_cmtdelay),

        .o_forward_value(o_forward_alu_value)
    );


    //
    wire        bru_valid;
    wire [3:0]  bru_dst_rob;
    wire [7:0]  bru_fid;

    wire [31:0] bru_result;
    wire [3:0]  bru_cmtdelay;

    execute_bru execute_bru_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .i_bp_pattern       (i_bp_pattern),
        .i_bp_taken         (i_bp_taken),
        .i_bp_hit           (i_bp_hit),
        .i_bp_target        (i_bp_target),

        //
        .i_valid            (i_valid & i_pipe_bru),

        .i_pc               (i_pc),

        .i_src0_value       (i_src0_value),
        .i_src1_value       (i_src1_value),

        .i_dst_rob          (i_dst_rob),

        .i_imm              (i_imm),

        .i_fid              (i_fid),

        .i_bru_cmd          (i_bru_cmd),
        .i_bagu_cmd         (i_bagu_cmd),

        //
        .o_valid            (bru_valid),
        .o_dst_rob          (bru_dst_rob),
        .o_fid              (bru_fid),

        .o_result           (bru_result),
        .o_cmtdelay         (bru_cmtdelay),

        //
        .o_bco_valid        (o_bco_valid),
        .o_bco_pc           (o_bco_pc),
        .o_bco_oldpattern   (o_bco_oldpattern),
        .o_bco_taken        (o_bco_taken),
        .o_bco_target       (o_bco_target)
    );


    //
    wire        mul_valid;
    wire [3:0]  mul_dst_rob;
    wire [7:0]  mul_fid;
    
    wire [31:0] mul_result;
    wire [3:0]  mul_cmtdelay;

    execute_mul execute_mul_INST (
        .clk            (clk),
        .resetn         (resetn),

        //
        .i_valid        (i_valid & i_pipe_mul),

        .i_src0_value   (i_src0_value),
        .i_src1_value   (i_src1_value),
        
        .i_dst_rob      (i_dst_rob),

        .i_fid          (i_fid),

        .i_mul_cmd      (i_mul_cmd),

        //
        .o_valid        (mul_valid),
        .o_dst_rob      (mul_dst_rob),
        .o_fid          (mul_fid),

        .o_result       (mul_result),
        .o_cmtdelay     (mul_cmtdelay)
    );


    //
    wire        mem_valid;
    wire [3:0]  mem_dst_rob;
    wire [7:0]  mem_fid;

    wire [31:0] mem_result;
    wire [3:0]  mem_cmtdelay;
    wire        mem_lsmiss;

    execute_mem execute_mem_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .bco_valid          (bco_valid),

        //
        .s_qaddr            (s_qaddr),
        .s_busy             (s_busy),

        .s_o_busy_uncached  (s_o_busy_uncached),

        //
        .i_commit_en_store  (i_mem_commit_en_store),

        .o_commit_readyn    (o_mem_commit_readyn),

        //
        .i_wbmem_en         (i_mem_wbmem_en),
        
        .o_wbmem_valid      (o_mem_wbmem_valid),
        .o_wbmem_addr       (o_mem_wbmem_addr),
        .o_wbmem_strb       (o_mem_wbmem_strb),
        .o_wbmem_lswidth    (o_mem_wbmem_lswidth),
        .o_wbmem_data       (o_mem_wbmem_data),
        .o_wbmem_uncached   (o_mem_wbmem_uncached),

        //
        .i_update_tag_en    (i_dcache_update_tag_en),
        .i_update_tag_addr  (i_dcache_update_tag_addr),
        .i_update_tag_valid (i_dcache_update_tag_valid),

        .i_update_data_valid(i_dcache_update_data_valid),
        .i_update_data_addr (i_dcache_update_data_addr),
        .i_update_data_strb (i_dcache_update_data_strb),
        .i_update_data      (i_dcache_update_data),

        .o_update_data_ready(o_dcache_update_data_ready),

        //
        .i_valid            (i_valid & i_pipe_mem),

        .i_src0_value       (i_src0_value),
        .i_src1_value       (i_src1_value),

        .i_dst_rob          (i_dst_rob),
        
        .i_imm              (i_imm),

        .i_fid              (i_fid),

        .i_mem_cmd          (i_mem_cmd),

        //
        .o_valid            (mem_valid),
        .o_dst_rob          (mem_dst_rob),
        .o_fid              (mem_fid),

        .o_result           (mem_result),
        .o_cmtdelay         (mem_cmtdelay),
        .o_lsmiss           (mem_lsmiss)
    );

    //
    assign o_valid      = alu_valid     | bru_valid     | mul_valid     | mem_valid;
    assign o_dst_rob    = alu_dst_rob   | bru_dst_rob   | mul_dst_rob   | mem_dst_rob;
    assign o_fid        = alu_fid       | bru_fid       | mul_fid       | mem_fid;

    assign o_result     = alu_result    | bru_result    | mul_result    | mem_result;
    assign o_cmtdelay   = alu_cmtdelay  | bru_cmtdelay  | mul_cmtdelay  | mem_cmtdelay;

    assign o_lsmiss     = mem_lsmiss;

    //

endmodule
