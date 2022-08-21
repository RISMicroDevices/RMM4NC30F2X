
module execute_mem_storebuffer (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire            bco_valid,

    // StoreBuffer write (on STORE instruction issued, in-order)
    input   wire            enb,
    input   wire [3:0]      web,
    input   wire [1:0]      dinb_lswidth,
    input   wire [31:0]     dinb_addr,
    input   wire [31:0]     dinb_data,
    input   wire            dinb_uncached,

    // StoreBuffer commit (on ROB commit)
    input   wire            wec,

    output  wire            doutc_valid,
    output  wire [31:0]     doutc_addr,
    output  wire [3:0]      doutc_strb,
    output  wire [1:0]      doutc_lswidth,
    output  wire [31:0]     doutc_data,
    output  wire            doutc_uncached,

    // StoreBuffer query
    input   wire [31:0]     qin_addr,

    output  wire [3:0]      qout_strb,
    output  wire [31:0]     qout_data
);

    //
    integer i;
    genvar  j;

    //
    wire [6:0]  fifo_p;

    //
    wire    enb_x;

    assign enb_x = enb & ~bco_valid;

    
    //
    wire s_full;
    wire s_empty;

    wire r_pop;   // functionally accepted reading from FIFO
    wire r_push;  // functionally accepted writing into FIFO

    wire p_hold;  // read and write FIFO simultaneously
    wire p_pop;   // read FIFO only
    wire p_push;  // write FIFO only

    assign r_pop  = (wec  ) & ~s_empty;
    assign r_push = (enb_x) & ~s_full;

    assign p_hold = r_pop & enb_x;
    
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
        else if (snoop_hit) begin
            fifo_p_R <= 7'b1;
        end
        else if (bco_valid) begin
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

            if (p_shr && i < 5) begin

                if (enb_x && fifo_p[i + 1]) begin

                    addr_R    [i] <= dinb_addr;

                    uncached_R[i] <= dinb_uncached;
                    lswidth_R [i] <= dinb_lswidth;

                    b0_strb_R [i] <= web[0];
                    b0_data_R [i] <= dinb_data[7:0];

                    b1_strb_R [i] <= web[1];
                    b1_data_R [i] <= dinb_data[15:8];

                    b2_strb_R [i] <= web[2];
                    b2_data_R [i] <= dinb_data[23:16];

                    b3_strb_R [i] <= web[3];
                    b3_data_R [i] <= dinb_data[31:24];
                end
                else begin

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
            else if (enb_x && fifo_p[i]) begin

                addr_R    [i] <= dinb_addr;

                uncached_R[i] <= dinb_uncached;
                lswidth_R [i] <= dinb_lswidth;

                b0_strb_R [i] <= web[0];
                b0_data_R [i] <= dinb_data[7:0];

                b1_strb_R [i] <= web[1];
                b1_data_R [i] <= dinb_data[15:8];

                b2_strb_R [i] <= web[2];
                b2_data_R [i] <= dinb_data[23:16];

                b3_strb_R [i] <= web[3];
                b3_data_R [i] <= dinb_data[31:24];
            end

        end
    end

    // Byte part select
    reg [3:0]   sel_comb    [3:0];

    always @(*) begin

        sel_comb[0] = { 1'b1, 3'b0 };
        sel_comb[1] = { 1'b1, 3'b0 };
        sel_comb[2] = { 1'b1, 3'b0 };
        sel_comb[3] = { 1'b1, 3'b0 };

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
    assign qout_strb  = {   sel_comb[3][3] ? 1'b0 : (p_valid[0] ? b3_strb_R[sel_comb[3][2:0]] : 1'b0),
                            sel_comb[2][3] ? 1'b0 : (p_valid[0] ? b2_strb_R[sel_comb[2][2:0]] : 1'b0),
                            sel_comb[1][3] ? 1'b0 : (p_valid[0] ? b1_strb_R[sel_comb[1][2:0]] : 1'b0), 
                            sel_comb[0][3] ? 1'b0 : (p_valid[0] ? b0_strb_R[sel_comb[0][2:0]] : 1'b0) };

    assign qout_data  = {   b3_data_R[sel_comb[3][2:0]],
                            b2_data_R[sel_comb[2][2:0]],
                            b1_data_R[sel_comb[1][2:0]],
                            b0_data_R[sel_comb[0][2:0]] };

    //
    assign doutc_valid      = p_valid   [0];
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

endmodule
