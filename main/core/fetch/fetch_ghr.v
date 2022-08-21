
module fetch_ghr (
    input   wire            clk,
    input   wire            resetn,

    input   wire            wen,
    input   wire [7:0]      wdata,

    output  wire [7:0]      rdata
);

    reg [7:0]   ghr_R;

    always @(posedge clk) begin

        if (~resetn) begin
            ghr_R <= 'b0;
        end
        else if (wen) begin
            ghr_R <= wdata;
        end
    end

    assign rdata = ghr_R;

endmodule
