
module execute_mem_postcmtbuffer (
    input   wire            clk,
    input   wire            resetn,

    // StoreBuffer write (on STORE instruction committed, in-order)
    input   wire            web,
    input   wire [31:0]     dinb_addr,
    input   wire [3:0]      dinb_strb,
    input   wire [1:0]      dinb_lswidth,
    input   wire [31:0]     dinb_data,
    input   wire            dinb_uncached,

    // StoreBuffer commit (on AXI write-through action done)
    input   wire            wec,

    output  wire            doutc_valid,
    output  wire [31:0]     doutc_addr,
    output  wire [3:0]      doutc_strb,
    output  wire [1:0]      doutc_lswidth,
    output  wire [31:0]     doutc_data,
    output  wire            doutc_uncached,

    input   wire            dinc_hit,           // 1 clk delayed

    // Store into cache
    output  wire            store_data_en,
    output  wire [31:0]     store_data_addr,
    output  wire [3:0]      store_data_strb,
    output  wire [31:0]     store_data,

    // StoreBuffer query
    input   wire [31:0]     qin_addr,

    output  wire [3:0]      qout_strb,
    output  wire [31:0]     qout_data,

    // LoadBuffer state query
    output  wire [31:0]     s_qaddr,
    input   wire            s_busy,

    // StoreBuffer state
    output  wire            s_o_busy_uncached,

    // StoreBuffer commit ready
    output  wire            readyn
);

    //
    integer i;
    genvar  j;

    //
    wire [6:0]  fifo_p;

    //
    wire s_full;
    wire s_empty;

    wire r_pop;   // functionally accepted reading from FIFO
    wire r_push;  // functionally accepted writing into FIFO

    wire p_hold;  // read and write FIFO simultaneously
    wire p_pop;   // read FIFO only
    wire p_push;  // write FIFO only

    assign r_pop  = (wec) & ~s_empty;
    assign r_push = (web) & ~s_full;

    assign p_hold = r_pop & web;
    
    assign p_pop  = ~p_hold & r_pop;
    assign p_push = ~p_hold & r_push;

    //
    wire p_shr;

    assign p_shr = r_pop;

    // FIFO entry valid logic
    wire [5:0]  p_valid;
    wire [5:0]  p_valid_carrier;

    generate

        for (j = 0; j < 6; j = j + 1) begin

            if (j < 5) begin

                assign p_valid[j]         = fifo_p[j + 1] | p_valid_carrier[j + 1];
                assign p_valid_carrier[j] = p_valid[j];
            end
            else begin
                
                assign p_valid[j]         = fifo_p[j + 1];
                assign p_valid_carrier[j] = p_valid[j];
            end
        end
    endgenerate

    //
    reg [6:0]   fifo_p_R;

    assign fifo_p = fifo_p_R;

    assign s_full  = fifo_p_R[6];
    assign s_empty = fifo_p_R[0];

    always @(posedge clk) begin

        if (~resetn) begin
            fifo_p_R <= 7'b1;
        end
        else if (p_pop) begin
            fifo_p_R <= { 1'b0, fifo_p_R[6:1] };
        end
        else if (p_push) begin
            fifo_p_R <= { fifo_p_R[5:0], 1'b0 };
        end
    end


    //
    reg [31:0]  addr_R      [5:0];

    reg         uncached_R  [5:0];
    reg [1:0]   lswidth_R   [5:0];

    reg         b0_strb_R   [5:0];
    reg [7:0]   b0_data_R   [5:0];

    reg         b1_strb_R   [5:0];
    reg [7:0]   b1_data_R   [5:0];

    reg         b2_strb_R   [5:0];
    reg [7:0]   b2_data_R   [5:0];

    reg         b3_strb_R   [5:0];
    reg [7:0]   b3_data_R   [5:0];

    always @(posedge clk) begin

        for (i = 0; i < 6; i = i + 1) begin

            if (p_shr) begin

                if (web && fifo_p[i + 1]) begin

                    addr_R    [i] <= dinb_addr;

                    uncached_R[i] <= dinb_uncached;
                    lswidth_R [i] <= dinb_lswidth;

                    b0_strb_R [i] <= dinb_strb[0];
                    b0_data_R [i] <= dinb_data[7:0];

                    b1_strb_R [i] <= dinb_strb[1];
                    b1_data_R [i] <= dinb_data[15:8];

                    b2_strb_R [i] <= dinb_strb[2];
                    b2_data_R [i] <= dinb_data[23:16];

                    b3_strb_R [i] <= dinb_strb[3];
                    b3_data_R [i] <= dinb_data[31:24];
                end
                else if (i < 5) begin

                    addr_R    [i] <= addr_R    [i + 1];

                    uncached_R[i] <= uncached_R[i + 1];
                    lswidth_R [i] <= lswidth_R [i + 1];

                    b0_strb_R [i] <= b0_strb_R [i + 1];
                    b0_data_R [i] <= b0_data_R [i + 1];

                    b1_strb_R [i] <= b1_strb_R [i + 1];
                    b1_data_R [i] <= b1_data_R [i + 1];

                    b2_strb_R [i] <= b2_strb_R [i + 1];
                    b2_data_R [i] <= b2_data_R [i + 1];

                    b3_strb_R [i] <= b3_strb_R [i + 1];
                    b3_data_R [i] <= b3_data_R [i + 1];
                end
            end
            else if (web && fifo_p[i]) begin

                addr_R    [i] <= dinb_addr;

                uncached_R[i] <= dinb_uncached;
                lswidth_R [i] <= dinb_lswidth;

                b0_strb_R [i] <= dinb_strb[0];
                b0_data_R [i] <= dinb_data[7:0];

                b1_strb_R [i] <= dinb_strb[1];
                b1_data_R [i] <= dinb_data[15:8];

                b2_strb_R [i] <= dinb_strb[2];
                b2_data_R [i] <= dinb_data[23:16];

                b3_strb_R [i] <= dinb_strb[3];
                b3_data_R [i] <= dinb_data[31:24];
            end
        end
    end


    //
    wire [5:0]  p_uncached;

    generate
        for (j = 0; j < 6; j = j + 1) begin

            assign p_uncached[j] = p_valid[j] & uncached_R[j];
        end
    endgenerate

    assign s_o_busy_uncached = |(p_uncached);


    // Cache write-back delay compensation
    reg         comp_valid_R;
    
    reg [31:0]  comp_addr_R;

    reg         comp_b0_strb_R;
    reg [7:0]   comp_b0_data_R;

    reg         comp_b1_strb_R;
    reg [7:0]   comp_b1_data_R;

    reg         comp_b2_strb_R;
    reg [7:0]   comp_b2_data_R;

    reg         comp_b3_strb_R;
    reg [7:0]   comp_b3_data_R;
    
    always @(posedge clk) begin

        if (~resetn) begin
            comp_valid_R <= 'b0;
        end
        else if (wec & ~doutc_uncached) begin
            comp_valid_R <= 1'b1;
        end
        else begin
            comp_valid_R <= 1'b0;
        end

        if (wec & ~doutc_uncached) begin

            comp_addr_R     <= doutc_addr;

            comp_b0_strb_R  <= doutc_strb[0];
            comp_b0_data_R  <= doutc_data[7:0];

            comp_b1_strb_R  <= doutc_strb[1];
            comp_b1_data_R  <= doutc_data[15:8];

            comp_b2_strb_R  <= doutc_strb[2];
            comp_b2_data_R  <= doutc_data[23:16];

            comp_b3_strb_R  <= doutc_strb[3];
            comp_b3_data_R  <= doutc_data[31:24];
        end
    end

    //
    wire    comp_hit;

    assign comp_hit = comp_valid_R && qin_addr[31:2] == comp_addr_R[31:2];

    //


    // Byte part select
    reg [4:0]   sel_comb    [3:0];

    always @(*) begin

        sel_comb[0] = { ~comp_hit, comp_hit, 3'b0 };
        sel_comb[1] = { ~comp_hit, comp_hit, 3'b0 };
        sel_comb[2] = { ~comp_hit, comp_hit, 3'b0 };
        sel_comb[3] = { ~comp_hit, comp_hit, 3'b0 };

        for (i = 0; i < 6; i = i + 1) begin

            if (p_valid[i] && qin_addr[31:2] == addr_R[i][31:2] && ~uncached_R[i]) begin

                if (b0_strb_R[i]) begin
                    sel_comb[0] = i;
                end

                if (b1_strb_R[i]) begin
                    sel_comb[1] = i;
                end

                if (b2_strb_R[i]) begin
                    sel_comb[2] = i;
                end

                if (b3_strb_R[i]) begin
                    sel_comb[3] = i;
                end
            end
        end
    end

    //
    assign qout_strb  = {   sel_comb[3][4] ? 1'b0 : (sel_comb[3][3] ? comp_b3_strb_R : (b3_strb_R[sel_comb[3][2:0]] & p_valid[0])),
                            sel_comb[2][4] ? 1'b0 : (sel_comb[2][3] ? comp_b2_strb_R : (b2_strb_R[sel_comb[2][2:0]] & p_valid[0])),
                            sel_comb[1][4] ? 1'b0 : (sel_comb[1][3] ? comp_b1_strb_R : (b1_strb_R[sel_comb[1][2:0]] & p_valid[0])), 
                            sel_comb[0][4] ? 1'b0 : (sel_comb[0][3] ? comp_b0_strb_R : (b0_strb_R[sel_comb[0][2:0]] & p_valid[0])) };

    assign qout_data  = {   sel_comb[3][3] ? comp_b3_data_R : b3_data_R[sel_comb[3][2:0]],
                            sel_comb[2][3] ? comp_b2_data_R : b2_data_R[sel_comb[2][2:0]],
                            sel_comb[1][3] ? comp_b1_data_R : b1_data_R[sel_comb[1][2:0]],
                            sel_comb[0][3] ? comp_b0_data_R : b0_data_R[sel_comb[0][2:0]] };

    //
    assign s_qaddr          = addr_R    [0];

    assign doutc_valid      = p_valid   [0] & ~s_busy;
    assign doutc_uncached   = uncached_R[0];
    assign doutc_lswidth    = lswidth_R [0];
    assign doutc_addr       = addr_R    [0];

    assign doutc_strb  = {  b3_strb_R[0],
                            b2_strb_R[0],
                            b1_strb_R[0],
                            b0_strb_R[0] };

    assign doutc_data  = {  b3_data_R[0],
                            b2_data_R[0],
                            b1_data_R[0],
                            b0_data_R[0] };

    //
    assign readyn = fifo_p[6] | fifo_p[5];


    // Cache writeback on cached store commit
    reg         store_en_R;

    reg         store_valid_R;
    reg [31:0]  store_addr_R;
    reg [3:0]   store_strb_R;
    reg [31:0]  store_data_R;
    reg         store_uncached_R;

    always @(posedge clk) begin

        if (~resetn) begin
            store_en_R <= 'b0;
        end
        else begin
            store_en_R <= wec;
        end

        store_valid_R    <= doutc_valid;
        store_addr_R     <= doutc_addr;
        store_strb_R     <= doutc_strb;
        store_data_R     <= doutc_data;
        store_uncached_R <= doutc_uncached;
    end

    //
    assign store_data_en    = store_valid_R & ~store_uncached_R & store_en_R & dinc_hit;
    assign store_data_addr  = store_addr_R;
    assign store_data_strb  = store_strb_R;
    assign store_data       = store_data_R;

    //

endmodule
