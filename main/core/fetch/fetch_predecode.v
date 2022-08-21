`include "fetch_predecode_def.v"

module fetch_predecode (
    input   wire [31:0]         din,
    output  wire [35:0]         dout
);

    wire [5:0]  opcode;

    wire [4:0]  rs;
    wire [4:0]  rt;
    wire [4:0]  rd;

    wire [4:0]  sa;
    wire [5:0]  func;

    assign opcode = din[31:26];

    assign rs = din[25:21];
    assign rt = din[20:16];
    assign rd = din[15:11];

    assign sa   = din[10:6];
    assign func = din[5:0];

    // Instructions
    wire i_beq, i_bne,  i_bgez, i_bgtz,  i_blez, i_bltz;
    wire i_j,   i_jal,  i_jr,   i_jalr;

    //     insn     |           opcode   |           func     |         sa      |         rs     |          rt      |         rd      |
    //
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


    //
    wire    p_branch;
    wire    p_jump;
    wire    p_jump_link;

    assign p_branch    = i_beq  | i_bne  | i_bgez | i_bgtz | i_blez | i_bltz;
    assign p_jump      = i_j    | i_jr;
    assign p_jump_link = i_jal  | i_jalr;

    //
    wire [3:0]  prefix;

    assign prefix = p_branch    ? `PREDECODED_BRANCH 
                  : p_jump      ? `PREDECODED_JUMP
                  : p_jump_link ? `PREDECODED_JUMP_LINK
                  : `PREDECODED_NORMAL;

    // 
    assign dout = { prefix, din };

    //

endmodule
