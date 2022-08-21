
module issue_pick_core (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire            bco_valid,

    // 
    input   wire [3:0]      i_valid,

    input   wire [15:0]     i_src0_rob,
    input   wire [3:0]      i_src0_rdy,

    input   wire [15:0]     i_src1_rob,
    input   wire [3:0]      i_src1_rdy,

    input   wire [15:0]     i_dst_rob,

    input   wire [3:0]      i_branch,
    input   wire [3:0]      i_load,
    input   wire [3:0]      i_store,

    input   wire [3:0]      i_pipe_alu,
    input   wire [3:0]      i_pipe_mul,
    input   wire [3:0]      i_pipe_mem,
    input   wire [3:0]      i_pipe_bru,

    //
    output  wire [3:0]      o_en,
    output  wire [1:0]      o_pick,

    output  wire [3:0]      o_prepick_forward_src0,
    output  wire [3:0]      o_prepick_forward_src1,

    //
    output  wire            o_valid,

    output  wire [3:0]      o_dst_rob,

    output  wire            o_pipe_alu,
    output  wire            o_pipe_mul,
    output  wire            o_pipe_mem,
    output  wire            o_pipe_bru
);

    //
    integer i;
    genvar  j;


    // ALU-forward path register
    reg  [3:0]  alu_forward_rob;
    reg         alu_forward_valid;

    wire [3:0]  alu_forward_rob_next;
    wire        alu_forward_valid_next;

    assign alu_forward_rob_next   = o_dst_rob;
    assign alu_forward_valid_next = o_valid & o_pipe_alu;

    always @(posedge clk) begin

        if (~resetn) begin
            alu_forward_valid <= 'b0;
        end
        else if (snoop_hit) begin
            alu_forward_valid <= 'b0;
        end
        else if (bco_valid) begin
            alu_forward_valid <= 'b0;
        end
        else begin
            alu_forward_valid <= alu_forward_valid_next;
        end
    end

    always @(posedge clk) begin
        alu_forward_rob <= alu_forward_rob_next;
    end

    
    // Normal Order Fence
    wire [3:0]  fence_normal;

    assign fence_normal = 4'b0000;


    // Branch Fence
    wire [3:0]  fence_b;
    wire [3:0]  fence_b_carrier;

    assign fence_b        [0] = 1'b0;
    assign fence_b_carrier[0] = 1'b0;

    generate
        for (j = 1; j < 4; j = j + 1) begin

            assign fence_b        [j] = i_branch[j]     & fence_b_carrier[j];
            assign fence_b_carrier[j] = i_branch[j - 1] | fence_b_carrier[j - 1];
        end
    endgenerate

    // Load/Store Fence
    wire [3:0]  fence_ls;
    wire [3:0]  fence_ls_carrier;

    assign fence_ls        [0] = 1'b0;
    assign fence_ls_carrier[0] = 1'b0;

    generate
        for (j = 1; j < 4; j = j + 1) begin

            assign fence_ls        [j] = (i_store[j] | i_load[j]) & fence_ls_carrier[j];
            assign fence_ls_carrier[j] =  i_store[j - 1] | fence_ls_carrier[j - 1];
        end
    endgenerate

    // Architectural Pipeline Harzard Detection
    reg  [3:0]  aphd_R,     aphd_next;

    wire [3:0]  aphd_hit;

    always @(posedge clk) begin

        if (~resetn) begin
            aphd_R <= 'b0;
        end
        else begin
            aphd_R <= aphd_next;
        end
    end

    always @(*) begin

        aphd_next = { 1'b0, aphd_R[3:1] };

        if (o_valid) begin
            
            if (o_pipe_alu) begin
                // 1 stage
                // aphd_next[1 -2] = 1'b1;
            end
            else if (o_pipe_mul) begin
                // 4 stage
                aphd_next[3 -2] = 1'b1;
            end
            else if (o_pipe_mem) begin
                // 2 stage
                aphd_next[3 -2] = 1'b1;
            end
            else if (o_pipe_bru) begin
                // 1 stage
                // aphd_next[1 -2] = 1'b1;
            end
        end
    end

    generate
        for (j = 0; j < 4; j = j + 1) begin

            assign aphd_hit[j] = i_pipe_alu[j] ? aphd_R[1 -1]
                               : i_pipe_mul[j] ? aphd_R[3 -1]
                               : i_pipe_mem[j] ? aphd_R[3 -1]
                               : i_pipe_bru[j] ? aphd_R[1 -1]
                               : 1'b0;
        end
    endgenerate

    // Issue window Pre-pick
    wire [3:0]  prepick_forward_src0;
    wire [3:0]  prepick_forward_src1;

    wire [3:0]  prepick_rdy_src0;
    wire [3:0]  prepick_rdy_src1;

    wire [3:0]  prepick_rdy;

    generate
        for (j = 0; j < 4; j = j + 1) begin

            assign prepick_forward_src0[j] = ~i_src0_rdy[j] & alu_forward_valid & (i_src0_rob[j * 4 +: 4] == alu_forward_rob);
            assign prepick_forward_src1[j] = ~i_src1_rdy[j] & alu_forward_valid & (i_src1_rob[j * 4 +: 4] == alu_forward_rob);

            assign prepick_rdy_src0[j] = i_src0_rdy[j] | prepick_forward_src0[j];
            assign prepick_rdy_src1[j] = i_src1_rdy[j] | prepick_forward_src1[j];

            assign prepick_rdy[j] = i_valid[j] & prepick_rdy_src0[j] & prepick_rdy_src1[j];
        end
    endgenerate

    // Issue window Pick
    wire [3:0]  pick_rdy;

    generate
        for (j = 0; j < 4; j = j + 1) begin

            assign pick_rdy[j] = prepick_rdy[j] & ~fence_normal[j] & ~fence_b[j] & ~fence_ls[j] & ~aphd_hit[j];
        end
    endgenerate

    //
    assign o_pick = pick_rdy[0] ? 2'b00
                  : pick_rdy[1] ? 2'b01
                  : pick_rdy[2] ? 2'b10
                  : pick_rdy[3] ? 2'b11
                  :               2'b00;

    assign o_en   = pick_rdy[0] ? 4'b0001
                  : pick_rdy[1] ? 4'b0010
                  : pick_rdy[2] ? 4'b0100
                  : pick_rdy[3] ? 4'b1000
                  :               4'b0000;

    assign o_valid = |(pick_rdy);

    //
    reg  [3:0]  o_src0_rob_comb;
    reg         o_src0_rdy_comb;

    reg  [3:0]  o_src1_rob_comb;
    reg         o_src1_rdy_comb;

    reg  [3:0]  o_dst_rob_comb;

    reg         o_pipe_alu_comb;
    reg         o_pipe_mul_comb;
    reg         o_pipe_mem_comb;
    reg         o_pipe_bru_comb;

    always @(*) begin

        o_src0_rob_comb     = i_src0_rob    [o_pick *  4 +:  4];
        o_src0_rdy_comb     = i_src0_rdy    [o_pick *  1 +:  1];

        o_src1_rob_comb     = i_src1_rob    [o_pick *  4 +:  4];
        o_src1_rdy_comb     = i_src1_rdy    [o_pick *  1 +:  1];

        o_dst_rob_comb      = i_dst_rob     [o_pick *  4 +:  4];

        o_pipe_alu_comb     = i_pipe_alu    [o_pick *  1 +:  1];
        o_pipe_mul_comb     = i_pipe_mul    [o_pick *  1 +:  1];
        o_pipe_mem_comb     = i_pipe_mem    [o_pick *  1 +:  1];
        o_pipe_bru_comb     = i_pipe_bru    [o_pick *  1 +:  1];
    end

    //
    assign o_prepick_forward_src0 = prepick_forward_src0;
    assign o_prepick_forward_src1 = prepick_forward_src1;

    //
    assign o_src0_rob   = o_src0_rob_comb;
    assign o_src0_rdy   = o_src0_rdy_comb;

    assign o_src1_rob   = o_src1_rob_comb;
    assign o_src1_rdy   = o_src1_rdy_comb;

    assign o_dst_rob    = o_dst_rob_comb;

    assign o_pipe_alu   = o_pipe_alu_comb;
    assign o_pipe_mul   = o_pipe_mul_comb;
    assign o_pipe_mem   = o_pipe_mem_comb;
    assign o_pipe_bru   = o_pipe_bru_comb;

    //

endmodule
