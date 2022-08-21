`define     ENABLE_SLAVE0_AXI_REGISTER_SLICE
`define     ENABLE_SLAVE1_AXI_REGISTER_SLICE
`define     ENABLE_SLAVE2_AXI_REGISTER_SLICE
`define     ENABLE_SLAVE3_AXI_REGISTER_SLICE


`define     MMU_WRITE_CHANNEL_IDLE          1'b0
`define     MMU_WRITE_CHANNEL_EXCLUSIVE     1'b1

`define     MMU_READ_CHANNEL_IDLE           1'b0
`define     MMU_READ_CHANNEL_EXCLUSIVE      1'b1

module soc_axi_mmu (
    input   wire            clk,
    input   wire            resetn,

    // AXI Slave Interface
    input   wire [3:0]      axi_s_awid,
    input   wire [31:0]     axi_s_awaddr,
    input   wire [7:0]      axi_s_awlen,
    input   wire [2:0]      axi_s_awsize,
    input   wire [1:0]      axi_s_awburst,
    input   wire            axi_s_awuser,
    input   wire            axi_s_awvalid,
    output  wire            axi_s_awready,

    input   wire [31:0]     axi_s_wdata,
    input   wire [3:0]      axi_s_wstrb,
    input   wire            axi_s_wlast,
    input   wire            axi_s_wvalid,
    output  wire            axi_s_wready,

    output  wire [3:0]      axi_s_bid,
    output  wire [1:0]      axi_s_bresp,
    output  wire            axi_s_bvalid,
    input   wire            axi_s_bready,

    input   wire [3:0]      axi_s_arid,
    input   wire [31:0]     axi_s_araddr,
    input   wire [7:0]      axi_s_arlen,
    input   wire [2:0]      axi_s_arsize,
    input   wire [1:0]      axi_s_arburst,
    input   wire            axi_s_aruser,
    input   wire            axi_s_arvalid,
    output  wire            axi_s_arready,

    output  wire [3:0]      axi_s_rid,
    output  wire [31:0]     axi_s_rdata,
    output  wire [1:0]      axi_s_rresp,
    output  wire            axi_s_rlast,
    output  wire            axi_s_rvalid,
    input   wire            axi_s_rready,

    // AXI Master Interface 0
    output  wire [3:0]      axi_m0_awid,
    output  wire [31:0]     axi_m0_awaddr,
    output  wire [7:0]      axi_m0_awlen,
    output  wire [2:0]      axi_m0_awsize,
    output  wire [1:0]      axi_m0_awburst,
    output  wire            axi_m0_awuser,
    output  wire            axi_m0_awvalid,
    input   wire            axi_m0_awready,

    output  wire [31:0]     axi_m0_wdata,
    output  wire [3:0]      axi_m0_wstrb,
    output  wire            axi_m0_wlast,
    output  wire            axi_m0_wvalid,
    input   wire            axi_m0_wready,

    input   wire [3:0]      axi_m0_bid,
    input   wire [1:0]      axi_m0_bresp,
    input   wire            axi_m0_bvalid,
    output  wire            axi_m0_bready,

    output  wire [3:0]      axi_m0_arid,
    output  wire [31:0]     axi_m0_araddr,
    output  wire [7:0]      axi_m0_arlen,
    output  wire [2:0]      axi_m0_arsize,
    output  wire [1:0]      axi_m0_arburst,
    output  wire            axi_m0_aruser,
    output  wire            axi_m0_arvalid,
    input   wire            axi_m0_arready,

    input   wire [3:0]      axi_m0_rid,
    input   wire [31:0]     axi_m0_rdata,
    input   wire [1:0]      axi_m0_rresp,
    input   wire            axi_m0_rlast,
    input   wire            axi_m0_rvalid,
    output  wire            axi_m0_rready,

    // AXI Master Interface 1
    output  wire [3:0]      axi_m1_awid,
    output  wire [31:0]     axi_m1_awaddr,
    output  wire [7:0]      axi_m1_awlen,
    output  wire [2:0]      axi_m1_awsize,
    output  wire [1:0]      axi_m1_awburst,
    output  wire            axi_m1_awuser,
    output  wire            axi_m1_awvalid,
    input   wire            axi_m1_awready,

    output  wire [31:0]     axi_m1_wdata,
    output  wire [3:0]      axi_m1_wstrb,
    output  wire            axi_m1_wlast,
    output  wire            axi_m1_wvalid,
    input   wire            axi_m1_wready,

    input   wire [3:0]      axi_m1_bid,
    input   wire [1:0]      axi_m1_bresp,
    input   wire            axi_m1_bvalid,
    output  wire            axi_m1_bready,

    output  wire [3:0]      axi_m1_arid,
    output  wire [31:0]     axi_m1_araddr,
    output  wire [7:0]      axi_m1_arlen,
    output  wire [2:0]      axi_m1_arsize,
    output  wire [1:0]      axi_m1_arburst,
    output  wire            axi_m1_aruser,
    output  wire            axi_m1_arvalid,
    input   wire            axi_m1_arready,

    input   wire [3:0]      axi_m1_rid,
    input   wire [31:0]     axi_m1_rdata,
    input   wire [1:0]      axi_m1_rresp,
    input   wire            axi_m1_rlast,
    input   wire            axi_m1_rvalid,
    output  wire            axi_m1_rready,

    // AXI Master Interface 2
    output  wire [3:0]      axi_m2_awid,
    output  wire [31:0]     axi_m2_awaddr,
    output  wire [7:0]      axi_m2_awlen,
    output  wire [2:0]      axi_m2_awsize,
    output  wire [1:0]      axi_m2_awburst,
    output  wire            axi_m2_awuser,
    output  wire            axi_m2_awvalid,
    input   wire            axi_m2_awready,

    output  wire [31:0]     axi_m2_wdata,
    output  wire [3:0]      axi_m2_wstrb,
    output  wire            axi_m2_wlast,
    output  wire            axi_m2_wvalid,
    input   wire            axi_m2_wready,

    input   wire [3:0]      axi_m2_bid,
    input   wire [1:0]      axi_m2_bresp,
    input   wire            axi_m2_bvalid,
    output  wire            axi_m2_bready,

    output  wire [3:0]      axi_m2_arid,
    output  wire [31:0]     axi_m2_araddr,
    output  wire [7:0]      axi_m2_arlen,
    output  wire [2:0]      axi_m2_arsize,
    output  wire [1:0]      axi_m2_arburst,
    output  wire            axi_m2_aruser,
    output  wire            axi_m2_arvalid,
    input   wire            axi_m2_arready,

    input   wire [3:0]      axi_m2_rid,
    input   wire [31:0]     axi_m2_rdata,
    input   wire [1:0]      axi_m2_rresp,
    input   wire            axi_m2_rlast,
    input   wire            axi_m2_rvalid,
    output  wire            axi_m2_rready,

    // AXI Master Interface 3
    output  wire [3:0]      axi_m3_awid,
    output  wire [31:0]     axi_m3_awaddr,
    output  wire [7:0]      axi_m3_awlen,
    output  wire [2:0]      axi_m3_awsize,
    output  wire [1:0]      axi_m3_awburst,
    output  wire            axi_m3_awuser,
    output  wire            axi_m3_awvalid,
    input   wire            axi_m3_awready,

    output  wire [31:0]     axi_m3_wdata,
    output  wire [3:0]      axi_m3_wstrb,
    output  wire            axi_m3_wlast,
    output  wire            axi_m3_wvalid,
    input   wire            axi_m3_wready,

    input   wire [3:0]      axi_m3_bid,
    input   wire [1:0]      axi_m3_bresp,
    input   wire            axi_m3_bvalid,
    output  wire            axi_m3_bready,

    output  wire [3:0]      axi_m3_arid,
    output  wire [31:0]     axi_m3_araddr,
    output  wire [7:0]      axi_m3_arlen,
    output  wire [2:0]      axi_m3_arsize,
    output  wire [1:0]      axi_m3_arburst,
    output  wire            axi_m3_aruser,
    output  wire            axi_m3_arvalid,
    input   wire            axi_m3_arready,

    input   wire [3:0]      axi_m3_rid,
    input   wire [31:0]     axi_m3_rdata,
    input   wire [1:0]      axi_m3_rresp,
    input   wire            axi_m3_rlast,
    input   wire            axi_m3_rvalid,
    output  wire            axi_m3_rready,

    // AXI Master Interface X (Address decoding failure Fall-through)
    output  wire [3:0]      axi_mx_awid,
    output  wire [31:0]     axi_mx_awaddr,
    output  wire [7:0]      axi_mx_awlen,
    output  wire [2:0]      axi_mx_awsize,
    output  wire [1:0]      axi_mx_awburst,
    output  wire            axi_mx_awuser,
    output  wire            axi_mx_awvalid,
    input   wire            axi_mx_awready,

    output  wire [31:0]     axi_mx_wdata,
    output  wire [3:0]      axi_mx_wstrb,
    output  wire            axi_mx_wlast,
    output  wire            axi_mx_wvalid,
    input   wire            axi_mx_wready,

    input   wire [3:0]      axi_mx_bid,
    input   wire [1:0]      axi_mx_bresp,
    input   wire            axi_mx_bvalid,
    output  wire            axi_mx_bready,

    output  wire [3:0]      axi_mx_arid,
    output  wire [31:0]     axi_mx_araddr,
    output  wire [7:0]      axi_mx_arlen,
    output  wire [2:0]      axi_mx_arsize,
    output  wire [1:0]      axi_mx_arburst,
    output  wire            axi_mx_aruser,
    output  wire            axi_mx_arvalid,
    input   wire            axi_mx_arready,

    input   wire [3:0]      axi_mx_rid,
    input   wire [31:0]     axi_mx_rdata,
    input   wire [1:0]      axi_mx_rresp,
    input   wire            axi_mx_rlast,
    input   wire            axi_mx_rvalid,
    output  wire            axi_mx_rready
);


    //
    wire [3:0]  isolated_axi_m0_awid;
    wire [31:0] isolated_axi_m0_awaddr;
    wire [7:0]  isolated_axi_m0_awlen;
    wire [2:0]  isolated_axi_m0_awsize;
    wire [1:0]  isolated_axi_m0_awburst;
    wire        isolated_axi_m0_awuser;
    wire        isolated_axi_m0_awvalid;
    wire        isolated_axi_m0_awready;

    wire [31:0] isolated_axi_m0_wdata;
    wire [3:0]  isolated_axi_m0_wstrb;
    wire        isolated_axi_m0_wlast;
    wire        isolated_axi_m0_wvalid;
    wire        isolated_axi_m0_wready;

    wire [3:0]  isolated_axi_m0_bid;
    wire [1:0]  isolated_axi_m0_bresp;
    wire        isolated_axi_m0_bvalid;
    wire        isolated_axi_m0_bready;

    wire [3:0]  isolated_axi_m0_arid;
    wire [31:0] isolated_axi_m0_araddr;
    wire [7:0]  isolated_axi_m0_arlen;
    wire [2:0]  isolated_axi_m0_arsize;
    wire [1:0]  isolated_axi_m0_arburst;
    wire        isolated_axi_m0_aruser;
    wire        isolated_axi_m0_arvalid;
    wire        isolated_axi_m0_arready;

    wire [3:0]  isolated_axi_m0_rid;
    wire [31:0] isolated_axi_m0_rdata;
    wire [1:0]  isolated_axi_m0_rresp;
    wire        isolated_axi_m0_rlast;
    wire        isolated_axi_m0_rvalid;
    wire        isolated_axi_m0_rready;

