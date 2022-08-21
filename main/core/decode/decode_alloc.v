
module decode_alloc (
    input   wire            clk,
    input   wire            resetn,

    // 
    input   wire            snoop_hit,

    // ROB Allocation & Branch Information
    input   wire            en_alloc,
    input   wire            en_alloc_store,
    
    // BCO
    input   wire            bco_valid,

    // ROB Commit
    input   wire            en_commit,
    input   wire            en_commit_store,

    // ROB & Allocation Enable (Decode stage)
    output  wire            next_wen,

    // Stage Ready (Input from Issue, output to Fetch)
    input   wire            i_readyn,
    output  wire            o_readyn
);

    //
    wire    rob_readyn;

    decode_alloc_rob decode_alloc_rob_INST (
        .clk        (clk),
        .resetn     (resetn),

        .snoop_hit  (snoop_hit),

        .en_alloc   (next_wen),

        .en_commit  (en_commit),

        .bco_valid  (bco_valid),

        .readyn     (rob_readyn)
    );

    //
    wire    storebuffer_readyn;

    decode_alloc_storebuffer decode_alloc_storebuffer_INST (
        .clk            (clk),
        .resetn         (resetn),

        .snoop_hit      (snoop_hit),

        .en_alloc       (next_wen),
        .en_alloc_store (en_alloc_store),

        .en_commit      (en_commit),
        .en_commit_store(en_commit_store),

        .bco_valid      (bco_valid),

        .readyn         (storebuffer_readyn)
    );

    //
    wire    s_readyn;

    assign s_readyn = rob_readyn | storebuffer_readyn | i_readyn;

    // *NOTICE: The Decode Stage must still be available for at least 3 cycles after 'readyn' asserted.
    //
    reg     s_readyn_dly1_R;
    reg     s_readyn_dly2_R;
    reg     s_readyn_dly3_R;

    always @(posedge clk) begin

        if (~resetn) begin

            s_readyn_dly1_R <= 'b0;
            s_readyn_dly2_R <= 'b0;
            s_readyn_dly3_R <= 'b0;
        end
        else if (snoop_hit) begin

            s_readyn_dly1_R <= 'b1;
            s_readyn_dly2_R <= 'b1;
            s_readyn_dly3_R <= 'b1;
        end
        else begin

            s_readyn_dly1_R <= s_readyn;
            s_readyn_dly2_R <= s_readyn_dly1_R;
            s_readyn_dly3_R <= s_readyn_dly2_R;
        end
    end

    //
    assign next_wen = en_alloc & ~s_readyn_dly2_R;

    assign o_readyn = s_readyn;

    //

endmodule
