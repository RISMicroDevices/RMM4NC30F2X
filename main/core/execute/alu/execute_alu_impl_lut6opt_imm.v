`include "execute_alu_impl_lut6opt_imm_def.v"

module execute_alu_impl_lut6opt_imm (
    //
    input   wire [31:0]     d0,     // A0 ~ A1
    input   wire [15:0]     d1,     // A2

    input   wire [1:0]      sel,    // A3 ~ A4

    //
    output  wire [31:0]     s0
);
    //
    integer i;

    //
    reg [31:0]  s0_comb;

    always @(*) begin
        for (i = 0; i < 16; i = i + 1) begin

            case (sel)

                `ALU_IMPL_LUT6OPT_BYPASS:   begin

                    s0_comb[i]      = d0[i];
                    s0_comb[i + 16] = d0[i + 16];
                end

                `ALU_IMPL_LUT6OPT_IMM_ZEXT: begin

                    s0_comb[i]      = d1[i];
                    s0_comb[i + 16] = 1'b0;
                end

                `ALU_IMPL_LUT6OPT_IMM_SEXT: begin
                    
                    s0_comb[i]      = d1[i];
                    s0_comb[i + 16] = d1[15];
                end

                `ALU_IMPL_LUT6OPT_IMM_LUI:  begin

                    s0_comb[i]      = 1'b0;
                    s0_comb[i + 16] = d1[i];
                end

                default:    begin

                    s0_comb[i]      = 1'b0;
                    s0_comb[i + 16] = 1'b0;
                end

            endcase
        end
    end

    //
    assign s0 = s0_comb;

    //

endmodule
