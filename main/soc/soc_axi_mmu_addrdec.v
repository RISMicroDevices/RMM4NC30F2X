
module soc_axi_mmu_addrdec (
    input   wire [31:0]     i_addr,
    input   wire            i_user,

    output  wire            o_sel0,
    output  wire            o_sel1,
    output  wire            o_sel2,
    output  wire            o_sel3,

    output  wire            o_selx
);

    // BaseRAM
    assign o_sel0 = $unsigned(i_addr) >= 32'h00000000 && $unsigned(i_addr) <= 32'h003FFFFF;

    // ExtRAM
    assign o_sel1 = $unsigned(i_addr) >= 32'h00400000 && $unsigned(i_addr) <= 32'h007FFFFF;

    // USART
    assign o_sel2 = i_user && (i_addr == 32'h1FD003F8 || i_addr == 32'h1FD003FC);

    // CoPS devices
    assign o_sel3 = i_user && (i_addr == 32'h1FD004F0 || i_addr == 32'h1FD004F4);

    //
    assign o_selx = ~(o_sel0 | o_sel1 | o_sel2 | o_sel3);

    //

endmodule
