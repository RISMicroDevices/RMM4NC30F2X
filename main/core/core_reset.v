
module core_reset (
    input   wire            clk,
    input   wire            resetn,

    output  wire            o_resetn
);

    //
    reg [15:0]  resetn_R;

    always @(posedge clk or negedge resetn) begin

        if (~resetn) begin
            resetn_R <= 16'b0;
        end
        else begin
            resetn_R <= { resetn_R[14:0], 1'b1 };
        end
    end

    //
    assign o_resetn     = resetn_R[15];

    /*
    assign o_resetn     = resetn;
    */

    //

endmodule
