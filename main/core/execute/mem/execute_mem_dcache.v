
module execute_mem_dcache (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            update_tag_en,
    input   wire [31:0]     update_tag_addr,
    input   wire            update_tag_valid,

    input   wire            update_data_valid,
    input   wire [31:0]     update_data_addr,
    input   wire [3:0]      update_data_strb,
    input   wire [31:0]     update_data,

    output  wire            update_data_ready,

    //
    input   wire            store_data_en,
    input   wire [31:0]     store_data_addr,
    input   wire [3:0]      store_data_strb,
    input   wire [31:0]     store_data,

    //
    input   wire [31:0]     q_addr,

    output  wire            q_hit,
    output  wire [31:0]     q_data,

    //
    input   wire [31:0]     q1_addr,

    output  wire            q1_hit
);

    //
    reg  [31:0] q_addr_R;
    reg  [31:0] q1_addr_R;

    always @(posedge clk) begin

        q_addr_R    <= q_addr;
        q1_addr_R   <= q1_addr;
    end


    //
    wire        dtag_valid;
    wire [18:0] dtag_tag;

    wire        dtag_1valid;
    wire [18:0] dtag_1tag;

    execute_mem_dcache_tag execute_mem_dcache_tag_INST (
        .clk        (clk),
        .resetn     (resetn),

        .wea        (update_tag_en),
        .addra      (update_tag_addr[12:5]),
        .dina_valid (update_tag_valid),
        .dina_tag   (update_tag_addr[31:13]),

        .addrb      (q_addr[12:5]),
        .doutb_valid(dtag_valid),
        .doutb_tag  (dtag_tag),

        .addrc      (q1_addr[12:5]),
        .doutc_valid(dtag_1valid),
        .doutc_tag  (dtag_1tag)
    );

    // D-Tag output registers
    reg         dtag_odffs_valid;
    reg  [18:0] dtag_odffs_tag;

    reg         dtag_odffs_1valid;
    reg  [18:0] dtag_odffs_1tag;

    always @(posedge clk) begin

        if (~resetn) begin

            dtag_odffs_valid    <= 'b0;
            dtag_odffs_1valid   <= 'b0;
        end
        else begin

            dtag_odffs_valid    <= dtag_valid;
            dtag_odffs_1valid   <= dtag_1valid;
        end

        dtag_odffs_tag  <= dtag_tag;
        dtag_odffs_1tag <= dtag_1tag;
    end


    //
    reg         update_data_valid_IR;
    reg [31:0]  update_data_addr_IR;
    reg [3:0]   update_data_strb_IR;
    reg [31:0]  update_data_IR;

    always @(posedge clk) begin

        if (~resetn) begin
            update_data_valid_IR <= 'b0;
        end
        else if (~store_data_en) begin
            update_data_valid_IR <= update_data_valid;
        end

        if (~store_data_en) begin

            update_data_addr_IR <= update_data_addr;
            update_data_strb_IR <= update_data_strb;
            update_data_IR      <= update_data;
        end
    end

    //
    bram_dcache_data bram_dcache_data_INST (
        .clka   (clk),
        .addra  (store_data_en ? store_data_addr[12:2]  : update_data_addr_IR[12:2]),
        .dina   (store_data_en ? store_data             : update_data_IR),
        .ena    (store_data_en ? 1'b1                   : update_data_valid_IR),
        .wea    (store_data_en ? store_data_strb        : update_data_strb_IR),

        .clkb   (clk),
        .addrb  (q_addr[12:2]),
        .doutb  (q_data)
    );

    //
    reg         update_data_ready_OR;

    always @(posedge clk) begin

        if (~resetn) begin
            update_data_ready_OR <= 1'b1;
        end
        else begin
            update_data_ready_OR <= ~store_data_en;
        end
    end

    assign update_data_ready = ~store_data_en;

    //
    assign q_hit    = dtag_odffs_valid  && q_addr_R[31:13]  == dtag_odffs_tag;

    assign q1_hit   = dtag_odffs_1valid && q1_addr_R[31:13] == dtag_odffs_1tag;

    //assign q_hit    = 1'b0;

    //assign q1_hit   = 1'b0;

    //

endmodule
