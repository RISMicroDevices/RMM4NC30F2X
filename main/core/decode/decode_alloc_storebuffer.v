
module decode_alloc_storebuffer (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire            en_alloc,
    input   wire            en_alloc_store,

    //
    input   wire            en_commit,
    input   wire            en_commit_store,

    //
    input   wire            bco_valid,

    //
    output  wire            readyn
);

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

    assign r_pop  = (en_commit & en_commit_store) & ~s_empty;
    assign r_push = (en_alloc  & en_alloc_store)  & ~s_full;

    assign p_hold = r_pop & (en_alloc & en_alloc_store);
    
    assign p_pop  = ~p_hold & r_pop;
    assign p_push = ~p_hold & r_push;

    //
    reg [6:0]   fifo_p_R;

    assign fifo_p  = fifo_p_R;

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
    assign readyn = fifo_p_R[6] | fifo_p_R[5] | fifo_p_R[4] | fifo_p_R[3] | fifo_p_R[2];

    //

endmodule
