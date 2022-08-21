`define     MEMR_STATE_IDLE                     4'b0000

`define     MEMR_STATE_LOAD_UNCACHED_AXI_ADDR   4'b0100
`define     MEMR_STATE_LOAD_UNCACHED_AXI_DATA   4'b0101

`define     MEMR_STATE_LOAD_REFILL_AXI_ADDR     4'b1000
`define     MEMR_STATE_LOAD_REFILL_AXI_DATA     4'b1001
`define     MEMR_STATE_LOAD_REFILL_FIFO_WAIT    4'b1010


`define     AXI_BURST_LEN_1                     8'd0
`define     AXI_BURST_LEN_8                     8'd7

`define     AXI_BURST_SIZE_1                    3'b000
`define     AXI_BURST_SIZE_4                    3'b010

`define     AXI_BURST_TYPE_FIXED                2'b00
`define     AXI_BURST_TYPE_INCR                 2'b01
`define     AXI_BURST_TYPE_WRAP                 2'b10

module commit_mem_read_ctrl2axi (
    input   wire            clk,
    input   wire            resetn,

    //
    output  wire            s_busy,

    //
    input   wire            i_ctrl_en,

    input   wire [7:0]      i_ctrl_fid,
    input   wire [31:0]     i_ctrl_addr,
    input   wire            i_ctrl_uncached,
    input   wire [1:0]      i_ctrl_lswidth,

    //
    output  wire            o_rbuffer_uncached_en,
    output  wire [31:0]     o_rbuffer_uncached_addr,
    output  wire [31:0]     o_rbuffer_uncached_data,

    output  wire            o_rbuffer_cached_en,
    output  wire [31:0]     o_rbuffer_cached_addr,
    output  wire [31:0]     o_rbuffer_cached_data,

    output  wire            o_rbuffer_cached_clear,

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
    wire        dupd_empty;

    wire        dupd_write_en;
    wire [31:0] dupd_write_addr;
    wire [31:0] dupd_write_data;

    wire        dupd_read_en;
    wire [31:0] dupd_read_addr;
    wire [31:0] dupd_read_data;

    commit_mem_read_dataupdatebuffer commit_mem_read_dataupdatebuffer_INST (
        .clk        (clk),
        .resetn     (resetn),

        //
        .wea        (dupd_write_en),
        .dina_addr  (dupd_write_addr),
        .dina_data  (dupd_write_data),

        //
        .web        (dupd_read_en),
        .doutb_addr (dupd_read_addr),
        .doutb_data (dupd_read_data),

        //
        .s_full     (),
        .s_empty    (dupd_empty)
    );

    assign s_busy = ~dupd_empty;


    //
    reg [3:0]   state_R,    state_next;

    reg [8:0]   curfid_R,   curfid_next;

    reg [31:0]  curaddr_R,  curaddr_next;
    reg [2:0]   raddr_R,    raddr_next;

    always @(posedge clk) begin

        if (~resetn) begin

            state_R     <= `MEMR_STATE_IDLE;

            curfid_R    <= 'b0;

            curaddr_R   <= 'b0;
            raddr_R     <= 'b0;
        end
        else begin

            state_R     <= state_next;

            curfid_R    <= curfid_next;

            curaddr_R   <= curaddr_next;
            raddr_R     <= raddr_next;
        end
    end

    //
    reg     uncached_read_comb;
    reg     cached_read_comb;
    reg     cached_done_comb;

    always @(*) begin

        state_next      = state_R;

        curfid_next     = curfid_R;

        curaddr_next    = curaddr_R;
        raddr_next      = raddr_R;

        uncached_read_comb  = 1'b0;
        cached_read_comb    = 1'b0;
        cached_done_comb    = 1'b0;

        case (state_R)

            `MEMR_STATE_IDLE:   begin

                if (i_ctrl_en) begin

                    curaddr_next    = i_ctrl_addr;
                    raddr_next      = i_ctrl_addr[4:2];

                    curfid_next[8]  = 1'b0; // LoadBuffer would take 1 more cycle to commit

                    // Same instruction fall through, never issue a read/write request twice
                    if (curfid_R[8] && i_ctrl_fid == curfid_R[7:0]) begin 
                        state_next = `MEMR_STATE_IDLE;
                    end
                    else begin

                        curfid_next     = { 1'b1, i_ctrl_fid };

                        if (i_ctrl_uncached) begin
                            state_next = `MEMR_STATE_LOAD_UNCACHED_AXI_ADDR;
                        end
                        else begin
                            state_next = `MEMR_STATE_LOAD_REFILL_AXI_ADDR;
                        end
                    end
                end
            end


            `MEMR_STATE_LOAD_UNCACHED_AXI_ADDR: begin

                if (axi_m_arready) begin
                    state_next = `MEMR_STATE_LOAD_UNCACHED_AXI_DATA;
                end
            end

            `MEMR_STATE_LOAD_UNCACHED_AXI_DATA: begin

                if (axi_m_rvalid) begin

                    uncached_read_comb  = 1'b1;

                    state_next = `MEMR_STATE_IDLE;
                end
            end


            `MEMR_STATE_LOAD_REFILL_AXI_ADDR:   begin

                if (axi_m_arready) begin
                    state_next = `MEMR_STATE_LOAD_REFILL_AXI_DATA;
                end
            end

            `MEMR_STATE_LOAD_REFILL_AXI_DATA:   begin

                if (axi_m_rvalid) begin

                    cached_read_comb = 1'b1;

                    if (axi_m_rlast) begin
                        state_next = `MEMR_STATE_LOAD_REFILL_FIFO_WAIT;
                    end
                    else begin
                        
                        raddr_next = raddr_R + 'd1;

                        state_next = `MEMR_STATE_LOAD_REFILL_AXI_DATA;
                    end
                end
            end

            `MEMR_STATE_LOAD_REFILL_FIFO_WAIT:  begin

                if (dupd_empty) begin

                    cached_done_comb = 1'b1;

                    state_next = `MEMR_STATE_IDLE;
                end
            end

            default: begin
            end
        endcase
    end


    //
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

            `MEMR_STATE_IDLE:   begin

                if (state_next == `MEMR_STATE_LOAD_UNCACHED_AXI_ADDR) begin

                    araddr_next     = i_ctrl_addr;
                    arlen_next      = `AXI_BURST_LEN_1;
                    arburst_next    = `AXI_BURST_TYPE_FIXED;
                    aruser_next     = 1'b1;
                    arvalid_next    = 1'b1;

                    case (i_ctrl_lswidth)

                        `LSWIDTH_BYTE:  begin
                            arsize_next = `AXI_BURST_SIZE_1;
                        end

                        default:    begin
                            arsize_next = `AXI_BURST_SIZE_4;
                        end
                    endcase
                end
                else if (state_next == `MEMR_STATE_LOAD_REFILL_AXI_ADDR) begin

                    araddr_next     = i_ctrl_addr;
                    arlen_next      = `AXI_BURST_LEN_8;
                    arsize_next     = `AXI_BURST_SIZE_4;
                    arburst_next    = `AXI_BURST_TYPE_WRAP;
                    aruser_next     = 1'b0;
                    arvalid_next    = 1'b1;
                end
            end

            `MEMR_STATE_LOAD_UNCACHED_AXI_ADDR: begin

                if (state_next == `MEMR_STATE_LOAD_UNCACHED_AXI_DATA) begin
                    arvalid_next = 1'b0;
                end
            end

            `MEMR_STATE_LOAD_UNCACHED_AXI_DATA: begin
                //
            end

            `MEMR_STATE_LOAD_REFILL_AXI_ADDR:   begin

                if (state_next == `MEMR_STATE_LOAD_REFILL_AXI_DATA) begin
                    arvalid_next = 1'b0;
                end
            end

            `MEMR_STATE_LOAD_REFILL_AXI_DATA:   begin
                //
            end

            `MEMR_STATE_LOAD_REFILL_FIFO_WAIT:  begin
                //
            end

            default:    begin
            end
        endcase
    end

    //
    assign axi_m_arid       = 4'b0;
    assign axi_m_araddr     = araddr_R;
    assign axi_m_arlen      = arlen_R;
    assign axi_m_arsize     = arsize_R;
    assign axi_m_arburst    = arburst_R;
    assign axi_m_aruser     = aruser_R;
    assign axi_m_arvalid    = arvalid_R;
    
    //
    assign axi_m_rready     = 1'b1;


    //
    assign o_rbuffer_uncached_en    = uncached_read_comb;
    assign o_rbuffer_uncached_addr  = curaddr_R;
    assign o_rbuffer_uncached_data  = axi_m_rdata;

    //
    assign o_rbuffer_cached_en      = cached_read_comb;
    assign o_rbuffer_cached_addr    = { curaddr_R[31:5], raddr_R, 2'b0 };
    assign o_rbuffer_cached_data    = axi_m_rdata;

    assign o_rbuffer_cached_clear   = cached_done_comb;

    //
    assign dupd_write_en    = cached_read_comb;
    assign dupd_write_addr  = { curaddr_R[31:5], raddr_R, 2'b0 };
    assign dupd_write_data  = axi_m_rdata;

    //
    assign o_dcache_update_data_valid   = ~dupd_empty;
    assign o_dcache_update_data_addr    =  dupd_read_addr;
    assign o_dcache_update_data_strb    = 4'b1111;
    assign o_dcache_update_data         =  dupd_read_data;

    assign dupd_read_en                 = i_dcache_update_data_ready;

    //
    assign o_dcache_update_tag_en       = cached_read_comb | cached_done_comb;
    assign o_dcache_update_tag_addr     = curaddr_R;
    assign o_dcache_update_tag_valid    = cached_done_comb;

    //

endmodule