`ifdef ENABLE_SLAVE0_AXI_REGISTER_SLICE
    //
    soc_axi_mmu_register_slice soc_axi_mmu_register_slice_INST_M0 (
        .aclk           (clk),
        .aresetn        (resetn),

        //
        .s_axi_awid     (isolated_axi_m0_awid),
        .s_axi_awaddr   (isolated_axi_m0_awaddr),
        .s_axi_awlen    (isolated_axi_m0_awlen),
        .s_axi_awsize   (isolated_axi_m0_awsize),
        .s_axi_awburst  (isolated_axi_m0_awburst),
        .s_axi_awuser   (isolated_axi_m0_awuser),
        .s_axi_awvalid  (isolated_axi_m0_awvalid),
        .s_axi_awready  (isolated_axi_m0_awready),

        .s_axi_wdata    (isolated_axi_m0_wdata),
        .s_axi_wstrb    (isolated_axi_m0_wstrb),
        .s_axi_wlast    (isolated_axi_m0_wlast),
        .s_axi_wvalid   (isolated_axi_m0_wvalid),
        .s_axi_wready   (isolated_axi_m0_wready),

        .s_axi_bid      (isolated_axi_m0_bid),
        .s_axi_bresp    (isolated_axi_m0_bresp),
        .s_axi_bvalid   (isolated_axi_m0_bvalid),
        .s_axi_bready   (isolated_axi_m0_bready),

        .s_axi_arid     (isolated_axi_m0_arid),
        .s_axi_araddr   (isolated_axi_m0_araddr),
        .s_axi_arlen    (isolated_axi_m0_arlen),
        .s_axi_arsize   (isolated_axi_m0_arsize),
        .s_axi_arburst  (isolated_axi_m0_arburst),
        .s_axi_aruser   (isolated_axi_m0_aruser),
        .s_axi_arvalid  (isolated_axi_m0_arvalid),
        .s_axi_arready  (isolated_axi_m0_arready),

        .s_axi_rid      (isolated_axi_m0_rid),
        .s_axi_rdata    (isolated_axi_m0_rdata),
        .s_axi_rresp    (isolated_axi_m0_rresp),
        .s_axi_rlast    (isolated_axi_m0_rlast),
        .s_axi_rvalid   (isolated_axi_m0_rvalid),
        .s_axi_rready   (isolated_axi_m0_rready),

        //
        .m_axi_awid     (axi_m0_awid),
        .m_axi_awaddr   (axi_m0_awaddr),
        .m_axi_awlen    (axi_m0_awlen),
        .m_axi_awsize   (axi_m0_awsize),
        .m_axi_awburst  (axi_m0_awburst),
        .m_axi_awuser   (axi_m0_awuser),
        .m_axi_awvalid  (axi_m0_awvalid),
        .m_axi_awready  (axi_m0_awready),

        .m_axi_wdata    (axi_m0_wdata),
        .m_axi_wstrb    (axi_m0_wstrb),
        .m_axi_wlast    (axi_m0_wlast),
        .m_axi_wvalid   (axi_m0_wvalid),
        .m_axi_wready   (axi_m0_wready),

        .m_axi_bid      (axi_m0_bid),
        .m_axi_bresp    (axi_m0_bresp),
        .m_axi_bvalid   (axi_m0_bvalid),
        .m_axi_bready   (axi_m0_bready),

        .m_axi_arid     (axi_m0_arid),
        .m_axi_araddr   (axi_m0_araddr),
        .m_axi_arlen    (axi_m0_arlen),
        .m_axi_arsize   (axi_m0_arsize),
        .m_axi_arburst  (axi_m0_arburst),
        .m_axi_aruser   (axi_m0_aruser),
        .m_axi_arvalid  (axi_m0_arvalid),
        .m_axi_arready  (axi_m0_arready),

        .m_axi_rid      (axi_m0_rid),
        .m_axi_rdata    (axi_m0_rdata),
        .m_axi_rresp    (axi_m0_rresp),
        .m_axi_rlast    (axi_m0_rlast),
        .m_axi_rvalid   (axi_m0_rvalid),
        .m_axi_rready   (axi_m0_rready)
    );
`else

    assign axi_m0_awid              = isolated_axi_m0_awid;
    assign axi_m0_awaddr            = isolated_axi_m0_awaddr;
    assign axi_m0_awlen             = isolated_axi_m0_awlen;
    assign axi_m0_awsize            = isolated_axi_m0_awsize;
    assign axi_m0_awburst           = isolated_axi_m0_awburst;
    assign axi_m0_awuser            = isolated_axi_m0_awuser;
    assign axi_m0_awvalid           = isolated_axi_m0_awvalid;
    assign isolated_axi_m0_awready  = axi_m0_awready;

    assign axi_m0_wdata             = isolated_axi_m0_wdata;
    assign axi_m0_wstrb             = isolated_axi_m0_wstrb;
    assign axi_m0_wlast             = isolated_axi_m0_wlast;
    assign axi_m0_wvalid            = isolated_axi_m0_wvalid;
    assign isolated_axi_m0_wready   = axi_m0_wready;

    assign isolated_axi_m0_bid      = axi_m0_bid;
    assign isolated_axi_m0_bresp    = axi_m0_bresp;
    assign isolated_axi_m0_bvalid   = axi_m0_bvalid;
    assign axi_m0_bready            = isolated_axi_m0_bready;

    assign axi_m0_arid              = isolated_axi_m0_arid;
    assign axi_m0_araddr            = isolated_axi_m0_araddr;
    assign axi_m0_arlen             = isolated_axi_m0_arlen;
    assign axi_m0_arsize            = isolated_axi_m0_arsize;
    assign axi_m0_arburst           = isolated_axi_m0_arburst;
    assign axi_m0_aruser            = isolated_axi_m0_aruser;
    assign axi_m0_arvalid           = isolated_axi_m0_arvalid;
    assign isolated_axi_m0_arready  = axi_m0_arready;

    assign isolated_axi_m0_rid      = axi_m0_rid;
    assign isolated_axi_m0_rdata    = axi_m0_rdata;
    assign isolated_axi_m0_rresp    = axi_m0_rresp;
    assign isolated_axi_m0_rlast    = axi_m0_rlast;
    assign isolated_axi_m0_rvalid   = axi_m0_rvalid;
    assign axi_m0_rready            = isolated_axi_m0_rready;
