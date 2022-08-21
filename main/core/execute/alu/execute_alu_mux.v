`include "execute_alu_mux_def.v"

module execute_alu_mux (
    //
    input   wire [32:0]     d_gmath,
    input   wire [31:0]     d_shift,

    input   wire [1:0]      sel,

    //
    output  wire [31:0]     s0
);

    //
    reg [31:0]  s0_comb;

    always @(*) begin

        case (sel)

            `ALU_MUX_SHIFT: begin
                s0_comb = d_shift;
            end

            `ALU_MUX_SLT:   begin
                s0_comb = { 31'b0, d_gmath[31] };
            end

            `ALU_MUX_SLTU:  begin
                s0_comb = { 31'b0, d_gmath[32] };
            end

            default:        begin
                s0_comb = d_gmath[31:0];
            end
        endcase
    end

    //
    assign s0 = s0_comb;

    //

endmodule
