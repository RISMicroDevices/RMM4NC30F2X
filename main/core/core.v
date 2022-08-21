
module core (
    input   wire            clk,
    input   wire            resetn,

    // IF AXI Interface
    output  wire [3:0]      if_axi_m_arid,
    output  wire [31:0]     if_axi_m_araddr,
    output  wire [7:0]      if_axi_m_arlen,
    output  wire [2:0]      if_axi_m_arsize,
    output  wire [1:0]      if_axi_m_arburst,
    output  wire            if_axi_m_aruser,
    output  wire            if_axi_m_arvalid,
    input   wire            if_axi_m_arready,

    input   wire [3:0]      if_axi_m_rid,
    input   wire [31:0]     if_axi_m_rdata,
    input   wire [1:0]      if_axi_m_rresp,
    input   wire            if_axi_m_rlast,
    input   wire            if_axi_m_rvalid,
    output  wire            if_axi_m_rready,

    // MEM AXI Interface
    output  wire [3:0]      mem_axi_m_awid,
    output  wire [31:0]     mem_axi_m_awaddr,
    output  wire [7:0]      mem_axi_m_awlen,
    output  wire [2:0]      mem_axi_m_awsize,
    output  wire [1:0]      mem_axi_m_awburst,
    output  wire            mem_axi_m_awuser,
    output  wire            mem_axi_m_awvalid,
    input   wire            mem_axi_m_awready,

    output  wire [31:0]     mem_axi_m_wdata,
    output  wire [3:0]      mem_axi_m_wstrb,
    output  wire            mem_axi_m_wlast,
    output  wire            mem_axi_m_wvalid,
    input   wire            mem_axi_m_wready,

    input   wire [3:0]      mem_axi_m_bid,
    input   wire [1:0]      mem_axi_m_bresp,
    input   wire            mem_axi_m_bvalid,
    output  wire            mem_axi_m_bready,

    output  wire [3:0]      mem_axi_m_arid,
    output  wire [31:0]     mem_axi_m_araddr,
    output  wire [7:0]      mem_axi_m_arlen,
    output  wire [2:0]      mem_axi_m_arsize,
    output  wire [1:0]      mem_axi_m_arburst,
    output  wire            mem_axi_m_aruser,
    output  wire            mem_axi_m_arvalid,
    input   wire            mem_axi_m_arready,

    input   wire [3:0]      mem_axi_m_rid,
    input   wire [31:0]     mem_axi_m_rdata,
    input   wire [1:0]      mem_axi_m_rresp,
    input   wire            mem_axi_m_rlast,
    input   wire            mem_axi_m_rvalid,
    output  wire            mem_axi_m_rready
);

    //
    wire        sys_resetn;

    core_reset core_reset (
        .clk        (clk),
        .resetn     (resetn),

        .o_resetn   (sys_resetn)
    );


    // Snoop Filter distribution
    wire        snoop_hit;
    wire [31:0] snoop_addr;

   // Post-commit Snoop Filter distribution
    wire        snooptable_wea;
    wire [31:0] snooptable_addra;

    wire        snooptable_web;


    //
    assign snoop_hit        = 1'b0;
    assign snoop_addr       = 32'b0;

    assign snooptable_wea   = 'b0;
    assign snooptable_addra = 'b0;

    assign snooptable_web   = 'b0;


    // Branch Commit Override distribution
    wire        bco_valid;
    wire [31:0] bco_pc;
    wire [1:0]  bco_oldpattern;
    wire        bco_taken;
    wire [31:0] bco_target;


    // Writeback Logic distribution
    wire        wb_en;

    wire [3:0]  wb_dst_rob;
    wire [7:0]  wb_fid;
    wire [31:0] wb_result;
    wire        wb_lsmiss;
    wire [3:0]  wb_cmtdelay;

    wire        wb_bco_valid;
    wire [1:0]  wb_bco_pattern;
    wire        wb_bco_taken;
    wire [31:0] wb_bco_target;

    
    // (Post-load-commit writeback) No-Writeback Logic distribution
    wire        nowb_en;
    wire [3:0]  nowb_dst_rob;
    wire [31:0] nowb_value;


    // Commit Logic distribution
    wire        commit_o_en;
    wire        commit_o_store;
    wire [7:0]  commit_o_fid;
    wire [4:0]  commit_o_dst;
    wire [31:0] commit_o_result;

    wire        commit_i_valid;
    wire        commit_i_ready;
    wire [31:0] commit_i_pc;
    wire [3:0]  commit_i_rob;
    wire [4:0]  commit_i_dst;
    wire [31:0] commit_i_value;
    wire [7:0]  commit_i_fid;
    wire        commit_i_load;
    wire        commit_i_store;
    wire [1:0]  commit_i_lswidth;
    wire        commit_i_lsmiss;
    wire [3:0]  commit_i_cmtdelay;

    wire        commit_i_bco_valid;
    wire [1:0]  commit_i_bco_pattern;
    wire        commit_i_bco_taken;
    wire [31:0] commit_i_bco_target;

    wire        commit_i_mem_readyn;

    wire        commit_o_mem_store_en;


    // Memory Interaction interface
    wire        mem_o_wbmem_en;

    wire        mem_i_wbmem_valid;
    wire [31:0] mem_i_wbmem_addr;
    wire [3:0]  mem_i_wbmem_strb;
    wire [1:0]  mem_i_wbmem_lswidth;
    wire [31:0] mem_i_wbmem_data;
    wire        mem_i_wbmem_uncached;

    wire        mem_o_dcache_update_tag_en;
    wire [31:0] mem_o_dcache_update_tag_addr;
    wire        mem_o_dcache_update_tag_valid;

    wire        mem_o_dcache_update_data_valid;
    wire [31:0] mem_o_dcache_update_data_addr;
    wire [3:0]  mem_o_dcache_update_data_strb;
    wire [31:0] mem_o_dcache_update_data;

    wire        mem_i_dcache_update_data_ready;

    
    // LoadBuffer State Distribution
    wire [31:0] loadbuffer_s_qaddr;
    wire        loadbuffer_s_busy;

    // StoreBuffer State Distribution
    wire        postcmtbuffer_s_busy_uncached;


    //
    wire        fetch_i_readyn;

    wire        fetch_o_q_valid;
    wire [31:0] fetch_o_q_pc;
    wire [7:0]  fetch_o_q_fid;
    wire [31:0] fetch_o_q_data;

    wire        fetch_o_bp_valid;
    wire [1:0]  fetch_o_bp_pattern;
    wire        fetch_o_bp_taken;
    wire        fetch_o_bp_hit;
    wire [31:0] fetch_o_bp_target;

    fetch fetch_INST (
        .clk                (clk),
        .resetn             (sys_resetn),

        //
        .bco_valid          (bco_valid),
        .bco_pc             (bco_pc),
        .bco_oldpattern     (bco_oldpattern),
        .bco_taken          (bco_taken),
        .bco_target         (bco_target),

        //
        .readyn             (fetch_i_readyn),

        //
        .snoop_hit          (snoop_hit),
        .snoop_addr         (snoop_addr),

        //
        .snooptable_wea     (snooptable_wea),
        .snooptable_addra   (snooptable_addra),

        .snooptable_web     (snooptable_web),

        //
        .q_valid            (fetch_o_q_valid),
        .q_pc               (fetch_o_q_pc),
        .q_fid              (fetch_o_q_fid),
        .q_data             (fetch_o_q_data),

        //
        .bp_valid           (fetch_o_bp_valid),
        .bp_pattern         (fetch_o_bp_pattern),
        .bp_taken           (fetch_o_bp_taken),
        .bp_hit             (fetch_o_bp_hit),
        .bp_target          (fetch_o_bp_target),

        //
        .axi_m_arid         (if_axi_m_arid),
        .axi_m_araddr       (if_axi_m_araddr),
        .axi_m_arlen        (if_axi_m_arlen),
        .axi_m_arsize       (if_axi_m_arsize),
        .axi_m_arburst      (if_axi_m_arburst),
        .axi_m_aruser       (if_axi_m_aruser),
        .axi_m_arvalid      (if_axi_m_arvalid),
        .axi_m_arready      (if_axi_m_arready),

        .axi_m_rid          (if_axi_m_rid),
        .axi_m_rdata        (if_axi_m_rdata),
        .axi_m_rresp        (if_axi_m_rresp),
        .axi_m_rlast        (if_axi_m_rlast),
        .axi_m_rvalid       (if_axi_m_rvalid),
        .axi_m_rready       (if_axi_m_rready)
    );


    //
    wire        decode_i_readyn;

    wire        decode_o_issue_valid;

    wire [31:0] decode_o_issue_pc;

    wire [3:0]  decode_o_issue_src0_rob;
    wire        decode_o_issue_src0_ready;
    wire [31:0] decode_o_issue_src0_value;

    wire [3:0]  decode_o_issue_src1_rob;
    wire        decode_o_issue_src1_ready;
    wire [31:0] decode_o_issue_src1_value;

    wire [3:0]  decode_o_issue_dst_rob;

    wire [25:0] decode_o_issue_imm;

    wire [7:0]  decode_o_issue_fid;

    wire        decode_o_issue_branch;
    wire        decode_o_issue_load;
    wire        decode_o_issue_store;

    wire        decode_o_issue_pipe_alu;
    wire        decode_o_issue_pipe_mul;
    wire        decode_o_issue_pipe_mem;
    wire        decode_o_issue_pipe_bru;

    wire [4:0]  decode_o_issue_alu_cmd;
    wire [0:0]  decode_o_issue_mul_cmd;
    wire [4:0]  decode_o_issue_mem_cmd;
    wire [6:0]  decode_o_issue_bru_cmd;
    wire [1:0]  decode_o_issue_bagu_cmd;

    wire [1:0]  decode_o_bp_pattern;
    wire        decode_o_bp_taken;
    wire        decode_o_bp_hit;
    wire [31:0] decode_o_bp_target;

    decode decode_INST (
        .clk                    (clk),
        .resetn                 (sys_resetn),

        //
        .snoop_hit              (snoop_hit),

        //
        .if_readyn              (fetch_i_readyn),

        .issue_readyn           (decode_i_readyn),

        //
        .bco_valid              (bco_valid),

        //
        .bp_pattern             (fetch_o_bp_pattern),
        .bp_taken               (fetch_o_bp_taken),
        .bp_hit                 (fetch_o_bp_hit),
        .bp_target              (fetch_o_bp_target),

        //
        .if_valid               (fetch_o_q_valid),
        .if_pc                  (fetch_o_q_pc),
        .if_fid                 (fetch_o_q_fid),
        .if_data                (fetch_o_q_data),

        //
        .commit_i_en            (commit_o_en),
        .commit_i_store         (commit_o_store),
        .commit_i_fid           (commit_o_fid),
        .commit_i_dst           (commit_o_dst),
        .commit_i_result        (commit_o_result),

        .commit_o_valid         (commit_i_valid),
        .commit_o_ready         (commit_i_ready),
        .commit_o_pc            (commit_i_pc),
        .commit_o_rob           (commit_i_rob),
        .commit_o_dst           (commit_i_dst),
        .commit_o_value         (commit_i_value),
        .commit_o_fid           (commit_i_fid),
        .commit_o_load          (commit_i_load),
        .commit_o_store         (commit_i_store),
        .commit_o_lswidth       (commit_i_lswidth),
        .commit_o_lsmiss        (commit_i_lsmiss),
        .commit_o_cmtdelay      (commit_i_cmtdelay),

        .commit_o_bco_valid     (commit_i_bco_valid),
        .commit_o_bco_pattern   (commit_i_bco_pattern),
        .commit_o_bco_taken     (commit_i_bco_taken),
        .commit_o_bco_target    (commit_i_bco_target),

        //
        .wb_en                  (wb_en),

        .wb_dst_rob             (wb_dst_rob),
        .wb_fid                 (wb_fid),
        .wb_value               (wb_result),
        .wb_lsmiss              (wb_lsmiss),
        .wb_cmtdelay            (wb_cmtdelay),

        .wb_bco_valid           (wb_bco_valid),
        .wb_bco_pattern         (wb_bco_pattern),
        .wb_bco_taken           (wb_bco_taken),
        .wb_bco_target          (wb_bco_target),

        //
        .issue_valid            (decode_o_issue_valid),
        
        .issue_pc               (decode_o_issue_pc),

        .issue_src0_rob         (decode_o_issue_src0_rob),
        .issue_src0_ready       (decode_o_issue_src0_ready),
        .issue_src0_value       (decode_o_issue_src0_value),

        .issue_src1_rob         (decode_o_issue_src1_rob),
        .issue_src1_ready       (decode_o_issue_src1_ready),
        .issue_src1_value       (decode_o_issue_src1_value),

        .issue_dst_rob          (decode_o_issue_dst_rob),

        .issue_imm              (decode_o_issue_imm),

        .issue_fid              (decode_o_issue_fid),

        .issue_branch           (decode_o_issue_branch),
        .issue_load             (decode_o_issue_load),
        .issue_store            (decode_o_issue_store),

        .issue_pipe_alu         (decode_o_issue_pipe_alu),
        .issue_pipe_mul         (decode_o_issue_pipe_mul),
        .issue_pipe_mem         (decode_o_issue_pipe_mem),
        .issue_pipe_bru         (decode_o_issue_pipe_bru),

        .issue_alu_cmd          (decode_o_issue_alu_cmd),
        .issue_mul_cmd          (decode_o_issue_mul_cmd),
        .issue_mem_cmd          (decode_o_issue_mem_cmd),
        .issue_bru_cmd          (decode_o_issue_bru_cmd),
        .issue_bagu_cmd         (decode_o_issue_bagu_cmd),

        //
        .o_bp_pattern           (decode_o_bp_pattern),
        .o_bp_taken             (decode_o_bp_taken),
        .o_bp_hit               (decode_o_bp_hit),
        .o_bp_target            (decode_o_bp_target)
    );


    //
    wire        issue_o_valid;

    wire [31:0] issue_o_pc;

    wire [31:0] issue_o_src0_value;
    wire        issue_o_src0_forward_alu;

    wire [31:0] issue_o_src1_value;
    wire        issue_o_src1_forward_alu;

    wire [3:0]  issue_o_dst_rob;

    wire [25:0] issue_o_imm;

    wire [7:0]  issue_o_fid;

    wire        issue_o_pipe_alu;
    wire        issue_o_pipe_mul;
    wire        issue_o_pipe_mem;
    wire        issue_o_pipe_bru;

    wire [4:0]  issue_o_alu_cmd;
    wire [0:0]  issue_o_mul_cmd;
    wire [4:0]  issue_o_mem_cmd;
    wire [6:0]  issue_o_bru_cmd;
    wire [1:0]  issue_o_bagu_cmd;

    wire [1:0]  issue_o_bp_pattern;
    wire        issue_o_bp_taken;
    wire        issue_o_bp_hit;
    wire [31:0] issue_o_bp_target;

    issue issue_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .snoop_hit          (snoop_hit),

        //
        .readyn             (decode_i_readyn),

        //
        .bco_valid          (bco_valid),

        //
        .bp_pattern         (decode_o_bp_pattern),
        .bp_taken           (decode_o_bp_taken),
        .bp_hit             (decode_o_bp_hit),
        .bp_target          (decode_o_bp_target),

        //
        .wb_en              (wb_en),
        .wb_dst_rob         (wb_dst_rob),
        .wb_value           (wb_result),
        .wb_lsmiss          (wb_lsmiss),

        //
        .nowb_en            (nowb_en),
        .nowb_dst_rob       (nowb_dst_rob),
        .nowb_value         (nowb_value),

        //
        .i_valid            (decode_o_issue_valid),
        
        .i_pc               (decode_o_issue_pc),

        .i_src0_rob         (decode_o_issue_src0_rob),
        .i_src0_ready       (decode_o_issue_src0_ready),
        .i_src0_value       (decode_o_issue_src0_value),

        .i_src1_rob         (decode_o_issue_src1_rob),
        .i_src1_ready       (decode_o_issue_src1_ready),
        .i_src1_value       (decode_o_issue_src1_value),

        .i_dst_rob          (decode_o_issue_dst_rob),

        .i_imm              (decode_o_issue_imm),

        .i_fid              (decode_o_issue_fid),
        
        .i_branch           (decode_o_issue_branch),
        .i_load             (decode_o_issue_load),
        .i_store            (decode_o_issue_store),

        .i_pipe_alu         (decode_o_issue_pipe_alu),
        .i_pipe_mul         (decode_o_issue_pipe_mul),
        .i_pipe_mem         (decode_o_issue_pipe_mem),
        .i_pipe_bru         (decode_o_issue_pipe_bru),

        .i_alu_cmd          (decode_o_issue_alu_cmd),
        .i_mul_cmd          (decode_o_issue_mul_cmd),
        .i_mem_cmd          (decode_o_issue_mem_cmd),
        .i_bru_cmd          (decode_o_issue_bru_cmd),
        .i_bagu_cmd         (decode_o_issue_bagu_cmd),

        //
        .o_valid            (issue_o_valid),

        .o_pc               (issue_o_pc),

        .o_src0_value       (issue_o_src0_value),
        .o_src0_forward_alu (issue_o_src0_forward_alu),

        .o_src1_value       (issue_o_src1_value),
        .o_src1_forward_alu (issue_o_src1_forward_alu),

        .o_dst_rob          (issue_o_dst_rob),

        .o_imm              (issue_o_imm),
        
        .o_fid              (issue_o_fid),

        .o_pipe_alu         (issue_o_pipe_alu),
        .o_pipe_mul         (issue_o_pipe_mul),
        .o_pipe_mem         (issue_o_pipe_mem),
        .o_pipe_bru         (issue_o_pipe_bru),

        .o_alu_cmd          (issue_o_alu_cmd),
        .o_mul_cmd          (issue_o_mul_cmd),
        .o_mem_cmd          (issue_o_mem_cmd),
        .o_bru_cmd          (issue_o_bru_cmd),
        .o_bagu_cmd         (issue_o_bagu_cmd),

        .o_bp_pattern       (issue_o_bp_pattern),
        .o_bp_taken         (issue_o_bp_taken),
        .o_bp_hit           (issue_o_bp_hit),
        .o_bp_target        (issue_o_bp_target)
    );


    //
    wire [31:0] dispatch_i_forward_alu_value;

    wire [1:0]  dispatch_o_bp_pattern;
    wire        dispatch_o_bp_taken;
    wire        dispatch_o_bp_hit;
    wire [31:0] dispatch_o_bp_target;

    wire        dispatch_o_valid;

    wire [31:0] dispatch_o_pc;

    wire [31:0] dispatch_o_src0_value;
    wire [31:0] dispatch_o_src1_value;

    wire [3:0]  dispatch_o_dst_rob;

    wire [25:0] dispatch_o_imm;

    wire [7:0]  dispatch_o_fid;

    wire        dispatch_o_pipe_alu;
    wire        dispatch_o_pipe_mul;
    wire        dispatch_o_pipe_mem;
    wire        dispatch_o_pipe_bru;

    wire [4:0]  dispatch_o_alu_cmd;
    wire [0:0]  dispatch_o_mul_cmd;
    wire [4:0]  dispatch_o_mem_cmd;
    wire [6:0]  dispatch_o_bru_cmd;
    wire [1:0]  dispatch_o_bagu_cmd;

    dispatch dispatch_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .bco_valid          (bco_valid),

        //
        .i_bp_pattern       (issue_o_bp_pattern),
        .i_bp_taken         (issue_o_bp_taken),
        .i_bp_hit           (issue_o_bp_hit),
        .i_bp_target        (issue_o_bp_target),

        //
        .i_valid            (issue_o_valid),

        .i_pc               (issue_o_pc),

        .i_src0_value       (issue_o_src0_value),
        .i_src0_forward_alu (issue_o_src0_forward_alu),

        .i_src1_value       (issue_o_src1_value),
        .i_src1_forward_alu (issue_o_src1_forward_alu),

        .i_dst_rob          (issue_o_dst_rob),

        .i_imm              (issue_o_imm),

        .i_fid              (issue_o_fid),

        .i_pipe_alu         (issue_o_pipe_alu),
        .i_pipe_mul         (issue_o_pipe_mul),
        .i_pipe_mem         (issue_o_pipe_mem),
        .i_pipe_bru         (issue_o_pipe_bru),

        .i_alu_cmd          (issue_o_alu_cmd),
        .i_mul_cmd          (issue_o_mul_cmd),
        .i_mem_cmd          (issue_o_mem_cmd),
        .i_bru_cmd          (issue_o_bru_cmd),
        .i_bagu_cmd         (issue_o_bagu_cmd),

        //
        .i_forward_alu_value(dispatch_i_forward_alu_value),

        //
        .o_bp_pattern       (dispatch_o_bp_pattern),
        .o_bp_taken         (dispatch_o_bp_taken),
        .o_bp_hit           (dispatch_o_bp_hit),
        .o_bp_target        (dispatch_o_bp_target),

        //
        .o_valid            (dispatch_o_valid),

        .o_pc               (dispatch_o_pc),
        
        .o_src0_value       (dispatch_o_src0_value),
        .o_src1_value       (dispatch_o_src1_value),

        .o_dst_rob          (dispatch_o_dst_rob),

        .o_imm              (dispatch_o_imm),

        .o_fid              (dispatch_o_fid),

        .o_pipe_alu         (dispatch_o_pipe_alu),
        .o_pipe_mul         (dispatch_o_pipe_mul),
        .o_pipe_mem         (dispatch_o_pipe_mem),
        .o_pipe_bru         (dispatch_o_pipe_bru),

        .o_alu_cmd          (dispatch_o_alu_cmd),
        .o_mul_cmd          (dispatch_o_mul_cmd),
        .o_mem_cmd          (dispatch_o_mem_cmd),
        .o_bru_cmd          (dispatch_o_bru_cmd),
        .o_bagu_cmd         (dispatch_o_bagu_cmd)
    );


    //


    execute execute_INST (
        .clk                        (clk),
        .resetn                     (resetn),

        //
        .snoop_hit                  (snoop_hit),

        //
        .bco_valid                  (bco_valid),

        //
        .s_qaddr                    (loadbuffer_s_qaddr),
        .s_busy                     (loadbuffer_s_busy),

        .s_o_busy_uncached          (postcmtbuffer_s_busy_uncached),

        //
        .i_bp_pattern               (dispatch_o_bp_pattern),
        .i_bp_taken                 (dispatch_o_bp_taken),
        .i_bp_hit                   (dispatch_o_bp_hit),
        .i_bp_target                (dispatch_o_bp_target),

        //
        .i_mem_commit_en_store      (commit_o_mem_store_en),

        .o_mem_commit_readyn        (commit_i_mem_readyn),

        //
        .i_mem_wbmem_en             (mem_o_wbmem_en),

        .o_mem_wbmem_valid          (mem_i_wbmem_valid),
        .o_mem_wbmem_addr           (mem_i_wbmem_addr),
        .o_mem_wbmem_strb           (mem_i_wbmem_strb),
        .o_mem_wbmem_lswidth        (mem_i_wbmem_lswidth),
        .o_mem_wbmem_data           (mem_i_wbmem_data),
        .o_mem_wbmem_uncached       (mem_i_wbmem_uncached),

        //
        .i_dcache_update_tag_en     (mem_o_dcache_update_tag_en),
        .i_dcache_update_tag_addr   (mem_o_dcache_update_tag_addr),
        .i_dcache_update_tag_valid  (mem_o_dcache_update_tag_valid),

        .i_dcache_update_data_valid (mem_o_dcache_update_data_valid),
        .i_dcache_update_data_addr  (mem_o_dcache_update_data_addr),
        .i_dcache_update_data_strb  (mem_o_dcache_update_data_strb),
        .i_dcache_update_data       (mem_o_dcache_update_data),

        .o_dcache_update_data_ready (mem_i_dcache_update_data_ready),

        //
        .i_valid                    (dispatch_o_valid),

        .i_pc                       (dispatch_o_pc),

        .i_src0_value               (dispatch_o_src0_value),
        .i_src1_value               (dispatch_o_src1_value),

        .i_dst_rob                  (dispatch_o_dst_rob),

        .i_imm                      (dispatch_o_imm),

        .i_fid                      (dispatch_o_fid),

        .i_pipe_alu                 (dispatch_o_pipe_alu),
        .i_pipe_mul                 (dispatch_o_pipe_mul),
        .i_pipe_mem                 (dispatch_o_pipe_mem),
        .i_pipe_bru                 (dispatch_o_pipe_bru),

        .i_alu_cmd                  (dispatch_o_alu_cmd),
        .i_mul_cmd                  (dispatch_o_mul_cmd),
        .i_mem_cmd                  (dispatch_o_mem_cmd),
        .i_bru_cmd                  (dispatch_o_bru_cmd),
        .i_bagu_cmd                 (dispatch_o_bagu_cmd),

        //
        .o_bco_valid                (wb_bco_valid),
        .o_bco_pc                   (),
        .o_bco_oldpattern           (wb_bco_pattern),
        .o_bco_taken                (wb_bco_taken),
        .o_bco_target               (wb_bco_target),

        //
        .o_forward_alu_value        (dispatch_i_forward_alu_value),

        //
        .o_valid                    (wb_en),
        
        .o_dst_rob                  (wb_dst_rob),
        .o_fid                      (wb_fid),

        .o_result                   (wb_result),
        .o_cmtdelay                 (wb_cmtdelay),
        .o_lsmiss                   (wb_lsmiss)
    );


    //
    commit commit_INST (
        .clk                        (clk),
        .resetn                     (resetn),

        //
        .s_qaddr                    (loadbuffer_s_qaddr),
        .s_busy                     (loadbuffer_s_busy),

        .s_busy_uncached_store      (postcmtbuffer_s_busy_uncached),

        //
        .i_valid                    (commit_i_valid),
        .i_ready                    (commit_i_ready),
        .i_pc                       (commit_i_pc),
        .i_rob                      (commit_i_rob),
        .i_dst                      (commit_i_dst),
        .i_value                    (commit_i_value),
        .i_fid                      (commit_i_fid),
        .i_load                     (commit_i_load),
        .i_store                    (commit_i_store),
        .i_lswidth                  (commit_i_lswidth),
        .i_lsmiss                   (commit_i_lsmiss),
        .i_cmtdelay                 (commit_i_cmtdelay),

        .i_bco_valid                (commit_i_bco_valid),
        .i_bco_pattern              (commit_i_bco_pattern),
        .i_bco_taken                (commit_i_bco_taken),
        .i_bco_target               (commit_i_bco_target),

        //
        .o_en                       (commit_o_en),
        .o_store                    (commit_o_store),
        .o_fid                      (commit_o_fid),
        .o_dst                      (commit_o_dst),
        .o_result                   (commit_o_result),

        .o_bco_valid                (bco_valid),
        .o_bco_pc                   (bco_pc),
        .o_bco_pattern              (bco_oldpattern),
        .o_bco_taken                (bco_taken),
        .o_bco_target               (bco_target),

        //
        .o_mem_store_en             (commit_o_mem_store_en),

        .i_mem_readyn               (commit_i_mem_readyn),

        //
        .o_nowb_en                  (nowb_en),
        .o_nowb_dst_rob             (nowb_dst_rob),
        .o_nowb_value               (nowb_value),

        //
        .o_wbmem_en                 (mem_o_wbmem_en),
        
        .i_wbmem_valid              (mem_i_wbmem_valid),
        .i_wbmem_addr               (mem_i_wbmem_addr),
        .i_wbmem_strb               (mem_i_wbmem_strb),
        .i_wbmem_lswidth            (mem_i_wbmem_lswidth),
        .i_wbmem_data               (mem_i_wbmem_data),
        .i_wbmem_uncached           (mem_i_wbmem_uncached),

        //
        .o_dcache_update_tag_en     (mem_o_dcache_update_tag_en),
        .o_dcache_update_tag_addr   (mem_o_dcache_update_tag_addr),
        .o_dcache_update_tag_valid  (mem_o_dcache_update_tag_valid),

        //
        .o_dcache_update_data_valid (mem_o_dcache_update_data_valid),
        .o_dcache_update_data_addr  (mem_o_dcache_update_data_addr),
        .o_dcache_update_data_strb  (mem_o_dcache_update_data_strb),
        .o_dcache_update_data       (mem_o_dcache_update_data),

        .i_dcache_update_data_ready (mem_i_dcache_update_data_ready),

        //
        .axi_m_awid                 (mem_axi_m_awid),
        .axi_m_awaddr               (mem_axi_m_awaddr),
        .axi_m_awlen                (mem_axi_m_awlen),
        .axi_m_awsize               (mem_axi_m_awsize),
        .axi_m_awburst              (mem_axi_m_awburst),
        .axi_m_awuser               (mem_axi_m_awuser),
        .axi_m_awvalid              (mem_axi_m_awvalid),
        .axi_m_awready              (mem_axi_m_awready),

        .axi_m_wdata                (mem_axi_m_wdata),
        .axi_m_wstrb                (mem_axi_m_wstrb),
        .axi_m_wlast                (mem_axi_m_wlast),
        .axi_m_wvalid               (mem_axi_m_wvalid),
        .axi_m_wready               (mem_axi_m_wready),

        .axi_m_bid                  (mem_axi_m_bid),
        .axi_m_bresp                (mem_axi_m_bresp),
        .axi_m_bvalid               (mem_axi_m_bvalid),
        .axi_m_bready               (mem_axi_m_bready),

        //
        .axi_m_arid                 (mem_axi_m_arid),
        .axi_m_araddr               (mem_axi_m_araddr),
        .axi_m_arlen                (mem_axi_m_arlen),
        .axi_m_arsize               (mem_axi_m_arsize),
        .axi_m_arburst              (mem_axi_m_arburst),
        .axi_m_aruser               (mem_axi_m_aruser),
        .axi_m_arvalid              (mem_axi_m_arvalid),
        .axi_m_arready              (mem_axi_m_arready),

        .axi_m_rid                  (mem_axi_m_rid),
        .axi_m_rdata                (mem_axi_m_rdata),
        .axi_m_rresp                (mem_axi_m_rresp),
        .axi_m_rlast                (mem_axi_m_rlast),
        .axi_m_rvalid               (mem_axi_m_rvalid),
        .axi_m_rready               (mem_axi_m_rready)
    );

    //

endmodule
