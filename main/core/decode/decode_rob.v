`define         ENABLE_EXTRA_COMMIT_STAGE

module decode_rob (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    // ROB value read - src0
    input   wire [3:0]      addra,
    output  wire [31:0]     douta,
    output  wire            douta_ready,

    // ROB value read - src1
    input   wire [3:0]      addrb,
    output  wire [31:0]     doutb,
    output  wire            doutb_ready,

    // ROB allocate
    input   wire            en_alloc,

    input   wire [31:0]     dinc_pc,
    input   wire [4:0]      dinc_dst,
    input   wire [7:0]      dinc_fid,
    input   wire            dinc_load,
    input   wire            dinc_store,
    input   wire [1:0]      dinc_lswidth,

    // ROB writeback
    input   wire            en_writeback,

    input   wire [3:0]      addrd,
    input   wire [7:0]      dind_fid,
    input   wire [31:0]     dind_value,
    input   wire            dind_lsmiss,
    input   wire [3:0]      dind_cmtdelay,

    input   wire            dind_bco_valid,
    input   wire [1:0]      dind_bco_pattern,
    input   wire            dind_bco_taken,
    input   wire [31:0]     dind_bco_target,

    // ROB commit logic interface
    input   wire            en_commit,

    output  wire            doute_valid,
    output  wire            doute_ready,
    output  wire [31:0]     doute_pc,
    output  wire [3:0]      doute_rob,
    output  wire [4:0]      doute_dst,
    output  wire [31:0]     doute_value,
    output  wire [7:0]      doute_fid,
    output  wire            doute_load,
    output  wire            doute_store,
    output  wire            doute_lsmiss,
    output  wire [1:0]      doute_lswidth,
    output  wire [3:0]      doute_cmtdelay,

    output  wire            doute_bco_valid,
    output  wire [1:0]      doute_bco_pattern,
    output  wire            doute_bco_taken,
    output  wire [31:0]     doute_bco_target,

    //
    output  wire [4:0]      next_rob,

    //
    input   wire            bco_valid
);

    //
    integer i;
    genvar  j;


    //
    reg [4:0]   wptr_R;
    reg [4:0]   rptr_R;
    reg [4:0]   cptr_R;

    reg [4:0]   wptr_next;
    reg [4:0]   rptr_next;
    reg [4:0]   cptr_next;

    wire ptr_overlap;
    wire ptr_toured;

    wire cptr_overlap;
    wire cptr_toured;

    wire s_c_commitable;

//  wire s_full;        // *NOTICE: ROB full situation is preprocessed in rob_alloc stage
    wire s_empty;
    wire s_cempty;

    assign ptr_overlap  = wptr_R[3:0] == rptr_R[3:0];
    assign ptr_toured   = wptr_R[4]   != rptr_R[4];

    assign cptr_overlap = wptr_R[3:0] == cptr_R[3:0];
    assign cptr_toured  = wptr_R[4]   != cptr_R[4];

    assign s_empty  =  ptr_overlap & ~ ptr_toured;
    assign s_cempty = cptr_overlap & ~cptr_toured;

    always @(posedge clk) begin

        if (~resetn) begin

            wptr_R <= 'b0;
            rptr_R <= 'b0;
            cptr_R <= 'b0;
        end
        else if (snoop_hit) begin

            wptr_R <= 'b0;
            rptr_R <= 'b0;
            cptr_R <= 'b0;
        end
        else begin

            wptr_R <= wptr_next;
            rptr_R <= rptr_next;
            cptr_R <= cptr_next;
        end
    end

    always @(*) begin

        wptr_next = wptr_R;
        rptr_next = rptr_R;
        cptr_next = cptr_R;

`ifdef ENABLE_EXTRA_COMMIT_STAGE

        if ((~doute_valid || en_commit) && ~s_cempty) begin

            if (s_c_commitable) begin
                cptr_next = cptr_R + 'd1;
            end
        end
