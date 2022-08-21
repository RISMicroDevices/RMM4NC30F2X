
module execute_mem_agu (
    //
    input   wire [31:0]     i_src0_value,
    input   wire [31:0]     i_src1_value,

    input   wire [25:0]     i_imm,

    //
    output  wire [31:0]     v_addr,

    output  wire [31:0]     p_addr,
    output  wire            p_uncached
);

    //
    assign v_addr = i_src0_value + { {(16){ i_imm[15] }}, i_imm[15:0] };

    //
    misc_vpaddr misc_vpaddr_mem_agu_INST (
        .vaddr  (v_addr),

        .paddr  (p_addr),
        .kseg1  (p_uncached)
    );

    //assign p_uncached = 1'b1;

    //


endmodule
