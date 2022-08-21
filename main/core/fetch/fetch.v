`include "fetch_predecode_def.v"

module fetch (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            bco_valid,   // branch commit valid
    input   wire [31:0]     bco_pc,
    input   wire [1:0]      bco_oldpattern,
    input   wire            bco_taken,
    input   wire [31:0]     bco_target,

    //
    input   wire            readyn,

    //
    input   wire            snoop_hit,
    input   wire [31:0]     snoop_addr,

    //
    input   wire            snooptable_wea,
    input   wire [31:0]     snooptable_addra,

    input   wire            snooptable_web,

    //
    output  wire            q_valid,
    output  wire [31:0]     q_pc,
    output  wire [7:0]      q_fid,
    output  wire [31:0]     q_data,

    //
    output  wire            bp_valid,
    output  wire [1:0]      bp_pattern,
    output  wire            bp_taken,
    output  wire            bp_hit,
    output  wire [31:0]     bp_target,

    // AXI interface
    output  wire [3:0]      axi_m_arid,
    output  wire [31:0]     axi_m_araddr,
    output  wire [7:0]      axi_m_arlen,
    output  wire [2:0]      axi_m_arsize,
    output  wire [1:0]      axi_m_arburst,
    output  wire            axi_m_aruser,
    output  wire            axi_m_arvalid,
    input   wire            axi_m_arready,

    input   wire [3:0]      axi_m_rid,
    input   wire [31:0]     axi_m_rdata,
    input   wire [1:0]      axi_m_rresp,
    input   wire            axi_m_rlast,
    input   wire            axi_m_rvalid,
    output  wire            axi_m_rready
);

    //
    wire        cache_hit;
    wire        cache_uncached;

    wire        cache_refilled_hit;
    wire        cache_uncached_done;

    wire        cctrl_miss;
    wire        cctrl_uncached;

    wire [31:0] queue_pc_paddr;
    wire [31:0] queue_pc_vaddr;
    wire        queue_pc_uncached;
    wire        queue_pc_valid;

    wire [31:0] queue_pc_o_vaddr;
    wire [7:0]  queue_pc_o_fid;
    wire        queue_pc_o_valid;

    reg         queue_pc_uncached_R;

    always @(posedge clk) begin

        if (~resetn) begin
            queue_pc_uncached_R <= 1'b0;
        end
        else begin
            queue_pc_uncached_R <= queue_pc_uncached;
        end
    end

    fetch_sequence fetch_sequence_INST (
        .clk                (clk),
        .resetn             (resetn),

        .readyn             (readyn),

        .bco_valid          (bco_valid),
        .bco_target         (bco_target),

        .snoop_hit          (snoop_hit),
        .snoop_addr         (snoop_addr),
        
        .cache_hit          (cache_hit),
        .cache_uncached     (cache_uncached),
        
        .cache_refilled_hit (cache_refilled_hit),
        .cache_uncached_done(cache_uncached_done),

        .bp_valid           (bp_valid),
        .bp_taken           (bp_taken),
        .bp_hit             (bp_hit),
        .bp_target          (bp_target),

        .cctrl_miss         (cctrl_miss),
        .cctrl_uncached     (cctrl_uncached),

        .pc_vaddr           (queue_pc_vaddr),
        .pc_paddr           (queue_pc_paddr),
        .pc_uncached        (queue_pc_uncached),
        .pc_valid           (queue_pc_valid),

        .o_pc_vaddr         (queue_pc_o_vaddr),
        .o_pc_fid           (queue_pc_o_fid),
        .o_pc_valid         (queue_pc_o_valid)
    );

    assign cache_uncached = queue_pc_uncached_R;


    //
    wire        pht_update_en;
    wire [31:0] pht_update_pc;
    wire [1:0]  pht_update_oldpattern;
    wire        pht_update_taken;

    wire        btb_update_en;
    wire [31:0] btb_update_pc;
    wire [31:0] btb_update_target;

    wire        GHR_wen;
    wire [7:0]  GHR_wdata;

    wire [7:0]  GHR_rdata;

    fetch_prediction fetch_prediction_INST (
        .clk                    (clk),
        .resetn                 (resetn),
        
        .pc                     (queue_pc_paddr),

        .pht_update_en          (pht_update_en),
        .pht_update_pc          (pht_update_pc),
        .pht_update_oldpattern  (pht_update_oldpattern),
        .pht_update_taken       (pht_update_taken),

        .btb_update_en          (btb_update_en),
        .btb_update_pc          (btb_update_pc),
        .btb_update_target      (btb_update_target),
        
        .bp_pattern             (bp_pattern),
        .bp_taken               (bp_taken),
        .bp_target_valid        (bp_hit),
        .bp_target              (bp_target),
        
        .GHR_rdata              (GHR_rdata),
        
        .GHR_wen                (GHR_wen),
        .GHR_wdata              (GHR_wdata)
    );

    fetch_ghr fetch_ghr_INST (
        .clk    (clk),
        .resetn (resetn),

        .wen    (GHR_wen),
        .wdata  (GHR_wdata),

        .rdata  (GHR_rdata)
    );

    assign pht_update_en         = bco_valid;
    assign pht_update_pc         = bco_pc;
    assign pht_update_oldpattern = bco_oldpattern;
    assign pht_update_taken      = bco_taken;

    assign btb_update_en         = bco_valid;
    assign btb_update_pc         = bco_pc;
    assign btb_update_target     = bco_target;

    //
    wire        update_data_wea;
    wire [31:0] update_data_addr;
    wire [35:0] update_data;

    wire        update_tag_wea;
    wire [32:0] update_tag;

    wire        icache_hit;
    wire [35:0] icache_data;

    wire        icache_bp_valid;

    fetch_icache fetch_icache_INST (
        .clk    (clk),
        .resetn (resetn),
        
        .update_data_wea    (update_data_wea),
        .update_data_addr   (update_data_addr),
        .update_data        (update_data),

        .update_tag_wea     (update_tag_wea),
        .update_tag         (update_tag),

        .snoop_hit          (snoop_hit),
        .snoop_addr         (snoop_addr),

        .q_addr             (queue_pc_paddr),
        
        .q_hit              (icache_hit),
        .q_data             (icache_data)
    );

    assign icache_bp_valid = icache_data[35:32] == `PREDECODED_BRANCH
                          || icache_data[35:32] == `PREDECODED_JUMP
                          || icache_data[35:32] == `PREDECODED_JUMP_LINK;

    //
    wire        ibuffer_uncached_we;
    wire [31:0] ibuffer_uncached_addr;
    wire [35:0] ibuffer_uncached_din;

    wire        ibuffer_uncached_done;

    wire        ibuffer_refilled_wea;
    wire [31:0] ibuffer_refilled_addra;

    wire        ibuffer_refilled_web;
    wire [3:0]  ibuffer_refilled_addrb;
    wire [35:0] ibuffer_refilled_dinb;

    wire        ibuffer_refilled_reset;

    wire        ibuffer_refilled_hit;

    wire        ibuffer_hit;
    wire [35:0] ibuffer_data;

    wire        ibuffer_bp_valid;

    fetch_ibuffer fetch_ibuffer_INST (
        .clk    (clk),
        .resetn (resetn),

        .uncached_we    (ibuffer_uncached_we),
        .uncached_addr  (ibuffer_uncached_addr),
        .uncached_din   (ibuffer_uncached_din),

        .uncached_done  (ibuffer_uncached_done),

        .refilled_wea   (ibuffer_refilled_wea),
        .refilled_addra (ibuffer_refilled_addra),
        
        .refilled_web   (ibuffer_refilled_web),
        .refilled_addrb (ibuffer_refilled_addrb),
        .refilled_dinb  (ibuffer_refilled_dinb),

        .refilled_reset (ibuffer_refilled_reset),

        .refilled_hit   (ibuffer_refilled_hit),

        .snoop_hit      (snoop_hit),
        .snoop_addr     (snoop_addr),

        .q_addr         (queue_pc_paddr),

        .q_hit          (ibuffer_hit),
        .q_data         (ibuffer_data)
    );

    assign ibuffer_bp_valid = ibuffer_data[35:32] == `PREDECODED_BRANCH
                           || ibuffer_data[35:32] == `PREDECODED_JUMP
                           || ibuffer_data[35:32] == `PREDECODED_JUMP_LINK;

    assign cache_refilled_hit  = ibuffer_refilled_hit;
    assign cache_uncached_done = ibuffer_uncached_done;


    //
    wire [31:0] predecode_din;
    wire [35:0] predecode_dout;

    fetch_predecode fetch_predecode_INST (
        .din    (predecode_din),
        .dout   (predecode_dout)
    );

    //
    wire [31:0] snooptable_q_addr;
    wire        snooptable_q_hit;

    fetch_snooptable fetch_snooptable_INST (
        .clk        (clk),
        .resetn     (resetn),

        .wea        (snooptable_wea),
        .addra      (snooptable_addra),

        .web        (snooptable_web),

        .q_addr     (snooptable_q_addr),
        .q_hit      (snooptable_q_hit) 
    );

    //
    wire [3:0]  ctrl_axi_m_arid;
    wire [31:0] ctrl_axi_m_araddr;
    wire [7:0]  ctrl_axi_m_arlen;
    wire [2:0]  ctrl_axi_m_arsize;
    wire [1:0]  ctrl_axi_m_arburst;
    wire        ctrl_axi_m_aruser;
    wire        ctrl_axi_m_arvalid;
    wire        ctrl_axi_m_arready;

    wire [3:0]  ctrl_axi_m_rid;
    wire [31:0] ctrl_axi_m_rdata;
    wire [1:0]  ctrl_axi_m_rresp;
    wire        ctrl_axi_m_rlast;
    wire        ctrl_axi_m_rvalid;
    wire        ctrl_axi_m_rready;

    fetch_ctrl2axi fetch_ctrl2axi_INST (
        .clk                    (clk),
        .resetn                 (resetn),

        .pc                     (queue_pc_paddr),

        .cctrl_miss             (cctrl_miss),
        .cctrl_uncached         (cctrl_uncached),

        .snoop_hit              (snoop_hit),
        .snoop_addr             (snoop_addr),

        .predecode_dout         (predecode_din),
        .predecode_din          (predecode_dout),

        .snoop_query_addr       (snooptable_q_addr),
        .snoop_query_hit        (snooptable_q_hit),

        .update_data_wea        (update_data_wea),
        .update_data_addr       (update_data_addr),
        .update_data_din        (update_data),
        
        .update_tag_wea         (update_tag_wea),
        .update_tag             (update_tag),

        .buffer_uncached_we     (ibuffer_uncached_we),
        .buffer_uncached_addr   (ibuffer_uncached_addr),
        .buffer_uncached_din    (ibuffer_uncached_din),

        .buffer_refilled_wea    (ibuffer_refilled_wea),
        .buffer_refilled_addra  (ibuffer_refilled_addra),
        
        .buffer_refilled_web    (ibuffer_refilled_web),
        .buffer_refilled_addrb  (ibuffer_refilled_addrb),
        .buffer_refilled_dinb   (ibuffer_refilled_dinb),
        
        .buffer_refilled_reset  (ibuffer_refilled_reset),

        .axi_m_arid             (ctrl_axi_m_arid),
        .axi_m_araddr           (ctrl_axi_m_araddr),
        .axi_m_arlen            (ctrl_axi_m_arlen),
        .axi_m_arsize           (ctrl_axi_m_arsize),
        .axi_m_arburst          (ctrl_axi_m_arburst),
        .axi_m_arvalid          (ctrl_axi_m_arvalid),
        .axi_m_aruser           (ctrl_axi_m_aruser),
        .axi_m_arready          (ctrl_axi_m_arready),

        .axi_m_rid              (ctrl_axi_m_rid),
        .axi_m_rdata            (ctrl_axi_m_rdata),
        .axi_m_rresp            (ctrl_axi_m_rresp),
        .axi_m_rlast            (ctrl_axi_m_rlast),
        .axi_m_rvalid           (ctrl_axi_m_rvalid),
        .axi_m_rready           (ctrl_axi_m_rready)
    );

    //
    fetch_axi_register_slice fetch_axi_register_slice_INST (
        .aclk           (clk),
        .aresetn        (resetn),

        .s_axi_araddr   (ctrl_axi_m_araddr),
        .s_axi_arburst  (ctrl_axi_m_arburst),
        .s_axi_arid     (ctrl_axi_m_arid),
        .s_axi_arlen    (ctrl_axi_m_arlen),
        .s_axi_arready  (ctrl_axi_m_arready),
        .s_axi_arsize   (ctrl_axi_m_arsize),
        .s_axi_aruser   (ctrl_axi_m_aruser),
        .s_axi_arvalid  (ctrl_axi_m_arvalid),

        .s_axi_rdata    (ctrl_axi_m_rdata),
        .s_axi_rid      (ctrl_axi_m_rid),
        .s_axi_rlast    (ctrl_axi_m_rlast),
        .s_axi_rready   (ctrl_axi_m_rready),
        .s_axi_rresp    (ctrl_axi_m_rresp),
        .s_axi_rvalid   (ctrl_axi_m_rvalid),

        .m_axi_araddr   (axi_m_araddr),
        .m_axi_arburst  (axi_m_arburst),
        .m_axi_arid     (axi_m_arid),
        .m_axi_arlen    (axi_m_arlen),
        .m_axi_arready  (axi_m_arready),
        .m_axi_arsize   (axi_m_arsize),
        .m_axi_aruser   (axi_m_aruser),
        .m_axi_arvalid  (axi_m_arvalid),

        .m_axi_rdata    (axi_m_rdata),
        .m_axi_rid      (axi_m_rid),
        .m_axi_rlast    (axi_m_rlast),
        .m_axi_rready   (axi_m_rready),
        .m_axi_rresp    (axi_m_rresp),
        .m_axi_rvalid   (axi_m_rvalid)
    );

    //
    assign cache_hit    = icache_hit | ibuffer_hit;

    reg cache_hit_R;

    always @(posedge clk) begin

        if (~resetn) begin
            cache_hit_R <= 'b0; 
        end
        else begin
            cache_hit_R <= cache_hit;
        end
    end

    //
    assign q_valid  = queue_pc_o_valid & cache_hit;
    assign q_pc     = queue_pc_o_vaddr;
    assign q_fid    = queue_pc_o_fid;
    assign q_data   = ibuffer_hit ? ibuffer_data[31:0] : icache_data[31:0];

    //
    assign bp_valid = queue_pc_o_valid & (ibuffer_hit ? ibuffer_bp_valid : icache_bp_valid);

    //

endmodule