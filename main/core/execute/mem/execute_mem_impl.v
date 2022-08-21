module execute_mem_impl (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            bco_valid,

    //
    input   wire            snoop_hit,

    // LoadBuffer state query
    output  wire [31:0]     s_qaddr,
    input   wire            s_busy,

    // StoreBuffer state
    output  wire            s_o_busy_uncached,

    //
    input   wire            commit_en_store,

    output  wire            commit_readyn,

    //
    input   wire            wbmem_en,

    output  wire            wbmem_valid,
    output  wire [31:0]     wbmem_addr,
    output  wire [3:0]      wbmem_strb,
    output  wire [1:0]      wbmem_lswidth,
    output  wire [31:0]     wbmem_data,
    output  wire            wbmem_uncached,

    //
    input   wire            update_tag_en,
    input   wire [31:0]     update_tag_addr,
    input   wire            update_tag_valid,

    input   wire            update_data_valid,
    input   wire [31:0]     update_data_addr,
    input   wire [3:0]      update_data_strb,
    input   wire [31:0]     update_data,

    output  wire            update_data_ready,

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
    wire        s_byte;
    wire        s_load;
    wire        s_store;

    assign s_byte  = i_mem_cmd[2];
    assign s_load  = i_mem_cmd[1];
    assign s_store = i_mem_cmd[0];


    //
    wire [31:0] agu_v_addr;

    wire [31:0] agu_p_addr;
    wire        agu_p_uncached;

    execute_mem_agu execute_mem_agu_INST (
        //
        .i_src0_value   (i_src0_value),
        .i_src1_value   (i_src1_value),

        .i_imm          (i_imm),

        //
        .v_addr         (agu_v_addr),

        .p_addr         (agu_p_addr),
        .p_uncached     (agu_p_uncached)
    );

    //

    
    //
    wire [31:0] s1dffs_src1_value;

    wire        s1dffs_valid;
    wire [3:0]  s1dffs_dst_rob;

    wire [7:0]  s1dffs_fid;

    wire        s1dffs_s_byte;
    wire        s1dffs_s_load;
    wire        s1dffs_s_store;

    wire [31:0] s1dffs_agu_v_addr;

    wire [31:0] s1dffs_agu_p_addr;
    wire        s1dffs_agu_p_uncached;

    execute_mem_s1dffs execute_mem_s1dffs_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .bco_valid          (bco_valid),

        //
        .i_src1_value       (i_src1_value),

        .i_valid            (i_valid),
        .i_dst_rob          (i_dst_rob),

        .i_fid              (i_fid),

        .i_s_byte           (s_byte),
        .i_s_load           (s_load),
        .i_s_store          (s_store),

        .i_agu_v_addr       (agu_v_addr),

        .i_agu_p_addr       (agu_p_addr),
        .i_agu_p_uncached   (agu_p_uncached),

        //
        .o_src1_value       (s1dffs_src1_value),

        .o_valid            (s1dffs_valid),
        .o_dst_rob          (s1dffs_dst_rob),

        .o_fid              (s1dffs_fid),

        .o_s_byte           (s1dffs_s_byte),
        .o_s_load           (s1dffs_s_load),
        .o_s_store          (s1dffs_s_store),

        .o_agu_v_addr       (s1dffs_agu_v_addr),

        .o_agu_p_addr       (s1dffs_agu_p_addr),
        .o_agu_p_uncached   (s1dffs_agu_p_uncached)    
    );



    //
    wire        dcache_hit;
    wire [31:0] dcache_data;

    wire        dcache_wbmem_hit;

    wire        dcache_store_data_en;
    wire [31:0] dcache_store_data_addr;
    wire [3:0]  dcache_store_data_strb;
    wire [31:0] dcache_store_data;

    execute_mem_dcache execute_mem_dcache_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .update_tag_en      (update_tag_en),
        .update_tag_addr    (update_tag_addr),
        .update_tag_valid   (update_tag_valid),

        .update_data_valid  (update_data_valid),
        .update_data_addr   (update_data_addr),
        .update_data_strb   (update_data_strb),
        .update_data        (update_data),

        .update_data_ready  (update_data_ready),

        //
        .store_data_en      (dcache_store_data_en),
        .store_data_addr    (dcache_store_data_addr),
        .store_data_strb    (dcache_store_data_strb),
        .store_data         (dcache_store_data),

        //
        .q_addr             (s1dffs_agu_p_addr),

        .q_hit              (dcache_hit),
        .q_data             (dcache_data),

        //
        .q1_addr            (wbmem_addr),

        .q1_hit             (dcache_wbmem_hit)
    );


    //
    wire        storebuffer_wen;
    wire [3:0]  storebuffer_wstrb;
    wire [1:0]  storebuffer_wlswidth;
    wire [31:0] storebuffer_wdata;

    wire        storebuffer_cmt_valid;
    wire [31:0] storebuffer_cmt_addr;
    wire [3:0]  storebuffer_cmt_strb;
    wire [1:0]  storebuffer_cmt_lswidth;
    wire [31:0] storebuffer_cmt_data;
    wire        storebuffer_cmt_uncached;

    wire [3:0]  storebuffer_qstrb;
    wire [31:0] storebuffer_qdata;

    wire [3:0]  qdffs_storebuffer_qstrb;
    wire [31:0] qdffs_storebuffer_qdata;

    reg  [3:0]  storebuffer_wstrb_comb;
    reg  [1:0]  storebuffer_wlswidth_comb;
    reg  [31:0] storebuffer_wdata_comb;

    assign storebuffer_wen      = s1dffs_s_store & s1dffs_valid;
    assign storebuffer_wstrb    = storebuffer_wstrb_comb;
    assign storebuffer_wdata    = storebuffer_wdata_comb;
    assign storebuffer_wlswidth = storebuffer_wlswidth_comb;

    always @(*) begin

        storebuffer_wstrb_comb = 4'b1111;
        storebuffer_wdata_comb = s1dffs_src1_value;

        storebuffer_wlswidth_comb = `LSWIDTH_WORD;

        if (s1dffs_s_byte) begin

            storebuffer_wstrb_comb                         = 4'b0;
            storebuffer_wstrb_comb[s1dffs_agu_p_addr[1:0]] = 1'b1;

            storebuffer_wlswidth_comb = `LSWIDTH_BYTE;

            storebuffer_wdata_comb = { s1dffs_src1_value[7:0],
                                       s1dffs_src1_value[7:0],
                                       s1dffs_src1_value[7:0],
                                       s1dffs_src1_value[7:0] };
        end
    end
    
    execute_mem_storebuffer execute_mem_storebuffer_INST (
        .clk            (clk),
        .resetn         (resetn),

        //
        .snoop_hit      (snoop_hit),

        .bco_valid      (bco_valid),

        //
        .enb            (storebuffer_wen),
        .web            (storebuffer_wstrb),
        .dinb_lswidth   (storebuffer_wlswidth),
        .dinb_addr      (s1dffs_agu_p_addr),
        .dinb_data      (storebuffer_wdata),
        .dinb_uncached  (s1dffs_agu_p_uncached),

        //
        .wec            (commit_en_store),

        .doutc_valid    (storebuffer_cmt_valid),
        .doutc_addr     (storebuffer_cmt_addr),
        .doutc_strb     (storebuffer_cmt_strb),
        .doutc_lswidth  (storebuffer_cmt_lswidth),
        .doutc_data     (storebuffer_cmt_data),
        .doutc_uncached (storebuffer_cmt_uncached),

        //
        .qin_addr       (s1dffs_agu_p_addr),

        .qout_strb      (storebuffer_qstrb),
        .qout_data      (storebuffer_qdata)
    );

    execute_mem_qdffs execute_mem_qdffs_storebuffer_INST (
        .clk            (clk),
        .resetn         (resetn),

        .i_strb         (storebuffer_qstrb),
        .i_data         (storebuffer_qdata),

        .o_strb         (qdffs_storebuffer_qstrb),
        .o_data         (qdffs_storebuffer_qdata)
    );

    //
    wire [3:0]  postcmtbuffer_qstrb;
    wire [31:0] postcmtbuffer_qdata;

    wire [3:0]  qdffs_postcmtbuffer_qstrb;
    wire [31:0] qdffs_postcmtbuffer_qdata;

    execute_mem_postcmtbuffer execute_mem_postcmtbuffer_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .s_qaddr            (s_qaddr),
        .s_busy             (s_busy),

        .s_o_busy_uncached  (s_o_busy_uncached),

        //
        .web                (storebuffer_cmt_valid & commit_en_store),
        .dinb_addr          (storebuffer_cmt_addr),
        .dinb_strb          (storebuffer_cmt_strb),
        .dinb_lswidth       (storebuffer_cmt_lswidth),
        .dinb_data          (storebuffer_cmt_data),
        .dinb_uncached      (storebuffer_cmt_uncached),

        //
        .wec                (wbmem_en),

        .doutc_valid        (wbmem_valid),
        .doutc_addr         (wbmem_addr),
        .doutc_strb         (wbmem_strb),
        .doutc_lswidth      (wbmem_lswidth),
        .doutc_data         (wbmem_data),
        .doutc_uncached     (wbmem_uncached),

        .dinc_hit           (dcache_wbmem_hit),

        //
        .store_data_en      (dcache_store_data_en),
        .store_data_addr    (dcache_store_data_addr),
        .store_data_strb    (dcache_store_data_strb),
        .store_data         (dcache_store_data),

        //
        .qin_addr           (s1dffs_agu_p_addr),

        .qout_strb          (postcmtbuffer_qstrb),
        .qout_data          (postcmtbuffer_qdata),

        //
        .readyn             (commit_readyn)
    );

    execute_mem_qdffs execute_mem_qdffs_postcmtbuffer_INST (
        .clk            (clk),
        .resetn         (resetn),

        .i_strb         (postcmtbuffer_qstrb),
        .i_data         (postcmtbuffer_qdata),

        .o_strb         (qdffs_postcmtbuffer_qstrb),
        .o_data         (qdffs_postcmtbuffer_qdata)
    );


    //
    wire        s2dffs_valid;
    wire [3:0]  s2dffs_dst_rob;
    wire [7:0]  s2dffs_fid;

    wire        s2dffs_s_byte;
    wire        s2dffs_s_load;
    wire        s2dffs_s_store;

    wire [31:0] s2dffs_agu_v_addr;

    wire [31:0] s2dffs_agu_p_addr;
    wire        s2dffs_agu_p_uncached;

    execute_mem_s2dffs execute_mem_s2dffs_INST (
        .clk                (clk),
        .resetn             (resetn),

        //
        .i_valid            (s1dffs_valid),
        .i_dst_rob          (s1dffs_dst_rob),
        .i_fid              (s1dffs_fid),

        .i_s_byte           (s1dffs_s_byte),
        .i_s_load           (s1dffs_s_load),
        .i_s_store          (s1dffs_s_store),

        .i_agu_v_addr       (s1dffs_agu_v_addr),

        .i_agu_p_addr       (s1dffs_agu_p_addr),
        .i_agu_p_uncached   (s1dffs_agu_p_uncached),

        //
        .o_valid            (s2dffs_valid),
        .o_dst_rob          (s2dffs_dst_rob),
        .o_fid              (s2dffs_fid),

        .o_s_byte           (s2dffs_s_byte),
        .o_s_load           (s2dffs_s_load),
        .o_s_store          (s2dffs_s_store),

        .o_agu_v_addr       (s2dffs_agu_v_addr),

        .o_agu_p_addr       (s2dffs_agu_p_addr),
        .o_agu_p_uncached   (s2dffs_agu_p_uncached)
    );


    //
    wire        dmux_valid;
    wire [31:0] dmux_data;

    execute_mem_dmux execute_mem_dmux_INST (
        //
        .s_byte             (s2dffs_s_byte),
        .s_addr             (s2dffs_agu_p_addr[1:0]),
        .s_uncached         (s2dffs_agu_p_uncached),

        //
        .dcache_hit         (dcache_hit),
        .dcache_data        (dcache_data),

        //
        .storebuffer_qstrb  (qdffs_storebuffer_qstrb),
        .storebuffer_qdata  (qdffs_storebuffer_qdata),

        //
        .postcmtbuffer_qstrb(qdffs_postcmtbuffer_qstrb),
        .postcmtbuffer_qdata(qdffs_postcmtbuffer_qdata),

        //
        .o_valid            (dmux_valid),
        .o_data             (dmux_data)
    );

    //
    assign o_valid   = s2dffs_valid;
    assign o_dst_rob = s2dffs_valid ? s2dffs_dst_rob : 'b0;
    assign o_fid     = s2dffs_valid ? s2dffs_fid     : 'b0;

    assign o_result  = s2dffs_valid ? (~dmux_valid ? s2dffs_agu_v_addr : dmux_data) : 'b0;
    assign o_lsmiss  = s2dffs_valid ? (~dmux_valid & s2dffs_s_load) : 'b0;

    assign o_cmtdelay   = 'b0;

    //

endmodule
