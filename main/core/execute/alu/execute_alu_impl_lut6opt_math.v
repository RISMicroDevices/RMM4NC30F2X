`include "execute_alu_impl_lut6opt_math_def.v"

module execute_alu_impl_lut6opt_math (
    //
    input   wire [31:0]     d0,     // A0
    input   wire [31:0]     d1,     // A1

    input   wire [2:0]      sel,    // A2 ~ A4

    //
    output  wire [32:0]     s0,
    output  wire [32:0]     s1,

    output  wire            sub
);
    //
    integer i;

    // *NOTICE: Part of ALU design is specially optimized for LUT6,
    //          and should be implemented as multiple double LUT5s.

    reg [32:0]  s0_comb;
    reg [32:0]  s1_comb;

    always @(*) begin
        
        s0_comb[32] = 1'b0;
        s1_comb[32] = 1'b0;

        case (sel)

            `ALU_IMPL_LUT6OPT_SUB:  begin

                s0_comb[32] = 1'b0;
                s1_comb[32] = 1'b1;
            end

            default:    begin
            end
        endcase

        for (i = 0; i < 32; i = i + 1) begin

            case (sel)

                `ALU_IMPL_LUT6OPT_ZERO:     begin

                    s0_comb[i] = 1'b0;
                    s1_comb[i] = 1'b0;
                end

                `ALU_IMPL_LUT6OPT_ZERO0:    begin

                    s0_comb[i] = 1'b0;
                    s1_comb[i] = d1[i];
                end

                `ALU_IMPL_LUT6OPT_ZERO1:    begin

                    s0_comb[i] = d0[i];
                    s1_comb[i] = 1'b0;
                end

                `ALU_IMPL_LUT6OPT_ADD:      begin

                    s0_comb[i] = d0[i];
                    s1_comb[i] = d1[i];
                end

                `ALU_IMPL_LUT6OPT_SUB:      begin

                    s0_comb[i] =  d0[i];
                    s1_comb[i] = ~d1[i];
                end

                `ALU_IMPL_LUT6OPT_AND:      begin
                    
                    s0_comb[i] = d0[i] & d1[i];
                    s1_comb[i] = 1'b0;
                end

                `ALU_IMPL_LUT6OPT_OR:       begin

                    s0_comb[i] = d0[i] | d1[i];
                    s1_comb[i] = 1'b0;
                end

                `ALU_IMPL_LUT6OPT_XOR:      begin

                    s0_comb[i] = d0[i] ^ d1[i];
                    s1_comb[i] = 1'b0;
                end

                default:                    begin

                    s0_comb[i] = 1'b0;
                    s1_comb[i] = 1'b0;
                end

            endcase
        end
    end

    //
    assign s0 = s0_comb;
    assign s1 = s1_comb;

    assign sub = sel == `ALU_IMPL_LUT6OPT_SUB;

    //

endmodule
