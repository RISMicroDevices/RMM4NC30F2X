`default_nettype none

module thinpad_top (
    input   wire            clk_50M,            // 50MHz 时钟输入

    input   wire            reset_btn,          // BTN6手动复位按钮开关，带消抖电路，按下时为1

    // BaseRAM信号
    inout   wire [31:0]     base_ram_data,      // BaseRAM数据，低8位与CPLD串口控制器共享
    output  wire [19:0]     base_ram_addr,      // BaseRAM地址
    output  wire [3:0]      base_ram_be_n,      // BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  wire            base_ram_ce_n,      // BaseRAM片选，低有效
    output  wire            base_ram_oe_n,      // BaseRAM读使能，低有效
    output  wire            base_ram_we_n,      // BaseRAM写使能，低有效

    // ExtRAM信号
    inout   wire [31:0]     ext_ram_data,       // ExtRAM数据
    output  wire [19:0]     ext_ram_addr,       // ExtRAM地址
    output  wire [3:0]      ext_ram_be_n,       // ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output  wire            ext_ram_ce_n,       // ExtRAM片选，低有效
    output  wire            ext_ram_oe_n,       // ExtRAM读使能，低有效
    output  wire            ext_ram_we_n,       // ExtRAM写使能，低有效

    // 直连串口信号
    output  wire            txd,                // 直连串口发送端
    input   wire            rxd                 // 直连串口接收端
);

    soc soc_INST (
        .clk_50M        (clk_50M),
        .ext_reset      (reset_btn),
        
        //
        .base_ram_data  (base_ram_data),
        .base_ram_addr  (base_ram_addr),
        .base_ram_be_n  (base_ram_be_n),
        .base_ram_ce_n  (base_ram_ce_n),
        .base_ram_oe_n  (base_ram_oe_n),
        .base_ram_we_n  (base_ram_we_n),

        //
        .ext_ram_data   (ext_ram_data),
        .ext_ram_addr   (ext_ram_addr),
        .ext_ram_be_n   (ext_ram_be_n),
        .ext_ram_ce_n   (ext_ram_ce_n),
        .ext_ram_oe_n   (ext_ram_oe_n),
        .ext_ram_we_n   (ext_ram_we_n),

        //
        .txd            (txd),
        .rxd            (rxd)
    );

endmodule
