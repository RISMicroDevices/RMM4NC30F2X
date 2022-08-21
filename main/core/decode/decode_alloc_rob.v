
module decode_alloc_rob (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire            en_alloc,

    //
    input   wire            en_commit,

    //
    input   wire            bco_valid,

    //
    output  wire            readyn
);

    // !! Inter-Stage Synchronization Register !!
    reg         en_alloc_R;

    always @(posedge clk) begin
        en_alloc_R  <= en_alloc;
    end


    //
    reg [4:0]   wptr_R, wptr_next;
    reg [4:0]   rptr_R, rptr_next;

    always @(posedge clk) begin

        if (~resetn) begin
            
            wptr_R <= 'b0;
            rptr_R <= 'b0;
        end
        else if (snoop_hit) begin

            wptr_R <= 'b0;
            rptr_R <= 'b0;
        end
        else begin
            
            wptr_R <= wptr_next;
            rptr_R <= rptr_next;
        end
    end

    //
    wire [4:0]  wptr_inc0;
    wire [4:0]  wptr_inc1;
    wire [4:0]  wptr_inc2;
    wire [4:0]  wptr_inc3;
    wire [4:0]  wptr_inc4;

    wire ptr_inc0_overlap, ptr_inc0_toured;
    wire ptr_inc1_overlap, ptr_inc1_toured;
    wire ptr_inc2_overlap, ptr_inc2_toured;
    wire ptr_inc3_overlap, ptr_inc3_toured;
    wire ptr_inc4_overlap, ptr_inc4_toured;

    assign wptr_inc0 = wptr_R;
    assign wptr_inc1 = wptr_R + 'd1;
    assign wptr_inc2 = wptr_R + 'd2;
    assign wptr_inc3 = wptr_R + 'd3;
    assign wptr_inc4 = wptr_R + 'd4;

    assign ptr_inc0_overlap = wptr_inc0[3:0] == rptr_R[3:0];
    assign ptr_inc1_overlap = wptr_inc1[3:0] == rptr_R[3:0];
    assign ptr_inc2_overlap = wptr_inc2[3:0] == rptr_R[3:0];
    assign ptr_inc3_overlap = wptr_inc3[3:0] == rptr_R[3:0];
    assign ptr_inc4_overlap = wptr_inc4[3:0] == rptr_R[3:0];

    assign ptr_inc0_toured = wptr_inc0[4] != rptr_R[4];
    assign ptr_inc1_toured = wptr_inc1[4] != rptr_R[4];
    assign ptr_inc2_toured = wptr_inc2[4] != rptr_R[4];
    assign ptr_inc3_toured = wptr_inc3[4] != rptr_R[4];
    assign ptr_inc4_toured = wptr_inc4[4] != rptr_R[4];

    // *NOTICE: The 'readyn' state signal is asserted when there was only 4 or less slots free.
    //
    wire s_readyn = ( ptr_inc0_overlap &  ptr_inc0_toured)
                  | ( ptr_inc1_overlap &  ptr_inc1_toured)
                  | ( ptr_inc2_overlap &  ptr_inc2_toured)
                  | ( ptr_inc3_overlap &  ptr_inc3_toured)
                  | ( ptr_inc4_overlap &  ptr_inc4_toured);

    wire s_empty  =   ptr_inc0_overlap & ~ptr_inc0_toured;

    //
    always @(*) begin

        wptr_next = wptr_R;
        rptr_next = rptr_R;

        if (en_commit & ~s_empty) begin
            rptr_next = rptr_R + 'd1;
        end

        if (bco_valid) begin

            wptr_next = 'b0;
            rptr_next = 'b0;
        end
        else if (en_alloc_R) begin
            wptr_next = wptr_R + 'd1;
        end
    end

    //
    assign readyn = s_readyn;

    //

endmodule
