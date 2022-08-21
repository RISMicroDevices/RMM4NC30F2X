module decode_idecode (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire [31:0]     insn,
    input   wire            valid,

    //
    output  wire [4:0]      src0,
    output  wire [4:0]      src1,
    output  wire [4:0]      dst,

    output  wire [25:0]     imm,

    output  wire            branch,
    output  wire            load,
    output  wire            store,
    output  wire [1:0]      lswidth,

    output  wire            pipe_alu,
    output  wire            pipe_mul,
    output  wire            pipe_mem,
    output  wire            pipe_bru,

    output  wire [4:0]      alu_cmd,
    output  wire [0:0]      mul_cmd,
    output  wire [4:0]      mem_cmd,
    output  wire [6:0]      bru_cmd,
    output  wire [1:0]      bagu_cmd
);

    wire [5:0]  opcode;

    wire [4:0]  rs, rt, rd;
    wire [4:0]  sa;
    wire [5:0]  func;
    wire [15:0] iimm;
    wire [25:0] jindex;

    assign opcode = insn[31:26];

    assign rs = insn[25:21];
    assign rt = insn[20:16];
    assign rd = insn[15:11];

    assign sa       = insn[10:6];
    assign func     = insn[5:0];
    assign iimm     = insn[15:0];
    assign jindex   = insn[25:0];

    // Instructions
    wire i_add, i_addi, i_addu, i_addiu, i_sub,  i_slt,  i_sltu,  i_mul;
    wire i_and, i_andi, i_lui,  i_or,    i_ori,  i_xor,  i_xori;
    wire i_sll, i_sllv, i_sra,  i_srav,  i_srl,  i_srlv;
    wire i_beq, i_bne,  i_bgez, i_bgtz,  i_blez, i_bltz;
    wire i_j,   i_jal,  i_jr,   i_jalr;
    wire i_lb,  i_lw,   i_sb,   i_sw;

    //     insn     |           opcode   |           func     |         sa      |         rs     |          rt      |         rd      |
    //
    assign i_add    = opcode == 6'b000000 && func == 6'b100000 && sa == 5'b00000;
    assign i_addi   = opcode == 6'b001000;
    assign i_addu   = opcode == 6'b000000 && func == 6'b100001 && sa == 5'b00000;
    assign i_addiu  = opcode == 6'b001001;
    assign i_sub    = opcode == 6'b000000 && func == 6'b100010 && sa == 5'b00000;
    assign i_slt    = opcode == 6'b000000 && func == 6'b101010 && sa == 5'b00000;
    assign i_sltu   = opcode == 6'b000000 && func == 6'b101011 && sa == 5'b00000;
    assign i_mul    = opcode == 6'b011100 && func == 6'b000010 && sa == 5'b00000;

    assign i_and    = opcode == 6'b000000 && func == 6'b100100 && sa == 5'b00000;
    assign i_andi   = opcode == 6'b001100;
    assign i_lui    = opcode == 6'b001111                                        && rs == 5'b00000;
    assign i_or     = opcode == 6'b000000 && func == 6'b100101 && sa == 5'b00000;
    assign i_ori    = opcode == 6'b001101;
    assign i_xor    = opcode == 6'b000000 && func == 6'b100110 && sa == 5'b00000;
    assign i_xori   = opcode == 6'b001110;

    assign i_sllv   = opcode == 6'b000000 && func == 6'b000100 && sa == 5'b00000;
    assign i_sll    = opcode == 6'b000000 && func == 6'b000000                   && rs == 5'b00000;
    assign i_srav   = opcode == 6'b000000 && func == 6'b000111 && sa == 5'b00000;
    assign i_sra    = opcode == 6'b000000 && func == 6'b000011                   && rs == 5'b00000;
    assign i_srlv   = opcode == 6'b000000 && func == 6'b000110 && sa == 5'b00000;
    assign i_srl    = opcode == 6'b000000 && func == 6'b000010                   && rs == 5'b00000;

    assign i_beq    = opcode == 6'b000100;
    assign i_bne    = opcode == 6'b000101;
    assign i_bgez   = opcode == 6'b000001                                                          && rt == 5'b00001;
    assign i_bgtz   = opcode == 6'b000111                                                          && rt == 5'b00000;
    assign i_blez   = opcode == 6'b000110                                                          && rt == 5'b00000;
    assign i_bltz   = opcode == 6'b000001                                                          && rt == 5'b00000;

    assign i_j      = opcode == 6'b000010;
    assign i_jal    = opcode == 6'b000011;
    assign i_jr     = opcode == 6'b000000 && func == 6'b001000 && sa == 5'b00000                   && rt == 5'b00000 && rd == 5'b00000;
    assign i_jalr   = opcode == 6'b000000 && func == 6'b001001 && sa == 5'b00000                   && rt == 5'b00000;

    assign i_lb     = opcode == 6'b100000;
    assign i_lw     = opcode == 6'b100011;
    assign i_sb     = opcode == 6'b101000;
    assign i_sw     = opcode == 6'b101011;

    //
    wire iform_i_1op;
    wire iform_i_1opn;
    wire iform_i_2opn;
    wire iform_r;
    wire iform_j_n;
    wire iform_j_r31;

    assign iform_i_1op      = i_addi  | i_addiu | i_andi  | i_lui   | i_ori   | i_xori  | i_lb    | i_lw;
    assign iform_i_1opn     = i_bgez  | i_bgtz  | i_blez  | i_bltz;
    assign iform_i_2opn     = i_beq   | i_bne   | i_sb    | i_sw;

    assign iform_r          = i_add   | i_addu  | i_sub   | i_slt   | i_sltu  | i_mul   | i_and   | i_or    | i_xor
                            | i_sllv  | i_sll   | i_srav  | i_sra   | i_srlv  | i_srl   | i_jr    | i_jalr;

    assign iform_j_n        = i_j;
    assign iform_j_r31      = i_jal;

    //
    wire iattr_branch;
    wire iattr_load;
    wire iattr_store;

    assign iattr_branch     = i_beq   | i_bne   | i_bgez  | i_bgtz  | i_blez  | i_bltz
                            | i_j     | i_jal   | i_jr    | i_jalr;
    assign iattr_load       = i_lb    | i_lw;
    assign iattr_store      = i_sb    | i_sw;

    //
    assign lswidth  = i_lb       ? `LSWIDTH_BYTE
                    : i_sb       ? `LSWIDTH_BYTE
                    : i_lw       ? `LSWIDTH_WORD
                    : i_sw       ? `LSWIDTH_WORD
                    :              `LSWIDTH_WORD;

    //
    assign alu_cmd  = i_add      ? `ALU_ADD
                    : i_addi     ? `ALU_ADDI
                    : i_addu     ? `ALU_ADD
                    : i_addiu    ? `ALU_ADDI
                    : i_sub      ? `ALU_SUB
                    : i_slt      ? `ALU_SLT
                    : i_sltu     ? `ALU_SLTU
                    : i_and      ? `ALU_AND
                    : i_andi     ? `ALU_ANDI
                    : i_or       ? `ALU_OR
                    : i_ori      ? `ALU_ORI
                    : i_xor      ? `ALU_XOR
                    : i_xori     ? `ALU_XORI
                    : i_sll      ? `ALU_SLL
                    : i_sllv     ? `ALU_SLLV
                    : i_sra      ? `ALU_SRA
                    : i_srav     ? `ALU_SRAV
                    : i_srl      ? `ALU_SRL
                    : i_srlv     ? `ALU_SRLV
                    : i_lui      ? `ALU_LUI
                    :              `ALU_NOP;

    //
    assign mul_cmd  = i_mul      ? `MUL_EN
                    :              `MUL_NOP;

    //
    assign mem_cmd  = i_lb       ? `MEM_LB
                    : i_lw       ? `MEM_LW
                    : i_sb       ? `MEM_SB
                    : i_sw       ? `MEM_SW
                    :              `MEM_NOP;

    //
    assign bru_cmd  = i_beq      ? `BRU_BRANCH_EQ
                    : i_bne      ? `BRU_BRANCH_NEQ
                    : i_bgez     ? `BRU_BRANCH_GEZ
                    : i_bgtz     ? `BRU_BRANCH_GTZ
                    : i_blez     ? `BRU_BRANCH_LEZ
                    : i_bltz     ? `BRU_BRANCH_LTZ
                    : i_j        ? `BRU_JUMP
                    : i_jal      ? `BRU_JCALL
                    : i_jr       ? `BRU_JUMP
                    : i_jalr     ? `BRU_JCALL
                    :              `BRU_NOP;

    //
    assign bagu_cmd = i_beq     ? `BAGU_RLT
                    : i_bne     ? `BAGU_RLT
                    : i_bgez    ? `BAGU_RLT
                    : i_bgtz    ? `BAGU_RLT
                    : i_blez    ? `BAGU_RLT
                    : i_bltz    ? `BAGU_RLT
                    : i_j       ? `BAGU_IMM
                    : i_jal     ? `BAGU_IMM
                    : i_jr      ? `BAGU_REG
                    : i_jalr    ? `BAGU_REG
                    :             `BAGU_NOP;

    //

    assign pipe_alu = alu_cmd != `ALU_NOP;

    assign pipe_mul = mul_cmd != `MUL_NOP;

    assign pipe_mem = mem_cmd != `MEM_NOP;

    assign pipe_bru = bru_cmd != `BRU_NOP;


    //
    assign src0 = iform_i_1op   ? rs
                : iform_i_1opn  ? rs
                : iform_i_2opn  ? rs
                : iform_r       ? rs
                : iform_j_n     ? 'b0
                : iform_j_r31   ? 'b0
                :                 'b0;

    assign src1 = iform_i_1op   ? 'b0
                : iform_i_1opn  ? 'b0
                : iform_i_2opn  ? rt
                : iform_r       ? rt
                : iform_j_n     ? 'b0
                : iform_j_r31   ? 'b0
                :                 'b0;

    assign dst  = iform_i_1op   ? rt
                : iform_i_1opn  ? 'b0
                : iform_i_2opn  ? 'b0
                : iform_r       ? rd
                : iform_j_n     ? 'b0
                : iform_j_r31   ? 'd31
                :                 'b0;

    assign imm  = iform_i_1op   ? { 10'b0, iimm }
                : iform_i_1opn  ? { 10'b0, iimm }
                : iform_i_2opn  ? { 10'b0, iimm }
                : iform_r       ? { 21'b0, sa   }
                : iform_j_n     ? jindex
                : iform_j_r31   ? jindex
                :                 'b0;


    //
    assign branch   = iattr_branch;
    assign load     = iattr_load;
    assign store    = iattr_store;

    //

endmodule
