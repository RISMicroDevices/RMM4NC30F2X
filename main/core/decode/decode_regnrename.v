
module decode_regnrename (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    // Instruction register rename & allocation
    input   wire            en,

    input   wire [7:0]      i_fid,
    input   wire [3:0]      i_rob,

    input   wire [4:0]      i_src0,
    input   wire [4:0]      i_src1,
    input   wire [4:0]      i_dst,

    output  wire [3:0]      o_src0_rob,
    output  wire            o_src0_ready,
    output  wire [31:0]     o_src0_value,

    output  wire [3:0]      o_src1_rob,
    output  wire            o_src1_ready,
    output  wire [31:0]     o_src1_value,

    // ROB read - src0
    output  wire [3:0]      rob_addra,
    input   wire [31:0]     rob_dina,
    input   wire            rob_dina_ready,

    // ROB read - src1
    output  wire [3:0]      rob_addrb,
    input   wire [31:0]     rob_dinb,
    input   wire            rob_dinb_ready,

    // ROB commit
    input   wire            rob_cm_en,
    input   wire [4:0]      rob_cm_addr,
    input   wire [7:0]      rob_cm_fid,
    input   wire [31:0]     rob_cm_data,

    // 
    input   wire            bco_valid
);

    //
    wire [31:0] regfs_data0;
    wire [31:0] regfs_data1;

    decode_regfiles decode_regfiles_INST (
        .clk    (clk),
        .resetn (resetn),
        
        .raddr0 (i_src0),
        .raddr1 (i_src1),

        .rdata0 (regfs_data0),
        .rdata1 (regfs_data1),

        .wen    (rob_cm_en),
        .waddr  (rob_cm_addr),
        .wdata  (rob_cm_data)
    );

    //
    wire        rat_src0_valid;
    wire [3:0]  rat_src0_rob;

    wire        rat_src1_valid;
    wire [3:0]  rat_src1_rob;

    decode_rat decode_rat_INST (
        .clk            (clk),
        .resetn         (resetn),
        
        .snoop_hit      (snoop_hit),

        .addra          (i_src0),
        .douta_valid    (rat_src0_valid),
        .douta_rob      (rat_src0_rob),

        .addrb          (i_src1),
        .doutb_valid    (rat_src1_valid),
        .doutb_rob      (rat_src1_rob),

        .wec            (en),
        .addrc          (i_dst),
        .dinc_fid       (i_fid),
        .dinc_rob       (i_rob[3:0]),

        .wee            (rob_cm_en),
        .addre          (rob_cm_addr),
        .dine_fid       (rob_cm_fid),

        .bco_valid      (bco_valid)
    );

    //
    wire [31:0] rdffs_regfs_data0;
    wire [31:0] rdffs_regfs_data1;

    wire        rdffs_rat_src0_valid;
    wire [3:0]  rdffs_rat_src0_rob;

    wire        rdffs_rat_src1_valid;
    wire [3:0]  rdffs_rat_src1_rob;

    decode_rdffs decode_rdffs_INST (
        .clk                (clk),
        .resetn             (resetn),

        .snoop_hit          (snoop_hit),

        .bco_valid          (bco_valid),

        //
        .i_regfs_data0      (regfs_data0),
        .i_regfs_data1      (regfs_data1),

        .i_rat_src0_valid   (rat_src0_valid),
        .i_rat_src0_rob     (rat_src0_rob),

        .i_rat_src1_valid   (rat_src1_valid),
        .i_rat_src1_rob     (rat_src1_rob),

        //
        .o_regfs_data0      (rdffs_regfs_data0),
        .o_regfs_data1      (rdffs_regfs_data1),
        
        .o_rat_src0_valid   (rdffs_rat_src0_valid),
        .o_rat_src0_rob     (rdffs_rat_src0_rob),

        .o_rat_src1_valid   (rdffs_rat_src1_valid),
        .o_rat_src1_rob     (rdffs_rat_src1_rob)
    );

    //
    assign rob_addra = rdffs_rat_src0_rob;
    assign rob_addrb = rdffs_rat_src1_rob;

    //
    assign o_src0_rob   = rdffs_rat_src0_rob;
    assign o_src0_value = rdffs_rat_src0_valid ? rob_dina       : rdffs_regfs_data0;
    assign o_src0_ready = rdffs_rat_src0_valid ? rob_dina_ready : 1'b1;

    assign o_src1_rob   = rdffs_rat_src1_rob;
    assign o_src1_value = rdffs_rat_src1_valid ? rob_dinb       : rdffs_regfs_data1;
    assign o_src1_ready = rdffs_rat_src1_valid ? rob_dinb_ready : 1'b1;

    //

endmodule
 