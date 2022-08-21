`define         AXI_BURST_LEN_1             8'd0

`define         AXI_BURST_SIZE_1            3'b000
`define         AXI_BURST_SIZE_4            3'b010

`define         AXI_BURST_TYPE_FIXED        2'b00
`define         AXI_BURST_TYPE_INCR         2'b01
`define         AXI_BURST_TYPE_WRAP         2'b10

module commit_mem_write_ctrl2axi (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            i_wbmem_valid,
    input   wire [31:0]     i_wbmem_addr,
    input   wire [3:0]      i_wbmem_strb,
    input   wire [1:0]      i_wbmem_lswidth,
    input   wire [31:0]     i_wbmem_data,
    input   wire            i_wbmem_uncached,

    output  wire            o_wbmem_en,

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
    output  wire            axi_m_bready
);

    //
    reg     accepted_aw_R;
    reg     accepted_w_R;

    always @(posedge clk) begin

        if (~resetn) begin
            accepted_aw_R <= 1'b0;
        end
        else if (accepted_aw_R) begin

            if (axi_m_wready) begin
                accepted_aw_R <= 1'b0;
            end
        end
        else if (i_wbmem_valid & axi_m_awready) begin

            if (accepted_w_R) begin
                accepted_aw_R <= 1'b0;
            end
            else if (axi_m_wready) begin
                accepted_aw_R <= 1'b0;
            end
            else begin
                accepted_aw_R <= 1'b1;
            end
        end
    end

    always @(posedge clk) begin

        if (~resetn) begin
            accepted_w_R <= 1'b0;
        end
        else if (accepted_w_R) begin

            if (axi_m_awready) begin
                accepted_w_R <= 1'b0;
            end
        end
        else if (i_wbmem_valid & axi_m_wready) begin

            if (accepted_aw_R) begin
                accepted_w_R <= 1'b0;
            end
            else if (axi_m_awready) begin
                accepted_w_R <= 1'b0;
            end
            else begin
                accepted_w_R <= 1'b1;
            end
        end
    end

    //
    wire    s_accepted;

    assign s_accepted = (axi_m_awready    & axi_m_wready) 
                     || (axi_m_awready    & accepted_w_R) 
                     || (accepted_aw_R    & axi_m_wready);

    //

    //
    assign axi_m_awid       = 4'b0;
    assign axi_m_awaddr     = i_wbmem_addr;
    assign axi_m_awlen      = `AXI_BURST_LEN_1;
    assign axi_m_awburst    = `AXI_BURST_TYPE_INCR;
    assign axi_m_awuser     = i_wbmem_uncached;
    assign axi_m_awsize     = i_wbmem_lswidth == `LSWIDTH_BYTE ? `AXI_BURST_SIZE_1 : `AXI_BURST_SIZE_4;

    assign axi_m_awvalid    = i_wbmem_valid & ~accepted_aw_R;


    //
    assign axi_m_wdata      = i_wbmem_data;
    assign axi_m_wstrb      = i_wbmem_strb;
    assign axi_m_wlast      = 1'b1;
    
    assign axi_m_wvalid     = i_wbmem_valid & ~accepted_w_R;

    //
    assign axi_m_bready     = 1'b1;

    //
    assign o_wbmem_en       = s_accepted;

    //

endmodule
