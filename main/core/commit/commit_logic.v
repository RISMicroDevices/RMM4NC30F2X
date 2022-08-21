module commit_logic (
    input   wire            clk,
    input   wire            resetn,

    // Post-commit Snoop Filter
    output  wire [31:0]     o_snooptable_qaddr,

    input   wire            i_snooptable_qhit,

    //
    output  wire            o_snoop_hit,

    // StoreBuffer state
    input   wire            s_busy_uncached_store,

    //
    input   wire            i_valid,
    input   wire            i_ready,
    input   wire [31:0]     i_pc,
    input   wire [3:0]      i_rob,
    input   wire [4:0]      i_dst,
    input   wire [31:0]     i_value,
    input   wire [7:0]      i_fid,
    input   wire            i_load,
    input   wire            i_store,
    input   wire [1:0]      i_lswidth,
    input   wire            i_lsmiss,
    input   wire [3:0]      i_cmtdelay,

    input   wire            i_bco_valid,
    input   wire [1:0]      i_bco_pattern,
    input   wire            i_bco_taken,
    input   wire [31:0]     i_bco_target,

    //
    output  wire            o_en,
    output  wire            o_store,
    output  wire [7:0]      o_fid,
    output  wire [4:0]      o_dst,
    output  wire [31:0]     o_result,

    output  wire            o_bco_valid,
    output  wire [31:0]     o_bco_pc,
    output  wire [1:0]      o_bco_pattern,
    output  wire            o_bco_taken,
    output  wire [31:0]     o_bco_target,

    //
    output  wire            o_nowb_en,
    output  wire [3:0]      o_nowb_dst_rob,
    output  wire [31:0]     o_nowb_value,

    //
    output  wire [31:0]     o_loadbuffer_qaddr,

    input   wire            i_loadbuffer_qhit,
    input   wire [31:0]     i_loadbuffer_qdata,

    //
    output  wire            o_rdctrl_en,
    output  wire [7:0]      o_rdctrl_fid,
    output  wire [31:0]     o_rdctrl_addr,
    output  wire            o_rdctrl_uncached,
    output  wire [1:0]      o_rdctrl_lswidth,

    //
    output  wire            o_mem_store_en,

    input   wire            i_mem_readyn
);

    
    // Normal instructions commit logic
    wire        normal_en;
    wire        normal_store;
    wire [7:0]  normal_fid;
    wire [4:0]  normal_dst;
    wire [31:0] normal_result;

    assign normal_en        = i_valid ? (i_ready && i_cmtdelay == 0 && ~o_bco_valid && ~i_snooptable_qhit) : 1'b0;
    assign normal_store     = 1'b0;
    assign normal_fid       = i_fid;
    assign normal_dst       = i_dst;
    assign normal_result    = i_value;

    // BCO commit logic
    reg         bco_valid_R;
    reg  [31:0] bco_pc_R;
    reg  [1:0]  bco_pattern_R;
    reg         bco_taken_R;
    reg  [31:0] bco_target_R;

    wire        cmt_bco_valid;
    wire [31:0] cmt_bco_pc;
    wire [1:0]  cmt_bco_pattern;
    wire        cmt_bco_taken;
    wire [31:0] cmt_bco_target;

    always @(posedge clk) begin
        
        if (~resetn) begin
            bco_valid_R <= 1'b0;
        end
        else if (o_en) begin
            
            if (i_bco_valid) begin
                bco_valid_R <= 1'b1;
            end
            else begin
                bco_valid_R <= 1'b0;
            end
        end

        if (o_en && i_bco_valid) begin

            bco_pc_R        <= i_pc;
            bco_pattern_R   <= i_bco_pattern;
            bco_taken_R     <= i_bco_taken;
            bco_target_R    <= i_bco_target;
        end
    end

    assign cmt_bco_valid      = bco_valid_R && o_en; // Branch Commit Override on delayslot commit
    assign cmt_bco_pc         = bco_pc_R;
    assign cmt_bco_pattern    = bco_pattern_R;
    assign cmt_bco_taken      = bco_taken_R;
    assign cmt_bco_target     = bco_target_R;

    // BCO output stage
    reg         bco_valid_OR;
    reg [31:0]  bco_pc_OR;
    reg [1:0]   bco_pattern_OR;
    reg         bco_taken_OR;
    reg [31:0]  bco_target_OR;

    always @(posedge clk) begin

        if (~resetn) begin
            bco_valid_OR <= 1'b0;
        end
        else begin
            bco_valid_OR <= cmt_bco_valid;
        end

        bco_pc_OR       <= cmt_bco_pc;
        bco_pattern_OR  <= cmt_bco_pattern;
        bco_taken_OR    <= cmt_bco_taken;
        bco_target_OR   <= cmt_bco_target;
    end

    assign o_bco_valid      = bco_valid_OR;
    assign o_bco_pc         = bco_pc_OR;
    assign o_bco_pattern    = bco_pattern_OR;
    assign o_bco_taken      = bco_taken_OR;
    assign o_bco_target     = bco_target_OR;


    // Store instructions commit logic
    wire        storei_en;
    wire        storei_store;
    wire [7:0]  storei_fid;
    wire [4:0]  storei_dst;
    wire [31:0] storei_result;

    assign storei_en        = i_valid ? (normal_en && i_store && ~i_mem_readyn) : 1'b0;
    assign storei_store     = 1'b1;
    assign storei_fid       = i_fid;
    assign storei_dst       = i_dst;
    assign storei_result    = i_value;

    //
    assign o_mem_store_en   = storei_en;


    // Load instructions commit logic
    wire        loadi_en;
    wire        loadi_store;
    wire [7:0]  loadi_fid;
    wire [4:0]  loadi_dst;
    wire [31:0] loadi_result;

    wire [31:0] loadi_paddr;
    wire        loadi_uncached;

    assign loadi_en         = i_valid ? (normal_en && i_load && (~i_lsmiss | i_loadbuffer_qhit)) : 1'b0;
    assign loadi_store      = 1'b0;
    assign loadi_fid        = i_fid;
    assign loadi_dst        = i_dst;

    assign loadi_result     = i_lsmiss ? (
        i_lswidth == `LSWIDTH_BYTE  ? i_loadbuffer_qdata[i_value[1:0] * 8 +: 8]
                                    : i_loadbuffer_qdata
    ) : i_value;

    //
    misc_vpaddr misc_vpaddr_INST (
        .vaddr  (i_value),

        .paddr  (loadi_paddr),
        .kseg1  (loadi_uncached)
    );

    //assign loadi_uncached = 1'b1;

    assign o_rdctrl_en          = i_valid ? (normal_en && i_load && i_lsmiss && (~loadi_uncached || ~s_busy_uncached_store)) : 1'b0;
    assign o_rdctrl_fid         = loadi_fid;
    assign o_rdctrl_addr        = loadi_paddr;
    assign o_rdctrl_uncached    = loadi_uncached;
    assign o_rdctrl_lswidth     = i_lswidth;

    assign o_loadbuffer_qaddr   = loadi_paddr;

    //
    reg         nowb_en_OR;
    reg [3:0]   nowb_dst_rob_OR;
    reg [31:0]  nowb_value_OR;

    always @(posedge clk) begin

        if (~resetn) begin
            nowb_en_OR <= 'b0;
        end
        else begin
            nowb_en_OR <= i_valid ? (loadi_en && i_lsmiss) : 1'b0;
        end

        nowb_dst_rob_OR <= i_rob;
        nowb_value_OR   <= loadi_result;
    end


    //
    assign o_en     = i_load    ? loadi_en
                    : i_store   ? storei_en
                    :             normal_en;

    assign o_store  = i_load    ? loadi_store
                    : i_store   ? storei_store
                    :             normal_store;

    assign o_fid    = i_load    ? loadi_fid
                    : i_store   ? storei_fid
                    :             normal_fid;

    assign o_dst    = i_load    ? loadi_dst
                    : i_store   ? storei_dst
                    :             normal_dst;

    assign o_result = i_load    ? loadi_result
                    : i_store   ? storei_result
                    :             normal_result;

    //
    assign o_nowb_en        = nowb_en_OR;
    assign o_nowb_dst_rob   = nowb_dst_rob_OR;
    assign o_nowb_value     = nowb_value_OR;

    //
    assign o_snooptable_qaddr = i_pc;
    
    assign o_snoop_hit        = i_snooptable_qhit;

    //


endmodule
