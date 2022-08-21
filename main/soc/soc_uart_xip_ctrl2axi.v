`define     ENABLE_PERIPH_CLOCK_DOMAIN

`define     UART_AXI_WRITE_CHANNEL_IDLE         2'b00
`define     UART_AXI_WRITE_CHANNEL_ACCEPTED     2'b01
`define     UART_AXI_WRITE_CHANNEL_RESPONSE     2'b10

`define     UART_AXI_READ_CHANNEL_IDLE          2'b00
`define     UART_AXI_READ_CHANNEL_ACCEPTED      2'b01
`define     UART_AXI_READ_CHANNEL_WAIT_ON_READ  2'b10
`define     UART_AXI_READ_CHANNEL_RESPONSE      2'b11

module soc_uart_xip_ctrl2axi (
    //
    input   wire            clk_sys,
    input   wire            resetn_sys,

    //
    input   wire            clk_periph,
    input   wire            resetn_periph,

    // AXI4 SI
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

    // UART Port
    input   wire            uart_rx,
    output  wire            uart_tx
);
    
    // *NOTICE: ATTENTION. This UART-AXI4-Lite bridge to AXI4 bus maintains
    //          NO SUPPORT for any multiple BURST operation, and unaligned single narrow burst.
    //          
    //          Write Channel Response and Read Channel Response from UARTLite IP is isolated.
    //          All error response is ignored (e.g. SLVERR).
    //          Incorrect/Unsupported operation takes ALWAYS NO EFFECT.
    //          Incorrect/Unsupported address read always acknowledges ALL ZERO data read.
    //
    //  W/R Addresses and Register Logics are converted in this module.
    //  - W: 0xBFD003F8 (0x1FD003F8 uncached) -> 0x04 (Transmit data FIFO)
    //  - R: 0xBFD003F8 (0x1FD003F8 uncached) <- 0x00 (Receive data FIFO)
    //  - R: 0xBFD003FC (0x1FD003FC uncached) <- 0x08 (UARTLite status register)


    // AXI4-Lite MI
    wire [3:0]  axi_m_awaddr;
    wire        axi_m_awvalid;
    wire        axi_m_awready;

    wire [31:0] axi_m_wdata;
    wire [3:0]  axi_m_wstrb;
    wire        axi_m_wvalid;
    wire        axi_m_wready;

    wire [1:0]  axi_m_bresp;
    wire        axi_m_bvalid;
    wire        axi_m_bready;

    wire [3:0]  axi_m_araddr;
    wire        axi_m_arvalid;
    wire        axi_m_arready;

    wire [31:0] axi_m_rdata;
    wire [1:0]  axi_m_rresp;
    wire        axi_m_rvalid;
    wire        axi_m_rready;

    // AXI4-Lite MI at Periph Clock Domain (If enabled)
    wire [3:0]  axi_pclk_m_awaddr;
    wire        axi_pclk_m_awvalid;
    wire        axi_pclk_m_awready;

    wire [31:0] axi_pclk_m_wdata;
    wire [3:0]  axi_pclk_m_wstrb;
    wire        axi_pclk_m_wvalid;
    wire        axi_pclk_m_wready;

    wire [1:0]  axi_pclk_m_bresp;
    wire        axi_pclk_m_bvalid;
    wire        axi_pclk_m_bready;

    wire [3:0]  axi_pclk_m_araddr;
    wire        axi_pclk_m_arvalid;
    wire        axi_pclk_m_arready;

    wire [31:0] axi_pclk_m_rdata;
    wire [1:0]  axi_pclk_m_rresp;
    wire        axi_pclk_m_rvalid;
    wire        axi_pclk_m_rready;

    soc_uart_xip soc_uart_xip_INST (

`ifdef ENABLE_PERIPH_CLOCK_DOMAIN
        .s_axi_aclk     (clk_periph),
        .s_axi_aresetn  (resetn_periph),
`else
        .s_axi_aclk     (clk_sys),
        .s_axi_aresetn  (resetn_sys),
`endif

        //
        .s_axi_awaddr   (axi_pclk_m_awaddr),
        .s_axi_awvalid  (axi_pclk_m_awvalid),
        .s_axi_awready  (axi_pclk_m_awready),

        .s_axi_wdata    (axi_pclk_m_wdata),
        .s_axi_wstrb    (axi_pclk_m_wstrb),
        .s_axi_wvalid   (axi_pclk_m_wvalid),
        .s_axi_wready   (axi_pclk_m_wready),

        .s_axi_bresp    (axi_pclk_m_bresp),
        .s_axi_bvalid   (axi_pclk_m_bvalid),
        .s_axi_bready   (axi_pclk_m_bready),

        .s_axi_araddr   (axi_pclk_m_araddr),
        .s_axi_arvalid  (axi_pclk_m_arvalid),
        .s_axi_arready  (axi_pclk_m_arready),

        .s_axi_rdata    (axi_pclk_m_rdata),
        .s_axi_rresp    (axi_pclk_m_rresp),
        .s_axi_rvalid   (axi_pclk_m_rvalid),
        .s_axi_rready   (axi_pclk_m_rready),

        //
        .rx             (uart_rx),
        .tx             (uart_tx)
    );


    

`ifdef ENABLE_PERIPH_CLOCK_DOMAIN

    soc_periph_clock_converter soc_periph_clock_converter_INST (
        //
        .s_axi_aclk     (clk_sys),
        .s_axi_aresetn  (resetn_sys),

        //
        .m_axi_aclk     (clk_periph),
        .m_axi_aresetn  (resetn_periph),

        //
        .s_axi_awaddr   (axi_m_awaddr),
        .s_axi_awvalid  (axi_m_awvalid),
        .s_axi_awready  (axi_m_awready),

        .s_axi_wdata    (axi_m_wdata),
        .s_axi_wstrb    (axi_m_wstrb),
        .s_axi_wvalid   (axi_m_wvalid),
        .s_axi_wready   (axi_m_wready),

        .s_axi_bresp    (axi_m_bresp),
        .s_axi_bvalid   (axi_m_bvalid),
        .s_axi_bready   (axi_m_bready),

        .s_axi_araddr   (axi_m_araddr),
        .s_axi_arvalid  (axi_m_arvalid),
        .s_axi_arready  (axi_m_arready),
        
        .s_axi_rdata    (axi_m_rdata),
        .s_axi_rresp    (axi_m_rresp),
        .s_axi_rvalid   (axi_m_rvalid),
        .s_axi_rready   (axi_m_rready),

        //
        .m_axi_awaddr   (axi_pclk_m_awaddr),
        .m_axi_awvalid  (axi_pclk_m_awvalid),
        .m_axi_awready  (axi_pclk_m_awready),

        .m_axi_wdata    (axi_pclk_m_wdata),
        .m_axi_wstrb    (axi_pclk_m_wstrb),
        .m_axi_wvalid   (axi_pclk_m_wvalid),
        .m_axi_wready   (axi_pclk_m_wready),

        .m_axi_bresp    (axi_pclk_m_bresp),
        .m_axi_bvalid   (axi_pclk_m_bvalid),
        .m_axi_bready   (axi_pclk_m_bready),

        .m_axi_araddr   (axi_pclk_m_araddr),
        .m_axi_arvalid  (axi_pclk_m_arvalid),
        .m_axi_arready  (axi_pclk_m_arready),
        
        .m_axi_rdata    (axi_pclk_m_rdata),
        .m_axi_rresp    (axi_pclk_m_rresp),
        .m_axi_rvalid   (axi_pclk_m_rvalid),
        .m_axi_rready   (axi_pclk_m_rready)
    );
`else

    assign axi_pclk_m_awaddr    = axi_m_awaddr;
    assign axi_pclk_m_awvalid   = axi_m_awvalid;
    assign axi_m_awready        = axi_pclk_m_awready;

    assign axi_pclk_m_wdata     = axi_m_wdata;
    assign axi_pclk_m_wstrb     = axi_m_wstrb;
    assign axi_pclk_m_wvalid    = axi_m_wvalid;
    assign axi_m_wready         = axi_pclk_m_wready;

    assign axi_m_bresp          = axi_pclk_m_bresp;
    assign axi_m_bvalid         = axi_pclk_m_bvalid;
    assign axi_pclk_m_bready    = axi_m_bready;

    assign axi_pclk_m_araddr    = axi_m_araddr;
    assign axi_pclk_m_arvalid   = axi_m_arvalid;
    assign axi_m_arready        = axi_pclk_m_arready;

    assign axi_m_rdata          = axi_pclk_m_rdata;
    assign axi_m_rresp          = axi_pclk_m_rresp;
    assign axi_m_rvalid         = axi_pclk_m_rvalid;
    assign axi_pclk_m_rready    = axi_m_rready;
`endif

    // AXI4 SI at System Clock Domain
    wire [3:0]  axi_sclk_s_awid;
    wire [31:0] axi_sclk_s_awaddr;
    wire [7:0]  axi_sclk_s_awlen;
    wire [2:0]  axi_sclk_s_awsize;
    wire [1:0]  axi_sclk_s_awburst;
    wire        axi_sclk_s_awuser;
    wire        axi_sclk_s_awvalid;
    wire        axi_sclk_s_awready;

    wire [31:0] axi_sclk_s_wdata;
    wire [3:0]  axi_sclk_s_wstrb;
    wire        axi_sclk_s_wlast;
    wire        axi_sclk_s_wvalid;
    wire        axi_sclk_s_wready;

    wire [3:0]  axi_sclk_s_bid;
    wire [1:0]  axi_sclk_s_bresp;
    wire        axi_sclk_s_bvalid;
    wire        axi_sclk_s_bready;

    wire [3:0]  axi_sclk_s_arid;
    wire [31:0] axi_sclk_s_araddr;
    wire [7:0]  axi_sclk_s_arlen;
    wire [2:0]  axi_sclk_s_arsize;
    wire [1:0]  axi_sclk_s_arburst;
    wire        axi_sclk_s_aruser;
    wire        axi_sclk_s_arvalid;
    wire        axi_sclk_s_arready;

    wire [3:0]  axi_sclk_s_rid;
    wire [31:0] axi_sclk_s_rdata;
    wire [1:0]  axi_sclk_s_rresp;
    wire        axi_sclk_s_rlast;
    wire        axi_sclk_s_rvalid;
    wire        axi_sclk_s_rready;

    assign axi_sclk_s_awid      = axi_s_awid;
    assign axi_sclk_s_awaddr    = axi_s_awaddr;
    assign axi_sclk_s_awlen     = axi_s_awlen;
    assign axi_sclk_s_awsize    = axi_s_awsize;
    assign axi_sclk_s_awburst   = axi_s_awburst;
    assign axi_sclk_s_awuser    = axi_s_awuser;
    assign axi_sclk_s_awvalid   = axi_s_awvalid;
    assign axi_s_awready        = axi_sclk_s_awready;

    assign axi_sclk_s_wdata     = axi_s_wdata;
    assign axi_sclk_s_wstrb     = axi_s_wstrb;
    assign axi_sclk_s_wlast     = axi_s_wlast;
    assign axi_sclk_s_wvalid    = axi_s_wvalid;
    assign axi_s_wready         = axi_sclk_s_wready;

    assign axi_s_bid            = axi_sclk_s_bid;
    assign axi_s_bresp          = axi_sclk_s_bresp;
    assign axi_s_bvalid         = axi_sclk_s_bvalid;
    assign axi_sclk_s_bready    = axi_s_bready;

    assign axi_sclk_s_arid      = axi_s_arid;
    assign axi_sclk_s_araddr    = axi_s_araddr;
    assign axi_sclk_s_arlen     = axi_s_arlen;
    assign axi_sclk_s_arsize    = axi_s_arsize;
    assign axi_sclk_s_arburst   = axi_s_arburst;
    assign axi_sclk_s_aruser    = axi_s_aruser;
    assign axi_sclk_s_arvalid   = axi_s_arvalid;
    assign axi_s_arready        = axi_sclk_s_arready;

    assign axi_s_rid            = axi_sclk_s_rid;
    assign axi_s_rdata          = axi_sclk_s_rdata;
    assign axi_s_rresp          = axi_sclk_s_rresp;
    assign axi_s_rlast          = axi_sclk_s_rlast;
    assign axi_s_rvalid         = axi_sclk_s_rvalid;
    assign axi_sclk_s_rready    = axi_s_rready;


    // Read channel
    reg  [1:0]  rch_state_R,    rch_state_next;

    reg  [31:0] rch_addr_R,     rch_addr_next;
    reg  [3:0]  rch_id_R,       rch_id_next;

    wire        rch_addr_invalid;
    wire [3:0]  rch_addr_converted;
    wire [31:0] rch_data_converted;


    assign rch_addr_invalid     = axi_sclk_s_araddr != 32'h1FD003F8
                               && axi_sclk_s_araddr != 32'h1FD003FC;

    assign rch_addr_converted   = axi_sclk_s_araddr == 32'h1FD003F8 ? 4'h0
                                                               : 4'h8;

    assign rch_data_converted   = rch_addr_R   == 32'h1FD003F8 ? { 24'b0, axi_m_rdata[7:0] }
                                                               : { 30'b0, axi_m_rdata[0], ~axi_m_rdata[3] };

    always @(posedge clk_sys) begin

        if (~resetn_sys) begin
            rch_state_R <= `UART_AXI_READ_CHANNEL_IDLE;
        end
        else begin
            rch_state_R <= rch_state_next;
        end

        rch_addr_R  <= rch_addr_next;
        rch_id_R    <= rch_id_next;
    end

    always @(*) begin

        rch_state_next = rch_state_R;

        rch_addr_next  = rch_addr_R;
        rch_id_next    = rch_id_R;

        case (rch_state_R) 

            `UART_AXI_READ_CHANNEL_IDLE:    begin

                if (axi_sclk_s_arvalid) begin

                    rch_addr_next = axi_sclk_s_araddr;
                    rch_id_next   = axi_sclk_s_arid;
                    
                    if (rch_addr_invalid) begin
                        rch_state_next = `UART_AXI_READ_CHANNEL_RESPONSE;
                    end
                    else begin
                        rch_state_next = `UART_AXI_READ_CHANNEL_ACCEPTED;
                    end
                end
            end

            `UART_AXI_READ_CHANNEL_ACCEPTED:    begin

                if (axi_m_arready) begin
                    rch_state_next = `UART_AXI_READ_CHANNEL_WAIT_ON_READ;
                end
            end

            `UART_AXI_READ_CHANNEL_WAIT_ON_READ:    begin

                if (axi_m_rvalid) begin
                    rch_state_next = `UART_AXI_READ_CHANNEL_RESPONSE;
                end
            end

            `UART_AXI_READ_CHANNEL_RESPONSE:    begin

                if (axi_sclk_s_rready) begin
                    rch_state_next = `UART_AXI_READ_CHANNEL_IDLE;
                end
            end

            default:    begin
            end
        endcase
    end


    reg [3:0]   m_araddr_OR,    m_araddr_next;
    reg         m_arvalid_OR,   m_arvalid_next;

    always @(posedge clk_sys) begin

        if (~resetn_sys) begin
            m_arvalid_OR <= 'b0;
        end
        else begin
            m_arvalid_OR <= m_arvalid_next;
        end

        m_araddr_OR <= m_araddr_next;
    end

    always @(*) begin

        m_araddr_next   = m_araddr_OR;
        m_arvalid_next  = m_arvalid_OR;

        case (rch_state_R)

            `UART_AXI_READ_CHANNEL_IDLE:    begin

                if (rch_state_next == `UART_AXI_READ_CHANNEL_ACCEPTED) begin

                    m_araddr_next   = rch_addr_converted;
                    m_arvalid_next  = 1'b1;
                end
            end

            `UART_AXI_READ_CHANNEL_ACCEPTED:    begin

                if (rch_state_next == `UART_AXI_READ_CHANNEL_WAIT_ON_READ) begin

                    m_arvalid_next  = 1'b0;
                end
            end

            default:    begin
            end
        endcase
    end

    assign axi_m_araddr     = m_araddr_OR;
    assign axi_m_arvalid    = m_arvalid_OR;


    reg         m_rready_OR,    m_rready_next;

    always @(posedge clk_sys) begin

        if (~resetn_sys) begin
            m_rready_OR <= 'b0;
        end
        else begin
            m_rready_OR <= m_rready_next;
        end
    end

    always @(*) begin

        m_rready_next   = m_rready_OR;

        case (rch_state_R)

            `UART_AXI_READ_CHANNEL_ACCEPTED:    begin

                if (rch_state_next == `UART_AXI_READ_CHANNEL_WAIT_ON_READ) begin
                    m_rready_next = 1'b1;
                end
            end

            `UART_AXI_READ_CHANNEL_WAIT_ON_READ:    begin

                if (rch_state_next == `UART_AXI_READ_CHANNEL_RESPONSE) begin
                    m_rready_next = 1'b0;
                end
            end

            default:    begin
            end
        endcase
    end

    assign axi_m_rready = m_rready_OR;
 

    reg  [31:0] s_rdata_OR,     s_rdata_next;
    reg         s_rvalid_OR,    s_rvalid_next;

    always @(posedge clk_sys) begin

        if (~resetn_sys) begin
            s_rvalid_OR <= 'b0;
        end
        else begin
            s_rvalid_OR <= s_rvalid_next;
        end

        s_rdata_OR  <= s_rdata_next;
    end

    always @(*) begin

        s_rvalid_next   = s_rvalid_OR;
        s_rdata_next    = s_rdata_OR;

        case (rch_state_R)

            `UART_AXI_READ_CHANNEL_IDLE:    begin

                if (rch_state_next == `UART_AXI_READ_CHANNEL_RESPONSE) begin

                    s_rdata_next    = 32'b0;
                    s_rvalid_next   = 1'b1;
                end
            end

            `UART_AXI_READ_CHANNEL_WAIT_ON_READ:    begin

                if (rch_state_next == `UART_AXI_READ_CHANNEL_RESPONSE) begin

                    s_rdata_next    = rch_data_converted;
                    s_rvalid_next   = 1'b1;
                end
            end

            `UART_AXI_READ_CHANNEL_RESPONSE:    begin

                if (rch_state_next == `UART_AXI_READ_CHANNEL_IDLE) begin

                    s_rvalid_next   = 1'b0;
                end
            end

            default:    begin
            end
        endcase
    end

    assign axi_sclk_s_rid    = rch_id_R;
    assign axi_sclk_s_rdata  = s_rdata_OR;
    assign axi_sclk_s_rresp  = 2'b0;
    assign axi_sclk_s_rlast  = 1'b1;
    assign axi_sclk_s_rvalid = s_rvalid_OR;


    reg     s_arready_comb;

    always @(*) begin

        s_arready_comb = 1'b0;

        case (rch_state_R)

            `UART_AXI_READ_CHANNEL_IDLE:    begin

                if (rch_state_next == `UART_AXI_READ_CHANNEL_ACCEPTED
                 || rch_state_next == `UART_AXI_READ_CHANNEL_RESPONSE) begin

                    s_arready_comb = 1'b1;
                 end
            end

            default:    begin
            end
        endcase
    end

    assign axi_sclk_s_arready = s_arready_comb;


    // Write channel
    reg  [1:0]  wch_state_R,    wch_state_next;

    reg  [3:0]  wch_id_R,       wch_id_next;

    wire        wch_addr_invalid;
    wire [2:0]  wch_addr_converted;
    wire [7:0]  wch_data_converted;

    assign wch_addr_invalid     = axi_sclk_s_awaddr != 32'h1FD003F8
                               && axi_sclk_s_awaddr != 32'h1FD003FC;

    assign wch_addr_converted   = 4'h4;
    assign wch_data_converted   = axi_sclk_s_wdata[7:0];
 
    always @(posedge clk_sys) begin

        if (~resetn_sys) begin
            wch_state_R <= `UART_AXI_WRITE_CHANNEL_IDLE;
        end
        else begin
            wch_state_R <= wch_state_next;
        end

        wch_id_R  <= wch_id_next;
    end

    always @(*) begin

        wch_state_next = wch_state_R;

        wch_id_next    = wch_id_R;

        case (wch_state_R)

            `UART_AXI_WRITE_CHANNEL_IDLE:   begin

                if (axi_sclk_s_awvalid & axi_sclk_s_wvalid) begin

                    wch_id_next = axi_sclk_s_awid;

                    if (wch_addr_invalid) begin
                        wch_state_next = `UART_AXI_WRITE_CHANNEL_RESPONSE;
                    end
                    else begin
                        wch_state_next = `UART_AXI_WRITE_CHANNEL_ACCEPTED;
                    end
                end
            end

            `UART_AXI_WRITE_CHANNEL_ACCEPTED:   begin

                // *NOTICE: Attention. This logic is only compatiable with Xilinx UARTLite IP.
                //          UARTLite IP would always assert 'awready' and 'wready' in a single beat,
                //          when 'awvalid' and 'wvalid' were asserted simultaneously.
                //          *AXI4-Lite speciality*
                if (axi_m_awready & axi_m_wready) begin
                    wch_state_next = `UART_AXI_WRITE_CHANNEL_RESPONSE;
                end
            end

            `UART_AXI_WRITE_CHANNEL_RESPONSE:   begin

                if (axi_sclk_s_bready) begin
                    wch_state_next = `UART_AXI_WRITE_CHANNEL_IDLE;
                end
            end

            default:    begin
            end
        endcase
    end


    reg [3:0]   m_awaddr_OR,    m_awaddr_next;
    reg         m_awvalid_OR,   m_awvalid_next;

    reg [31:0]  m_wdata_OR,     m_wdata_next;
    reg         m_wvalid_OR,    m_wvalid_next;

    always @(posedge clk_sys) begin

        if (~resetn_sys) begin

            m_awvalid_OR    <= 'b0;
            m_wvalid_OR     <= 'b0;
        end
        else begin

            m_awvalid_OR    <= m_awvalid_next;
            m_wvalid_OR     <= m_wvalid_next;
        end

        m_awaddr_OR <= m_awaddr_next;
        m_wdata_OR  <= m_wdata_next;
    end

    always @(*) begin

        m_awaddr_next   = m_awaddr_OR;
        m_awvalid_next  = m_awvalid_OR;

        m_wdata_next    = m_wdata_OR;
        m_wvalid_next   = m_wvalid_OR;

        case (wch_state_R)

            `UART_AXI_WRITE_CHANNEL_IDLE:   begin

                if (wch_state_next == `UART_AXI_WRITE_CHANNEL_ACCEPTED) begin

                    m_awaddr_next   = wch_addr_converted;
                    m_awvalid_next  = 1'b1;

                    m_wdata_next    = wch_data_converted;
                    m_wvalid_next   = 1'b1;
                end
            end

            `UART_AXI_WRITE_CHANNEL_ACCEPTED:   begin

                if (wch_state_next == `UART_AXI_WRITE_CHANNEL_RESPONSE) begin

                    m_awvalid_next  = 1'b0;
                    m_wvalid_next   = 1'b0;
                end
            end

            default:    begin
            end
        endcase
    end

    assign axi_m_awaddr     = m_awaddr_OR;
    assign axi_m_awvalid    = m_awvalid_OR;

    assign axi_m_wdata      = m_wdata_OR;
    assign axi_m_wstrb      = 4'b0001;
    assign axi_m_wvalid     = m_wvalid_OR;

    assign axi_m_bready     = 1'b1;


    reg         s_awready_comb;
    reg         s_wready_comb; 

    reg         s_bvalid_comb;

    always @(*) begin

        s_awready_comb  = 1'b0;
        s_wready_comb   = 1'b0;

        s_bvalid_comb   = 1'b0;

        case (wch_state_R)

            `UART_AXI_WRITE_CHANNEL_IDLE:   begin

                if (wch_state_next == `UART_AXI_WRITE_CHANNEL_ACCEPTED
                 || wch_state_next == `UART_AXI_WRITE_CHANNEL_RESPONSE) begin

                    s_awready_comb  = 1'b1;
                    s_wready_comb   = 1'b1;
                 end
            end

            `UART_AXI_WRITE_CHANNEL_RESPONSE:   begin
                s_bvalid_comb   = 1'b1;
            end

            default:    begin
            end
        endcase
    end

    assign axi_sclk_s_awready    = s_awready_comb;

    assign axi_sclk_s_wready     = s_wready_comb;

    assign axi_sclk_s_bid        = wch_id_R;
    assign axi_sclk_s_bresp      = 2'b00;
    assign axi_sclk_s_bvalid     = s_bvalid_comb;

    //

    //

endmodule
