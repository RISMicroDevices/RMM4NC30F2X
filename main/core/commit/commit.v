//`define     ENABLE_AXI_BUS_REGISTER_SLICE

module commit (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire [31:0]     s_qaddr,
    output  wire            s_busy,

    input   wire            s_busy_uncached_store,

    //
    input   wire            i_valid,
    input   wire            i_ready,
    input   wire [31:0]     i_pc,
    input   wire [3:0]      i_rob,
    input   wire [4:0]      i_dst,
    input   wire [31:0]     i_value,
    input   wire [7:0]      i_fid,
    input   wire            i_load,
    input   wire            i_store,
    input   wire [1:0]      i_lswidth,
    input   wire            i_lsmiss,
    input   wire [3:0]      i_cmtdelay,

    input   wire            i_bco_valid,
    input   wire [1:0]      i_bco_pattern,
    input   wire            i_bco_taken,
    input   wire [31:0]     i_bco_target,

    //
    output  wire            o_en,
    output  wire            o_store,
    output  wire [7:0]      o_fid,
    output  wire [4:0]      o_dst,
    output  wire [31:0]     o_result,

    output  wire            o_bco_valid,
    output  wire [31:0]     o_bco_pc,
    output  wire [1:0]      o_bco_pattern,
    output  wire            o_bco_taken,
    output  wire [31:0]     o_bco_target,

    //
    output  wire            o_mem_store_en,

    input   wire            i_mem_readyn,

    //
    output  wire            o_nowb_en,
    output  wire [3:0]      o_nowb_dst_rob,
    output  wire [31:0]     o_nowb_value,

    //
    output  wire            o_wbmem_en,

    input   wire            i_wbmem_valid,
    input   wire [31:0]     i_wbmem_addr,
    input   wire [3:0]      i_wbmem_strb,
    input   wire [1:0]      i_wbmem_lswidth,
    input   wire [31:0]     i_wbmem_data,
    input   wire            i_wbmem_uncached,

    //
    output  wire            o_dcache_update_tag_en,
    output  wire [31:0]     o_dcache_update_tag_addr,
    output  wire            o_dcache_update_tag_valid,

    //
    output  wire            o_dcache_update_data_valid,
    output  wire [31:0]     o_dcache_update_data_addr,
    output  wire [3:0]      o_dcache_update_data_strb,
    output  wire [31:0]     o_dcache_update_data,

    input   wire            i_dcache_update_data_ready,

    // AXI write interface
    output  wire [3:0]      axi_m_awid,
    output  wire [31:0]     axi_m_awaddr,
    output  wire [7:0]      axi_m_awlen,
    output  wire [2:0]      axi_m_awsize,
    output  wire [1:0]      axi_m_awburst,
    output  wire            axi_m_awuser,
    output  wire            axi_m_awvalid,
    input   wire            axi_m_awready,

    output  wire [31:0]     axi_m_wdata,
    output  wire [3:0]      axi_m_wstrb,
    output  wire            axi_m_wlast,
    output  wire            axi_m_wvalid,
    input   wire            axi_m_wready,

    input   wire [3:0]      axi_m_bid,
    input   wire [1:0]      axi_m_bresp,
    input   wire            axi_m_bvalid,
    output  wire            axi_m_bready,

    // AXI read interface
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
    wire        loadbuffer_wea;
    wire [31:0] loadbuffer_addra;
    wire [31:0] loadbuffer_dina;

    wire        loadbuffer_web;
    wire [31:0] loadbuffer_addrb;
    wire [31:0] loadbuffer_dinb;

    wire        loadbuffer_wec;

    wire [31:0] loadbuffer_qaddr;

    wire        loadbuffer_qhit;
    wire [31:0] loadbuffer_qdata;

    wire        loadbuffer_s_busy;

    commit_mem_loadbuffer commit_mem_loadbuffer_INST (
        .clk        (clk),
        .resetn     (resetn),

        //
        .s_qaddr    (s_qaddr),
        .s_busy     (loadbuffer_s_busy),

        //
        .wea        (loadbuffer_wea),
        .addra      (loadbuffer_addra),
        .dina       (loadbuffer_dina),

        //
        .web        (loadbuffer_web),
        .addrb      (loadbuffer_addrb),
        .dinb       (loadbuffer_dinb),

        //
        .wec        (loadbuffer_wec),

        //
        .qaddr      (loadbuffer_qaddr),
        
        .qhit       (loadbuffer_qhit),
        .qdata      (loadbuffer_qdata)
    );


    //
    wire [3:0]  memwr_axi_m_awid;
    wire [31:0] memwr_axi_m_awaddr;
    wire [7:0]  memwr_axi_m_awlen;
    wire [2:0]  memwr_axi_m_awsize;
    wire [1:0]  memwr_axi_m_awburst;
    wire        memwr_axi_m_awuser;
    wire        memwr_axi_m_awvalid;
    wire        memwr_axi_m_awready;

    wire [31:0] memwr_axi_m_wdata;
    wire [3:0]  memwr_axi_m_wstrb;
    wire        memwr_axi_m_wlast;
    wire        memwr_axi_m_wvalid;
    wire        memwr_axi_m_wready;

    wire [3:0]  memwr_axi_m_bid;
    wire [1:0]  memwr_axi_m_bresp;
    wire        memwr_axi_m_bvalid;
    wire        memwr_axi_m_bready;

    commit_mem_write_ctrl2axi commit_mem_write_ctrl2axi_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .i_wbmem_valid      (i_wbmem_valid),
        .i_wbmem_addr       (i_wbmem_addr),
        .i_wbmem_strb       (i_wbmem_strb),
        .i_wbmem_lswidth    (i_wbmem_lswidth),
        .i_wbmem_data       (i_wbmem_data),
        .i_wbmem_uncached   (i_wbmem_uncached),

        .o_wbmem_en         (o_wbmem_en),

        //
        .axi_m_awid         (memwr_axi_m_awid),
        .axi_m_awaddr       (memwr_axi_m_awaddr),
        .axi_m_awlen        (memwr_axi_m_awlen),
        .axi_m_awsize       (memwr_axi_m_awsize),
        .axi_m_awburst      (memwr_axi_m_awburst),
        .axi_m_awuser       (memwr_axi_m_awuser),
        .axi_m_awvalid      (memwr_axi_m_awvalid),
        .axi_m_awready      (memwr_axi_m_awready),

        .axi_m_wdata        (memwr_axi_m_wdata),
        .axi_m_wstrb        (memwr_axi_m_wstrb),
        .axi_m_wlast        (memwr_axi_m_wlast),
        .axi_m_wvalid       (memwr_axi_m_wvalid),
        .axi_m_wready       (memwr_axi_m_wready),

        .axi_m_bid          (memwr_axi_m_bid),
        .axi_m_bresp        (memwr_axi_m_bresp),
        .axi_m_bvalid       (memwr_axi_m_bvalid),
        .axi_m_bready       (memwr_axi_m_bready)
    );


    //
    wire        rdctrl_en;
    wire [7:0]  rdctrl_fid;
    wire [31:0] rdctrl_addr;
    wire        rdctrl_uncached;
    wire [1:0]  rdctrl_lswidth;

    wire [3:0]  memrd_axi_m_arid;
    wire [31:0] memrd_axi_m_araddr;
    wire [7:0]  memrd_axi_m_arlen;
    wire [2:0]  memrd_axi_m_arsize;
    wire [1:0]  memrd_axi_m_arburst;
    wire        memrd_axi_m_aruser;
    wire        memrd_axi_m_arvalid;
    wire        memrd_axi_m_arready;

    wire [3:0]  memrd_axi_m_rid;
    wire [31:0] memrd_axi_m_rdata;
    wire [1:0]  memrd_axi_m_rresp;
    wire        memrd_axi_m_rlast;
    wire        memrd_axi_m_rvalid;
    wire        memrd_axi_m_rready;

    wire        memrd_s_busy;

    commit_mem_read_ctrl2axi commit_mem_read_ctrl2axi_INST (
        .clk                        (clk),
        .resetn                     (resetn),

        //
        .s_busy                     (memrd_s_busy),

        //
        .i_ctrl_en                  (rdctrl_en),
        .i_ctrl_fid                 (rdctrl_fid),
        .i_ctrl_addr                (rdctrl_addr),
        .i_ctrl_uncached            (rdctrl_uncached),
        .i_ctrl_lswidth             (rdctrl_lswidth),

        //
        .o_rbuffer_uncached_en      (loadbuffer_wea),
        .o_rbuffer_uncached_addr    (loadbuffer_addra),
        .o_rbuffer_uncached_data    (loadbuffer_dina),

        .o_rbuffer_cached_en        (loadbuffer_web),
        .o_rbuffer_cached_addr      (loadbuffer_addrb),
        .o_rbuffer_cached_data      (loadbuffer_dinb),

        .o_rbuffer_cached_clear     (loadbuffer_wec),

        //
        .o_dcache_update_tag_en     (o_dcache_update_tag_en),
        .o_dcache_update_tag_addr   (o_dcache_update_tag_addr),
        .o_dcache_update_tag_valid  (o_dcache_update_tag_valid),

        //
        .o_dcache_update_data_valid (o_dcache_update_data_valid),
        .o_dcache_update_data_addr  (o_dcache_update_data_addr),
        .o_dcache_update_data_strb  (o_dcache_update_data_strb),
        .o_dcache_update_data       (o_dcache_update_data),
        
        .i_dcache_update_data_ready (i_dcache_update_data_ready),

        //
        .axi_m_arid                 (memrd_axi_m_arid),
        .axi_m_araddr               (memrd_axi_m_araddr),
        .axi_m_arlen                (memrd_axi_m_arlen),
        .axi_m_arsize               (memrd_axi_m_arsize),
        .axi_m_arburst              (memrd_axi_m_arburst),
        .axi_m_aruser               (memrd_axi_m_aruser),
        .axi_m_arvalid              (memrd_axi_m_arvalid),
        .axi_m_arready              (memrd_axi_m_arready),

        //
        .axi_m_rid                  (memrd_axi_m_rid),
        .axi_m_rdata                (memrd_axi_m_rdata),
        .axi_m_rresp                (memrd_axi_m_rresp),
        .axi_m_rlast                (memrd_axi_m_rlast),
        .axi_m_rvalid               (memrd_axi_m_rvalid),
        .axi_m_rready               (memrd_axi_m_rready)
    );


    // TODO: Post-commit snoop filter
    //
    commit_logic commit_logic_INST (
        .clk                    (clk),
        .resetn                 (resetn),

        //
        .o_snooptable_qaddr     (),
        .i_snooptable_qhit      (1'b0),

        //
        .o_snoop_hit            (),

        //
        .s_busy_uncached_store  (s_busy_uncached_store),

        //
        .i_valid                (i_valid),
        .i_ready                (i_ready),
        .i_pc                   (i_pc),
        .i_rob                  (i_rob),
        .i_dst                  (i_dst),
        .i_value                (i_value),
        .i_fid                  (i_fid),
        .i_load                 (i_load),
        .i_store                (i_store),
        .i_lswidth              (i_lswidth),
        .i_lsmiss               (i_lsmiss),
        .i_cmtdelay             (i_cmtdelay),

        .i_bco_valid            (i_bco_valid),
        .i_bco_pattern          (i_bco_pattern),
        .i_bco_taken            (i_bco_taken),
        .i_bco_target           (i_bco_target),

        //
        .o_en                   (o_en),
        .o_store                (o_store),
        .o_fid                  (o_fid),
        .o_dst                  (o_dst),
        .o_result               (o_result),

        .o_bco_valid            (o_bco_valid),
        .o_bco_pc               (o_bco_pc),
        .o_bco_pattern          (o_bco_pattern),
        .o_bco_taken            (o_bco_taken),
        .o_bco_target           (o_bco_target),

        //
        .o_nowb_en              (o_nowb_en),
        .o_nowb_dst_rob         (o_nowb_dst_rob),
        .o_nowb_value           (o_nowb_value),

        //
        .o_loadbuffer_qaddr     (loadbuffer_qaddr),

        .i_loadbuffer_qhit      (loadbuffer_qhit),
        .i_loadbuffer_qdata     (loadbuffer_qdata),

        //
        .o_rdctrl_en            (rdctrl_en),
        .o_rdctrl_fid           (rdctrl_fid),
        .o_rdctrl_addr          (rdctrl_addr),
        .o_rdctrl_uncached      (rdctrl_uncached),
        .o_rdctrl_lswidth       (rdctrl_lswidth),

        //
        .o_mem_store_en         (o_mem_store_en),

        .i_mem_readyn           (i_mem_readyn)
    );


`ifdef ENABLE_AXI_BUS_REGISTER_SLICE
    //
    commit_axi_register_slice commit_axi_register_slice_INST (
        .aclk           (clk),
        .aresetn        (resetn),

        //
        .s_axi_awid     (memwr_axi_m_awid),
        .s_axi_awaddr   (memwr_axi_m_awaddr),
        .s_axi_awlen    (memwr_axi_m_awlen),
        .s_axi_awsize   (memwr_axi_m_awsize),
        .s_axi_awburst  (memwr_axi_m_awburst),
        .s_axi_awuser   (memwr_axi_m_awuser),
        .s_axi_awvalid  (memwr_axi_m_awvalid),
        .s_axi_awready  (memwr_axi_m_awready),

        .s_axi_wdata    (memwr_axi_m_wdata),
        .s_axi_wstrb    (memwr_axi_m_wstrb),
        .s_axi_wlast    (memwr_axi_m_wlast),
        .s_axi_wvalid   (memwr_axi_m_wvalid),
        .s_axi_wready   (memwr_axi_m_wready),

        .s_axi_bid      (memwr_axi_m_bid),
        .s_axi_bresp    (memwr_axi_m_bresp),
        .s_axi_bvalid   (memwr_axi_m_bvalid),
        .s_axi_bready   (memwr_axi_m_bready),

        //
        .s_axi_arid     (memrd_axi_m_arid),
        .s_axi_araddr   (memrd_axi_m_araddr),
        .s_axi_arlen    (memrd_axi_m_arlen),
        .s_axi_arsize   (memrd_axi_m_arsize),
        .s_axi_arburst  (memrd_axi_m_arburst),
        .s_axi_aruser   (memrd_axi_m_aruser),
        .s_axi_arvalid  (memrd_axi_m_arvalid),
        .s_axi_arready  (memrd_axi_m_arready),

        .s_axi_rid      (memrd_axi_m_rid),
        .s_axi_rdata    (memrd_axi_m_rdata),
        .s_axi_rresp    (memrd_axi_m_rresp),
        .s_axi_rlast    (memrd_axi_m_rlast),
        .s_axi_rvalid   (memrd_axi_m_rvalid),
        .s_axi_rready   (memrd_axi_m_rready),

        //
        .m_axi_awid     (axi_m_awid),
        .m_axi_awaddr   (axi_m_awaddr),
        .m_axi_awlen    (axi_m_awlen),
        .m_axi_awsize   (axi_m_awsize),
        .m_axi_awburst  (axi_m_awburst),
        .m_axi_awuser   (axi_m_awuser),
        .m_axi_awvalid  (axi_m_awvalid),
        .m_axi_awready  (axi_m_awready),

        .m_axi_wdata    (axi_m_wdata),
        .m_axi_wstrb    (axi_m_wstrb),
        .m_axi_wlast    (axi_m_wlast),
        .m_axi_wvalid   (axi_m_wvalid),
        .m_axi_wready   (axi_m_wready),

        .m_axi_bid      (axi_m_bid),
        .m_axi_bresp    (axi_m_bresp),
        .m_axi_bvalid   (axi_m_bvalid),
        .m_axi_bready   (axi_m_bready),

        //
        .m_axi_arid     (axi_m_arid),
        .m_axi_araddr   (axi_m_araddr),
        .m_axi_arlen    (axi_m_arlen),
        .m_axi_arsize   (axi_m_arsize),
        .m_axi_arburst  (axi_m_arburst),
        .m_axi_aruser   (axi_m_aruser),
        .m_axi_arvalid  (axi_m_arvalid),
        .m_axi_arready  (axi_m_arready),

        .m_axi_rid      (axi_m_rid),
        .m_axi_rdata    (axi_m_rdata),
        .m_axi_rresp    (axi_m_rresp),
        .m_axi_rlast    (axi_m_rlast),
        .m_axi_rvalid   (axi_m_rvalid),
        .m_axi_rready   (axi_m_rready)
    );

`else

    //
    assign axi_m_awid           = memwr_axi_m_awid;
    assign axi_m_awaddr         = memwr_axi_m_awaddr;
    assign axi_m_awlen          = memwr_axi_m_awlen;
    assign axi_m_awsize         = memwr_axi_m_awsize;
    assign axi_m_awburst        = memwr_axi_m_awburst;
    assign axi_m_awuser         = memwr_axi_m_awuser;
    assign axi_m_awvalid        = memwr_axi_m_awvalid;
    assign memwr_axi_m_awready  = axi_m_awready;

    assign axi_m_wdata          = memwr_axi_m_wdata;
    assign axi_m_wstrb          = memwr_axi_m_wstrb;
    assign axi_m_wlast          = memwr_axi_m_wlast;
    assign axi_m_wvalid         = memwr_axi_m_wvalid;
    assign memwr_axi_m_wready   = axi_m_wready;

    assign memwr_axi_m_bid      = axi_m_bid;
    assign memwr_axi_m_bresp    = axi_m_bresp;
    assign memwr_axi_m_bvalid   = axi_m_bvalid;
    assign axi_m_bready         = memwr_axi_m_bready;

    //
    assign axi_m_arid           = memrd_axi_m_arid;
    assign axi_m_araddr         = memrd_axi_m_araddr;
    assign axi_m_arlen          = memrd_axi_m_arlen;
    assign axi_m_arsize         = memrd_axi_m_arsize;
    assign axi_m_arburst        = memrd_axi_m_arburst;
    assign axi_m_aruser         = memrd_axi_m_aruser;
    assign axi_m_arvalid        = memrd_axi_m_arvalid;
    assign memrd_axi_m_arready  = axi_m_arready;

    assign memrd_axi_m_rid      = axi_m_rid;
    assign memrd_axi_m_rdata    = axi_m_rdata;
    assign memrd_axi_m_rresp    = axi_m_rresp;
    assign memrd_axi_m_rlast    = axi_m_rlast;
    assign memrd_axi_m_rvalid   = axi_m_rvalid;
    assign axi_m_rready         = memrd_axi_m_rready;
`endif

    //
    assign s_busy = loadbuffer_s_busy || memrd_s_busy;

    //

endmodule
