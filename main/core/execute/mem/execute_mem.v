
module execute_mem (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            bco_valid,

    // LoadBuffer state query
    output  wire [31:0]     s_qaddr,
    input   wire            s_busy,

    output  wire            s_o_busy_uncached,

    //
    input   wire            i_commit_en_store,

    output  wire            o_commit_readyn,

    //
    input   wire            i_wbmem_en,

    output  wire            o_wbmem_valid,
    output  wire [31:0]     o_wbmem_addr,
    output  wire [3:0]      o_wbmem_strb,
    output  wire [1:0]      o_wbmem_lswidth,
    output  wire [31:0]     o_wbmem_data,
    output  wire            o_wbmem_uncached,

    //
    input   wire            i_update_tag_en,
    input   wire [31:0]     i_update_tag_addr,
    input   wire            i_update_tag_valid,

    input   wire            i_update_data_valid,
    input   wire [31:0]     i_update_data_addr,
    input   wire [3:0]      i_update_data_strb,
    input   wire [31:0]     i_update_data,

    output  wire            o_update_data_ready,

    //
    input   wire            i_valid,

    input   wire [31:0]     i_src0_value,
    input   wire [31:0]     i_src1_value,

    input   wire [3:0]      i_dst_rob,

    input   wire [25:0]     i_imm,

    input   wire [7:0]      i_fid,

    input   wire [4:0]      i_mem_cmd,

    //
    output  wire            o_valid,
    output  wire [3:0]      o_dst_rob,
    output  wire [7:0]      o_fid,

    output  wire [31:0]     o_result,
    output  wire [3:0]      o_cmtdelay,
    output  wire            o_lsmiss
);

    //
    wire        idffs_valid;

    wire [31:0] idffs_src0_value;
    wire [31:0] idffs_src1_value;

    wire [3:0]  idffs_dst_rob;

    wire [25:0] idffs_imm;

    wire [7:0]  idffs_fid;

    wire [4:0]  idffs_mem_cmd;

    //
    execute_mem_idffs execute_mem_idffs_INST (
        .clk            (clk),
        .resetn         (resetn),

        //
        .bco_valid      (bco_valid),

        //
        .i_valid        (i_valid),

        .i_src0_value   (i_src0_value),
        .i_src1_value   (i_src1_value),

        .i_dst_rob      (i_dst_rob),

        .i_imm          (i_imm),
        
        .i_fid          (i_fid),

        .i_mem_cmd      (i_mem_cmd),

        //
        .o_valid        (idffs_valid),

        .o_src0_value   (idffs_src0_value),
        .o_src1_value   (idffs_src1_value),

        .o_dst_rob      (idffs_dst_rob),

        .o_imm          (idffs_imm),

        .o_fid          (idffs_fid),
        
        .o_mem_cmd      (idffs_mem_cmd)
    );


    //
    wire        impl_valid;
    wire [3:0]  impl_dst_rob;
    wire [7:0]  impl_fid;

    wire [31:0] impl_result;
    wire [3:0]  impl_cmtdelay;
    wire        impl_lsmiss;

    execute_mem_impl execute_mem_impl_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .bco_valid          (bco_valid),

        //
        .s_qaddr            (s_qaddr),
        .s_busy             (s_busy),

        .s_o_busy_uncached  (s_o_busy_uncached),

        //
        .commit_en_store    (i_commit_en_store),

        .commit_readyn      (o_commit_readyn),

        //
        .wbmem_en           (i_wbmem_en),

        .wbmem_valid        (o_wbmem_valid),
        .wbmem_addr         (o_wbmem_addr),
        .wbmem_strb         (o_wbmem_strb),
        .wbmem_lswidth      (o_wbmem_lswidth),
        .wbmem_data         (o_wbmem_data),
        .wbmem_uncached     (o_wbmem_uncached),

        //
        .update_tag_en      (i_update_tag_en),
        .update_tag_addr    (i_update_tag_addr),
        .update_tag_valid   (i_update_tag_valid),

        .update_data_valid  (i_update_data_valid),
        .update_data_addr   (i_update_data_addr),
        .update_data_strb   (i_update_data_strb),
        .update_data        (i_update_data),

        .update_data_ready  (o_update_data_ready),

        //
        .i_valid            (idffs_valid),

        .i_src0_value       (idffs_src0_value),
        .i_src1_value       (idffs_src1_value),

        .i_dst_rob          (idffs_dst_rob),

        .i_imm              (idffs_imm),

        .i_fid              (idffs_fid),

        .i_mem_cmd          (idffs_mem_cmd),

        //
        .o_valid            (impl_valid),
        .o_dst_rob          (impl_dst_rob),
        .o_fid              (impl_fid),

        .o_result           (impl_result),
        .o_cmtdelay         (impl_cmtdelay),
        .o_lsmiss           (impl_lsmiss)
    );

    //
    execute_mem_odffs execute_mem_odffs_INST (
        .clk            (clk),
        .resetn         (resetn),

        //
        .i_valid        (impl_valid),
        .i_dst_rob      (impl_dst_rob),
        .i_fid          (impl_fid),
        
        .i_result       (impl_result),
        .i_cmtdelay     (impl_cmtdelay),
        .i_lsmiss       (impl_lsmiss),

        //
        .o_valid        (o_valid),
        .o_dst_rob      (o_dst_rob),
        .o_fid          (o_fid),

        .o_result       (o_result),
        .o_cmtdelay     (o_cmtdelay),
        .o_lsmiss       (o_lsmiss)
    );

    //

endmodule