`endif


    //
    wire [3:0]  isolated_axi_m1_awid;
    wire [31:0] isolated_axi_m1_awaddr;
    wire [7:0]  isolated_axi_m1_awlen;
    wire [2:0]  isolated_axi_m1_awsize;
    wire [1:0]  isolated_axi_m1_awburst;
    wire        isolated_axi_m1_awuser;
    wire        isolated_axi_m1_awvalid;
    wire        isolated_axi_m1_awready;

    wire [31:0] isolated_axi_m1_wdata;
    wire [3:0]  isolated_axi_m1_wstrb;
    wire        isolated_axi_m1_wlast;
    wire        isolated_axi_m1_wvalid;
    wire        isolated_axi_m1_wready;

    wire [3:0]  isolated_axi_m1_bid;
    wire [1:0]  isolated_axi_m1_bresp;
    wire        isolated_axi_m1_bvalid;
    wire        isolated_axi_m1_bready;

    wire [3:0]  isolated_axi_m1_arid;
    wire [31:0] isolated_axi_m1_araddr;
    wire [7:0]  isolated_axi_m1_arlen;
    wire [2:0]  isolated_axi_m1_arsize;
    wire [1:0]  isolated_axi_m1_arburst;
    wire        isolated_axi_m1_aruser;
    wire        isolated_axi_m1_arvalid;
    wire        isolated_axi_m1_arready;

    wire [3:0]  isolated_axi_m1_rid;
    wire [31:0] isolated_axi_m1_rdata;
    wire [1:0]  isolated_axi_m1_rresp;
    wire        isolated_axi_m1_rlast;
    wire        isolated_axi_m1_rvalid;
    wire        isolated_axi_m1_rready;

`ifdef ENABLE_SLAVE1_AXI_REGISTER_SLICE
    //
    soc_axi_mmu_register_slice soc_axi_mmu_register_slice_INST_M1 (
        .aclk           (clk),
        .aresetn        (resetn),

        //
        .s_axi_awid     (isolated_axi_m1_awid),
        .s_axi_awaddr   (isolated_axi_m1_awaddr),
        .s_axi_awlen    (isolated_axi_m1_awlen),
        .s_axi_awsize   (isolated_axi_m1_awsize),
        .s_axi_awburst  (isolated_axi_m1_awburst),
        .s_axi_awuser   (isolated_axi_m1_awuser),
        .s_axi_awvalid  (isolated_axi_m1_awvalid),
        .s_axi_awready  (isolated_axi_m1_awready),

        .s_axi_wdata    (isolated_axi_m1_wdata),
        .s_axi_wstrb    (isolated_axi_m1_wstrb),
        .s_axi_wlast    (isolated_axi_m1_wlast),
        .s_axi_wvalid   (isolated_axi_m1_wvalid),
        .s_axi_wready   (isolated_axi_m1_wready),

        .s_axi_bid      (isolated_axi_m1_bid),
        .s_axi_bresp    (isolated_axi_m1_bresp),
        .s_axi_bvalid   (isolated_axi_m1_bvalid),
        .s_axi_bready   (isolated_axi_m1_bready),

        .s_axi_arid     (isolated_axi_m1_arid),
        .s_axi_araddr   (isolated_axi_m1_araddr),
        .s_axi_arlen    (isolated_axi_m1_arlen),
        .s_axi_arsize   (isolated_axi_m1_arsize),
        .s_axi_arburst  (isolated_axi_m1_arburst),
        .s_axi_aruser   (isolated_axi_m1_aruser),
        .s_axi_arvalid  (isolated_axi_m1_arvalid),
        .s_axi_arready  (isolated_axi_m1_arready),

        .s_axi_rid      (isolated_axi_m1_rid),
        .s_axi_rdata    (isolated_axi_m1_rdata),
        .s_axi_rresp    (isolated_axi_m1_rresp),
        .s_axi_rlast    (isolated_axi_m1_rlast),
        .s_axi_rvalid   (isolated_axi_m1_rvalid),
        .s_axi_rready   (isolated_axi_m1_rready),

        //
        .m_axi_awid     (axi_m1_awid),
        .m_axi_awaddr   (axi_m1_awaddr),
        .m_axi_awlen    (axi_m1_awlen),
        .m_axi_awsize   (axi_m1_awsize),
        .m_axi_awburst  (axi_m1_awburst),
        .m_axi_awuser   (axi_m1_awuser),
        .m_axi_awvalid  (axi_m1_awvalid),
        .m_axi_awready  (axi_m1_awready),

        .m_axi_wdata    (axi_m1_wdata),
        .m_axi_wstrb    (axi_m1_wstrb),
        .m_axi_wlast    (axi_m1_wlast),
        .m_axi_wvalid   (axi_m1_wvalid),
        .m_axi_wready   (axi_m1_wready),

        .m_axi_bid      (axi_m1_bid),
        .m_axi_bresp    (axi_m1_bresp),
        .m_axi_bvalid   (axi_m1_bvalid),
        .m_axi_bready   (axi_m1_bready),

        .m_axi_arid     (axi_m1_arid),
        .m_axi_araddr   (axi_m1_araddr),
        .m_axi_arlen    (axi_m1_arlen),
        .m_axi_arsize   (axi_m1_arsize),
        .m_axi_arburst  (axi_m1_arburst),
        .m_axi_aruser   (axi_m1_aruser),
        .m_axi_arvalid  (axi_m1_arvalid),
        .m_axi_arready  (axi_m1_arready),

        .m_axi_rid      (axi_m1_rid),
        .m_axi_rdata    (axi_m1_rdata),
        .m_axi_rresp    (axi_m1_rresp),
        .m_axi_rlast    (axi_m1_rlast),
        .m_axi_rvalid   (axi_m1_rvalid),
        .m_axi_rready   (axi_m1_rready)
    );
