`include "execute_alu_impl_shift_def.v"

module execute_alu_impl_shift (
    //
    input   wire [31:0]     d0,

    input   wire [4:0]      sa0,
    input   wire [4:0]      sa1,
    input   wire            sa_sel,

    input   wire [1:0]      sel,

    //
    output  wire [31:0]     s0
);

    //
    wire [4:0]  sa = sa_sel ? sa1 : sa0;

    //
    reg  [31:0] s0_comb;

    always @(*) begin

        case (sel)

            `ALU_IMPL_SRL:  begin   // SRL
                s0_comb = $unsigned(d0) >> sa;
            end

            `ALU_IMPL_SRA:  begin   // SRA
                s0_comb = $signed(d0) >> sa;
            end

            default:        begin   // SLL
                s0_comb = $unsigned(d0) << sa;
            end

        endcase
    end

    //
    assign s0 = s0_comb;

    //

endmodule
