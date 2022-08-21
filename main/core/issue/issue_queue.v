
module issue_queue (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    //
    input   wire            bco_valid,

    //
    output  wire [8:0]      fifo_pr,

    // Queue write from Decode Stage
    input   wire            wea,

    input   wire [31:0]     dina_pc,
    
    input   wire [3:0]      dina_src0_rob,
    input   wire            dina_src0_ready,
    input   wire [31:0]     dina_src0_value,

    input   wire [3:0]      dina_src1_rob,
    input   wire            dina_src1_ready,
    input   wire [31:0]     dina_src1_value,

    input   wire [3:0]      dina_rob,

    input   wire [25:0]     dina_imm,

    input   wire [1:0]      dina_bp_pattern,
    input   wire            dina_bp_taken,
    input   wire            dina_bp_hit,
    input   wire [31:0]     dina_bp_target,

    input   wire [7:0]      dina_fid,

    input   wire            dina_branch,
    input   wire            dina_load,
    input   wire            dina_store,

    input   wire            dina_pipe_alu,
    input   wire            dina_pipe_mul,
    input   wire            dina_pipe_mem,
    input   wire            dina_pipe_bru,

    input   wire [4:0]      dina_alu_cmd,
    input   wire [0:0]      dina_mul_cmd,
    input   wire [4:0]      dina_mem_cmd,
    input   wire [6:0]      dina_bru_cmd,
    input   wire [1:0]      dina_bagu_cmd,

    // Writeback wake-up port 0 (from wake-up controller)
    input   wire            web,

    input   wire [3:0]      dinb_rob,
    input   wire [31:0]     dinb_value,

    // Writeback wake-up port 1 (from wake-up controller)
    input   wire            wec,

    input   wire [3:0]      dinc_rob,
    input   wire [31:0]     dinc_value,

    // Issue window port bundle (to issue controller)
    input   wire [3:0]      wed,                // issue pick

    output  wire [3:0]      doutd_valid,

    output  wire [127:0]    doutd_pc,

    output  wire [15:0]     doutd_src0_rob,
    output  wire [3:0]      doutd_src0_rdy,
    output  wire [127:0]    doutd_src0_value,

    output  wire [15:0]     doutd_src1_rob,
    output  wire [3:0]      doutd_src1_rdy,
    output  wire [127:0]    doutd_src1_value,

    output  wire [15:0]     doutd_dst_rob,

    output  wire [103:0]    doutd_imm,

    output  wire [7:0]      doutd_bp_pattern,
    output  wire [3:0]      doutd_bp_taken,
    output  wire [3:0]      doutd_bp_hit,
    output  wire [127:0]    doutd_bp_target,

    output  wire [31:0]     doutd_fid,

    output  wire [3:0]      doutd_branch,
    output  wire [3:0]      doutd_load,
    output  wire [3:0]      doutd_store,

    output  wire [3:0]      doutd_pipe_alu,
    output  wire [3:0]      doutd_pipe_mul,
    output  wire [3:0]      doutd_pipe_mem,
    output  wire [3:0]      doutd_pipe_bru,

    output  wire [19:0]     doutd_alu_cmd,
    output  wire [3:0]      doutd_mul_cmd,
    output  wire [19:0]     doutd_mem_cmd,
    output  wire [27:0]     doutd_bru_cmd,
    output  wire [7:0]      doutd_bagu_cmd
);

    //
    integer i;
    genvar  j;

    //
    wire s_full;
    wire s_empty;

    wire r_pop;   // functionally accepted reading from FIFO
    wire r_push;  // functionally accepted writing into FIFO

    wire p_hold;  // read and write FIFO simultaneously
    wire p_pop;   // read FIFO only
    wire p_push;  // write FIFO only

    assign r_pop  = |(wed) & ~s_empty;
    assign r_push =   wea  & ~s_full;

    assign p_hold = r_pop & wea;
    
    assign p_pop  = ~p_hold & r_pop;
    assign p_push = ~p_hold & r_push;

    //
    wire [7:0]  p_wed;

    assign p_wed  = { 4'b0, wed };

    // P registers
    /* NOTICE: Don't change this in Artix-7, or timing failure */
    (*MAX_FANOUT = 8 *) reg  [8:0]  fifo_p;

    assign s_full  = fifo_p[8];
    assign s_empty = fifo_p[0];

    always @(posedge clk) begin

        if (~resetn) begin
            fifo_p <= 9'b1;
        end
        else if (bco_valid) begin
            fifo_p <= 9'b1;
        end
        else if (p_pop) begin
            fifo_p <= { 1'b0, fifo_p[8:1] };
        end
        else if (p_push) begin
            fifo_p <= { fifo_p[7:0], 1'b0 };
        end
    end


    // FIFO compressing logic
    wire [7:0]  p_shr;
    wire [7:0]  p_shr_carrier;

    assign p_shr        [7] = 1'b0;
    assign p_shr_carrier[0] = 1'b0;

    generate
        
        for (j = 0; j < 7; j = j + 1) begin

            assign p_shr        [j]     = p_wed[j] | p_shr_carrier[j];
            assign p_shr_carrier[j + 1] = p_shr[j];
        end
    endgenerate

    // FIFO entry valid logic
    wire [7:0]  p_valid;
    wire [7:0]  p_valid_carrier;

    generate

        for (j = 0; j < 8; j = j + 1) begin

            if (j < 7) begin

                assign p_valid[j]         = fifo_p[j + 1] | p_valid_carrier[j + 1];
                assign p_valid_carrier[j] = p_valid[j];
            end
            else begin

                assign p_valid[j]         = fifo_p[j + 1];
                assign p_valid_carrier[j] = p_valid[j];
            end
        end
    endgenerate


    // FIFO operation reduction
    wire [7:0]  p_fifo_shr;
    wire [7:0]  p_fifo_write;

    generate

        for (j = 0; j < 8; j = j + 1) begin

            assign p_fifo_shr  [j] = p_shr[j];
            assign p_fifo_write[j] = wea 
                                   & (p_shr[j] ? fifo_p[j + 1] : fifo_p[j]) 
                                   & (~bco_valid);
        end
    endgenerate

    //
    reg  [31:0] pc_R        [7:0];

    reg  [3:0]  src0_rob_R  [7:0];
    reg         src0_rdy_R  [7:0];
    reg  [31:0] src0_value_R[7:0];

    reg  [3:0]  src1_rob_R  [7:0];
    reg         src1_rdy_R  [7:0];
    reg  [31:0] src1_value_R[7:0];

    reg  [25:0] imm_R       [7:0];

    reg  [3:0]  dst_rob_R   [7:0];

    always @(posedge clk) begin

        for (i = 0; i < 8; i = i + 1) begin

            if (p_fifo_write[i]) begin

                src0_rob_R  [i] <= dina_src0_rob;

                src0_rdy_R  [i] <= dina_src0_ready 
                                || (web && dinb_rob == dina_src0_rob)
                                || (wec && dinc_rob == dina_src0_rob);

                src0_value_R[i] <= (web && dinb_rob == dina_src0_rob && ~dina_src0_ready) ? dinb_value 
                                 : (wec && dinc_rob == dina_src0_rob && ~dina_src0_ready) ? dinc_value 
                                 : dina_src0_value;
            end
            else if (p_fifo_shr[i]) begin

                if (i < 7) begin

                    src0_rob_R  [i] <= src0_rob_R  [i + 1];

                    if (~src0_rdy_R[i + 1] && web && (dinb_rob == src0_rob_R[i + 1])) begin

                        src0_rdy_R  [i] <= 1'b1;
                        src0_value_R[i] <= dinb_value;
                    end
                    else if (~src0_rdy_R[i + 1] && wec && (dinc_rob == src0_rob_R[i + 1])) begin

                        src0_rdy_R  [i] <= 1'b1;
                        src0_value_R[i] <= dinc_value;
                    end
                    else begin

                        src0_rdy_R  [i] <= src0_rdy_R  [i + 1];
                        src0_value_R[i] <= src0_value_R[i + 1];
                    end
                end
            end
            else if (~src0_rdy_R[i]) begin

                if (web && (dinb_rob == src0_rob_R[i])) begin

                    src0_rdy_R  [i] <= 1'b1;
                    src0_value_R[i] <= dinb_value;
                end
                else if (wec && (dinc_rob == src0_rob_R[i])) begin

                    src0_rdy_R  [i] <= 1'b1;
                    src0_value_R[i] <= dinc_value;
                end
            end
        end
    end

    always @(posedge clk) begin

        for (i = 0; i < 8; i = i + 1) begin

            if (p_fifo_write[i]) begin

                src1_rob_R  [i] <= dina_src1_rob;

                src1_rdy_R  [i] <= dina_src1_ready
                                || (web && dinb_rob == dina_src1_rob)
                                || (wec && dinc_rob == dina_src1_rob);

                src1_value_R[i] <= (web && dinb_rob == dina_src1_rob && ~dina_src1_ready) ? dinb_value
                                 : (wec && dinc_rob == dina_src1_rob && ~dina_src1_ready) ? dinc_value
                                 : dina_src1_value;
            end
            else if (p_fifo_shr[i]) begin
                
                if (i < 7) begin

                    src1_rob_R  [i] <= src1_rob_R  [i + 1];

                    if (~src1_rdy_R[i + 1] && web && (dinb_rob == src1_rob_R[i + 1])) begin

                        src1_rdy_R  [i] <= 1'b1;
                        src1_value_R[i] <= dinb_value;
                    end
                    else if (~src1_rdy_R[i + 1] && wec && (dinc_rob == src1_rob_R[i + 1])) begin

                        src1_rdy_R  [i] <= 1'b1;
                        src1_value_R[i] <= dinc_value;
                    end
                    else begin

                        src1_rdy_R  [i] <= src1_rdy_R  [i + 1];
                        src1_value_R[i] <= src1_value_R[i + 1];
                    end
                end
            end
            else if (~src1_rdy_R[i]) begin

                if (web && (dinb_rob == src1_rob_R[i])) begin

                    src1_rdy_R  [i] <= 1'b1;
                    src1_value_R[i] <= dinb_value;
                end
                else if (wec && (dinc_rob == src1_rob_R[i])) begin
                    
                    src1_rdy_R  [i] <= 1'b1;
                    src1_value_R[i] <= dinc_value;
                end
            end
        end
    end

    always @(posedge clk) begin

        for (i = 0; i < 8; i = i + 1) begin

            if (p_fifo_write[i]) begin

                pc_R        [i] <= dina_pc;
                imm_R       [i] <= dina_imm;
                dst_rob_R   [i] <= dina_rob;
            end
            else if (p_fifo_shr[i] && i < 7) begin

                pc_R        [i] <= pc_R        [i + 1];
                imm_R       [i] <= imm_R       [i + 1];
                dst_rob_R   [i] <= dst_rob_R   [i + 1];
            end
        end
    end

    
    //
    reg  [1:0]  bp_pattern_R[7:0];
    reg         bp_taken_R  [7:0];
    reg         bp_hit_R    [7:0];
    reg  [31:0] bp_target_R [7:0];

    always @(posedge clk) begin

        for (i = 0; i < 8; i = i + 1) begin

            if (p_fifo_write[i]) begin

                bp_pattern_R[i] <= dina_bp_pattern;
                bp_taken_R  [i] <= dina_bp_taken;
                bp_hit_R    [i] <= dina_bp_hit;
                bp_target_R [i] <= dina_bp_target;
            end
            else if (p_fifo_shr[i] && i < 7) begin

                bp_pattern_R[i] <= bp_pattern_R [i + 1];
                bp_taken_R  [i] <= bp_taken_R   [i + 1];
                bp_hit_R    [i] <= bp_hit_R     [i + 1];
                bp_target_R [i] <= bp_target_R  [i + 1];
            end
        end
    end


    //
    reg  [7:0]  fid_R       [7:0];

    reg         branch_R    [7:0];
    reg         load_R      [7:0];
    reg         store_R     [7:0];

    always @(posedge clk) begin

        for (i = 0; i < 8; i = i + 1) begin

            if (p_fifo_write[i]) begin

                fid_R       [i] <= dina_fid;

                branch_R    [i] <= dina_branch;
                load_R      [i] <= dina_load;
                store_R     [i] <= dina_store;
            end
            else if (p_fifo_shr[i] && i < 7) begin

                fid_R       [i] <= fid_R        [i + 1];

                branch_R    [i] <= branch_R     [i + 1];
                load_R      [i] <= load_R       [i + 1];
                store_R     [i] <= store_R      [i + 1];
            end
        end
    end

    //
    reg         pipe_alu_R  [7:0];
    reg         pipe_mul_R  [7:0];
    reg         pipe_mem_R  [7:0];
    reg         pipe_bru_R  [7:0];

    always @(posedge clk) begin

        for (i = 0; i < 8; i = i + 1) begin

            if (p_fifo_write[i]) begin

                pipe_alu_R  [i] <= dina_pipe_alu;
                pipe_mul_R  [i] <= dina_pipe_mul;
                pipe_mem_R  [i] <= dina_pipe_mem;
                pipe_bru_R  [i] <= dina_pipe_bru;
            end
            else if (p_fifo_shr[i] && i < 7) begin

                pipe_alu_R  [i] <= pipe_alu_R   [i + 1];
                pipe_mul_R  [i] <= pipe_mul_R   [i + 1];
                pipe_mem_R  [i] <= pipe_mem_R   [i + 1];
                pipe_bru_R  [i] <= pipe_bru_R   [i + 1];
            end
        end
    end

    //
    reg  [4:0]  alu_cmd_R   [7:0];
    reg  [0:0]  mul_cmd_R   [7:0];
    reg  [4:0]  mem_cmd_R   [7:0];
    reg  [6:0]  bru_cmd_R   [7:0];
    reg  [1:0]  bagu_cmd_R  [7:0];

    always @(posedge clk) begin

        for (i = 0; i < 8; i = i + 1) begin

            if (p_fifo_write[i]) begin

                alu_cmd_R   [i] <= dina_alu_cmd;
                mul_cmd_R   [i] <= dina_mul_cmd;
                mem_cmd_R   [i] <= dina_mem_cmd;
                bru_cmd_R   [i] <= dina_bru_cmd;
                bagu_cmd_R  [i] <= dina_bagu_cmd;
            end
            else if (p_fifo_shr[i] && i < 7) begin

                alu_cmd_R   [i] <= alu_cmd_R    [i + 1];
                mul_cmd_R   [i] <= mul_cmd_R    [i + 1];
                mem_cmd_R   [i] <= mem_cmd_R    [i + 1];
                bru_cmd_R   [i] <= bru_cmd_R    [i + 1];
                bagu_cmd_R  [i] <= bagu_cmd_R   [i + 1];
            end
        end
    end

    //
    generate 

        for (j = 0; j < 4; j = j + 1) begin

            assign doutd_valid      [j *  1 +:  1] = p_valid[j] & ~bco_valid;

            assign doutd_pc         [j * 32 +: 32] = pc_R[j];

            assign doutd_src0_rob   [j *  4 +:  4] = src0_rob_R[j]; 
            assign doutd_src0_rdy   [j *  1 +:  1] = src0_rdy_R[j];
            assign doutd_src0_value [j * 32 +: 32] = src0_value_R[j];

            assign doutd_src1_rob   [j *  4 +:  4] = src1_rob_R[j];
            assign doutd_src1_rdy   [j *  1 +:  1] = src1_rdy_R[j];
            assign doutd_src1_value [j * 32 +: 32] = src1_value_R[j];

            assign doutd_dst_rob    [j *  4 +:  4] = dst_rob_R[j];

            assign doutd_imm        [j * 26 +: 26] = imm_R[j];

            assign doutd_bp_pattern [j * 2  +:  2] = bp_pattern_R[j];
            assign doutd_bp_taken   [j * 1  +:  1] = bp_taken_R  [j];
            assign doutd_bp_hit     [j * 1  +:  1] = bp_hit_R    [j];
            assign doutd_bp_target  [j * 32 +: 32] = bp_target_R [j];

            assign doutd_fid        [j *  8 +:  8] = fid_R[j];

            assign doutd_branch     [j *  1 +:  1] = branch_R[j];
            assign doutd_load       [j *  1 +:  1] = load_R[j];
            assign doutd_store      [j *  1 +:  1] = store_R[j];

            assign doutd_pipe_alu   [j *  1 +:  1] = pipe_alu_R[j];
            assign doutd_pipe_mul   [j *  1 +:  1] = pipe_mul_R[j];
            assign doutd_pipe_mem   [j *  1 +:  1] = pipe_mem_R[j];
            assign doutd_pipe_bru   [j *  1 +:  1] = pipe_bru_R[j];

            assign doutd_alu_cmd    [j *  5 +:  5] = alu_cmd_R[j];
            assign doutd_mul_cmd    [j *  1 +:  1] = mul_cmd_R[j];
            assign doutd_mem_cmd    [j *  5 +:  5] = mem_cmd_R[j];
            assign doutd_bru_cmd    [j *  7 +:  7] = bru_cmd_R[j];
            assign doutd_bagu_cmd   [j *  2 +:  2] = bagu_cmd_R[j];
        end
    endgenerate

    //
    assign fifo_pr = fifo_p;

    //

endmodule
