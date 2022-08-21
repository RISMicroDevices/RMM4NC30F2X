
module issue_alloc (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire [8:0]      fifo_pr,

    //
    input   wire            i_valid,

    output  wire            o_readyn,

    output  wire            next_wen
);

    // *NOTICE: The 'readyn' state signal is asserted when there was only 4 or less slots free.
    //
    wire s_readyn;

    assign s_readyn = fifo_pr[8] | fifo_pr[7] | fifo_pr[6] | fifo_pr[5] | fifo_pr[4] | fifo_pr[3];

    // *NOTICE: The Issue Stage must still be available for at least 4 cycles after 'readyn' asserted.
    //
    reg s_readyn_dly1_R;
    reg s_readyn_dly2_R;
    reg s_readyn_dly3_R;
    reg s_readyn_dly4_R;

    always @(posedge clk) begin

        if (~resetn) begin

            s_readyn_dly1_R <= 'b0;
            s_readyn_dly2_R <= 'b0;
            s_readyn_dly3_R <= 'b0;
            s_readyn_dly4_R <= 'b0;
        end
        else if (snoop_hit) begin

            s_readyn_dly1_R <= 'b1;
            s_readyn_dly2_R <= 'b1;
            s_readyn_dly3_R <= 'b1;
            s_readyn_dly4_R <= 'b1;
        end
        else begin

            s_readyn_dly1_R <= s_readyn;
            s_readyn_dly2_R <= s_readyn_dly1_R;
            s_readyn_dly3_R <= s_readyn_dly2_R;
            s_readyn_dly4_R <= s_readyn_dly3_R;
        end
    end

    //
    assign next_wen = i_valid & ~s_readyn_dly4_R;

    assign o_readyn = s_readyn;

    //

endmodule
