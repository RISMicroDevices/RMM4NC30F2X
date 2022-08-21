// @description
//  ** PART OF **
//  RMM4NC3001X - Gemini 3001
//  (MIPS32 Processor for NSCSCC2021)
//
//  Definitions of BRU conditions
//
// @author Kumonda221
//

/**
*   BRU Command bits (high-active):       
*      
*       6       5      4     3    2     1    0
*   +--------+------+-----+----+-----+----+-----+
*   | ALWAYS | CALL | GTZ | EZ | LTZ | EQ | NEQ |
*   +--------+------+-----+----+-----+----+-----+
*/

`define     BRU_NOP                        7'h00

`define     BRU_JUMP                       7'h40
`define     BRU_JCALL                      7'h60

`define     BRU_BRANCH_EQ                  7'h02
`define     BRU_BRANCH_NEQ                 7'h01

`define     BRU_BRANCH_GEZ                 7'h18
`define     BRU_BRANCH_GTZ                 7'h10
`define     BRU_BRANCH_LEZ                 7'h0C
`define     BRU_BRANCH_LTZ                 7'h04
