
module soc_reset (
    input   wire            mmcm_clk,
    input   wire            mmcm_locked,

    output  wire            sys_clk,
    output  wire            sys_resetn
);

    //
    reg [15:0]  resetn_R;

    always @(posedge mmcm_clk or negedge mmcm_locked) begin

        if (~mmcm_locked) begin
            resetn_R <= 16'b0;
        end
        else begin
            resetn_R <= { resetn_R[14:0], 1'b1 };
        end
    end

    //
    assign sys_clk        = mmcm_clk;
    assign sys_resetn     = resetn_R[15];

    //

endmodule
