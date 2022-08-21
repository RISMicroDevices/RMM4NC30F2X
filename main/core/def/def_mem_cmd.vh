// @description
//  ** PART OF **
//  RMM4NC3001X - Gemini 3001
//  (MIPS32 Processor for NSCSCC2021)
//
//  Definitions of MEM commands
//
// @author Kumonda221
//

/**
*   MEM command bits (high effective): 
*   
*   **WORD by default**
*
*   +----------+----------+------+------+-------+
*   | reserved | reserved | BYTE | LOAD | STORE |
*   +----------+----------+------+------+-------+
*/

`define     MEM_NOP            5'h00

`define     MEM_LB             5'h06
`define     MEM_LW             5'h02

`define     MEM_SB             5'h05
`define     MEM_SW             5'h01

`define     MEM_BIT_STORE      5'h01
`define     MEM_BIT_LOAD       5'h02
`define     MEM_BIT_LSBYTE     5'h04
