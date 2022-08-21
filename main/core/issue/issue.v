
module issue (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    output  wire            readyn,

    // Branch commit
    input   wire            bco_valid,

    //
    input   wire [1:0]      bp_pattern,
    input   wire            bp_taken,
    input   wire            bp_hit,
    input   wire [31:0]     bp_target,

    // Writeback wake-up
    input   wire            wb_en,
    input   wire [3:0]      wb_dst_rob,
    input   wire [31:0]     wb_value,
    input   wire            wb_lsmiss,

    // No-Writeback wake-up
    input   wire            nowb_en,
    input   wire [3:0]      nowb_dst_rob,
    input   wire [31:0]     nowb_value,

    //
    input   wire            i_valid,

    input   wire [31:0]     i_pc,

    input   wire [3:0]      i_src0_rob,
    input   wire            i_src0_ready,
    input   wire [31:0]     i_src0_value,

    input   wire [3:0]      i_src1_rob,
    input   wire            i_src1_ready,
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
    output  wire            o_pipe_mul,
    output  wire            o_pipe_mem,
    output  wire            o_pipe_bru,

    output  wire [4:0]      o_alu_cmd,
    output  wire [0:0]      o_mul_cmd,
    output  wire [4:0]      o_mem_cmd,
    output  wire [6:0]      o_bru_cmd,
    output  wire [1:0]      o_bagu_cmd,

    //
    output  wire [1:0]      o_bp_pattern,
    output  wire            o_bp_taken,
    output  wire            o_bp_hit,
    output  wire [31:0]     o_bp_target
);

    //
    wire [1:0]  idffs_bp_pattern;
    wire        idffs_bp_taken;
    wire        idffs_bp_hit;
    wire [31:0] idffs_bp_target;

    wire        idffs_wb_en;
    wire [3:0]  idffs_wb_dst_rob;
    wire [31:0] idffs_wb_value;
    wire        idffs_wb_lsmiss;

    wire [31:0] idffs_pc;

    wire        idffs_valid;
    
    wire [3:0]  idffs_src0_rob;
    wire        idffs_src0_rdy;
    wire [31:0] idffs_src0_value;

    wire [3:0]  idffs_src1_rob;
    wire        idffs_src1_rdy;
    wire [31:0] idffs_src1_value;

    wire [3:0]  idffs_dst_rob;

    wire [25:0] idffs_imm;

    wire [7:0]  idffs_fid;

    wire        idffs_branch;
    wire        idffs_load;
    wire        idffs_store;

    wire        idffs_pipe_alu;
    wire        idffs_pipe_mul;
    wire        idffs_pipe_mem;
    wire        idffs_pipe_bru;

    wire [4:0]  idffs_alu_cmd;
    wire [0:0]  idffs_mul_cmd;
    wire [4:0]  idffs_mem_cmd;
    wire [6:0]  idffs_bru_cmd;
    wire [1:0]  idffs_bagu_cmd;

    issue_idffs issue_idffs_INST (
        .clk            (clk),
        .resetn         (resetn),

        .snoop_hit      (snoop_hit),

        .bco_valid      (bco_valid),

        //
        .i_bp_pattern   (bp_pattern),
        .i_bp_taken     (bp_taken),
        .i_bp_hit       (bp_hit),
        .i_bp_target    (bp_target),
        
        .i_wb_en        (wb_en),
        .i_wb_dst_rob   (wb_dst_rob),
        .i_wb_value     (wb_value),
        .i_wb_lsmiss    (wb_lsmiss),

        .i_pc           (i_pc),

        .i_valid        (i_valid),

        .i_src0_rob     (i_src0_rob),
        .i_src0_rdy     (i_src0_ready),
        .i_src0_value   (i_src0_value),

        .i_src1_rob     (i_src1_rob),
        .i_src1_rdy     (i_src1_ready),
        .i_src1_value   (i_src1_value),

        .i_dst_rob      (i_dst_rob),

        .i_imm          (i_imm),

        .i_fid          (i_fid),

        .i_branch       (i_branch),
        .i_load         (i_load),
        .i_store        (i_store),

        .i_pipe_alu     (i_pipe_alu),
        .i_pipe_mul     (i_pipe_mul),
        .i_pipe_mem     (i_pipe_mem),
        .i_pipe_bru     (i_pipe_bru),

        .i_alu_cmd      (i_alu_cmd),
        .i_mul_cmd      (i_mul_cmd),
        .i_mem_cmd      (i_mem_cmd),
        .i_bru_cmd      (i_bru_cmd),
        .i_bagu_cmd     (i_bagu_cmd),

        //
        .o_bp_pattern   (idffs_bp_pattern),
        .o_bp_taken     (idffs_bp_taken),
        .o_bp_hit       (idffs_bp_hit),
        .o_bp_target    (idffs_bp_target),

        .o_wb_en        (idffs_wb_en),
        .o_wb_dst_rob   (idffs_wb_dst_rob),
        .o_wb_value     (idffs_wb_value),
        .o_wb_lsmiss    (idffs_wb_lsmiss),

        .o_pc           (idffs_pc),

        .o_valid        (idffs_valid),
        
        .o_src0_rob     (idffs_src0_rob),
        .o_src0_rdy     (idffs_src0_rdy),
        .o_src0_value   (idffs_src0_value),

        .o_src1_rob     (idffs_src1_rob),
        .o_src1_rdy     (idffs_src1_rdy),
        .o_src1_value   (idffs_src1_value),

        .o_dst_rob      (idffs_dst_rob),

        .o_imm          (idffs_imm),

        .o_fid          (idffs_fid),

        .o_branch       (idffs_branch),
        .o_load         (idffs_load),
        .o_store        (idffs_store),

        .o_pipe_alu     (idffs_pipe_alu),
        .o_pipe_mul     (idffs_pipe_mul),
        .o_pipe_mem     (idffs_pipe_mem),
        .o_pipe_bru     (idffs_pipe_bru),

        .o_alu_cmd      (idffs_alu_cmd),
        .o_mul_cmd      (idffs_mul_cmd),
        .o_mem_cmd      (idffs_mem_cmd),
        .o_bru_cmd      (idffs_bru_cmd),
        .o_bagu_cmd     (idffs_bagu_cmd)
    );

    //
    wire        wht_src0_rdy;
    wire [31:0] wht_src0_value;

    wire        wht_src1_rdy;
    wire [31:0] wht_src1_value;
    
    issue_wht issue_wht_INST (
        .clk            (clk),
        .resetn         (resetn),

        //
        .wea            (idffs_wb_en & ~idffs_wb_lsmiss),
        .dina_rob       (idffs_wb_dst_rob),
        .dina_value     (idffs_wb_value),

        .web            (nowb_en),
        .dinb_rob       (nowb_dst_rob),
        .dinb_value     (nowb_value),

        //
        .qina_rdy       (idffs_src0_rdy),
        .qina_rob       (idffs_src0_rob),
        .qina_value     (idffs_src0_value),

        .qouta_rdy      (wht_src0_rdy),
        .qouta_value    (wht_src0_value),

        //
        .qinb_rdy       (idffs_src1_rdy),
        .qinb_rob       (idffs_src1_rob),
        .qinb_value     (idffs_src1_value),

        .qoutb_rdy      (wht_src1_rdy),
        .qoutb_value    (wht_src1_value)
    );

    //
    wire [8:0]  queue_fifo_pr;

    wire        alloc_next_wen;

    issue_alloc issue_alloc_INST (
        .clk            (clk),
        .resetn         (resetn),

        .snoop_hit      (snoop_hit),

        .fifo_pr        (queue_fifo_pr),

        .i_valid        (idffs_valid),

        .o_readyn       (readyn),

        .next_wen       (alloc_next_wen)
    );

    //
    wire [3:0]      queue_we;

    wire [3:0]      queue_valid;

    wire [127:0]    queue_pc;

    wire [15:0]     queue_src0_rob;
    wire [3:0]      queue_src0_rdy;
    wire [127:0]    queue_src0_value;

    wire [15:0]     queue_src1_rob;
    wire [3:0]      queue_src1_rdy;
    wire [127:0]    queue_src1_value;

    wire [15:0]     queue_dst_rob;

    wire [103:0]    queue_imm;

    wire [7:0]      queue_bp_pattern;
    wire [3:0]      queue_bp_taken;
    wire [3:0]      queue_bp_hit;
    wire [127:0]    queue_bp_target;

    wire [31:0]     queue_fid;

    wire [3:0]      queue_branch;
    wire [3:0]      queue_load;
    wire [3:0]      queue_store;

    wire [3:0]      queue_pipe_alu;
    wire [3:0]      queue_pipe_mul;
    wire [3:0]      queue_pipe_mem;
    wire [3:0]      queue_pipe_bru;

    wire [19:0]     queue_alu_cmd;
    wire [3:0]      queue_mul_cmd;
    wire [19:0]     queue_mem_cmd;
    wire [27:0]     queue_bru_cmd;
    wire [7:0]      queue_bagu_cmd;

    issue_queue issue_queue_INST (
        .clk                (clk),
        .resetn             (resetn),

        .snoop_hit          (snoop_hit),
        
        .bco_valid          (bco_valid),

        .fifo_pr            (queue_fifo_pr),

        //
        .wea                (alloc_next_wen),

        .dina_pc            (idffs_pc),

        .dina_src0_rob      (idffs_src0_rob),
        .dina_src0_ready    (wht_src0_rdy),
        .dina_src0_value    (wht_src0_value),

        .dina_src1_rob      (idffs_src1_rob),
        .dina_src1_ready    (wht_src1_rdy),
        .dina_src1_value    (wht_src1_value),

        .dina_rob           (idffs_dst_rob),

        .dina_imm           (idffs_imm),

        .dina_fid           (idffs_fid),

        .dina_bp_pattern    (idffs_bp_pattern),
        .dina_bp_taken      (idffs_bp_taken),
        .dina_bp_hit        (idffs_bp_hit),
        .dina_bp_target     (idffs_bp_target),

        .dina_branch        (idffs_branch),
        .dina_load          (idffs_load),
        .dina_store         (idffs_store),

        .dina_pipe_alu      (idffs_pipe_alu),
        .dina_pipe_mul      (idffs_pipe_mul),
        .dina_pipe_mem      (idffs_pipe_mem),
        .dina_pipe_bru      (idffs_pipe_bru),

        .dina_alu_cmd       (idffs_alu_cmd),
        .dina_mul_cmd       (idffs_mul_cmd),
        .dina_mem_cmd       (idffs_mem_cmd),
        .dina_bru_cmd       (idffs_bru_cmd),
        .dina_bagu_cmd      (idffs_bagu_cmd),

        //
        .web                (idffs_wb_en & ~idffs_wb_lsmiss),
        .dinb_rob           (idffs_wb_dst_rob),
        .dinb_value         (idffs_wb_value),

        //
        .wec                (nowb_en),
        .dinc_rob           (nowb_dst_rob),
        .dinc_value         (nowb_value),

        //
        .wed                (queue_we),

        .doutd_valid        (queue_valid),

        .doutd_pc           (queue_pc),
        
        .doutd_src0_rdy     (queue_src0_rdy),
        .doutd_src0_rob     (queue_src0_rob),
        .doutd_src0_value   (queue_src0_value),

        .doutd_src1_rdy     (queue_src1_rdy),
        .doutd_src1_rob     (queue_src1_rob),
        .doutd_src1_value   (queue_src1_value),

        .doutd_dst_rob      (queue_dst_rob),

        .doutd_imm          (queue_imm),

        .doutd_bp_pattern   (queue_bp_pattern),
        .doutd_bp_taken     (queue_bp_taken),
        .doutd_bp_hit       (queue_bp_hit),
        .doutd_bp_target    (queue_bp_target),

        .doutd_fid          (queue_fid),

        .doutd_branch       (queue_branch),
        .doutd_load         (queue_load),
        .doutd_store        (queue_store),

        .doutd_pipe_alu     (queue_pipe_alu),
        .doutd_pipe_mul     (queue_pipe_mul),
        .doutd_pipe_mem     (queue_pipe_mem),
        .doutd_pipe_bru     (queue_pipe_bru),

        .doutd_alu_cmd      (queue_alu_cmd),
        .doutd_mul_cmd      (queue_mul_cmd),
        .doutd_mem_cmd      (queue_mem_cmd),
        .doutd_bru_cmd      (queue_bru_cmd),
        .doutd_bagu_cmd     (queue_bagu_cmd)
    );

    //
    issue_pick issue_pick_INST (
        .clk                (clk),
        .resetn             (resetn),

        .snoop_hit          (snoop_hit),
        
        .bco_valid          (bco_valid),

        //
        .i_valid            (queue_valid),

        .i_pc               (queue_pc),

        .i_src0_rob         (queue_src0_rob),
        .i_src0_rdy         (queue_src0_rdy),
        .i_src0_value       (queue_src0_value),
        
        .i_src1_rob         (queue_src1_rob),
        .i_src1_rdy         (queue_src1_rdy),
        .i_src1_value       (queue_src1_value),

        .i_dst_rob          (queue_dst_rob),
        
        .i_imm              (queue_imm),

        .i_bp_pattern       (queue_bp_pattern),
        .i_bp_taken         (queue_bp_taken),
        .i_bp_hit           (queue_bp_hit),
        .i_bp_target        (queue_bp_target),

        .i_fid              (queue_fid),

        .i_branch           (queue_branch),
        .i_load             (queue_load),
        .i_store            (queue_store),

        .i_pipe_alu         (queue_pipe_alu),
        .i_pipe_mul         (queue_pipe_mul),
        .i_pipe_mem         (queue_pipe_mem),
        .i_pipe_bru         (queue_pipe_bru),

        .i_alu_cmd          (queue_alu_cmd),
        .i_mul_cmd          (queue_mul_cmd),
        .i_mem_cmd          (queue_mem_cmd),
        .i_bru_cmd          (queue_bru_cmd),
        .i_bagu_cmd         (queue_bagu_cmd),

        //
        .o_en               (queue_we),
        
        //
        .o_valid            (o_valid),

        .o_pc               (o_pc),

        .o_src0_value       (o_src0_value),
        .o_src0_forward_alu (o_src0_forward_alu),

        .o_src1_value       (o_src1_value),
        .o_src1_forward_alu (o_src1_forward_alu),

        .o_dst_rob          (o_dst_rob),

        .o_imm              (o_imm),

        .o_bp_pattern       (o_bp_pattern),
        .o_bp_taken         (o_bp_taken),
        .o_bp_hit           (o_bp_hit),
        .o_bp_target        (o_bp_target),

        .o_fid              (o_fid),

        .o_pipe_alu         (o_pipe_alu),
        .o_pipe_mul         (o_pipe_mul),
        .o_pipe_mem         (o_pipe_mem),
        .o_pipe_bru         (o_pipe_bru),

        .o_alu_cmd          (o_alu_cmd),
        .o_mul_cmd          (o_mul_cmd),
        .o_mem_cmd          (o_mem_cmd),
        .o_bru_cmd          (o_bru_cmd),
        .o_bagu_cmd         (o_bagu_cmd)
    );

    //

endmodule
