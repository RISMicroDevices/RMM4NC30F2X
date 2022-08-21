
module decode (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,      // Snoop filter refresh

    //
    output  wire            if_readyn,

    input   wire            issue_readyn,

    // Branch commit
    input   wire            bco_valid,

    //
    input   wire [1:0]      bp_pattern,
    input   wire            bp_taken,
    input   wire            bp_hit,
    input   wire [31:0]     bp_target,

    //
    input   wire            if_valid,
    input   wire [31:0]     if_pc,
    input   wire [7:0]      if_fid,
    input   wire [31:0]     if_data,

    // commit logic interface
    input   wire            commit_i_en,
    input   wire            commit_i_store,
    input   wire [7:0]      commit_i_fid,
    input   wire [4:0]      commit_i_dst,
    input   wire [31:0]     commit_i_result,

    output  wire            commit_o_valid,
    output  wire            commit_o_ready,
    output  wire [31:0]     commit_o_pc,
    output  wire [3:0]      commit_o_rob,
    output  wire [4:0]      commit_o_dst,
    output  wire [31:0]     commit_o_value,
    output  wire [7:0]      commit_o_fid,
    output  wire            commit_o_load,
    output  wire            commit_o_store,
    output  wire [1:0]      commit_o_lswidth,
    output  wire            commit_o_lsmiss,
    output  wire [3:0]      commit_o_cmtdelay,

    output  wire            commit_o_bco_valid,
    output  wire [1:0]      commit_o_bco_pattern,
    output  wire            commit_o_bco_taken,
    output  wire [31:0]     commit_o_bco_target,

    // writeback
    input   wire            wb_en,

    input   wire [3:0]      wb_dst_rob,
    input   wire [7:0]      wb_fid,
    input   wire [31:0]     wb_value,
    input   wire            wb_lsmiss,
    input   wire [3:0]      wb_cmtdelay,

    input   wire            wb_bco_valid,
    input   wire [1:0]      wb_bco_pattern,
    input   wire            wb_bco_taken,
    input   wire [31:0]     wb_bco_target,

    // Issue Stage
    output  wire            issue_valid,

    output  wire [31:0]     issue_pc,

    output  wire [3:0]      issue_src0_rob,
    output  wire            issue_src0_ready,
    output  wire [31:0]     issue_src0_value,

    output  wire [3:0]      issue_src1_rob,
    output  wire            issue_src1_ready,
    output  wire [31:0]     issue_src1_value,

    output  wire [3:0]      issue_dst_rob,

    output  wire [25:0]     issue_imm,

    output  wire [7:0]      issue_fid,

    output  wire            issue_branch,
    output  wire            issue_load,
    output  wire            issue_store,

    output  wire            issue_pipe_alu,
    output  wire            issue_pipe_mul,
    output  wire            issue_pipe_mem,
    output  wire            issue_pipe_bru,

    output  wire [4:0]      issue_alu_cmd,
    output  wire [0:0]      issue_mul_cmd,
    output  wire [4:0]      issue_mem_cmd,
    output  wire [6:0]      issue_bru_cmd,
    output  wire [1:0]      issue_bagu_cmd,

    //
    output  wire [1:0]      o_bp_pattern,
    output  wire            o_bp_taken,
    output  wire            o_bp_hit,
    output  wire [31:0]     o_bp_target
); 

    //
    wire        alloc_next_wen;

    //
    wire [4:0]  rob_next_rob;


    //
    wire        idffs_wb_en;
    wire [3:0]  idffs_wb_dst_rob;
    wire [7:0]  idffs_wb_fid;
    wire [31:0] idffs_wb_value;
    wire        idffs_wb_lsmiss;
    wire [3:0]  idffs_wb_cmtdelay;

    wire        idffs_wb_bco_valid;
    wire [1:0]  idffs_wb_bco_pattern;
    wire        idffs_wb_bco_taken;
    wire [31:0] idffs_wb_bco_target;

    wire        idffs_valid;
    wire [31:0] idffs_pc;
    wire [7:0]  idffs_fid;
    wire [31:0] idffs_data;

    wire [1:0]  idffs_bp_pattern;
    wire        idffs_bp_taken;
    wire        idffs_bp_hit;
    wire [31:0] idffs_bp_target;

    //
    wire [4:0]  idec_src0;
    wire [4:0]  idec_src1;
    wire [4:0]  idec_dst;

    wire [25:0] idec_imm;

    wire        idec_branch;
    wire        idec_load;
    wire        idec_store;
    wire [1:0]  idec_lswidth;

    wire        idec_pipe_alu;
    wire        idec_pipe_mul;
    wire        idec_pipe_mem;
    wire        idec_pipe_bru;

    wire [4:0]  idec_alu_cmd;
    wire [0:0]  idec_mul_cmd;
    wire [4:0]  idec_mem_cmd;
    wire [6:0]  idec_bru_cmd;
    wire [1:0]  idec_bagu_cmd;


    //
    wire [31:0] idecdffs_pc;

    wire [4:0]  idecdffs_src0;
    wire [4:0]  idecdffs_src1;
    wire [4:0]  idecdffs_dst;

    wire [25:0] idecdffs_imm;

    wire [7:0]  idecdffs_fid;

    wire        idecdffs_load;
    wire        idecdffs_store;
    wire [1:0]  idecdffs_lswidth;

    wire        idecdffs_pipe_alu;
    wire        idecdffs_pipe_mul;
    wire        idecdffs_pipe_mem;
    wire        idecdffs_pipe_bru;

    wire [4:0]  idecdffs_alu_cmd;
    wire [0:0]  idecdffs_mul_cmd;
    wire [4:0]  idecdffs_mem_cmd;
    wire [6:0]  idecdffs_bru_cmd;
    wire [1:0]  idecdffs_bagu_cmd;

    wire [1:0]  idecdffs_bp_pattern;
    wire        idecdffs_bp_taken;
    wire        idecdffs_bp_hit;
    wire [31:0] idecdffs_bp_target;

    wire        idecdffs_next_wen;

    //
    decode_idffs decode_idffs_INST (
        .clk                (clk),
        .resetn             (resetn),

        .snoop_hit          (snoop_hit),

        .bco_valid          (bco_valid),

        .i_wb_en            (wb_en),
        .i_wb_dst_rob       (wb_dst_rob),
        .i_wb_fid           (wb_fid),
        .i_wb_value         (wb_value),
        .i_wb_lsmiss        (wb_lsmiss),
        .i_wb_cmtdelay      (wb_cmtdelay),

        .i_wb_bco_valid     (wb_bco_valid),
        .i_wb_bco_pattern   (wb_bco_pattern),
        .i_wb_bco_taken     (wb_bco_taken),
        .i_wb_bco_target    (wb_bco_target),

        .i_valid            (if_valid),
        .i_pc               (if_pc),
        .i_fid              (if_fid),
        .i_data             (if_data),

        .i_bp_pattern       (bp_pattern),
        .i_bp_taken         (bp_taken),
        .i_bp_hit           (bp_hit),
        .i_bp_target        (bp_target),

        .o_wb_en            (idffs_wb_en),
        .o_wb_dst_rob       (idffs_wb_dst_rob),
        .o_wb_fid           (idffs_wb_fid),
        .o_wb_value         (idffs_wb_value),
        .o_wb_lsmiss        (idffs_wb_lsmiss),
        .o_wb_cmtdelay      (idffs_wb_cmtdelay),

        .o_wb_bco_valid     (idffs_wb_bco_valid),
        .o_wb_bco_pattern   (idffs_wb_bco_pattern),
        .o_wb_bco_taken     (idffs_wb_bco_taken),
        .o_wb_bco_target    (idffs_wb_bco_target),

        .o_valid            (idffs_valid),
        .o_pc               (idffs_pc),
        .o_fid              (idffs_fid),
        .o_data             (idffs_data),

        .o_bp_pattern       (idffs_bp_pattern),
        .o_bp_taken         (idffs_bp_taken),
        .o_bp_hit           (idffs_bp_hit),
        .o_bp_target        (idffs_bp_target)
    );

    //
    decode_alloc decode_alloc_INST (
        .clk                (clk),
        .resetn             (resetn),

        .snoop_hit          (snoop_hit),

        .en_alloc           (idffs_valid),
        .en_alloc_store     (idec_store),
        
        .bco_valid          (bco_valid),

        .en_commit          (commit_i_en),
        .en_commit_store    (commit_i_store),

        .next_wen           (alloc_next_wen),

        .i_readyn           (issue_readyn),
        .o_readyn           (if_readyn)
    );

    decode_idecode decode_idecode_INST (
        .clk        (clk),
        .resetn     (resetn),

        .valid      (idffs_valid),
        .insn       (idffs_data),

        .src0       (idec_src0),
        .src1       (idec_src1),
        .dst        (idec_dst),

        .imm        (idec_imm),

        .branch     (idec_branch),
        .load       (idec_load),
        .store      (idec_store),
        .lswidth    (idec_lswidth),

        .pipe_alu   (idec_pipe_alu),
        .pipe_mul   (idec_pipe_mul),
        .pipe_mem   (idec_pipe_mem),
        .pipe_bru   (idec_pipe_bru),

        .alu_cmd    (idec_alu_cmd),
        .mul_cmd    (idec_mul_cmd),
        .mem_cmd    (idec_mem_cmd),
        .bru_cmd    (idec_bru_cmd),
        .bagu_cmd   (idec_bagu_cmd)
    );

    //
    decode_idecdffs decode_idecdffs_INST (
        .clk            (clk),
        .resetn         (resetn),

        //
        .snoop_hit      (snoop_hit),
        
        //
        .bco_valid      (bco_valid),

        //
        .i_pc           (idffs_pc),

        .i_src0         (idec_src0),
        .i_src1         (idec_src1),
        .i_dst          (idec_dst),

        .i_imm          (idec_imm),
        
        .i_fid          (idffs_fid),
        
        .i_branch       (idec_branch),
        .i_load         (idec_load),
        .i_store        (idec_store),
        .i_lswidth      (idec_lswidth),
        
        .i_pipe_alu     (idec_pipe_alu),
        .i_pipe_mul     (idec_pipe_mul),
        .i_pipe_mem     (idec_pipe_mem),
        .i_pipe_bru     (idec_pipe_bru),

        .i_alu_cmd      (idec_alu_cmd),
        .i_mul_cmd      (idec_mul_cmd),
        .i_mem_cmd      (idec_mem_cmd),
        .i_bru_cmd      (idec_bru_cmd),
        .i_bagu_cmd     (idec_bagu_cmd),

        .i_bp_pattern   (idffs_bp_pattern),
        .i_bp_taken     (idffs_bp_taken),
        .i_bp_hit       (idffs_bp_hit),
        .i_bp_target    (idffs_bp_target),

        .i_next_wen     (alloc_next_wen),

        //
        .o_pc           (idecdffs_pc),

        .o_src0         (idecdffs_src0),
        .o_src1         (idecdffs_src1),
        .o_dst          (idecdffs_dst),

        .o_imm          (idecdffs_imm),

        .o_fid          (idecdffs_fid),
        
        .o_branch       (idecdffs_branch),
        .o_load         (idecdffs_load),
        .o_store        (idecdffs_store),
        .o_lswidth      (idecdffs_lswidth),

        .o_pipe_alu     (idecdffs_pipe_alu),
        .o_pipe_mul     (idecdffs_pipe_mul),
        .o_pipe_mem     (idecdffs_pipe_mem),
        .o_pipe_bru     (idecdffs_pipe_bru),

        .o_alu_cmd      (idecdffs_alu_cmd),
        .o_mul_cmd      (idecdffs_mul_cmd),
        .o_mem_cmd      (idecdffs_mem_cmd),
        .o_bru_cmd      (idecdffs_bru_cmd),
        .o_bagu_cmd     (idecdffs_bagu_cmd),

        .o_bp_pattern   (idecdffs_bp_pattern),
        .o_bp_taken     (idecdffs_bp_taken),
        .o_bp_hit       (idecdffs_bp_hit),
        .o_bp_target    (idecdffs_bp_target),

        .o_next_wen     (idecdffs_next_wen)
    );


    //
    wire [3:0]  rob_addra;
    wire [31:0] rob_douta;
    wire        rob_douta_ready;

    wire [3:0]  rob_addrb;
    wire [31:0] rob_doutb;
    wire        rob_doutb_ready;

    decode_rob decode_rob_INST (
        .clk                (clk),
        .resetn             (resetn),
        
        .snoop_hit          (snoop_hit),

        .addra              (rob_addra),
        .douta              (rob_douta),
        .douta_ready        (rob_douta_ready),

        .addrb              (rob_addrb),
        .doutb              (rob_doutb),
        .doutb_ready        (rob_doutb_ready),

        .en_alloc           (idecdffs_next_wen),
        .dinc_pc            (idecdffs_pc),
        .dinc_dst           (idecdffs_dst),
        .dinc_fid           (idecdffs_fid),
        .dinc_load          (idecdffs_load),
        .dinc_store         (idecdffs_store),
        .dinc_lswidth       (idecdffs_lswidth),

        .en_writeback       (idffs_wb_en),
        .addrd              (idffs_wb_dst_rob),
        .dind_fid           (idffs_wb_fid),
        .dind_value         (idffs_wb_value),
        .dind_lsmiss        (idffs_wb_lsmiss),
        .dind_cmtdelay      (idffs_wb_cmtdelay),

        .dind_bco_valid     (idffs_wb_bco_valid),
        .dind_bco_pattern   (idffs_wb_bco_pattern),
        .dind_bco_taken     (idffs_wb_bco_taken),
        .dind_bco_target    (idffs_wb_bco_target),

        .en_commit          (commit_i_en),
        .doute_valid        (commit_o_valid),
        .doute_ready        (commit_o_ready),
        .doute_pc           (commit_o_pc),
        .doute_rob          (commit_o_rob),
        .doute_dst          (commit_o_dst),
        .doute_value        (commit_o_value),
        .doute_fid          (commit_o_fid),
        .doute_load         (commit_o_load),
        .doute_store        (commit_o_store),
        .doute_lswidth      (commit_o_lswidth),
        .doute_lsmiss       (commit_o_lsmiss),
        .doute_cmtdelay     (commit_o_cmtdelay),

        .doute_bco_valid    (commit_o_bco_valid),
        .doute_bco_pattern  (commit_o_bco_pattern),
        .doute_bco_taken    (commit_o_bco_taken),
        .doute_bco_target   (commit_o_bco_target),

        .bco_valid          (bco_valid),

        .next_rob           (rob_next_rob)
    );

    //
    wire [3:0]  regnrename_src0_rob;
    wire        regnrename_src0_ready;
    wire [31:0] regnrename_src0_value;

    wire [3:0]  regnrename_src1_rob;
    wire        regnrename_src1_ready;
    wire [31:0] regnrename_src1_value;

    decode_regnrename decode_regnrename_INST (
        .clk            (clk),
        .resetn         (resetn),

        .snoop_hit      (snoop_hit),

        .en             (idecdffs_next_wen),
        .i_rob          (rob_next_rob[3:0]),
        .i_fid          (idecdffs_fid),
        .i_src0         (idecdffs_src0),
        .i_src1         (idecdffs_src1),
        .i_dst          (idecdffs_dst),

        .o_src0_rob     (regnrename_src0_rob),
        .o_src0_ready   (regnrename_src0_ready),
        .o_src0_value   (regnrename_src0_value),

        .o_src1_rob     (regnrename_src1_rob),
        .o_src1_ready   (regnrename_src1_ready),
        .o_src1_value   (regnrename_src1_value),

        .rob_addra      (rob_addra),
        .rob_dina       (rob_douta),
        .rob_dina_ready (rob_douta_ready),

        .rob_addrb      (rob_addrb),
        .rob_dinb       (rob_doutb),
        .rob_dinb_ready (rob_doutb_ready),
        
        .rob_cm_en      (commit_i_en),
        .rob_cm_addr    (commit_i_dst),
        .rob_cm_fid     (commit_i_fid),
        .rob_cm_data    (commit_i_result),

        .bco_valid      (bco_valid)
    );

    //
    wire        iregdffs_issue_valid;
    wire [31:0] iregdffs_issue_pc;

    wire [3:0]  iregdffs_issue_dst_rob;

    wire [25:0] iregdffs_issue_imm;

    wire [7:0]  iregdffs_issue_fid;

    wire        iregdffs_issue_branch;
    wire        iregdffs_issue_load;
    wire        iregdffs_issue_store;

    wire        iregdffs_issue_pipe_alu;
    wire        iregdffs_issue_pipe_mul;
    wire        iregdffs_issue_pipe_mem;
    wire        iregdffs_issue_pipe_bru;

    wire [4:0]  iregdffs_issue_alu_cmd;
    wire [0:0]  iregdffs_issue_mul_cmd;
    wire [4:0]  iregdffs_issue_mem_cmd;
    wire [6:0]  iregdffs_issue_bru_cmd;
    wire [1:0]  iregdffs_issue_bagu_cmd;

    decode_iregdffs decode_iregdffs_INST (
        .clk                (clk),
        .resetn             (resetn),

        .snoop_hit          (snoop_hit),

        //
        .bco_valid          (bco_valid),

        //
        .i_issue_valid      (idecdffs_next_wen),
        .i_issue_pc         (idecdffs_pc),

        .i_issue_rob        (rob_next_rob[3:0]),

        .i_issue_imm        (idecdffs_imm),

        .i_issue_fid        (idecdffs_fid),

        .i_issue_branch     (idecdffs_branch),
        .i_issue_load       (idecdffs_load),
        .i_issue_store      (idecdffs_store),

        .i_issue_pipe_alu   (idecdffs_pipe_alu),
        .i_issue_pipe_mul   (idecdffs_pipe_mul),
        .i_issue_pipe_mem   (idecdffs_pipe_mem),
        .i_issue_pipe_bru   (idecdffs_pipe_bru),

        .i_issue_alu_cmd    (idecdffs_alu_cmd),
        .i_issue_mul_cmd    (idecdffs_mul_cmd),
        .i_issue_mem_cmd    (idecdffs_mem_cmd),
        .i_issue_bru_cmd    (idecdffs_bru_cmd),
        .i_issue_bagu_cmd   (idecdffs_bagu_cmd),
        
        //
        .o_issue_valid      (iregdffs_issue_valid),
        .o_issue_pc         (iregdffs_issue_pc),

        .o_issue_rob        (iregdffs_issue_dst_rob),

        .o_issue_imm        (iregdffs_issue_imm),

        .o_issue_fid        (iregdffs_issue_fid),

        .o_issue_branch     (iregdffs_issue_branch),
        .o_issue_load       (iregdffs_issue_load),
        .o_issue_store      (iregdffs_issue_store),

        .o_issue_pipe_alu   (iregdffs_issue_pipe_alu),
        .o_issue_pipe_mul   (iregdffs_issue_pipe_mul),
        .o_issue_pipe_mem   (iregdffs_issue_pipe_mem),
        .o_issue_pipe_bru   (iregdffs_issue_pipe_bru),

        .o_issue_alu_cmd    (iregdffs_issue_alu_cmd),
        .o_issue_mul_cmd    (iregdffs_issue_mul_cmd),
        .o_issue_mem_cmd    (iregdffs_issue_mem_cmd),
        .o_issue_bru_cmd    (iregdffs_issue_bru_cmd),
        .o_issue_bagu_cmd   (iregdffs_issue_bagu_cmd)
    );
    
    //
    assign issue_src0_rob   = regnrename_src0_rob;
    assign issue_src0_ready = regnrename_src0_ready;
    assign issue_src0_value = regnrename_src0_value;

    assign issue_src1_rob   = regnrename_src1_rob;
    assign issue_src1_ready = regnrename_src1_ready;
    assign issue_src1_value = regnrename_src1_value;

    assign issue_valid      = iregdffs_issue_valid;
    assign issue_pc         = iregdffs_issue_pc;

    assign issue_dst_rob    = iregdffs_issue_dst_rob;

    assign issue_imm        = iregdffs_issue_imm;

    assign issue_fid        = iregdffs_issue_fid;

    assign issue_branch     = iregdffs_issue_branch;
    assign issue_load       = iregdffs_issue_load;
    assign issue_store      = iregdffs_issue_store;

    assign issue_pipe_alu   = iregdffs_issue_pipe_alu;
    assign issue_pipe_mul   = iregdffs_issue_pipe_mul;
    assign issue_pipe_mem   = iregdffs_issue_pipe_mem;
    assign issue_pipe_bru   = iregdffs_issue_pipe_bru;

    assign issue_alu_cmd    = iregdffs_issue_alu_cmd;
    assign issue_mul_cmd    = iregdffs_issue_mul_cmd;
    assign issue_mem_cmd    = iregdffs_issue_mem_cmd;
    assign issue_bru_cmd    = iregdffs_issue_bru_cmd;
    assign issue_bagu_cmd   = iregdffs_issue_bagu_cmd;

    //
    assign o_bp_pattern     = idecdffs_bp_pattern;
    assign o_bp_taken       = idecdffs_bp_taken;
    assign o_bp_hit         = idecdffs_bp_hit;
    assign o_bp_target      = idecdffs_bp_target;

    //

endmodule
