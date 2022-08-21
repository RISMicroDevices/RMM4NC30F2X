module execute_bru_impl_agu (
    //
    input   wire [31:0]     i_pc,

    input   wire [31:0]     i_src0_value,
    input   wire [31:0]     i_src1_value,

    input   wire [25:0]     i_imm,

    input   wire [1:0]      i_bagu_cmd,

    //
    output  wire [31:0]     o_target,
    output  wire [31:0]     o_wavefront
);

    //
    wire [31:0] s_pc;

    assign s_pc = i_pc + 'd4;

    //
    wire [31:0] s_rlt;
    wire [31:0] s_imm;
    wire [31:0] s_reg;

    wire [31:0] s_wavefront;

    assign s_rlt = s_pc + { {(14){i_imm[15]}}, i_imm[15:0], 2'b0 };

    assign s_imm = { s_pc[31:28], i_imm[25:0], 2'b0 };

    assign s_reg = i_src0_value;

    assign s_wavefront = i_pc + 'd8;

    //
    reg  [31:0] target_comb;

    always @(*) begin

        case (i_bagu_cmd)

            `BAGU_IMM:  begin
                target_comb = s_imm;
            end

            `BAGU_REG:  begin
                target_comb = s_reg;
            end

            default:    begin
                target_comb = s_rlt;
            end
        endcase
    end

    //
    assign o_target    = target_comb;

    assign o_wavefront = s_wavefront;

    //

endmodule
