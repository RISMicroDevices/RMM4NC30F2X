
`define     SRAM_AXI_IDLE                       3'b000

`define     SRAM_AXI_WRITE_PROCEDURE            3'b001
`define     SRAM_AXI_WRITE_RESPONSE             3'b101

`define     SRAM_AXI_READ_PROCEDURE             3'b010


module soc_sram_ctrl2axi (
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
    input   wire            axi_s_rready,

    //
    output  wire [19:0]     mem_A,
    
    output  wire            mem_CEN,
    output  wire            mem_OEN,
    output  wire            mem_WEN,

    output  wire            mem_BE0N,
    output  wire            mem_BE1N,
    output  wire            mem_BE2N,
    output  wire            mem_BE3N,

    inout   wire [31:0]     mem_D
);

    //
    wire        ctrl_ena;
    wire [3:0]  ctrl_wea;
    wire [19:0] ctrl_addra;
    wire [31:0] ctrl_dina;

    wire [31:0] ctrl_douta;
    wire        ctrl_readya;

    soc_sram_ctrl soc_sram_ctrl_INST (
        .clk        (clk),
        .resetn     (resetn),

        //
        .ena        (ctrl_ena),
        .wea        (ctrl_wea),
        .addra      (ctrl_addra),
        .dina       (ctrl_dina),
        .douta      (ctrl_douta),

        .readya     (ctrl_readya),

        //
        .mem_A      (mem_A),

        .mem_CEN    (mem_CEN),
        .mem_OEN    (mem_OEN),
        .mem_WEN    (mem_WEN),

        .mem_BE0N   (mem_BE0N),
        .mem_BE1N   (mem_BE1N),
        .mem_BE2N   (mem_BE2N),
        .mem_BE3N   (mem_BE3N),

        .mem_D      (mem_D)
    );

    //
    wire        axiagu_set_en;
    wire [31:0] axiagu_set_addr;
    wire [1:0]  axiagu_set_burst_type;
    wire [2:0]  axiagu_set_burst_size;
    wire [7:0]  axiagu_set_burst_len;

    wire        axiagu_incr_en;

    wire [31:0] axiagu_o_addr;
    wire        axiagu_o_last;

    axi_agu32 axi_agu32_INST (
        .clk            (clk),
        .resetn         (resetn),

        .set_en         (axiagu_set_en),
        .set_addr       (axiagu_set_addr),
        .set_burst_type (axiagu_set_burst_type),
        .set_burst_size (axiagu_set_burst_size),
        .set_burst_len  (axiagu_set_burst_len),

        .incr_en        (axiagu_incr_en),

        .o_addr         (axiagu_o_addr),
        .o_last         (axiagu_o_last)
    );


    //
    // *NOTICE: Write interfaces: READY before VALID handshake
    //          Read  interfaces: VALID before READY handshake
    reg [2:0]   state_R,    state_next;

    always @(posedge clk) begin

        if (~resetn) begin
            state_R <= `SRAM_AXI_IDLE;
        end
        else begin
            state_R <= state_next;
        end
    end

    always @(*) begin

        state_next = state_R;

        case (state_R)

            `SRAM_AXI_IDLE: begin

                if (axi_s_awvalid) begin

                    if (axi_s_wvalid & axi_s_wlast & ctrl_readya) begin
                        state_next = `SRAM_AXI_WRITE_RESPONSE;
                    end
                    else begin
                        state_next = `SRAM_AXI_WRITE_PROCEDURE;
                    end
                end
                else if (axi_s_arvalid & ctrl_readya) begin
                    state_next = `SRAM_AXI_READ_PROCEDURE;
                end
            end

            //
            `SRAM_AXI_WRITE_PROCEDURE:  begin
                
                if (ctrl_readya & axi_s_wlast & axi_s_wvalid) begin
                    state_next = `SRAM_AXI_WRITE_RESPONSE;
                end
            end

            `SRAM_AXI_WRITE_RESPONSE:   begin

                if (axi_s_bready) begin
                    state_next = `SRAM_AXI_IDLE;
                end
            end

            //
            `SRAM_AXI_READ_PROCEDURE:   begin

                if (axi_s_rvalid & axi_s_rlast & axi_s_rready) begin
                    state_next = `SRAM_AXI_IDLE;
                end
            end

            //
            default:    begin
            end
        endcase
    end


    //
    reg [3:0]   id_R,   id_next;

    always @(posedge clk) begin

        id_R <= id_next;
    end

    always @(*) begin

        id_next = id_R;

        case (state_R)

            `SRAM_AXI_IDLE: begin

                if (state_next == `SRAM_AXI_WRITE_PROCEDURE
                 || state_next == `SRAM_AXI_WRITE_RESPONSE) begin
                    id_next = axi_s_awid;
                end
                else if (state_next == `SRAM_AXI_READ_PROCEDURE) begin
                    id_next = axi_s_arid;
                end
            end

            default:    begin
            end
        endcase
    end


    //
    reg         axiagu_set_en_comb;
    reg [31:0]  axiagu_set_addr_comb;
    reg [1:0]   axiagu_set_burst_type_comb;
    reg [2:0]   axiagu_set_burst_size_comb;
    reg [7:0]   axiagu_set_burst_len_comb;

    reg         axiagu_incr_en_comb;

    always @(*) begin
        
        axiagu_set_en_comb          = 'b0;
        axiagu_set_addr_comb        = 'b0;
        axiagu_set_burst_type_comb  = 'b0;
        axiagu_set_burst_size_comb  = 'b0;
        axiagu_set_burst_len_comb   = 'b0;

        axiagu_incr_en_comb         = 'b0;

        case (state_R)

            `SRAM_AXI_IDLE: begin

                if (state_next == `SRAM_AXI_WRITE_PROCEDURE
                 || state_next == `SRAM_AXI_WRITE_RESPONSE) begin
                    
                    axiagu_set_en_comb          = 1'b1;
                    axiagu_set_addr_comb        = axi_s_awaddr;
                    axiagu_set_burst_type_comb  = axi_s_awburst;
                    axiagu_set_burst_size_comb  = axi_s_awsize;
                    axiagu_set_burst_len_comb   = axi_s_awlen;

                    //axiagu_incr_en_comb         = 1'b1;
                    axiagu_incr_en_comb         = ctrl_readya;
                end
                else if (state_next == `SRAM_AXI_READ_PROCEDURE) begin

                    axiagu_set_en_comb          = 1'b1;
                    axiagu_set_addr_comb        = axi_s_araddr;
                    axiagu_set_burst_type_comb  = axi_s_arburst;
                    axiagu_set_burst_size_comb  = axi_s_arsize;
                    axiagu_set_burst_len_comb   = axi_s_arlen;

                    //axiagu_incr_en_comb         = 1'b1;
                    axiagu_incr_en_comb         = ctrl_readya;
                end
            end

            `SRAM_AXI_WRITE_PROCEDURE:  begin

                if (axi_s_wvalid & ctrl_readya & ~axiagu_o_last) begin
                    axiagu_incr_en_comb = 1'b1;
                end
            end

            `SRAM_AXI_READ_PROCEDURE:   begin

                if (axi_s_rready & ctrl_readya & ~axiagu_o_last) begin
                    axiagu_incr_en_comb = 1'b1;
                end
            end

            default:    begin
            end
        endcase
    end

    assign axiagu_set_en            = axiagu_set_en_comb;
    assign axiagu_set_addr          = axiagu_set_addr_comb;
    assign axiagu_set_burst_type    = axiagu_set_burst_type_comb;
    assign axiagu_set_burst_size    = axiagu_set_burst_size_comb;
    assign axiagu_set_burst_len     = axiagu_set_burst_len_comb;

    assign axiagu_incr_en           = axiagu_incr_en_comb;


    //
    reg         ctrl_ena_comb;
    reg [3:0]   ctrl_wea_comb;
    reg [19:0]  ctrl_addra_comb;
    reg [31:0]  ctrl_dina_comb;

    always @(*) begin

        ctrl_ena_comb   = 'b0;
        ctrl_wea_comb   = 'b0;

        ctrl_addra_comb = axiagu_o_addr[21:2];
        ctrl_dina_comb  = axi_s_wdata;

        case (state_R)

            `SRAM_AXI_IDLE: begin

                if (state_next == `SRAM_AXI_WRITE_PROCEDURE 
                    && (axi_s_wvalid & ctrl_readya)) begin

                    ctrl_ena_comb   = 1'b1;
                    ctrl_wea_comb   = axi_s_wstrb;
                end
                else if (state_next == `SRAM_AXI_WRITE_RESPONSE) begin

                    ctrl_ena_comb   = 1'b1;
                    ctrl_wea_comb   = axi_s_wstrb;
                end
                else if (state_next == `SRAM_AXI_READ_PROCEDURE) begin

                    ctrl_ena_comb   = 1'b1;
                    ctrl_wea_comb   = 4'b0000;
                end
            end

            `SRAM_AXI_WRITE_PROCEDURE:  begin

                if (axi_s_wvalid & ctrl_readya) begin

                    ctrl_ena_comb   = 1'b1;
                    ctrl_wea_comb   = axi_s_wstrb;
                end
            end

            `SRAM_AXI_READ_PROCEDURE:   begin

                if (axi_s_rready & ctrl_readya) begin

                    ctrl_ena_comb   = 1'b1;
                    ctrl_wea_comb   = 4'b0000;
                end
            end

            default:    begin
            end

        endcase
    end

    assign ctrl_ena     = ctrl_ena_comb;
    assign ctrl_wea     = ctrl_wea_comb;
    assign ctrl_addra   = ctrl_addra_comb;
    assign ctrl_dina    = ctrl_dina_comb;


    // Write Address Channel
    assign axi_s_awready = state_R == `SRAM_AXI_IDLE;

    // Write Data Channel
    assign axi_s_wready  = (state_R == `SRAM_AXI_IDLE || state_R == `SRAM_AXI_WRITE_PROCEDURE) && ctrl_readya;

    // Write Response Channel
    reg         bvalid_R,   bvalid_next;

    always @(posedge clk) begin

        if (~resetn) begin
            bvalid_R <= 'b0;
        end
        else begin
            bvalid_R <= bvalid_next;
        end
    end

    always @(*) begin

        bvalid_next = bvalid_R;

        case (state_R)

            `SRAM_AXI_IDLE: begin

                if (state_next == `SRAM_AXI_WRITE_RESPONSE) begin
                    bvalid_next = 1'b1;
                end
            end

            `SRAM_AXI_WRITE_PROCEDURE:  begin

                if (state_next == `SRAM_AXI_WRITE_RESPONSE) begin
                    bvalid_next = 1'b1;
                end
            end

            `SRAM_AXI_WRITE_RESPONSE:   begin

                if (state_next == `SRAM_AXI_IDLE) begin
                    bvalid_next = 1'b0;
                end
            end

            default:    begin
            end
        endcase
    end

    assign axi_s_bid    = id_R;
    assign axi_s_bresp  = 2'b0;
    assign axi_s_bvalid = bvalid_R;


    // Read Address Channel
    reg     arready_R,  arready_next;

    always @(posedge clk) begin

        if (~resetn) begin
            arready_R <= 'b0;
        end
        else begin
            arready_R <= arready_next;
        end
    end

    always @(*) begin

        arready_next = 'b0;

        case (state_R)

            `SRAM_AXI_IDLE: begin
                
                if (state_next == `SRAM_AXI_READ_PROCEDURE) begin
                    arready_next = 1'b1;
                end
            end

            default:    begin
            end
        endcase
    end

    assign axi_s_arready = arready_R;

    // Read Channel
    reg         rlast_R,    rlast_next;
    reg         rvalid_R,   rvalid_next;

    reg         rlast_OR;

    always @(posedge clk) begin

        rlast_OR <= rlast_R;    // 'rlast' delayed to next read cycle
    end

    always @(posedge clk) begin

        if (~resetn) begin
            rvalid_R <= 'b0;
        end
        else begin
            rvalid_R <= rvalid_next;
        end

        rlast_R     <= rlast_next;
    end

    always @(*) begin

        rvalid_next = 1'b0;
        rlast_next  = 1'b0;

        case (state_R)

            `SRAM_AXI_IDLE: begin

                if (state_next == `SRAM_AXI_READ_PROCEDURE) begin
                    rlast_next = axiagu_o_last;
                end
            end

            `SRAM_AXI_READ_PROCEDURE:   begin
                
                rvalid_next = ctrl_readya;

                if (ctrl_ena) begin
                    rlast_next = axiagu_o_last;
                end
                else begin
                    rlast_next = rlast_R;
                end
            end

            default:    begin
            end
        endcase
    end

    assign axi_s_rid    = id_R;
    assign axi_s_rdata  = ctrl_douta;
    assign axi_s_rresp  = 2'b0;
    assign axi_s_rlast  = rlast_OR;
    assign axi_s_rvalid = rvalid_R;

    // 

endmodule