`endif

        if (en_commit && ~s_empty) begin
            rptr_next = rptr_R + 'd1;
        end

        if (bco_valid) begin

            wptr_next = 'b0;
            rptr_next = 'b0;
            cptr_next = 'b0;
        end
        else if (en_alloc) begin
            wptr_next = wptr_R + 'd1;
        end
    end

    //
    reg         rob_ready_R         [15:0];
    reg [31:0]  rob_pc_R            [15:0];
    reg [4:0]   rob_dst_R           [15:0];
    reg [31:0]  rob_value_R         [15:0];
    reg [7:0]   rob_fid_R           [15:0];

    reg         rob_load_R          [15:0];
    reg         rob_store_R         [15:0];
    reg         rob_lsmiss_R        [15:0];
    reg [1:0]   rob_lswidth_R       [15:0];
    reg [3:0]   rob_cmtdelay_R      [15:0];

    reg         rob_bco_valid_R     [15:0];
    reg [1:0]   rob_bco_pattern_R   [15:0];
    reg         rob_bco_taken_R     [15:0];
    reg [31:0]  rob_bco_target_R    [15:0];

    generate
        for (j = 0; j < 16; j = j + 1) begin : GENERATED_ROB_ENTRY_READY

            always @(posedge clk) begin
                
                if (~resetn) begin
                    rob_ready_R  [j] <= 'b0;
                end
                else if ((wptr_R[3:0] == j) && en_alloc) begin    // allocate
                    rob_ready_R  [j] <= 'b0;
                end
                else if ((addrd == j) && en_writeback && (rob_fid_R[j] == dind_fid)) begin     // writeback
                    rob_ready_R  [j] <= 'b1;
                end
            end
        end
    endgenerate

    always @(posedge clk) begin

        if (en_alloc) begin

            rob_pc_R     [wptr_R[3:0]] <= dinc_pc;
            rob_dst_R    [wptr_R[3:0]] <= dinc_dst;
            rob_fid_R    [wptr_R[3:0]] <= dinc_fid;
            rob_load_R   [wptr_R[3:0]] <= dinc_load;
            rob_store_R  [wptr_R[3:0]] <= dinc_store;
            rob_lswidth_R[wptr_R[3:0]] <= dinc_lswidth;
        end
    end

    //
    wire    fid_hit;

    assign fid_hit = rob_fid_R[addrd] == dind_fid;

    always @(posedge clk) begin

        if (en_writeback && fid_hit) begin
            
            rob_value_R     [addrd] <= dind_value;
            rob_lsmiss_R    [addrd] <= dind_lsmiss;
        end
    end

    always @(posedge clk) begin

        if (en_writeback && fid_hit) begin
            
            rob_bco_valid_R   [addrd] <= dind_bco_valid;
            rob_bco_pattern_R [addrd] <= dind_bco_pattern;
            rob_bco_taken_R   [addrd] <= dind_bco_taken;
            rob_bco_target_R  [addrd] <= dind_bco_target;
        end
    end

    always @(posedge clk) begin

        for (i = 0; i < 16; i = i + 1) begin

            if (en_writeback && addrd == i && fid_hit) begin
                rob_cmtdelay_R[i] <= dind_cmtdelay;
            end
            else if (rob_cmtdelay_R[i] != 'b0) begin
                rob_cmtdelay_R[i] <= rob_cmtdelay_R[i] - 'd1;
            end
        end
    end

    // ROB commit logic interface output stage
`ifdef ENABLE_EXTRA_COMMIT_STAGE

    //
    assign s_c_commitable = s_cempty ? 1'b0 
                          : (rob_ready_R[cptr_R[3:0]] && rob_cmtdelay_R[cptr_R[3:0]] == 'b0);

    //
    reg         valid_OR;
    reg         ready_OR;
    reg [31:0]  pc_OR;
    reg [3:0]   rob_OR;
    reg [4:0]   dst_OR;
    reg [31:0]  value_OR;
    reg [7:0]   fid_OR;
    reg         load_OR;
    reg         store_OR;
    reg         lsmiss_OR;
    reg [1:0]   lswidth_OR;
    reg [3:0]   cmtdelay_OR;

    reg         bco_valid_OR;
    reg [1:0]   bco_pattern_OR;
    reg         bco_taken_OR;
    reg [31:0]  bco_target_OR;

    always @(posedge clk) begin

        if (~resetn) begin
            valid_OR <= 1'b0;
        end
        else if (bco_valid) begin
            valid_OR <= 1'b0;
        end
        else if (~valid_OR || en_commit) begin
            valid_OR <= s_c_commitable;
        end
    end

    always @(posedge clk) begin

        if ((~valid_OR || en_commit) && s_c_commitable) begin

            ready_OR        <= rob_ready_R      [cptr_R[3:0]];
            pc_OR           <= rob_pc_R         [cptr_R[3:0]];
            rob_OR          <=                   cptr_R[3:0];
            dst_OR          <= rob_dst_R        [cptr_R[3:0]];
            value_OR        <= rob_value_R      [cptr_R[3:0]];
            fid_OR          <= rob_fid_R        [cptr_R[3:0]];
            load_OR         <= rob_load_R       [cptr_R[3:0]];
            store_OR        <= rob_store_R      [cptr_R[3:0]];
            lsmiss_OR       <= rob_lsmiss_R     [cptr_R[3:0]];
            lswidth_OR      <= rob_lswidth_R    [cptr_R[3:0]];
            cmtdelay_OR     <= rob_cmtdelay_R   [cptr_R[3:0]];

            bco_valid_OR    <= rob_bco_valid_R  [cptr_R[3:0]];
            bco_pattern_OR  <= rob_bco_pattern_R[cptr_R[3:0]];
            bco_taken_OR    <= rob_bco_taken_R  [cptr_R[3:0]];
            bco_target_OR   <= rob_bco_target_R [cptr_R[3:0]];
        end
    end

    assign doute_valid          = valid_OR;
    assign doute_ready          = ready_OR;
    assign doute_pc             = pc_OR;
    assign doute_rob            = rob_OR;
    assign doute_dst            = dst_OR;
    assign doute_value          = value_OR;
    assign doute_fid            = fid_OR;
    assign doute_load           = load_OR;
    assign doute_store          = store_OR;
    assign doute_lsmiss         = lsmiss_OR;
    assign doute_lswidth        = lswidth_OR;
    assign doute_cmtdelay       = cmtdelay_OR;

    assign doute_bco_valid      = bco_valid_OR;
    assign doute_bco_pattern    = bco_pattern_OR;
    assign doute_bco_taken      = bco_taken_OR;
    assign doute_bco_target     = bco_target_OR;

`else
    assign doute_valid          = ~s_empty;
    assign doute_ready          = rob_ready_R       [rptr_R[3:0]];
    assign doute_pc             = rob_pc_R          [rptr_R[3:0]];
    assign doute_rob            =                    rptr_R[3:0];
    assign doute_dst            = rob_dst_R         [rptr_R[3:0]];
    assign doute_value          = rob_value_R       [rptr_R[3:0]];
    assign doute_fid            = rob_fid_R         [rptr_R[3:0]];
    assign doute_load           = rob_load_R        [rptr_R[3:0]];
    assign doute_store          = rob_store_R       [rptr_R[3:0]];
    assign doute_lswidth        = rob_lswidth_R     [rptr_R[3:0]];
    assign doute_lsmiss         = rob_lsmiss_R      [rptr_R[3:0]];
    assign doute_cmtdelay       = rob_cmtdelay_R    [rptr_R[3:0]];

    assign doute_bco_valid      = rob_bco_valid_R   [rptr_R[3:0]];
    assign doute_bco_pattern    = rob_bco_pattern_R [rptr_R[3:0]];
    assign doute_bco_taken      = rob_bco_taken_R   [rptr_R[3:0]];
    assign doute_bco_target     = rob_bco_target_R  [rptr_R[3:0]];
`endif

    // ROB read value logic
    assign douta = rob_value_R[addra];
    assign doutb = rob_value_R[addrb];

    assign douta_ready  = rob_ready_R[addra] ? ~rob_lsmiss_R[addra] : 1'b0;
    assign doutb_ready  = rob_ready_R[addrb] ? ~rob_lsmiss_R[addrb] : 1'b0;

    //
    assign next_rob = wptr_R;

    //

endmodule
