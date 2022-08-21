// @description
//  ** PART OF **
//  RMM4NC3001X - Gemini 3001
//  (MIPS32 Processor for NSCSCC2021)
//
//  Common regfile module (2 read ports, 1 write port)
//
// @author Kumonda221
//

module decode_regfiles (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire [4:0]      raddr0,
    input   wire [4:0]      raddr1,

    output  wire [31:0]     rdata0,
    output  wire [31:0]     rdata1,

    //
    input   wire [4:0]      waddr,
    input   wire            wen,
    input   wire [31:0]     wdata

);

    (*ram_style = "distributed" *) reg[31:0] regstack[31:1];

    // Write logic
    integer i;
    always @(posedge clk) begin

        if ((waddr != 5'b0) && wen) begin
            regstack[waddr] <= wdata;
        end
    end

    // Read logic
    assign rdata0 = (raddr0 == 5'b0) ? 32'b0 : regstack[raddr0];
    assign rdata1 = (raddr1 == 5'b0) ? 32'b0 : regstack[raddr1];

    //

endmodule
