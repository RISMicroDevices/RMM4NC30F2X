// @description
//  ** PART OF **
//  RMM4NC3001X - Gemini 3001
//  (MIPS32 Processor for NSCSCC2021)
//
//  Virtual Address to Physical Address Translation and Attribution
//
// @author Kumonda221
//

module misc_vpaddr (
    input   wire[31:0]          vaddr,

    output  wire[31:0]          paddr,
    output  wire                kseg1
);

    wire useg;
    wire seg0, seg1, seg2, seg3;

    assign useg = ~vaddr[31];

    assign seg0 =  vaddr[31] & ~vaddr[30] & ~vaddr[29];
    assign seg1 =  vaddr[31] & ~vaddr[30] &  vaddr[29];
    assign seg2 =  vaddr[31] &  vaddr[30] & ~vaddr[29];
    assign seg3 =  vaddr[31] &  vaddr[30] &  vaddr[29];
    
    //
    assign paddr[28:0]  = vaddr[28:0];
    assign paddr[31:29] = (seg0 | seg1) ? 3'b0 : vaddr[31:29];

    //
    // assign kseg1 = 1'b1;
    assign kseg1 = seg1;

    //

endmodule
