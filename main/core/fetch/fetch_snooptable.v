
module fetch_snooptable (
    input   wire            clk,
    input   wire            resetn,

    // Snoop entry shift-in
    input   wire            wea,
    input   wire [31:0]     addra,

    // Snoop entry pop-out
    input   wire            web,

    // Snoop hit query
    input   wire [31:0]     q_addr,
    output  wire            q_hit
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

    assign r_pop  = (web) & ~s_empty;
    assign r_push = (wea) & ~s_full;

    assign p_hold = r_pop & wea;
    
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
    reg [31:0]  addr_R  [5:0];

    always @(posedge clk) begin

        for (i = 0; i < 6; i = i + 1) begin

            if (p_shr) begin

                if (wea && fifo_p[i + 1]) begin
                    addr_R[i] <= addra;
                end
                else if (i < 5) begin
                    addr_R[i] <= addr_R[i + 1];
                end
            end
            else if (wea && fifo_p[i]) begin
                addr_R[i] <= addra;
            end
        end
    end

    //
    wire [5:0]  snoop_hit;

    generate

        for (j = 0; j < 6; j = j + 1) begin
            assign snoop_hit[j] = p_valid[j] && (q_addr[31:6] == addr_R[j][31:6]);
        end
    endgenerate

    //
    assign q_hit = |(snoop_hit);

    //

endmodule
