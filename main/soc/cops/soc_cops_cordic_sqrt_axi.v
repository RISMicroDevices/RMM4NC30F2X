`define     COPS_CORDIC_SQRT_WRITE_IDLE             2'b00
`define     COPS_CORDIC_SQRT_WRITE_BUSY             2'b01
`define     COPS_CORDIC_SQRT_WRITE_RESPONSE         2'b10

`define     COPS_CORDIC_SQRT_READ_IDLE              1'b0
`define     COPS_CORDIC_SQRT_READ_WAIT              1'b1

module soc_cops_cordic_sqrt_axi (
    input   wire            clk,
    input   wire            resetn,

    // 
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
    input   wire            axi_s_rready
);
    
    //
    // *NOTICE: COPS-CORDIC-Sqrt Registers
    //    - 0x8FD004F0 (0x1FD004F0 uncached): Operation register (push on write, pop on read)
    //    - 0x8FD004F4 (0x1FD004F4 uncached): Status register (read-only)
    //

    //
    wire [31:0] s_axis_cartesian_tdata;
    wire        s_axis_cartesian_tvalid;

    wire [23:0] m_axis_dout_tdata;
    wire        m_axis_dout_tvalid;

    soc_cops_cordic_sqrt soc_cops_cordic_sqrt_INST (
        .aclk                   (clk),
        .aresetn                (resetn),

        //
        .s_axis_cartesian_tdata (s_axis_cartesian_tdata),
        .s_axis_cartesian_tvalid(s_axis_cartesian_tvalid),

        //
        .m_axis_dout_tdata      (m_axis_dout_tdata),
        .m_axis_dout_tvalid     (m_axis_dout_tvalid)
    );


    //
    reg [1:0]   statew_R,    statew_next;

    always @(posedge clk) begin

        if (~resetn) begin
            statew_R <= `COPS_CORDIC_SQRT_WRITE_IDLE;
        end
        else begin
            statew_R <= statew_next;
        end
    end

    always @(*) begin

        statew_next = statew_R;

        case (statew_R)

            `COPS_CORDIC_SQRT_WRITE_IDLE:   begin

                if (axi_s_awvalid && axi_s_wvalid) begin
                    statew_next = `COPS_CORDIC_SQRT_WRITE_BUSY;
                end
            end

            `COPS_CORDIC_SQRT_WRITE_BUSY:   begin

                if (m_axis_dout_tvalid) begin
                    statew_next = `COPS_CORDIC_SQRT_WRITE_RESPONSE;
                end
            end

            `COPS_CORDIC_SQRT_WRITE_RESPONSE:   begin

                if (axi_s_bready) begin
                    statew_next = `COPS_CORDIC_SQRT_WRITE_IDLE;
                end
            end

            default:    begin
            end
        endcase
    end

    //
    reg         awready_R,  awready_next;
    reg         wready_R,   wready_next;

    reg [3:0]   awid_R,     awid_next;

    always @(posedge clk) begin

        if (~resetn) begin

            awready_R   <= 1'b0;
            wready_R    <= 1'b0;
        end
        else begin

            awready_R   <= awready_next;
            wready_R    <= wready_next;
        end

        awid_R <= awid_next;
    end

    always @(*) begin

        awready_next    = 1'b0;
        wready_next     = 1'b0;

        awid_next       = awid_R;

        case (statew_R)

            `COPS_CORDIC_SQRT_WRITE_IDLE:   begin

                if (statew_next == `COPS_CORDIC_SQRT_WRITE_BUSY) begin
                    
                    awready_next = 1'b1;
                    wready_next  = 1'b1;

                    awid_next    = axi_s_awid;
                end
            end

            default:    begin
            end
        endcase
    end

    assign axi_s_awready    = awready_R;
    assign axi_s_wready     = wready_R;

    //
    reg         bvalid_R,   bvalid_next;

    always @(posedge clk) begin

        if (~resetn) begin
            bvalid_R <= 1'b0;
        end
        else begin
            bvalid_R <= bvalid_next;
        end
    end

    always @(*) begin

        bvalid_next = bvalid_R;
        
        case (statew_R)

            `COPS_CORDIC_SQRT_WRITE_BUSY:   begin

                if (statew_next == `COPS_CORDIC_SQRT_WRITE_RESPONSE) begin
                    bvalid_next = 1'b1;
                end
            end

            `COPS_CORDIC_SQRT_WRITE_RESPONSE:   begin

                if (statew_next == `COPS_CORDIC_SQRT_WRITE_IDLE) begin
                    bvalid_next = 1'b0;
                end
            end

            default:    begin
            end
        endcase
    end

    assign axi_s_bid    = awid_R;
    assign axi_s_bresp  = 2'b0;
    assign axi_s_bvalid = bvalid_R;

    //
    reg [31:0]  axis_tdata_R,   axis_tdata_next;
    reg         axis_tvalid_R,  axis_tvalid_next;

    always @(posedge clk) begin

        if (~resetn) begin
            axis_tvalid_R <= 1'b0;
        end
        else begin
            axis_tvalid_R <= axis_tvalid_next;
        end

        axis_tdata_R    <= axis_tdata_next;
    end

    always @(*) begin

        axis_tdata_next     = axis_tdata_R;
        axis_tvalid_next    = 1'b0;

        case (statew_R)

            `COPS_CORDIC_SQRT_WRITE_IDLE:   begin

                if (statew_next == `COPS_CORDIC_SQRT_WRITE_BUSY) begin

                    axis_tdata_next  = axi_s_wdata;
                    axis_tvalid_next = 1'b1;
                end
            end

            default:    begin
            end
        endcase
    end

    assign s_axis_cartesian_tdata   = axis_tdata_R;
    assign s_axis_cartesian_tvalid  = axis_tvalid_R;


    //
    wire    p_addr_data;
    wire    p_addr_status;

    assign p_addr_data      = axi_s_araddr == 32'h1FD004F0;
    assign p_addr_status    = axi_s_araddr == 32'h1FD004F4;

    //
    reg     stater_R,           stater_next;

    always @(posedge clk) begin

        if (~resetn) begin
            stater_R <= `COPS_CORDIC_SQRT_READ_IDLE;
        end
        else begin
            stater_R <= stater_next;
        end
    end

    always @(*) begin

        case (stater_R)

            `COPS_CORDIC_SQRT_READ_IDLE:    begin

                if (axi_s_arvalid) begin
                    stater_next = `COPS_CORDIC_SQRT_READ_WAIT;
                end
            end

            `COPS_CORDIC_SQRT_READ_WAIT:    begin

                if (axi_s_rready) begin
                    stater_next = `COPS_CORDIC_SQRT_READ_IDLE;
                end
            end

            default:    begin
            end
        endcase
    end

    //
    reg     p_addr_data_R,      p_addr_data_next;
    reg     p_addr_status_R,    p_addr_status_next;

    always @(posedge clk) begin

        if (~resetn) begin

            p_addr_data_R   <= 1'b0;
            p_addr_status_R <= 1'b0;
        end
        else begin

            p_addr_data_R   <= p_addr_data_next;
            p_addr_status_R <= p_addr_status_next;
        end
    end

    always @(*) begin

        p_addr_data_next    = p_addr_data_R;
        p_addr_status_next  = p_addr_status_R;

        case (stater_R)

            `COPS_CORDIC_SQRT_READ_IDLE:    begin
                
                if (stater_next == `COPS_CORDIC_SQRT_READ_WAIT) begin

                    p_addr_data_next    = p_addr_data;
                    p_addr_status_next  = p_addr_status;
                end
            end

            default:    begin
            end
        endcase
    end

    //
    reg [3:0]   arid_R,     arid_next;

    always @(posedge clk) begin
        arid_R <= arid_next;
    end

    always @(*) begin

        arid_next = arid_R;

        case (stater_R)

            `COPS_CORDIC_SQRT_READ_IDLE:    begin

                if (stater_next == `COPS_CORDIC_SQRT_READ_WAIT) begin
                    arid_next = axi_s_arid;
                end
            end

            default:    begin
            end
        endcase
    end

    //
    reg         cordic_valid_R, cordic_valid_next;
    reg [31:0]  cordic_dout_R,  cordic_dout_next;

    always @(posedge clk) begin

        if (~resetn) begin
            cordic_valid_R <= 1'b0;
        end
        else begin
            cordic_valid_R <= cordic_valid_next;
        end

        cordic_dout_R   <= cordic_dout_next;
    end

    always @(*) begin

        cordic_valid_next   = cordic_valid_R;
        cordic_dout_next    = cordic_dout_R;

        case (stater_R)

            `COPS_CORDIC_SQRT_READ_WAIT:    begin
                
                if (stater_next == `COPS_CORDIC_SQRT_READ_IDLE && p_addr_data) begin
                    cordic_valid_next = 1'b0;
                end
            end

            default:    begin
            end
        endcase

        if (m_axis_dout_tvalid) begin

            cordic_valid_next = 1'b1;
            cordic_dout_next  = { 8'b0, m_axis_dout_tdata };
        end
    end

    //
    assign axi_s_arready    = stater_R == `COPS_CORDIC_SQRT_READ_IDLE;

    assign axi_s_rid    = arid_R;
    assign axi_s_rdata  = p_addr_data_R ? cordic_dout_R : { 31'b0, cordic_valid_R };
    assign axi_s_rresp  = 2'b0;
    assign axi_s_rlast  = 1'b1;
    assign axi_s_rvalid = stater_R == `COPS_CORDIC_SQRT_READ_WAIT;

    //

endmodule
