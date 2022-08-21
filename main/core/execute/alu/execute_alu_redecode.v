`include "execute_alu_mux_def.v"
`include "execute_alu_impl_lut6opt_imm_def.v"
`include "execute_alu_impl_lut6opt_math_def.v"
`include "execute_alu_impl_shift_def.v"

module execute_alu_redecode (
    //
    input   wire            i_valid,
    input   wire [4:0]      i_alu_cmd,

    //
    output  wire [1:0]      o_alu_math_imm,
    output  wire [2:0]      o_alu_math_func,

    output  wire [0:0]      o_alu_shift_sa_sel,
    output  wire [1:0]      o_alu_shift_func,

    output  wire [1:0]      o_alu_mux
);

    //
    reg [1:0]   alu_math_imm_comb;
    reg [2:0]   alu_math_func_comb;

    reg [0:0]   alu_shift_sa_sel_comb;
    reg [1:0]   alu_shift_func_comb;

    reg [1:0]   alu_mux_comb;

    always @(*) begin

        alu_math_func_comb      = `ALU_IMPL_LUT6OPT_ZERO;
        alu_math_imm_comb       = `ALU_IMPL_LUT6OPT_BYPASS;

        alu_shift_func_comb     = `ALU_IMPL_SLL;
        alu_shift_sa_sel_comb   = `ALU_IMPL_SA_RS;

        alu_mux_comb            = `ALU_MUX_GMATH;

        if (i_valid) begin

            case (i_alu_cmd)

                `ALU_ADD:   begin

                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_ADD;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_BYPASS;
                end

                `ALU_ADDI:  begin

                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_ADD;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_IMM_SEXT;
                end

                `ALU_SUB:   begin

                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_SUB;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_BYPASS;
                end

                `ALU_SUBI:  begin

                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_SUB;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_IMM_SEXT;
                end

                `ALU_AND:   begin

                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_AND;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_BYPASS;
                end

                `ALU_ANDI:  begin

                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_AND;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_IMM_ZEXT;
                end

                `ALU_OR:    begin

                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_OR;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_BYPASS;
                end

                `ALU_ORI:   begin

                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_OR;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_IMM_ZEXT;
                end

                `ALU_XOR:   begin

                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_XOR;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_BYPASS;
                end

                `ALU_XORI:  begin

                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_XOR;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_IMM_ZEXT;
                end

                `ALU_SLT:   begin
                    
                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_SUB;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_BYPASS;

                    alu_mux_comb        = `ALU_MUX_SLT;
                end

                `ALU_SLTU:   begin
                    
                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_SUB;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_BYPASS;

                    alu_mux_comb        = `ALU_MUX_SLTU;
                end

                `ALU_LUI:   begin

                    alu_math_func_comb  = `ALU_IMPL_LUT6OPT_ZERO0;
                    alu_math_imm_comb   = `ALU_IMPL_LUT6OPT_IMM_LUI;
                end

                `ALU_SLL:   begin

                    alu_shift_func_comb     = `ALU_IMPL_SLL;
                    alu_shift_sa_sel_comb   = `ALU_IMPL_SA_IMM;

                    alu_mux_comb            = `ALU_MUX_SHIFT;
                end

                `ALU_SLLV:  begin

                    alu_shift_func_comb     = `ALU_IMPL_SLL;
                    alu_shift_sa_sel_comb   = `ALU_IMPL_SA_RS;

                    alu_mux_comb            = `ALU_MUX_SHIFT;
                end

                `ALU_SRL:   begin

                    alu_shift_func_comb     = `ALU_IMPL_SRL;
                    alu_shift_sa_sel_comb   = `ALU_IMPL_SA_IMM;

                    alu_mux_comb            = `ALU_MUX_SHIFT;
                end

                `ALU_SRLV:  begin

                    alu_shift_func_comb     = `ALU_IMPL_SRL;
                    alu_shift_sa_sel_comb   = `ALU_IMPL_SA_RS;

                    alu_mux_comb            = `ALU_MUX_SHIFT;
                end

                `ALU_SRA:   begin

                    alu_shift_func_comb     = `ALU_IMPL_SRA;
                    alu_shift_sa_sel_comb   = `ALU_IMPL_SA_IMM;

                    alu_mux_comb            = `ALU_MUX_SHIFT;
                end

                `ALU_SRAV:  begin

                    alu_shift_func_comb     = `ALU_IMPL_SRA;
                    alu_shift_sa_sel_comb   = `ALU_IMPL_SA_RS;

                    alu_mux_comb            = `ALU_MUX_SHIFT;
                end

                default:    begin
                end
            endcase
        end
    end

    //
    assign o_alu_math_imm       = alu_math_imm_comb;
    assign o_alu_math_func      = alu_math_func_comb;

    assign o_alu_shift_sa_sel   = alu_shift_sa_sel_comb;
    assign o_alu_shift_func     = alu_shift_func_comb;

    assign o_alu_mux            = alu_mux_comb;

    //

endmodule
