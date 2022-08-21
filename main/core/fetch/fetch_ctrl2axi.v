
`define     FETCH_STATE_IDLE                    3'b000

`define     FETCH_STATE_UNCACHED_AXI_ADDR       3'b100
`define     FETCH_STATE_UNCACHED_AXI_DATA       3'b101

`define     FETCH_STATE_REFILL_AXI_ADDR         3'b010
`define     FETCH_STATE_REFILL_AXI_DATA         3'b011


`define     AXI_BURST_LEN_1                     8'd0
`define     AXI_BURST_LEN_8                     8'd7
`define     AXI_BURST_LEN_16                    8'd15

`define     AXI_BURST_SIZE_4                    3'b010

`define     AXI_BURST_TYPE_FIXED                2'b00
`define     AXI_BURST_TYPE_INCR                 2'b01
`define     AXI_BURST_TYPE_WRAP                 2'b10


module fetch_ctrl2axi (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire [31:0]     pc,

    //
    input   wire            cctrl_miss,
    input   wire            cctrl_uncached,

    //
    input   wire            snoop_hit,
    input   wire [31:0]     snoop_addr,

    //
    output  wire [31:0]     predecode_dout,
    input   wire [35:0]     predecode_din,

    //
    output  wire            update_data_wea,
    output  wire [31:0]     update_data_addr,
    output  wire [35:0]     update_data_din,

    //
    output  wire            update_tag_wea,
    output  wire [32:0]     update_tag,

    //
    output  wire            buffer_uncached_we,
    output  wire [31:0]     buffer_uncached_addr,
    output  wire [35:0]     buffer_uncached_din,

    //
    output  wire            buffer_refilled_wea,
    output  wire [31:0]     buffer_refilled_addra,

    output  wire            buffer_refilled_web,
    output  wire [3:0]      buffer_refilled_addrb,
    output  wire [35:0]     buffer_refilled_dinb,

    output  wire            buffer_refilled_reset,

    // Snoop filter table
    output  wire [31:0]     snoop_query_addr,
    input   wire            snoop_query_hit,

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
    reg [2:0]   state_R,     state_next;
    reg [4:0]   axi_cnt_R,   axi_cnt_next;

    reg [3:0]   raddr_R,     raddr_next;

    (*MAX_FANOUT = 128 *)
    reg [31:0]  curaddr_R,   curaddr_next;

    always @(posedge clk) begin

        if (~resetn) begin

            state_R     <= `FETCH_STATE_IDLE;
            axi_cnt_R   <= 'b0;

            raddr_R     <= 'b0;

            curaddr_R   <= 'b0;
        end
        else begin

            state_R     <= state_next;
            axi_cnt_R   <= axi_cnt_next;

            raddr_R     <= raddr_next;

            curaddr_R   <= curaddr_next;
        end
    end


    //
    reg     refill_read_comb;
    reg     refill_done_comb;
    reg     uncached_read_comb;

    always @(*) begin

        state_next   = state_R;
        axi_cnt_next = axi_cnt_R;

        raddr_next   = raddr_R;

        curaddr_next = curaddr_R;

        refill_read_comb   = 1'b0;
        refill_done_comb   = 1'b0;
        uncached_read_comb = 1'b0;

        case (state_R)

            `FETCH_STATE_IDLE: begin

                if (cctrl_uncached) begin

                    curaddr_next = pc;
                    raddr_next   = pc[5:2];

                    state_next   = `FETCH_STATE_UNCACHED_AXI_ADDR;
                end
                else if (cctrl_miss) begin

                    curaddr_next = pc;
                    raddr_next   = pc[5:2];

                    axi_cnt_next = 'b0;
                    state_next   = `FETCH_STATE_REFILL_AXI_ADDR;
                end
            end

            `FETCH_STATE_UNCACHED_AXI_ADDR: begin
                
                if (snoop_query_hit) begin
                    state_next   = `FETCH_STATE_IDLE;
                end
                else if (axi_m_arready) begin
                    state_next   = `FETCH_STATE_UNCACHED_AXI_DATA;
                end
            end

            `FETCH_STATE_UNCACHED_AXI_DATA: begin

                if (axi_m_rvalid) begin

                    uncached_read_comb = 1'b1;
                    state_next         = `FETCH_STATE_IDLE;
                end
            end

            `FETCH_STATE_REFILL_AXI_ADDR: begin
                
                if (snoop_query_hit) begin
                    state_next   = `FETCH_STATE_IDLE;
                end
                else if (axi_m_arready) begin
                    state_next   = `FETCH_STATE_REFILL_AXI_DATA;
                end
            end

            `FETCH_STATE_REFILL_AXI_DATA: begin

                if (axi_cnt_R[4]) begin

                    refill_done_comb = 1'b1;
                    state_next       = `FETCH_STATE_IDLE;
                end
                else if (axi_m_rvalid) begin

                    axi_cnt_next = axi_cnt_R + 'd1;
                    raddr_next   = raddr_R   + 'd1;

                    refill_read_comb = 1'b1;

                    state_next   = `FETCH_STATE_REFILL_AXI_DATA;
                end
            end

            default: begin
            end
        endcase
    end


    //
    (*MAX_FANOUT = 16 *)
    reg [31:0]  araddr_R,   araddr_next;
    reg [7:0]   arlen_R,    arlen_next;
    reg [2:0]   arsize_R,   arsize_next;
    reg [1:0]   arburst_R,  arburst_next;
    reg         aruser_R,   aruser_next;
    reg         arvalid_R,  arvalid_next;

    always @(posedge clk) begin

        if (~resetn) begin
            
            araddr_R    <= 'b0;
            arlen_R     <= 'b0;
            arsize_R    <= 'b0;
            arburst_R   <= 'b0;
            aruser_R    <= 'b0;
            arvalid_R   <= 'b0;
        end
        else begin

            araddr_R    <= araddr_next;
            arlen_R     <= arlen_next;
            arsize_R    <= arsize_next;
            arburst_R   <= arburst_next;
            aruser_R    <= aruser_next;
            arvalid_R   <= arvalid_next;
        end
    end

    always @(*) begin

        araddr_next  = araddr_R;
        arlen_next   = arlen_R;
        arsize_next  = arsize_R;
        arburst_next = arburst_R;
        aruser_next  = aruser_R;
        arvalid_next = arvalid_R;

        case (state_R) 

            `FETCH_STATE_IDLE: begin

                if (state_next == `FETCH_STATE_UNCACHED_AXI_ADDR) begin

                    araddr_next  = pc;
                    arlen_next   = `AXI_BURST_LEN_1;
                    arsize_next  = `AXI_BURST_SIZE_4;
                    arburst_next = `AXI_BURST_TYPE_INCR;
                    aruser_next  = 1'b1;
                    arvalid_next = 1'b1;
                end
                else if (state_next == `FETCH_STATE_REFILL_AXI_ADDR) begin

                    araddr_next  = pc;
                    arlen_next   = `AXI_BURST_LEN_16;
                    arsize_next  = `AXI_BURST_SIZE_4;
                    arburst_next = `AXI_BURST_TYPE_WRAP;
                    aruser_next  = 1'b0;
                    arvalid_next = 1'b1;
                end
            end

            `FETCH_STATE_UNCACHED_AXI_ADDR: begin

                if (state_next == `FETCH_STATE_IDLE) begin
                    arvalid_next = 1'b0;
                end
                else if (state_next == `FETCH_STATE_UNCACHED_AXI_DATA) begin
                    arvalid_next = 1'b0;
                end
            end

            `FETCH_STATE_UNCACHED_AXI_DATA: begin
                // 
            end

            `FETCH_STATE_REFILL_AXI_ADDR: begin

                if (state_next == `FETCH_STATE_IDLE) begin
                    arvalid_next = 1'b0;
                end
                else if (state_next == `FETCH_STATE_REFILL_AXI_DATA) begin
                    arvalid_next = 1'b0;
                end
            end

            `FETCH_STATE_UNCACHED_AXI_DATA: begin
                //
            end

            default: begin
            end
        endcase
    end


    // Snoop filter
    reg     snoop_hit_R,     snoop_hit_next;
    wire    snoop_hit_s;

    assign snoop_hit_s = snoop_hit && (curaddr_R[12:6] == snoop_addr[12:6]);

    always @(posedge clk) begin
        
        if (~resetn) begin
            snoop_hit_R <= 'b0;
        end
        else begin
            snoop_hit_R <= snoop_hit_next;
        end
    end

    always @(*) begin

        snoop_hit_next = snoop_hit_R;

        if (state_next == `FETCH_STATE_IDLE) begin
            snoop_hit_next = 'b0;
        end
        else if (snoop_hit_s) begin
            snoop_hit_next = 'b1;
        end
    end


    //
    assign predecode_dout = axi_m_rdata;

    //
    assign snoop_query_addr     = curaddr_R;

    //
    assign update_data_wea  = refill_read_comb & ~snoop_hit_R;
    assign update_data_addr = { curaddr_R[31:6], raddr_R, 2'b0 };
    assign update_data_din  = predecode_din;

    //
    assign update_tag_wea   = (refill_read_comb | refill_done_comb) & ~snoop_hit_R;
    assign update_tag       = { refill_done_comb, curaddr_R };

    //
    assign buffer_uncached_we   = uncached_read_comb & ~snoop_hit_R;
    assign buffer_uncached_addr = curaddr_R;
    assign buffer_uncached_din  = predecode_din;

    //
    assign buffer_refilled_wea   = refill_read_comb & ~snoop_hit_R;
    assign buffer_refilled_addra = curaddr_R;

    assign buffer_refilled_web   = refill_read_comb & ~snoop_hit_R;
    assign buffer_refilled_addrb = raddr_R;
    assign buffer_refilled_dinb  = predecode_din;

    assign buffer_refilled_reset = refill_done_comb & ~snoop_hit_R;


    // read-address channel output logic
    assign axi_m_arid    = 'b0;

    assign axi_m_araddr  = araddr_R;
    assign axi_m_arlen   = arlen_R;
    assign axi_m_arsize  = arsize_R;
    assign axi_m_arburst = arburst_R;
    assign axi_m_aruser  = aruser_R;
    assign axi_m_arvalid = arvalid_R;

    // read channel output logic
    assign axi_m_rready  = 'b1;

    //

endmodule
