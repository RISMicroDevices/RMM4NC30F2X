
module execute_mem_qdffs (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire [3:0]      i_strb,
    input   wire [31:0]     i_data,

    //
    output  wire [3:0]      o_strb,
    output  wire [31:0]     o_data
);

    //
    reg [3:0]   strb_R;
    reg [31:0]  data_R;

    always @(posedge clk) begin

        strb_R <= i_strb;
        data_R <= i_data;
    end

    //
    assign o_strb = strb_R;
    assign o_data = data_R;

    //

endmodule