`else

    assign axi_m1_awid              = isolated_axi_m1_awid;
    assign axi_m1_awaddr            = isolated_axi_m1_awaddr;
    assign axi_m1_awlen             = isolated_axi_m1_awlen;
    assign axi_m1_awsize            = isolated_axi_m1_awsize;
    assign axi_m1_awburst           = isolated_axi_m1_awburst;
    assign axi_m1_awuser            = isolated_axi_m1_awuser;
    assign axi_m1_awvalid           = isolated_axi_m1_awvalid;
    assign isolated_axi_m1_awready  = axi_m1_awready;

    assign axi_m1_wdata             = isolated_axi_m1_wdata;
    assign axi_m1_wstrb             = isolated_axi_m1_wstrb;
    assign axi_m1_wlast             = isolated_axi_m1_wlast;
    assign axi_m1_wvalid            = isolated_axi_m1_wvalid;
    assign isolated_axi_m1_wready   = axi_m1_wready;

    assign isolated_axi_m1_bid      = axi_m1_bid;
    assign isolated_axi_m1_bresp    = axi_m1_bresp;
    assign isolated_axi_m1_bvalid   = axi_m1_bvalid;
    assign axi_m1_bready            = isolated_axi_m1_bready;

    assign axi_m1_arid              = isolated_axi_m1_arid;
    assign axi_m1_araddr            = isolated_axi_m1_araddr;
    assign axi_m1_arlen             = isolated_axi_m1_arlen;
    assign axi_m1_arsize            = isolated_axi_m1_arsize;
    assign axi_m1_arburst           = isolated_axi_m1_arburst;
    assign axi_m1_aruser            = isolated_axi_m1_aruser;
    assign axi_m1_arvalid           = isolated_axi_m1_arvalid;
    assign isolated_axi_m1_arready  = axi_m1_arready;

    assign isolated_axi_m1_rid      = axi_m1_rid;
    assign isolated_axi_m1_rdata    = axi_m1_rdata;
    assign isolated_axi_m1_rresp    = axi_m1_rresp;
    assign isolated_axi_m1_rlast    = axi_m1_rlast;
    assign isolated_axi_m1_rvalid   = axi_m1_rvalid;
    assign axi_m1_rready            = isolated_axi_m1_rready;
`endif


    //
    wire [3:0]  isolated_axi_m2_awid;
    wire [31:0] isolated_axi_m2_awaddr;
    wire [7:0]  isolated_axi_m2_awlen;
    wire [2:0]  isolated_axi_m2_awsize;
    wire [1:0]  isolated_axi_m2_awburst;
    wire        isolated_axi_m2_awuser;
    wire        isolated_axi_m2_awvalid;
    wire        isolated_axi_m2_awready;

    wire [31:0] isolated_axi_m2_wdata;
    wire [3:0]  isolated_axi_m2_wstrb;
    wire        isolated_axi_m2_wlast;
    wire        isolated_axi_m2_wvalid;
    wire        isolated_axi_m2_wready;

    wire [3:0]  isolated_axi_m2_bid;
    wire [1:0]  isolated_axi_m2_bresp;
    wire        isolated_axi_m2_bvalid;
    wire        isolated_axi_m2_bready;

    wire [3:0]  isolated_axi_m2_arid;
    wire [31:0] isolated_axi_m2_araddr;
    wire [7:0]  isolated_axi_m2_arlen;
    wire [2:0]  isolated_axi_m2_arsize;
    wire [1:0]  isolated_axi_m2_arburst;
    wire        isolated_axi_m2_aruser;
    wire        isolated_axi_m2_arvalid;
    wire        isolated_axi_m2_arready;

    wire [3:0]  isolated_axi_m2_rid;
    wire [31:0] isolated_axi_m2_rdata;
    wire [1:0]  isolated_axi_m2_rresp;
    wire        isolated_axi_m2_rlast;
    wire        isolated_axi_m2_rvalid;
    wire        isolated_axi_m2_rready;

    soc_axi_mmu_register_slice soc_axi_mmu_register_slice_INST_M2 (
        .aclk           (clk),
        .aresetn        (resetn),

        //
        .s_axi_awid     (isolated_axi_m2_awid),
        .s_axi_awaddr   (isolated_axi_m2_awaddr),
        .s_axi_awlen    (isolated_axi_m2_awlen),
        .s_axi_awsize   (isolated_axi_m2_awsize),
        .s_axi_awburst  (isolated_axi_m2_awburst),
        .s_axi_awuser   (isolated_axi_m2_awuser),
        .s_axi_awvalid  (isolated_axi_m2_awvalid),
        .s_axi_awready  (isolated_axi_m2_awready),

        .s_axi_wdata    (isolated_axi_m2_wdata),
        .s_axi_wstrb    (isolated_axi_m2_wstrb),
        .s_axi_wlast    (isolated_axi_m2_wlast),
        .s_axi_wvalid   (isolated_axi_m2_wvalid),
        .s_axi_wready   (isolated_axi_m2_wready),

        .s_axi_bid      (isolated_axi_m2_bid),
        .s_axi_bresp    (isolated_axi_m2_bresp),
        .s_axi_bvalid   (isolated_axi_m2_bvalid),
        .s_axi_bready   (isolated_axi_m2_bready),

        .s_axi_arid     (isolated_axi_m2_arid),
        .s_axi_araddr   (isolated_axi_m2_araddr),
        .s_axi_arlen    (isolated_axi_m2_arlen),
        .s_axi_arsize   (isolated_axi_m2_arsize),
        .s_axi_arburst  (isolated_axi_m2_arburst),
        .s_axi_aruser   (isolated_axi_m2_aruser),
        .s_axi_arvalid  (isolated_axi_m2_arvalid),
        .s_axi_arready  (isolated_axi_m2_arready),

        .s_axi_rid      (isolated_axi_m2_rid),
        .s_axi_rdata    (isolated_axi_m2_rdata),
        .s_axi_rresp    (isolated_axi_m2_rresp),
        .s_axi_rlast    (isolated_axi_m2_rlast),
        .s_axi_rvalid   (isolated_axi_m2_rvalid),
        .s_axi_rready   (isolated_axi_m2_rready),

        //
        .m_axi_awid     (axi_m2_awid),
        .m_axi_awaddr   (axi_m2_awaddr),
        .m_axi_awlen    (axi_m2_awlen),
        .m_axi_awsize   (axi_m2_awsize),
        .m_axi_awburst  (axi_m2_awburst),
        .m_axi_awuser   (axi_m2_awuser),
        .m_axi_awvalid  (axi_m2_awvalid),
        .m_axi_awready  (axi_m2_awready),

        .m_axi_wdata    (axi_m2_wdata),
        .m_axi_wstrb    (axi_m2_wstrb),
        .m_axi_wlast    (axi_m2_wlast),
        .m_axi_wvalid   (axi_m2_wvalid),
        .m_axi_wready   (axi_m2_wready),

        .m_axi_bid      (axi_m2_bid),
        .m_axi_bresp    (axi_m2_bresp),
        .m_axi_bvalid   (axi_m2_bvalid),
        .m_axi_bready   (axi_m2_bready),

        .m_axi_arid     (axi_m2_arid),
        .m_axi_araddr   (axi_m2_araddr),
        .m_axi_arlen    (axi_m2_arlen),
        .m_axi_arsize   (axi_m2_arsize),
        .m_axi_arburst  (axi_m2_arburst),
        .m_axi_aruser   (axi_m2_aruser),
        .m_axi_arvalid  (axi_m2_arvalid),
        .m_axi_arready  (axi_m2_arready),

        .m_axi_rid      (axi_m2_rid),
        .m_axi_rdata    (axi_m2_rdata),
        .m_axi_rresp    (axi_m2_rresp),
        .m_axi_rlast    (axi_m2_rlast),
        .m_axi_rvalid   (axi_m2_rvalid),
        .m_axi_rready   (axi_m2_rready)
    );


    //
    wire [3:0]  isolated_axi_m3_awid;
    wire [31:0] isolated_axi_m3_awaddr;
    wire [7:0]  isolated_axi_m3_awlen;
    wire [2:0]  isolated_axi_m3_awsize;
    wire [1:0]  isolated_axi_m3_awburst;
    wire        isolated_axi_m3_awuser;
    wire        isolated_axi_m3_awvalid;
    wire        isolated_axi_m3_awready;

    wire [31:0] isolated_axi_m3_wdata;
    wire [3:0]  isolated_axi_m3_wstrb;
    wire        isolated_axi_m3_wlast;
    wire        isolated_axi_m3_wvalid;
    wire        isolated_axi_m3_wready;

    wire [3:0]  isolated_axi_m3_bid;
    wire [1:0]  isolated_axi_m3_bresp;
    wire        isolated_axi_m3_bvalid;
    wire        isolated_axi_m3_bready;

    wire [3:0]  isolated_axi_m3_arid;
    wire [31:0] isolated_axi_m3_araddr;
    wire [7:0]  isolated_axi_m3_arlen;
    wire [2:0]  isolated_axi_m3_arsize;
    wire [1:0]  isolated_axi_m3_arburst;
    wire        isolated_axi_m3_aruser;
    wire        isolated_axi_m3_arvalid;
    wire        isolated_axi_m3_arready;

    wire [3:0]  isolated_axi_m3_rid;
    wire [31:0] isolated_axi_m3_rdata;
    wire [1:0]  isolated_axi_m3_rresp;
    wire        isolated_axi_m3_rlast;
    wire        isolated_axi_m3_rvalid;
    wire        isolated_axi_m3_rready;

    soc_axi_mmu_register_slice soc_axi_mmu_register_slice_INST_M3 (
        .aclk           (clk),
        .aresetn        (resetn),

        //
        .s_axi_awid     (isolated_axi_m3_awid),
        .s_axi_awaddr   (isolated_axi_m3_awaddr),
        .s_axi_awlen    (isolated_axi_m3_awlen),
        .s_axi_awsize   (isolated_axi_m3_awsize),
        .s_axi_awburst  (isolated_axi_m3_awburst),
        .s_axi_awuser   (isolated_axi_m3_awuser),
        .s_axi_awvalid  (isolated_axi_m3_awvalid),
        .s_axi_awready  (isolated_axi_m3_awready),

        .s_axi_wdata    (isolated_axi_m3_wdata),
        .s_axi_wstrb    (isolated_axi_m3_wstrb),
        .s_axi_wlast    (isolated_axi_m3_wlast),
        .s_axi_wvalid   (isolated_axi_m3_wvalid),
        .s_axi_wready   (isolated_axi_m3_wready),

        .s_axi_bid      (isolated_axi_m3_bid),
        .s_axi_bresp    (isolated_axi_m3_bresp),
        .s_axi_bvalid   (isolated_axi_m3_bvalid),
        .s_axi_bready   (isolated_axi_m3_bready),

        .s_axi_arid     (isolated_axi_m3_arid),
        .s_axi_araddr   (isolated_axi_m3_araddr),
        .s_axi_arlen    (isolated_axi_m3_arlen),
        .s_axi_arsize   (isolated_axi_m3_arsize),
        .s_axi_arburst  (isolated_axi_m3_arburst),
        .s_axi_aruser   (isolated_axi_m3_aruser),
        .s_axi_arvalid  (isolated_axi_m3_arvalid),
        .s_axi_arready  (isolated_axi_m3_arready),

        .s_axi_rid      (isolated_axi_m3_rid),
        .s_axi_rdata    (isolated_axi_m3_rdata),
        .s_axi_rresp    (isolated_axi_m3_rresp),
        .s_axi_rlast    (isolated_axi_m3_rlast),
        .s_axi_rvalid   (isolated_axi_m3_rvalid),
        .s_axi_rready   (isolated_axi_m3_rready),

        //
        .m_axi_awid     (axi_m3_awid),
        .m_axi_awaddr   (axi_m3_awaddr),
        .m_axi_awlen    (axi_m3_awlen),
        .m_axi_awsize   (axi_m3_awsize),
        .m_axi_awburst  (axi_m3_awburst),
        .m_axi_awuser   (axi_m3_awuser),
        .m_axi_awvalid  (axi_m3_awvalid),
        .m_axi_awready  (axi_m3_awready),

        .m_axi_wdata    (axi_m3_wdata),
        .m_axi_wstrb    (axi_m3_wstrb),
        .m_axi_wlast    (axi_m3_wlast),
        .m_axi_wvalid   (axi_m3_wvalid),
        .m_axi_wready   (axi_m3_wready),

        .m_axi_bid      (axi_m3_bid),
        .m_axi_bresp    (axi_m3_bresp),
        .m_axi_bvalid   (axi_m3_bvalid),
        .m_axi_bready   (axi_m3_bready),

        .m_axi_arid     (axi_m3_arid),
        .m_axi_araddr   (axi_m3_araddr),
        .m_axi_arlen    (axi_m3_arlen),
        .m_axi_arsize   (axi_m3_arsize),
        .m_axi_arburst  (axi_m3_arburst),
        .m_axi_aruser   (axi_m3_aruser),
        .m_axi_arvalid  (axi_m3_arvalid),
        .m_axi_arready  (axi_m3_arready),

        .m_axi_rid      (axi_m3_rid),
        .m_axi_rdata    (axi_m3_rdata),
        .m_axi_rresp    (axi_m3_rresp),
        .m_axi_rlast    (axi_m3_rlast),
        .m_axi_rvalid   (axi_m3_rvalid),
        .m_axi_rready   (axi_m3_rready)
    );

    //
    wire [3:0]  isolated_axi_mx_awid;
    wire [31:0] isolated_axi_mx_awaddr;
    wire [7:0]  isolated_axi_mx_awlen;
    wire [2:0]  isolated_axi_mx_awsize;
    wire [1:0]  isolated_axi_mx_awburst;
    wire        isolated_axi_mx_awuser;
    wire        isolated_axi_mx_awvalid;
    wire        isolated_axi_mx_awready;

    wire [31:0] isolated_axi_mx_wdata;
    wire [3:0]  isolated_axi_mx_wstrb;
    wire        isolated_axi_mx_wlast;
    wire        isolated_axi_mx_wvalid;
    wire        isolated_axi_mx_wready;

    wire [3:0]  isolated_axi_mx_bid;
    wire [1:0]  isolated_axi_mx_bresp;
    wire        isolated_axi_mx_bvalid;
    wire        isolated_axi_mx_bready;

    wire [3:0]  isolated_axi_mx_arid;
    wire [31:0] isolated_axi_mx_araddr;
    wire [7:0]  isolated_axi_mx_arlen;
    wire [2:0]  isolated_axi_mx_arsize;
    wire [1:0]  isolated_axi_mx_arburst;
    wire        isolated_axi_mx_aruser;
    wire        isolated_axi_mx_arvalid;
    wire        isolated_axi_mx_arready;

    wire [3:0]  isolated_axi_mx_rid;
    wire [31:0] isolated_axi_mx_rdata;
    wire [1:0]  isolated_axi_mx_rresp;
    wire        isolated_axi_mx_rlast;
    wire        isolated_axi_mx_rvalid;
    wire        isolated_axi_mx_rready;

    soc_axi_mmu_register_slice soc_axi_mmu_register_slice_INST_MX (
        .aclk           (clk),
        .aresetn        (resetn),

        //
        .s_axi_awid     (isolated_axi_mx_awid),
        .s_axi_awaddr   (isolated_axi_mx_awaddr),
        .s_axi_awlen    (isolated_axi_mx_awlen),
        .s_axi_awsize   (isolated_axi_mx_awsize),
        .s_axi_awburst  (isolated_axi_mx_awburst),
        .s_axi_awuser   (isolated_axi_mx_awuser),
        .s_axi_awvalid  (isolated_axi_mx_awvalid),
        .s_axi_awready  (isolated_axi_mx_awready),

        .s_axi_wdata    (isolated_axi_mx_wdata),
        .s_axi_wstrb    (isolated_axi_mx_wstrb),
        .s_axi_wlast    (isolated_axi_mx_wlast),
        .s_axi_wvalid   (isolated_axi_mx_wvalid),
        .s_axi_wready   (isolated_axi_mx_wready),

        .s_axi_bid      (isolated_axi_mx_bid),
        .s_axi_bresp    (isolated_axi_mx_bresp),
        .s_axi_bvalid   (isolated_axi_mx_bvalid),
        .s_axi_bready   (isolated_axi_mx_bready),

        .s_axi_arid     (isolated_axi_mx_arid),
        .s_axi_araddr   (isolated_axi_mx_araddr),
        .s_axi_arlen    (isolated_axi_mx_arlen),
        .s_axi_arsize   (isolated_axi_mx_arsize),
        .s_axi_arburst  (isolated_axi_mx_arburst),
        .s_axi_aruser   (isolated_axi_mx_aruser),
        .s_axi_arvalid  (isolated_axi_mx_arvalid),
        .s_axi_arready  (isolated_axi_mx_arready),

        .s_axi_rid      (isolated_axi_mx_rid),
        .s_axi_rdata    (isolated_axi_mx_rdata),
        .s_axi_rresp    (isolated_axi_mx_rresp),
        .s_axi_rlast    (isolated_axi_mx_rlast),
        .s_axi_rvalid   (isolated_axi_mx_rvalid),
        .s_axi_rready   (isolated_axi_mx_rready),

        //
        .m_axi_awid     (axi_mx_awid),
        .m_axi_awaddr   (axi_mx_awaddr),
        .m_axi_awlen    (axi_mx_awlen),
        .m_axi_awsize   (axi_mx_awsize),
        .m_axi_awburst  (axi_mx_awburst),
        .m_axi_awuser   (axi_mx_awuser),
        .m_axi_awvalid  (axi_mx_awvalid),
        .m_axi_awready  (axi_mx_awready),

        .m_axi_wdata    (axi_mx_wdata),
        .m_axi_wstrb    (axi_mx_wstrb),
        .m_axi_wlast    (axi_mx_wlast),
        .m_axi_wvalid   (axi_mx_wvalid),
        .m_axi_wready   (axi_mx_wready),

        .m_axi_bid      (axi_mx_bid),
        .m_axi_bresp    (axi_mx_bresp),
        .m_axi_bvalid   (axi_mx_bvalid),
        .m_axi_bready   (axi_mx_bready),

        .m_axi_arid     (axi_mx_arid),
        .m_axi_araddr   (axi_mx_araddr),
        .m_axi_arlen    (axi_mx_arlen),
        .m_axi_arsize   (axi_mx_arsize),
        .m_axi_arburst  (axi_mx_arburst),
        .m_axi_aruser   (axi_mx_aruser),
        .m_axi_arvalid  (axi_mx_arvalid),
        .m_axi_arready  (axi_mx_arready),

        .m_axi_rid      (axi_mx_rid),
        .m_axi_rdata    (axi_mx_rdata),
        .m_axi_rresp    (axi_mx_rresp),
        .m_axi_rlast    (axi_mx_rlast),
        .m_axi_rvalid   (axi_mx_rvalid),
        .m_axi_rready   (axi_mx_rready)
    );


    //
    wire        sel_wch0;
    wire        sel_wch1;
    wire        sel_wch2;
    wire        sel_wch3;

    wire        sel_wchx;


    // MI0 Master-to-Slave Write Channel Switch
    assign isolated_axi_m0_awid     = axi_s_awid;
    assign isolated_axi_m0_awaddr   = axi_s_awaddr;
    assign isolated_axi_m0_awlen    = axi_s_awlen;
    assign isolated_axi_m0_awsize   = axi_s_awsize;
    assign isolated_axi_m0_awburst  = axi_s_awburst;
    assign isolated_axi_m0_awuser   = axi_s_awuser;
    assign isolated_axi_m0_awvalid  = axi_s_awvalid & sel_wch0;

    assign isolated_axi_m0_wdata    = axi_s_wdata;
    assign isolated_axi_m0_wstrb    = axi_s_wstrb;
    assign isolated_axi_m0_wlast    = axi_s_wlast;
    assign isolated_axi_m0_wvalid   = axi_s_wvalid  & sel_wch0;

    assign isolated_axi_m0_bready   = axi_s_bready  & sel_wch0;

    // MI1 Master-to-Slave Write Channel Switch
    assign isolated_axi_m1_awid     = axi_s_awid;
    assign isolated_axi_m1_awaddr   = axi_s_awaddr;
    assign isolated_axi_m1_awlen    = axi_s_awlen;
    assign isolated_axi_m1_awsize   = axi_s_awsize;
    assign isolated_axi_m1_awburst  = axi_s_awburst;
    assign isolated_axi_m1_awuser   = axi_s_awuser;
    assign isolated_axi_m1_awvalid  = axi_s_awvalid & sel_wch1;

    assign isolated_axi_m1_wdata    = axi_s_wdata;
    assign isolated_axi_m1_wstrb    = axi_s_wstrb;
    assign isolated_axi_m1_wlast    = axi_s_wlast;
    assign isolated_axi_m1_wvalid   = axi_s_wvalid  & sel_wch1;

    assign isolated_axi_m1_bready   = axi_s_bready  & sel_wch1;

    // MI2 Master-to-Slave Write Channel Switch
    assign isolated_axi_m2_awid     = axi_s_awid;
    assign isolated_axi_m2_awaddr   = axi_s_awaddr;
    assign isolated_axi_m2_awlen    = axi_s_awlen;
    assign isolated_axi_m2_awsize   = axi_s_awsize;
    assign isolated_axi_m2_awburst  = axi_s_awburst;
    assign isolated_axi_m2_awuser   = axi_s_awuser;
    assign isolated_axi_m2_awvalid  = axi_s_awvalid & sel_wch2;

    assign isolated_axi_m2_wdata    = axi_s_wdata;
    assign isolated_axi_m2_wstrb    = axi_s_wstrb;
    assign isolated_axi_m2_wlast    = axi_s_wlast;
    assign isolated_axi_m2_wvalid   = axi_s_wvalid  & sel_wch2;

    assign isolated_axi_m2_bready   = axi_s_bready  & sel_wch2;

    // MI3 Master-to-Slave Write Channel Switch
    assign isolated_axi_m3_awid     = axi_s_awid;
    assign isolated_axi_m3_awaddr   = axi_s_awaddr;
    assign isolated_axi_m3_awlen    = axi_s_awlen;
    assign isolated_axi_m3_awsize   = axi_s_awsize;
    assign isolated_axi_m3_awburst  = axi_s_awburst;
    assign isolated_axi_m3_awuser   = axi_s_awuser;
    assign isolated_axi_m3_awvalid  = axi_s_awvalid & sel_wch3;

    assign isolated_axi_m3_wdata    = axi_s_wdata;
    assign isolated_axi_m3_wstrb    = axi_s_wstrb;
    assign isolated_axi_m3_wlast    = axi_s_wlast;
    assign isolated_axi_m3_wvalid   = axi_s_wvalid  & sel_wch3;

    assign isolated_axi_m3_bready   = axi_s_bready  & sel_wch3;

    // MIx Master-to-Slave Write Channel Switch
    assign isolated_axi_mx_awid     = axi_s_awid;
    assign isolated_axi_mx_awaddr   = axi_s_awaddr;
    assign isolated_axi_mx_awlen    = axi_s_awlen;
    assign isolated_axi_mx_awsize   = axi_s_awsize;
    assign isolated_axi_mx_awburst  = axi_s_awburst;
    assign isolated_axi_mx_awuser   = axi_s_awuser;
    assign isolated_axi_mx_awvalid  = axi_s_awvalid & sel_wchx;

    assign isolated_axi_mx_wdata    = axi_s_wdata;
    assign isolated_axi_mx_wstrb    = axi_s_wstrb;
    assign isolated_axi_mx_wlast    = axi_s_wlast;
    assign isolated_axi_mx_wvalid   = axi_s_wvalid  & sel_wchx;

    assign isolated_axi_mx_bready   = axi_s_bready  & sel_wchx;

    // MI Slave-to-Master Write Channel Switch
    assign axi_s_awready    = sel_wch0 ? isolated_axi_m0_awready
                            : sel_wch1 ? isolated_axi_m1_awready
                            : sel_wch2 ? isolated_axi_m2_awready
                            : sel_wch3 ? isolated_axi_m3_awready
                            : sel_wchx ? isolated_axi_mx_awready
                            : 1'b0;

    assign axi_s_wready     = sel_wch0 ? isolated_axi_m0_wready
                            : sel_wch1 ? isolated_axi_m1_wready
                            : sel_wch2 ? isolated_axi_m2_wready
                            : sel_wch3 ? isolated_axi_m3_wready
                            : sel_wchx ? isolated_axi_mx_wready
                            : 1'b0;

    assign axi_s_bvalid     = sel_wch0 ? isolated_axi_m0_bvalid
                            : sel_wch1 ? isolated_axi_m1_bvalid
                            : sel_wch2 ? isolated_axi_m2_bvalid
                            : sel_wch3 ? isolated_axi_m3_bvalid
                            : sel_wchx ? isolated_axi_mx_bvalid
                            : 1'b0;

    assign axi_s_bid        = sel_wch0 ? isolated_axi_m0_bid
                            : sel_wch1 ? isolated_axi_m1_bid
                            : sel_wch2 ? isolated_axi_m2_bid
                            : sel_wch3 ? isolated_axi_m3_bid
                            :            isolated_axi_mx_bid;

    assign axi_s_bresp      = sel_wch0 ? isolated_axi_m0_bresp
                            : sel_wch1 ? isolated_axi_m1_bresp
                            : sel_wch2 ? isolated_axi_m2_bresp
                            : sel_wch3 ? isolated_axi_m3_bresp
                            :            isolated_axi_mx_bresp;

    
    //
    reg [0:0]   state_wch_R,    state_wch_next;

    always @(posedge clk) begin

        if (~resetn) begin
            state_wch_R <= `MMU_WRITE_CHANNEL_IDLE;
        end
        else begin
            state_wch_R <= state_wch_next;
        end
    end

    always @(*) begin
        
        state_wch_next = state_wch_R;

        case (state_wch_R)

            `MMU_WRITE_CHANNEL_IDLE:    begin
                
                if (axi_s_awvalid) begin
                    state_wch_next = `MMU_WRITE_CHANNEL_EXCLUSIVE;
                end
            end

            `MMU_WRITE_CHANNEL_EXCLUSIVE:   begin

                if (axi_s_bready & axi_s_bvalid) begin
                    state_wch_next = `MMU_WRITE_CHANNEL_IDLE;
                end
            end

            default:    begin
            end
        endcase
    end

    //
    wire        dec_sel_wch0;
    wire        dec_sel_wch1;
    wire        dec_sel_wch2;
    wire        dec_sel_wch3;

    wire        dec_sel_wchx;

    soc_axi_mmu_addrdec soc_axi_mmu_addrdec_INST_WCH (
        //
        .i_addr     (axi_s_awaddr),
        .i_user     (axi_s_awuser),

        //
        .o_sel0     (dec_sel_wch0),
        .o_sel1     (dec_sel_wch1),
        .o_sel2     (dec_sel_wch2),
        .o_sel3     (dec_sel_wch3),
        
        .o_selx     (dec_sel_wchx)
    );

    //
    reg         sel_wch0_R,     sel_wch0_next;
    reg         sel_wch1_R,     sel_wch1_next;
    reg         sel_wch2_R,     sel_wch2_next;
    reg         sel_wch3_R,     sel_wch3_next;

    reg         sel_wchx_R,     sel_wchx_next;

    always @(posedge clk) begin

        if (~resetn) begin

            sel_wch0_R  <= 1'b0;
            sel_wch1_R  <= 1'b0;
            sel_wch2_R  <= 1'b0;
            sel_wch3_R  <= 1'b0;

            sel_wchx_R  <= 1'b0;
        end
        else begin

            sel_wch0_R  <= sel_wch0_next;
            sel_wch1_R  <= sel_wch1_next;
            sel_wch2_R  <= sel_wch2_next;
            sel_wch3_R  <= sel_wch3_next;

            sel_wchx_R  <= sel_wchx_next;
        end
    end

    always @(*) begin

        sel_wch0_next   = sel_wch0_R;
        sel_wch1_next   = sel_wch1_R;
        sel_wch2_next   = sel_wch2_R;
        sel_wch3_next   = sel_wch3_R;

        sel_wchx_next   = sel_wchx_R;

        case (state_wch_R)

            `MMU_WRITE_CHANNEL_IDLE:    begin

                if (state_wch_next == `MMU_WRITE_CHANNEL_EXCLUSIVE) begin

                    sel_wch0_next   = dec_sel_wch0;
                    sel_wch1_next   = dec_sel_wch1;
                    sel_wch2_next   = dec_sel_wch2;
                    sel_wch3_next   = dec_sel_wch3;

                    sel_wchx_next   = dec_sel_wchx;
                end
            end

            `MMU_WRITE_CHANNEL_EXCLUSIVE:   begin

                if (state_wch_next == `MMU_WRITE_CHANNEL_IDLE) begin

                    sel_wch0_next   = 1'b0;
                    sel_wch1_next   = 1'b0;
                    sel_wch2_next   = 1'b0;
                    sel_wch3_next   = 1'b0;

                    sel_wchx_next   = 1'b0;
                end
            end

            default:    begin
            end
        endcase
    end

    assign sel_wch0 = sel_wch0_R;
    assign sel_wch1 = sel_wch1_R;
    assign sel_wch2 = sel_wch2_R;
    assign sel_wch3 = sel_wch3_R;

    assign sel_wchx = sel_wchx_R;


    //
    wire        sel_rch0;
    wire        sel_rch1;
    wire        sel_rch2;
    wire        sel_rch3;

    wire        sel_rchx;

    // MI0 Master-to-Slave Read Channel Switch
    assign isolated_axi_m0_arid     = axi_s_arid;
    assign isolated_axi_m0_araddr   = axi_s_araddr;
    assign isolated_axi_m0_arlen    = axi_s_arlen;
    assign isolated_axi_m0_arsize   = axi_s_arsize;
    assign isolated_axi_m0_arburst  = axi_s_arburst;
    assign isolated_axi_m0_aruser   = axi_s_aruser;
    assign isolated_axi_m0_arvalid  = axi_s_arvalid & sel_rch0;

    assign isolated_axi_m0_rready   = axi_s_rready  & sel_rch0;

    // MI1 Master-to-Slave Read Channel Switch
    assign isolated_axi_m1_arid     = axi_s_arid;
    assign isolated_axi_m1_araddr   = axi_s_araddr;
    assign isolated_axi_m1_arlen    = axi_s_arlen;
    assign isolated_axi_m1_arsize   = axi_s_arsize;
    assign isolated_axi_m1_arburst  = axi_s_arburst;
    assign isolated_axi_m1_aruser   = axi_s_aruser;
    assign isolated_axi_m1_arvalid  = axi_s_arvalid & sel_rch1;

    assign isolated_axi_m1_rready   = axi_s_rready  & sel_rch1;

    // MI2 Master-to-Slave Read Channel Switch
    assign isolated_axi_m2_arid     = axi_s_arid;
    assign isolated_axi_m2_araddr   = axi_s_araddr;
    assign isolated_axi_m2_arlen    = axi_s_arlen;
    assign isolated_axi_m2_arsize   = axi_s_arsize;
    assign isolated_axi_m2_arburst  = axi_s_arburst;
    assign isolated_axi_m2_aruser   = axi_s_aruser;
    assign isolated_axi_m2_arvalid  = axi_s_arvalid & sel_rch2;

    assign isolated_axi_m2_rready   = axi_s_rready  & sel_rch2;

    // MI3 Master-to-Slave Read Channel Switch
    assign isolated_axi_m3_arid     = axi_s_arid;
    assign isolated_axi_m3_araddr   = axi_s_araddr;
    assign isolated_axi_m3_arlen    = axi_s_arlen;
    assign isolated_axi_m3_arsize   = axi_s_arsize;
    assign isolated_axi_m3_arburst  = axi_s_arburst;
    assign isolated_axi_m3_aruser   = axi_s_aruser;
    assign isolated_axi_m3_arvalid  = axi_s_arvalid & sel_rch3;

    assign isolated_axi_m3_rready   = axi_s_rready  & sel_rch3;

    // MIx Master-to-Slave Read Channel Switch
    assign isolated_axi_mx_arid     = axi_s_arid;
    assign isolated_axi_mx_araddr   = axi_s_araddr;
    assign isolated_axi_mx_arlen    = axi_s_arlen;
    assign isolated_axi_mx_arsize   = axi_s_arsize;
    assign isolated_axi_mx_arburst  = axi_s_arburst;
    assign isolated_axi_mx_aruser   = axi_s_aruser;
    assign isolated_axi_mx_arvalid  = axi_s_arvalid & sel_rchx;

    assign isolated_axi_mx_rready   = axi_s_rready  & sel_rchx;

    // MI Slave-to-Master Read Channel Switch
    assign axi_s_arready    = sel_rch0 ? isolated_axi_m0_arready
                            : sel_rch1 ? isolated_axi_m1_arready
                            : sel_rch2 ? isolated_axi_m2_arready
                            : sel_rch3 ? isolated_axi_m3_arready
                            : sel_rchx ? isolated_axi_mx_arready
                            : 1'b0;

    assign axi_s_rid        = sel_rch0 ? isolated_axi_m0_rid
                            : sel_rch1 ? isolated_axi_m1_rid
                            : sel_rch2 ? isolated_axi_m2_rid
                            : sel_rch3 ? isolated_axi_m3_rid
                            :            isolated_axi_mx_rid;

    assign axi_s_rdata      = sel_rch0 ? isolated_axi_m0_rdata
                            : sel_rch1 ? isolated_axi_m1_rdata
                            : sel_rch2 ? isolated_axi_m2_rdata
                            : sel_rch3 ? isolated_axi_m3_rdata
                            :            isolated_axi_mx_rdata;

    assign axi_s_rresp      = sel_rch0 ? isolated_axi_m0_rresp
                            : sel_rch1 ? isolated_axi_m1_rresp
                            : sel_rch2 ? isolated_axi_m2_rresp
                            : sel_rch3 ? isolated_axi_m3_rresp
                            :            isolated_axi_mx_rresp;

    assign axi_s_rlast      = sel_rch0 ? isolated_axi_m0_rlast
                            : sel_rch1 ? isolated_axi_m1_rlast
                            : sel_rch2 ? isolated_axi_m2_rlast
                            : sel_rch3 ? isolated_axi_m3_rlast
                            :            isolated_axi_mx_rlast;

    assign axi_s_rvalid     = sel_rch0 ? isolated_axi_m0_rvalid
                            : sel_rch1 ? isolated_axi_m1_rvalid
                            : sel_rch2 ? isolated_axi_m2_rvalid
                            : sel_rch3 ? isolated_axi_m3_rvalid
                            : sel_rchx ? isolated_axi_mx_rvalid
                            : 1'b0;


    //
    reg [0:0]   state_rch_R,    state_rch_next;

    always @(posedge clk) begin

        if (~resetn) begin
            state_rch_R <= `MMU_READ_CHANNEL_IDLE;
        end
        else begin
            state_rch_R <= state_rch_next;
        end
    end

    always @(*) begin

        state_rch_next = state_rch_R;

        case (state_rch_R)

            `MMU_READ_CHANNEL_IDLE: begin

                if (axi_s_arvalid) begin
                    state_rch_next = `MMU_READ_CHANNEL_EXCLUSIVE;
                end
            end

            `MMU_READ_CHANNEL_EXCLUSIVE:    begin

                if (axi_s_rvalid & axi_s_rlast & axi_s_rready) begin
                    state_rch_next = `MMU_READ_CHANNEL_IDLE;
                end
            end

            default:    begin
            end
        endcase
    end

    //
    wire        dec_sel_rch0;
    wire        dec_sel_rch1;
    wire        dec_sel_rch2;
    wire        dec_sel_rch3;

    wire        dec_sel_rchx;

    soc_axi_mmu_addrdec soc_axi_mmu_addrdec_INST_RCH (
        //
        .i_addr     (axi_s_araddr),
        .i_user     (axi_s_aruser),

        //
        .o_sel0     (dec_sel_rch0),
        .o_sel1     (dec_sel_rch1),
        .o_sel2     (dec_sel_rch2),
        .o_sel3     (dec_sel_rch3),

        .o_selx     (dec_sel_rchx)
    );
    
    //
    reg         sel_rch0_R,     sel_rch0_next;
    reg         sel_rch1_R,     sel_rch1_next;
    reg         sel_rch2_R,     sel_rch2_next;
    reg         sel_rch3_R,     sel_rch3_next;

    reg         sel_rchx_R,     sel_rchx_next;

    always @(posedge clk) begin

        if (~resetn) begin

            sel_rch0_R  <= 1'b0;
            sel_rch1_R  <= 1'b0;
            sel_rch2_R  <= 1'b0;
            sel_rch3_R  <= 1'b0;
        
            sel_rchx_R  <= 1'b0;
        end
        else begin

            sel_rch0_R  <= sel_rch0_next;
            sel_rch1_R  <= sel_rch1_next;
            sel_rch2_R  <= sel_rch2_next;
            sel_rch3_R  <= sel_rch3_next;

            sel_rchx_R  <= sel_rchx_next;
        end
    end

    always @(*) begin
        
        sel_rch0_next   = sel_rch0_R;
        sel_rch1_next   = sel_rch1_R;
        sel_rch2_next   = sel_rch2_R;
        sel_rch3_next   = sel_rch3_R;

        sel_rchx_next   = sel_rchx_R;

        case (state_rch_R)

            `MMU_READ_CHANNEL_IDLE: begin
                
                if (state_rch_next == `MMU_READ_CHANNEL_EXCLUSIVE) begin
                    
                    sel_rch0_next   = dec_sel_rch0;
                    sel_rch1_next   = dec_sel_rch1;
                    sel_rch2_next   = dec_sel_rch2;
                    sel_rch3_next   = dec_sel_rch3;

                    sel_rchx_next   = dec_sel_rchx;
                end
            end

            `MMU_READ_CHANNEL_EXCLUSIVE:    begin

                if (state_rch_next == `MMU_READ_CHANNEL_IDLE) begin

                    sel_rch0_next   = 1'b0;
                    sel_rch1_next   = 1'b0;
                    sel_rch2_next   = 1'b0;
                    sel_rch3_next   = 1'b0;

                    sel_rchx_next   = 1'b0;
                end
            end

            default:    begin
            end
        endcase
    end

    assign sel_rch0 = sel_rch0_R;
    assign sel_rch1 = sel_rch1_R;
    assign sel_rch2 = sel_rch2_R;
    assign sel_rch3 = sel_rch3_R;

    assign sel_rchx = sel_rchx_R;

    //

endmodule
