// @description
//  ** PART OF **
//  RMM4NC3001X - Gemini 3001
//  (MIPS32 Processor for NSCSCC2021)
//
//  Definitions of IALU commands
//
// @author Kumonda221
//

`define     ALU_NOP                    5'h00

`define     ALU_ADD                    5'h01
`define     ALU_ADDI                   5'h11

`define     ALU_SUB                    5'h02
`define     ALU_SUBI                   5'h12

`define     ALU_AND                    5'h03
`define     ALU_ANDI                   5'h13
`define     ALU_OR                     5'h04
`define     ALU_ORI                    5'h14
`define     ALU_XOR                    5'h05
`define     ALU_XORI                   5'h15

`define     ALU_SLT                    5'h06
`define     ALU_SLTU                   5'h0B

`define     ALU_SLL                    5'h07
`define     ALU_SLLV                   5'h17
`define     ALU_SRL                    5'h08
`define     ALU_SRLV                   5'h18
`define     ALU_SRA                    5'h09
`define     ALU_SRAV                   5'h19

`define     ALU_LUI                    5'h0A
