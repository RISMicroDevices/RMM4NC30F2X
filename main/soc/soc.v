
module soc (
    input   wire            clk_50M,
    input   wire            ext_reset,

    // BaseRAM signals
    inout   wire [31:0]     base_ram_data,
    output  wire [19:0]     base_ram_addr,
    output  wire [3:0]      base_ram_be_n,
    output  wire            base_ram_ce_n,
    output  wire            base_ram_oe_n,
    output  wire            base_ram_we_n,

    // ExtRAM signals
    inout   wire [31:0]     ext_ram_data,
    output  wire [19:0]     ext_ram_addr,
    output  wire [3:0]      ext_ram_be_n,
    output  wire            ext_ram_ce_n,
    output  wire            ext_ram_oe_n,
    output  wire            ext_ram_we_n,

    // USART
    output  wire            txd,
    input   wire            rxd
);

    // MCMM Clock Generation
    wire    mmcm_clk_sys;
    wire    mmcm_clk_periph;
    wire    mmcm_locked;

    soc_mmcm soc_mmcm_INST (
        //
        .clk_in         (clk_50M),
        .reset          (ext_reset),

        //
        .clk_out_sys    (mmcm_clk_sys),
        .clk_out_periph (mmcm_clk_periph),
        .locked         (mmcm_locked)
    );

    //
    wire    sys_clk;
    wire    sys_resetn;

    soc_reset soc_reset_INST_sys (
        //
        .mmcm_clk   (mmcm_clk_sys),
        .mmcm_locked(mmcm_locked),

        //
        .sys_clk    (sys_clk),
        .sys_resetn (sys_resetn)
    );


    //
    wire    periph_clk;
    wire    periph_resetn;

    soc_reset soc_reset_INST_periph (
        //
        .mmcm_clk   (mmcm_clk_periph),
        .mmcm_locked(mmcm_locked),

        .sys_clk    (periph_clk),
        .sys_resetn (periph_resetn)
    );


    //
    wire [3:0]  if_axi_m_arid;
    wire [31:0] if_axi_m_araddr;
    wire [7:0]  if_axi_m_arlen;
    wire [2:0]  if_axi_m_arsize;
    wire [1:0]  if_axi_m_arburst;
    wire        if_axi_m_aruser;
    wire        if_axi_m_arvalid;
    wire        if_axi_m_arready;

    wire [3:0]  if_axi_m_rid;
    wire [31:0] if_axi_m_rdata;
    wire [1:0]  if_axi_m_rresp;
    wire        if_axi_m_rlast;
    wire        if_axi_m_rvalid;
    wire        if_axi_m_rready;

    wire [3:0]  mem_axi_m_awid;
    wire [31:0] mem_axi_m_awaddr;
    wire [7:0]  mem_axi_m_awlen;
    wire [2:0]  mem_axi_m_awsize;
    wire [1:0]  mem_axi_m_awburst;
    wire        mem_axi_m_awuser;
    wire        mem_axi_m_awvalid;
    wire        mem_axi_m_awready;

    wire [31:0] mem_axi_m_wdata;
    wire [3:0]  mem_axi_m_wstrb;
    wire        mem_axi_m_wlast;
    wire        mem_axi_m_wvalid;
    wire        mem_axi_m_wready;

    wire [3:0]  mem_axi_m_bid;
    wire [1:0]  mem_axi_m_bresp;
    wire        mem_axi_m_bvalid;
    wire        mem_axi_m_bready;

    wire [3:0]  mem_axi_m_arid;
    wire [31:0] mem_axi_m_araddr;
    wire [7:0]  mem_axi_m_arlen;
    wire [2:0]  mem_axi_m_arsize;
    wire [1:0]  mem_axi_m_arburst;
    wire        mem_axi_m_aruser;
    wire        mem_axi_m_arvalid;
    wire        mem_axi_m_arready;

    wire [3:0]  mem_axi_m_rid;
    wire [31:0] mem_axi_m_rdata;
    wire [1:0]  mem_axi_m_rresp;
    wire        mem_axi_m_rlast;
    wire        mem_axi_m_rvalid;
    wire        mem_axi_m_rready;

    core core_INST (
        .clk                (sys_clk),
        .resetn             (sys_resetn),

        //
        .if_axi_m_arid      (if_axi_m_arid),
        .if_axi_m_araddr    (if_axi_m_araddr),
        .if_axi_m_arlen     (if_axi_m_arlen),
        .if_axi_m_arsize    (if_axi_m_arsize),
        .if_axi_m_arburst   (if_axi_m_arburst),
        .if_axi_m_aruser    (if_axi_m_aruser),
        .if_axi_m_arvalid   (if_axi_m_arvalid),
        .if_axi_m_arready   (if_axi_m_arready),

        .if_axi_m_rid       (if_axi_m_rid),
        .if_axi_m_rdata     (if_axi_m_rdata),
        .if_axi_m_rresp     (if_axi_m_rresp),
        .if_axi_m_rlast     (if_axi_m_rlast),
        .if_axi_m_rvalid    (if_axi_m_rvalid),
        .if_axi_m_rready    (if_axi_m_rready),

        //
        .mem_axi_m_awid     (mem_axi_m_awid),
        .mem_axi_m_awaddr   (mem_axi_m_awaddr),
        .mem_axi_m_awlen    (mem_axi_m_awlen),
        .mem_axi_m_awsize   (mem_axi_m_awsize),
        .mem_axi_m_awburst  (mem_axi_m_awburst),
        .mem_axi_m_awuser   (mem_axi_m_awuser),
        .mem_axi_m_awvalid  (mem_axi_m_awvalid),
        .mem_axi_m_awready  (mem_axi_m_awready),

        .mem_axi_m_wdata    (mem_axi_m_wdata),
        .mem_axi_m_wstrb    (mem_axi_m_wstrb),
        .mem_axi_m_wlast    (mem_axi_m_wlast),
        .mem_axi_m_wvalid   (mem_axi_m_wvalid),
        .mem_axi_m_wready   (mem_axi_m_wready),

        .mem_axi_m_bid      (mem_axi_m_bid),
        .mem_axi_m_bresp    (mem_axi_m_bresp),
        .mem_axi_m_bvalid   (mem_axi_m_bvalid),
        .mem_axi_m_bready   (mem_axi_m_bready),

        .mem_axi_m_arid     (mem_axi_m_arid),
        .mem_axi_m_araddr   (mem_axi_m_araddr),
        .mem_axi_m_arlen    (mem_axi_m_arlen),
        .mem_axi_m_arsize   (mem_axi_m_arsize),
        .mem_axi_m_arburst  (mem_axi_m_arburst),
        .mem_axi_m_aruser   (mem_axi_m_aruser),
        .mem_axi_m_arvalid  (mem_axi_m_arvalid),
        .mem_axi_m_arready  (mem_axi_m_arready),

        .mem_axi_m_rid      (mem_axi_m_rid),
        .mem_axi_m_rdata    (mem_axi_m_rdata),
        .mem_axi_m_rresp    (mem_axi_m_rresp),
        .mem_axi_m_rlast    (mem_axi_m_rlast),
        .mem_axi_m_rvalid   (mem_axi_m_rvalid),
        .mem_axi_m_rready   (mem_axi_m_rready)
    );

    //
    wire [3:0]  corebus_axi_awid;
    wire [31:0] corebus_axi_awaddr;
    wire [7:0]  corebus_axi_awlen;
    wire [2:0]  corebus_axi_awsize;
    wire [1:0]  corebus_axi_awburst;
    wire        corebus_axi_awuser;
    wire        corebus_axi_awvalid;
    wire        corebus_axi_awready;

    wire [31:0] corebus_axi_wdata;
    wire [3:0]  corebus_axi_wstrb;
    wire        corebus_axi_wlast;
    wire        corebus_axi_wvalid;
    wire        corebus_axi_wready;

    wire [3:0]  corebus_axi_bid;
    wire [1:0]  corebus_axi_bresp;
    wire        corebus_axi_bvalid;
    wire        corebus_axi_bready;

    wire [3:0]  corebus_axi_arid;
    wire [31:0] corebus_axi_araddr;
    wire [7:0]  corebus_axi_arlen;
    wire [2:0]  corebus_axi_arsize;
    wire [1:0]  corebus_axi_arburst;
    wire        corebus_axi_aruser;
    wire        corebus_axi_arvalid;
    wire        corebus_axi_arready;

    wire [3:0]  corebus_axi_rid;
    wire [31:0] corebus_axi_rdata;
    wire [1:0]  corebus_axi_rresp;
    wire        corebus_axi_rlast;
    wire        corebus_axi_rvalid;
    wire        corebus_axi_rready;

    wire [0:0]  UNCONNECTED_crossbar_s_axi_awready;
    wire [0:0]  UNCONNECTED_crossbar_s_axi_wready;
    wire [3:0]  UNCONNECTED_crossbar_s_axi_bid;
    wire [1:0]  UNCONNECTED_crossbar_s_axi_bresp;
    wire [0:0]  UNCONNECTED_crossbar_s_axi_bvalid;  

    axi_crossbar_2to1_xip axi_crossbar_2to1_xip_INST (
        .aclk               (sys_clk),
        .aresetn            (sys_resetn),

        //
        .s_axi_awid         ({ mem_axi_m_awid,      4'b0 }),
        .s_axi_awaddr       ({ mem_axi_m_awaddr,    32'b0 }),
        .s_axi_awlen        ({ mem_axi_m_awlen,     8'b0 }),
        .s_axi_awsize       ({ mem_axi_m_awsize,    3'b0 }),
        .s_axi_awburst      ({ mem_axi_m_awburst,   2'b0 }),
        .s_axi_awuser       ({ mem_axi_m_awuser,    1'b0 }),
        .s_axi_awvalid      ({ mem_axi_m_awvalid,   1'b0 }),
        .s_axi_awready      ({ mem_axi_m_awready,   UNCONNECTED_crossbar_s_axi_awready }),

        .s_axi_wdata        ({ mem_axi_m_wdata,     32'b0 }),
        .s_axi_wstrb        ({ mem_axi_m_wstrb,     4'b0 }),
        .s_axi_wlast        ({ mem_axi_m_wlast,     1'b0 }),
        .s_axi_wvalid       ({ mem_axi_m_wvalid,    1'b0 }),
        .s_axi_wready       ({ mem_axi_m_wready,    UNCONNECTED_crossbar_s_axi_wready }),

        .s_axi_bid          ({ mem_axi_m_bid,       UNCONNECTED_crossbar_s_axi_bid }),
        .s_axi_bresp        ({ mem_axi_m_bresp,     UNCONNECTED_crossbar_s_axi_bresp }),
        .s_axi_bvalid       ({ mem_axi_m_bvalid,    UNCONNECTED_crossbar_s_axi_bvalid }),
        .s_axi_bready       ({ mem_axi_m_bready,    1'b0 }),

        .s_axi_arid         ({ mem_axi_m_arid,      if_axi_m_arid }),
        .s_axi_araddr       ({ mem_axi_m_araddr,    if_axi_m_araddr }),
        .s_axi_arlen        ({ mem_axi_m_arlen,     if_axi_m_arlen }),
        .s_axi_arsize       ({ mem_axi_m_arsize,    if_axi_m_arsize }),
        .s_axi_arburst      ({ mem_axi_m_arburst,   if_axi_m_arburst }),
        .s_axi_aruser       ({ mem_axi_m_aruser,    if_axi_m_aruser }),
        .s_axi_arvalid      ({ mem_axi_m_arvalid,   if_axi_m_arvalid }),
        .s_axi_arready      ({ mem_axi_m_arready,   if_axi_m_arready }),

        .s_axi_rid          ({ mem_axi_m_rid,       if_axi_m_rid }),
        .s_axi_rdata        ({ mem_axi_m_rdata,     if_axi_m_rdata }),
        .s_axi_rresp        ({ mem_axi_m_rresp,     if_axi_m_rresp }),
        .s_axi_rlast        ({ mem_axi_m_rlast,     if_axi_m_rlast }),
        .s_axi_rvalid       ({ mem_axi_m_rvalid,    if_axi_m_rvalid }),
        .s_axi_rready       ({ mem_axi_m_rready,    if_axi_m_rready }),

        //
        .m_axi_awid         (corebus_axi_awid),
        .m_axi_awaddr       (corebus_axi_awaddr),
        .m_axi_awlen        (corebus_axi_awlen),
        .m_axi_awsize       (corebus_axi_awsize),
        .m_axi_awburst      (corebus_axi_awburst),
        .m_axi_awuser       (corebus_axi_awuser),
        .m_axi_awvalid      (corebus_axi_awvalid),
        .m_axi_awready      (corebus_axi_awready),
        
        .m_axi_wdata        (corebus_axi_wdata),
        .m_axi_wstrb        (corebus_axi_wstrb),
        .m_axi_wlast        (corebus_axi_wlast),
        .m_axi_wvalid       (corebus_axi_wvalid),
        .m_axi_wready       (corebus_axi_wready),
        
        .m_axi_bid          (corebus_axi_bid),
        .m_axi_bresp        (corebus_axi_bresp),
        .m_axi_bvalid       (corebus_axi_bvalid),
        .m_axi_bready       (corebus_axi_bready),
        
        .m_axi_arid         (corebus_axi_arid),
        .m_axi_araddr       (corebus_axi_araddr),
        .m_axi_arlen        (corebus_axi_arlen),
        .m_axi_arsize       (corebus_axi_arsize),
        .m_axi_arburst      (corebus_axi_arburst),
        .m_axi_aruser       (corebus_axi_aruser),
        .m_axi_arvalid      (corebus_axi_arvalid),
        .m_axi_arready      (corebus_axi_arready),
        
        .m_axi_rid          (corebus_axi_rid),
        .m_axi_rdata        (corebus_axi_rdata),
        .m_axi_rresp        (corebus_axi_rresp),
        .m_axi_rlast        (corebus_axi_rlast),
        .m_axi_rvalid       (corebus_axi_rvalid),
        .m_axi_rready       (corebus_axi_rready)
    );


    // On-Bus Device 0 - BaseRAM SRAM Controller
    wire [3:0]  axi_m0_awid;
    wire [31:0] axi_m0_awaddr;
    wire [7:0]  axi_m0_awlen;
    wire [2:0]  axi_m0_awsize;
    wire [1:0]  axi_m0_awburst;
    wire        axi_m0_awuser;
    wire        axi_m0_awvalid;
    wire        axi_m0_awready;

    wire [31:0] axi_m0_wdata;
    wire [3:0]  axi_m0_wstrb;
    wire        axi_m0_wlast;
    wire        axi_m0_wvalid;
    wire        axi_m0_wready;

    wire [3:0]  axi_m0_bid;
    wire [1:0]  axi_m0_bresp;
    wire        axi_m0_bvalid;
    wire        axi_m0_bready;

    wire [3:0]  axi_m0_arid;
    wire [31:0] axi_m0_araddr;
    wire [7:0]  axi_m0_arlen;
    wire [2:0]  axi_m0_arsize;
    wire [1:0]  axi_m0_arburst;
    wire        axi_m0_aruser;
    wire        axi_m0_arvalid;
    wire        axi_m0_arready;

    wire [3:0]  axi_m0_rid;
    wire [31:0] axi_m0_rdata;
    wire [1:0]  axi_m0_rresp;
    wire        axi_m0_rlast;
    wire        axi_m0_rvalid;
    wire        axi_m0_rready;

    soc_sram_ctrl2axi soc_sram_ctrl2axi_INST_BASE_RAM (
        .clk                (sys_clk),
        .resetn             (sys_resetn),

        //
        .axi_s_awid         (axi_m0_awid),
        .axi_s_awaddr       (axi_m0_awaddr),
        .axi_s_awlen        (axi_m0_awlen),
        .axi_s_awsize       (axi_m0_awsize),
        .axi_s_awburst      (axi_m0_awburst),
        .axi_s_awuser       (axi_m0_awuser),
        .axi_s_awvalid      (axi_m0_awvalid),
        .axi_s_awready      (axi_m0_awready),
        
        .axi_s_wdata        (axi_m0_wdata),
        .axi_s_wstrb        (axi_m0_wstrb),
        .axi_s_wlast        (axi_m0_wlast),
        .axi_s_wvalid       (axi_m0_wvalid),
        .axi_s_wready       (axi_m0_wready),
        
        .axi_s_bid          (axi_m0_bid),
        .axi_s_bresp        (axi_m0_bresp),
        .axi_s_bvalid       (axi_m0_bvalid),
        .axi_s_bready       (axi_m0_bready),
        
        .axi_s_arid         (axi_m0_arid),
        .axi_s_araddr       (axi_m0_araddr),
        .axi_s_arlen        (axi_m0_arlen),
        .axi_s_arsize       (axi_m0_arsize),
        .axi_s_arburst      (axi_m0_arburst),
        .axi_s_aruser       (axi_m0_aruser),
        .axi_s_arvalid      (axi_m0_arvalid),
        .axi_s_arready      (axi_m0_arready),
        
        .axi_s_rid          (axi_m0_rid),
        .axi_s_rdata        (axi_m0_rdata),
        .axi_s_rresp        (axi_m0_rresp),
        .axi_s_rlast        (axi_m0_rlast),
        .axi_s_rvalid       (axi_m0_rvalid),
        .axi_s_rready       (axi_m0_rready),

        //
        .mem_A              (base_ram_addr),

        .mem_CEN            (base_ram_ce_n),
        .mem_OEN            (base_ram_oe_n),
        .mem_WEN            (base_ram_we_n),

        .mem_BE0N           (base_ram_be_n[0]),
        .mem_BE1N           (base_ram_be_n[1]),
        .mem_BE2N           (base_ram_be_n[2]),
        .mem_BE3N           (base_ram_be_n[3]),

        .mem_D              (base_ram_data)
    );


    // On-Bus Device 1 - ExtRAM SRAM Controller
    wire [3:0]  axi_m1_awid;
    wire [31:0] axi_m1_awaddr;
    wire [7:0]  axi_m1_awlen;
    wire [2:0]  axi_m1_awsize;
    wire [1:0]  axi_m1_awburst;
    wire        axi_m1_awuser;
    wire        axi_m1_awvalid;
    wire        axi_m1_awready;

    wire [31:0] axi_m1_wdata;
    wire [3:0]  axi_m1_wstrb;
    wire        axi_m1_wlast;
    wire        axi_m1_wvalid;
    wire        axi_m1_wready;

    wire [3:0]  axi_m1_bid;
    wire [1:0]  axi_m1_bresp;
    wire        axi_m1_bvalid;
    wire        axi_m1_bready;

    wire [3:0]  axi_m1_arid;
    wire [31:0] axi_m1_araddr;
    wire [7:0]  axi_m1_arlen;
    wire [2:0]  axi_m1_arsize;
    wire [1:0]  axi_m1_arburst;
    wire        axi_m1_aruser;
    wire        axi_m1_arvalid;
    wire        axi_m1_arready;

    wire [3:0]  axi_m1_rid;
    wire [31:0] axi_m1_rdata;
    wire [1:0]  axi_m1_rresp;
    wire        axi_m1_rlast;
    wire        axi_m1_rvalid;
    wire        axi_m1_rready;

    soc_sram_ctrl2axi soc_sram_ctrl2axi_INST_EXT_RAM (
        .clk                (sys_clk),
        .resetn             (sys_resetn),

        //
        .axi_s_awid         (axi_m1_awid),
        .axi_s_awaddr       (axi_m1_awaddr),
        .axi_s_awlen        (axi_m1_awlen),
        .axi_s_awsize       (axi_m1_awsize),
        .axi_s_awburst      (axi_m1_awburst),
        .axi_s_awuser       (axi_m1_awuser),
        .axi_s_awvalid      (axi_m1_awvalid),
        .axi_s_awready      (axi_m1_awready),
        
        .axi_s_wdata        (axi_m1_wdata),
        .axi_s_wstrb        (axi_m1_wstrb),
        .axi_s_wlast        (axi_m1_wlast),
        .axi_s_wvalid       (axi_m1_wvalid),
        .axi_s_wready       (axi_m1_wready),
        
        .axi_s_bid          (axi_m1_bid),
        .axi_s_bresp        (axi_m1_bresp),
        .axi_s_bvalid       (axi_m1_bvalid),
        .axi_s_bready       (axi_m1_bready),
        
        .axi_s_arid         (axi_m1_arid),
        .axi_s_araddr       (axi_m1_araddr),
        .axi_s_arlen        (axi_m1_arlen),
        .axi_s_arsize       (axi_m1_arsize),
        .axi_s_arburst      (axi_m1_arburst),
        .axi_s_aruser       (axi_m1_aruser),
        .axi_s_arvalid      (axi_m1_arvalid),
        .axi_s_arready      (axi_m1_arready),
        
        .axi_s_rid          (axi_m1_rid),
        .axi_s_rdata        (axi_m1_rdata),
        .axi_s_rresp        (axi_m1_rresp),
        .axi_s_rlast        (axi_m1_rlast),
        .axi_s_rvalid       (axi_m1_rvalid),
        .axi_s_rready       (axi_m1_rready),

        //
        .mem_A              (ext_ram_addr),

        .mem_CEN            (ext_ram_ce_n),
        .mem_OEN            (ext_ram_oe_n),
        .mem_WEN            (ext_ram_we_n),

        .mem_BE0N           (ext_ram_be_n[0]),
        .mem_BE1N           (ext_ram_be_n[1]),
        .mem_BE2N           (ext_ram_be_n[2]),
        .mem_BE3N           (ext_ram_be_n[3]),

        .mem_D              (ext_ram_data)
    );


    // On-Bus Device 2 - UART Controller
    wire [3:0]  axi_m2_awid;
    wire [31:0] axi_m2_awaddr;
    wire [7:0]  axi_m2_awlen;
    wire [2:0]  axi_m2_awsize;
    wire [1:0]  axi_m2_awburst;
    wire        axi_m2_awuser;
    wire        axi_m2_awvalid;
    wire        axi_m2_awready;

    wire [31:0] axi_m2_wdata;
    wire [3:0]  axi_m2_wstrb;
    wire        axi_m2_wlast;
    wire        axi_m2_wvalid;
    wire        axi_m2_wready;

    wire [3:0]  axi_m2_bid;
    wire [1:0]  axi_m2_bresp;
    wire        axi_m2_bvalid;
    wire        axi_m2_bready;

    wire [3:0]  axi_m2_arid;
    wire [31:0] axi_m2_araddr;
    wire [7:0]  axi_m2_arlen;
    wire [2:0]  axi_m2_arsize;
    wire [1:0]  axi_m2_arburst;
    wire        axi_m2_aruser;
    wire        axi_m2_arvalid;
    wire        axi_m2_arready;

    wire [3:0]  axi_m2_rid;
    wire [31:0] axi_m2_rdata;
    wire [1:0]  axi_m2_rresp;
    wire        axi_m2_rlast;
    wire        axi_m2_rvalid;
    wire        axi_m2_rready;

    soc_uart_xip_ctrl2axi soc_uart_xip_ctrl2axi_INST (
        .clk_sys            (sys_clk),
        .resetn_sys         (sys_resetn),

        .clk_periph         (periph_clk),
        .resetn_periph      (periph_resetn),

        //
        .axi_s_awid         (axi_m2_awid),
        .axi_s_awaddr       (axi_m2_awaddr),
        .axi_s_awlen        (axi_m2_awlen),
        .axi_s_awsize       (axi_m2_awsize),
        .axi_s_awburst      (axi_m2_awburst),
        .axi_s_awuser       (axi_m2_awuser),
        .axi_s_awvalid      (axi_m2_awvalid),
        .axi_s_awready      (axi_m2_awready),
        
        .axi_s_wdata        (axi_m2_wdata),
        .axi_s_wstrb        (axi_m2_wstrb),
        .axi_s_wlast        (axi_m2_wlast),
        .axi_s_wvalid       (axi_m2_wvalid),
        .axi_s_wready       (axi_m2_wready),
        
        .axi_s_bid          (axi_m2_bid),
        .axi_s_bresp        (axi_m2_bresp),
        .axi_s_bvalid       (axi_m2_bvalid),
        .axi_s_bready       (axi_m2_bready),
        
        .axi_s_arid         (axi_m2_arid),
        .axi_s_araddr       (axi_m2_araddr),
        .axi_s_arlen        (axi_m2_arlen),
        .axi_s_arsize       (axi_m2_arsize),
        .axi_s_arburst      (axi_m2_arburst),
        .axi_s_aruser       (axi_m2_aruser),
        .axi_s_arvalid      (axi_m2_arvalid),
        .axi_s_arready      (axi_m2_arready),
        
        .axi_s_rid          (axi_m2_rid),
        .axi_s_rdata        (axi_m2_rdata),
        .axi_s_rresp        (axi_m2_rresp),
        .axi_s_rlast        (axi_m2_rlast),
        .axi_s_rvalid       (axi_m2_rvalid),
        .axi_s_rready       (axi_m2_rready),

        //
        .uart_tx            (txd),
        .uart_rx            (rxd)
    );


    // On-Bus Device 3 - CoPS devices
    wire [3:0]  axi_m3_awid;
    wire [31:0] axi_m3_awaddr;
    wire [7:0]  axi_m3_awlen;
    wire [2:0]  axi_m3_awsize;
    wire [1:0]  axi_m3_awburst;
    wire        axi_m3_awuser;
    wire        axi_m3_awvalid;
    wire        axi_m3_awready;

    wire [31:0] axi_m3_wdata;
    wire [3:0]  axi_m3_wstrb;
    wire        axi_m3_wlast;
    wire        axi_m3_wvalid;
    wire        axi_m3_wready;

    wire [3:0]  axi_m3_bid;
    wire [1:0]  axi_m3_bresp;
    wire        axi_m3_bvalid;
    wire        axi_m3_bready;

    wire [3:0]  axi_m3_arid;
    wire [31:0] axi_m3_araddr;
    wire [7:0]  axi_m3_arlen;
    wire [2:0]  axi_m3_arsize;
    wire [1:0]  axi_m3_arburst;
    wire        axi_m3_aruser;
    wire        axi_m3_arvalid;
    wire        axi_m3_arready;

    wire [3:0]  axi_m3_rid;
    wire [31:0] axi_m3_rdata;
    wire [1:0]  axi_m3_rresp;
    wire        axi_m3_rlast;
    wire        axi_m3_rvalid;
    wire        axi_m3_rready;

    soc_cops_cordic_sqrt_axi soc_cops_cordic_sqrt_axi_INST (
        .clk                (sys_clk),
        .resetn             (sys_resetn),

        //
        .axi_s_awid         (axi_m3_awid),
        .axi_s_awaddr       (axi_m3_awaddr),
        .axi_s_awlen        (axi_m3_awlen),
        .axi_s_awsize       (axi_m3_awsize),
        .axi_s_awburst      (axi_m3_awburst),
        .axi_s_awuser       (axi_m3_awuser),
        .axi_s_awvalid      (axi_m3_awvalid),
        .axi_s_awready      (axi_m3_awready),
        
        .axi_s_wdata        (axi_m3_wdata),
        .axi_s_wstrb        (axi_m3_wstrb),
        .axi_s_wlast        (axi_m3_wlast),
        .axi_s_wvalid       (axi_m3_wvalid),
        .axi_s_wready       (axi_m3_wready),
        
        .axi_s_bid          (axi_m3_bid),
        .axi_s_bresp        (axi_m3_bresp),
        .axi_s_bvalid       (axi_m3_bvalid),
        .axi_s_bready       (axi_m3_bready),
        
        .axi_s_arid         (axi_m3_arid),
        .axi_s_araddr       (axi_m3_araddr),
        .axi_s_arlen        (axi_m3_arlen),
        .axi_s_arsize       (axi_m3_arsize),
        .axi_s_arburst      (axi_m3_arburst),
        .axi_s_aruser       (axi_m3_aruser),
        .axi_s_arvalid      (axi_m3_arvalid),
        .axi_s_arready      (axi_m3_arready),
        
        .axi_s_rid          (axi_m3_rid),
        .axi_s_rdata        (axi_m3_rdata),
        .axi_s_rresp        (axi_m3_rresp),
        .axi_s_rlast        (axi_m3_rlast),
        .axi_s_rvalid       (axi_m3_rvalid),
        .axi_s_rready       (axi_m3_rready)
    );


    // Address-Out-Of-Bound fall through
    wire [3:0]  axi_mx_awid;
    wire [31:0] axi_mx_awaddr;
    wire [7:0]  axi_mx_awlen;
    wire [2:0]  axi_mx_awsize;
    wire [1:0]  axi_mx_awburst;
    wire        axi_mx_awuser;
    wire        axi_mx_awvalid;
    wire        axi_mx_awready;

    wire [31:0] axi_mx_wdata;
    wire [3:0]  axi_mx_wstrb;
    wire        axi_mx_wlast;
    wire        axi_mx_wvalid;
    wire        axi_mx_wready;

    wire [3:0]  axi_mx_bid;
    wire [1:0]  axi_mx_bresp;
    wire        axi_mx_bvalid;
    wire        axi_mx_bready;

    wire [3:0]  axi_mx_arid;
    wire [31:0] axi_mx_araddr;
    wire [7:0]  axi_mx_arlen;
    wire [2:0]  axi_mx_arsize;
    wire [1:0]  axi_mx_arburst;
    wire        axi_mx_aruser;
    wire        axi_mx_arvalid;
    wire        axi_mx_arready;

    wire [3:0]  axi_mx_rid;
    wire [31:0] axi_mx_rdata;
    wire [1:0]  axi_mx_rresp;
    wire        axi_mx_rlast;
    wire        axi_mx_rvalid;
    wire        axi_mx_rready;


    // Bus MMU
    soc_axi_mmu soc_axi_mmu_INST (
        .clk                (sys_clk),
        .resetn             (sys_resetn),

        //
        .axi_s_awid         (corebus_axi_awid),
        .axi_s_awaddr       (corebus_axi_awaddr),
        .axi_s_awlen        (corebus_axi_awlen),
        .axi_s_awsize       (corebus_axi_awsize),
        .axi_s_awburst      (corebus_axi_awburst),
        .axi_s_awuser       (corebus_axi_awuser),
        .axi_s_awvalid      (corebus_axi_awvalid),
        .axi_s_awready      (corebus_axi_awready),
        
        .axi_s_wdata        (corebus_axi_wdata),
        .axi_s_wstrb        (corebus_axi_wstrb),
        .axi_s_wlast        (corebus_axi_wlast),
        .axi_s_wvalid       (corebus_axi_wvalid),
        .axi_s_wready       (corebus_axi_wready),
        
        .axi_s_bid          (corebus_axi_bid),
        .axi_s_bresp        (corebus_axi_bresp),
        .axi_s_bvalid       (corebus_axi_bvalid),
        .axi_s_bready       (corebus_axi_bready),
        
        .axi_s_arid         (corebus_axi_arid),
        .axi_s_araddr       (corebus_axi_araddr),
        .axi_s_arlen        (corebus_axi_arlen),
        .axi_s_arsize       (corebus_axi_arsize),
        .axi_s_arburst      (corebus_axi_arburst),
        .axi_s_aruser       (corebus_axi_aruser),
        .axi_s_arvalid      (corebus_axi_arvalid),
        .axi_s_arready      (corebus_axi_arready),
        
        .axi_s_rid          (corebus_axi_rid),
        .axi_s_rdata        (corebus_axi_rdata),
        .axi_s_rresp        (corebus_axi_rresp),
        .axi_s_rlast        (corebus_axi_rlast),
        .axi_s_rvalid       (corebus_axi_rvalid),
        .axi_s_rready       (corebus_axi_rready),

        //
        .axi_m0_awid        (axi_m0_awid),
        .axi_m0_awaddr      (axi_m0_awaddr),
        .axi_m0_awlen       (axi_m0_awlen),
        .axi_m0_awsize      (axi_m0_awsize),
        .axi_m0_awburst     (axi_m0_awburst),
        .axi_m0_awuser      (axi_m0_awuser),
        .axi_m0_awvalid     (axi_m0_awvalid),
        .axi_m0_awready     (axi_m0_awready),
        
        .axi_m0_wdata       (axi_m0_wdata),
        .axi_m0_wstrb       (axi_m0_wstrb),
        .axi_m0_wlast       (axi_m0_wlast),
        .axi_m0_wvalid      (axi_m0_wvalid),
        .axi_m0_wready      (axi_m0_wready),
        
        .axi_m0_bid         (axi_m0_bid),
        .axi_m0_bresp       (axi_m0_bresp),
        .axi_m0_bvalid      (axi_m0_bvalid),
        .axi_m0_bready      (axi_m0_bready),
        
        .axi_m0_arid        (axi_m0_arid),
        .axi_m0_araddr      (axi_m0_araddr),
        .axi_m0_arlen       (axi_m0_arlen),
        .axi_m0_arsize      (axi_m0_arsize),
        .axi_m0_arburst     (axi_m0_arburst),
        .axi_m0_aruser      (axi_m0_aruser),
        .axi_m0_arvalid     (axi_m0_arvalid),
        .axi_m0_arready     (axi_m0_arready),
        
        .axi_m0_rid         (axi_m0_rid),
        .axi_m0_rdata       (axi_m0_rdata),
        .axi_m0_rresp       (axi_m0_rresp),
        .axi_m0_rlast       (axi_m0_rlast),
        .axi_m0_rvalid      (axi_m0_rvalid),
        .axi_m0_rready      (axi_m0_rready),

        //
        .axi_m1_awid        (axi_m1_awid),
        .axi_m1_awaddr      (axi_m1_awaddr),
        .axi_m1_awlen       (axi_m1_awlen),
        .axi_m1_awsize      (axi_m1_awsize),
        .axi_m1_awburst     (axi_m1_awburst),
        .axi_m1_awuser      (axi_m1_awuser),
        .axi_m1_awvalid     (axi_m1_awvalid),
        .axi_m1_awready     (axi_m1_awready),
        
        .axi_m1_wdata       (axi_m1_wdata),
        .axi_m1_wstrb       (axi_m1_wstrb),
        .axi_m1_wlast       (axi_m1_wlast),
        .axi_m1_wvalid      (axi_m1_wvalid),
        .axi_m1_wready      (axi_m1_wready),
        
        .axi_m1_bid         (axi_m1_bid),
        .axi_m1_bresp       (axi_m1_bresp),
        .axi_m1_bvalid      (axi_m1_bvalid),
        .axi_m1_bready      (axi_m1_bready),
        
        .axi_m1_arid        (axi_m1_arid),
        .axi_m1_araddr      (axi_m1_araddr),
        .axi_m1_arlen       (axi_m1_arlen),
        .axi_m1_arsize      (axi_m1_arsize),
        .axi_m1_arburst     (axi_m1_arburst),
        .axi_m1_aruser      (axi_m1_aruser),
        .axi_m1_arvalid     (axi_m1_arvalid),
        .axi_m1_arready     (axi_m1_arready),
        
        .axi_m1_rid         (axi_m1_rid),
        .axi_m1_rdata       (axi_m1_rdata),
        .axi_m1_rresp       (axi_m1_rresp),
        .axi_m1_rlast       (axi_m1_rlast),
        .axi_m1_rvalid      (axi_m1_rvalid),
        .axi_m1_rready      (axi_m1_rready),

        //
        .axi_m2_awid        (axi_m2_awid),
        .axi_m2_awaddr      (axi_m2_awaddr),
        .axi_m2_awlen       (axi_m2_awlen),
        .axi_m2_awsize      (axi_m2_awsize),
        .axi_m2_awburst     (axi_m2_awburst),
        .axi_m2_awuser      (axi_m2_awuser),
        .axi_m2_awvalid     (axi_m2_awvalid),
        .axi_m2_awready     (axi_m2_awready),
        
        .axi_m2_wdata       (axi_m2_wdata),
        .axi_m2_wstrb       (axi_m2_wstrb),
        .axi_m2_wlast       (axi_m2_wlast),
        .axi_m2_wvalid      (axi_m2_wvalid),
        .axi_m2_wready      (axi_m2_wready),
        
        .axi_m2_bid         (axi_m2_bid),
        .axi_m2_bresp       (axi_m2_bresp),
        .axi_m2_bvalid      (axi_m2_bvalid),
        .axi_m2_bready      (axi_m2_bready),
        
        .axi_m2_arid        (axi_m2_arid),
        .axi_m2_araddr      (axi_m2_araddr),
        .axi_m2_arlen       (axi_m2_arlen),
        .axi_m2_arsize      (axi_m2_arsize),
        .axi_m2_arburst     (axi_m2_arburst),
        .axi_m2_aruser      (axi_m2_aruser),
        .axi_m2_arvalid     (axi_m2_arvalid),
        .axi_m2_arready     (axi_m2_arready),
        
        .axi_m2_rid         (axi_m2_rid),
        .axi_m2_rdata       (axi_m2_rdata),
        .axi_m2_rresp       (axi_m2_rresp),
        .axi_m2_rlast       (axi_m2_rlast),
        .axi_m2_rvalid      (axi_m2_rvalid),
        .axi_m2_rready      (axi_m2_rready),

        //
        .axi_m3_awid        (axi_m3_awid),
        .axi_m3_awaddr      (axi_m3_awaddr),
        .axi_m3_awlen       (axi_m3_awlen),
        .axi_m3_awsize      (axi_m3_awsize),
        .axi_m3_awburst     (axi_m3_awburst),
        .axi_m3_awuser      (axi_m3_awuser),
        .axi_m3_awvalid     (axi_m3_awvalid),
        .axi_m3_awready     (axi_m3_awready),
        
        .axi_m3_wdata       (axi_m3_wdata),
        .axi_m3_wstrb       (axi_m3_wstrb),
        .axi_m3_wlast       (axi_m3_wlast),
        .axi_m3_wvalid      (axi_m3_wvalid),
        .axi_m3_wready      (axi_m3_wready),
        
        .axi_m3_bid         (axi_m3_bid),
        .axi_m3_bresp       (axi_m3_bresp),
        .axi_m3_bvalid      (axi_m3_bvalid),
        .axi_m3_bready      (axi_m3_bready),
        
        .axi_m3_arid        (axi_m3_arid),
        .axi_m3_araddr      (axi_m3_araddr),
        .axi_m3_arlen       (axi_m3_arlen),
        .axi_m3_arsize      (axi_m3_arsize),
        .axi_m3_arburst     (axi_m3_arburst),
        .axi_m3_aruser      (axi_m3_aruser),
        .axi_m3_arvalid     (axi_m3_arvalid),
        .axi_m3_arready     (axi_m3_arready),
        
        .axi_m3_rid         (axi_m3_rid),
        .axi_m3_rdata       (axi_m3_rdata),
        .axi_m3_rresp       (axi_m3_rresp),
        .axi_m3_rlast       (axi_m3_rlast),
        .axi_m3_rvalid      (axi_m3_rvalid),
        .axi_m3_rready      (axi_m3_rready),

        //
        .axi_mx_awid        (axi_mx_awid),
        .axi_mx_awaddr      (axi_mx_awaddr),
        .axi_mx_awlen       (axi_mx_awlen),
        .axi_mx_awsize      (axi_mx_awsize),
        .axi_mx_awburst     (axi_mx_awburst),
        .axi_mx_awuser      (axi_mx_awuser),
        .axi_mx_awvalid     (axi_mx_awvalid),
        .axi_mx_awready     (axi_mx_awready),
        
        .axi_mx_wdata       (axi_mx_wdata),
        .axi_mx_wstrb       (axi_mx_wstrb),
        .axi_mx_wlast       (axi_mx_wlast),
        .axi_mx_wvalid      (axi_mx_wvalid),
        .axi_mx_wready      (axi_mx_wready),
        
        .axi_mx_bid         (axi_mx_bid),
        .axi_mx_bresp       (axi_mx_bresp),
        .axi_mx_bvalid      (axi_mx_bvalid),
        .axi_mx_bready      (axi_mx_bready),
        
        .axi_mx_arid        (axi_mx_arid),
        .axi_mx_araddr      (axi_mx_araddr),
        .axi_mx_arlen       (axi_mx_arlen),
        .axi_mx_arsize      (axi_mx_arsize),
        .axi_mx_arburst     (axi_mx_arburst),
        .axi_mx_aruser      (axi_mx_aruser),
        .axi_mx_arvalid     (axi_mx_arvalid),
        .axi_mx_arready     (axi_mx_arready),
        
        .axi_mx_rid         (axi_mx_rid),
        .axi_mx_rdata       (axi_mx_rdata),
        .axi_mx_rresp       (axi_mx_rresp),
        .axi_mx_rlast       (axi_mx_rlast),
        .axi_mx_rvalid      (axi_mx_rvalid),
        .axi_mx_rready      (axi_mx_rready)
    );

    //

endmodule
