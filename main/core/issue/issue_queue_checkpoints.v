
module issue_queue_checkpoints (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    // Checkpoint write
    input   wire            wea,
    input   wire [1:0]      addra,
    input   wire [8:0]      dina_fifo_pr,

    // Checkpoint recovery & set invalidation (on BCO)
    input   wire            web,
    input   wire [1:0]      addrb,
    output  wire            doutb_valid,
    output  wire [8:0]      doutb_fifo_pr,

    // Checkpoint line invalidation (on Branch Commit, sync with BCO)
    input   wire            wec,
    input   wire [1:0]      addrc,

    // Checkpoint entry invalidation (on picked)
    input   wire [3:0]      wed
);

    //
    integer i;
    genvar  j;

    // *NOTICE: The limitation for checkpoints of maximum 4 branches is 
    //          detected and blocked in DECODE-alloc stage.

    //
    reg  [3:0]  valid_R;

    always @(posedge clk) begin

        for (i = 0; i < 4; i = i + 1) begin

            if (~resetn) begin
                valid_R[i] <= 'b0;
            end
            else if (snoop_hit) begin
                valid_R[i] <= 'b0;
            end
            else if (web) begin
                valid_R[i] <= 'b0;
            end
            else if (wec && (addrc == i)) begin
                valid_R[i] <= 'b0;
            end
            else if (wea && (addra == i)) begin
                valid_R[i] <= 'b1;
            end
        end
    end

    //
    wire [7:0]  p_wed;
    wire [8:0]  p_shr;

    assign p_wed    = { 4'b0, wed };
    assign p_shr[0] = 1'b0;

    generate
        for (j = 0; j < 8; j = j + 1) begin

            assign p_shr[j + 1] = p_wed[j] | p_shr[j];
        end
    endgenerate
    
    //
    reg  [8:0]  cp_fifo_pr  [3:0];

    always @(posedge clk) begin

        for (i = 0; i < 4; i = i + 1) begin

            if (wea && addra == i) begin

                if (dina_fifo_pr & p_shr) begin
                    cp_fifo_pr[i] <= { 1'b0, dina_fifo_pr[8:1] };
                end
                else begin
                    cp_fifo_pr[i] <= dina_fifo_pr;
                end
            end
            else if (cp_fifo_pr[i] & p_shr) begin
                cp_fifo_pr[i] <= { 1'b0, cp_fifo_pr[i][8:1] };
            end
        end
    end

    //
    assign doutb_valid   = valid_R   [addrb];
    assign doutb_fifo_pr = cp_fifo_pr[addrb];

    //

endmodule
