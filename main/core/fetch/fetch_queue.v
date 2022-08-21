
`define     FETCH_QUEUE_SEQUENTIAL              1'b0
`define     FETCH_QUEUE_LOCKED                  1'b1

`define     FETCH_STARTUP_PC                    32'h80000000

module fetch_queue (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            readyn,                 // from backends, high on not ready

    input   wire            bco_valid,              // branch commit override valid
    input   wire [31:0]     bco_target,             // branch commit override target

    //
    input   wire            snoop_hit,
    input   wire [31:0]     snoop_addr,

    //
    input   wire            cache_hit,
    input   wire            cache_uncached,

    input   wire            cache_refilled_hit,     // cache refill hit
    input   wire            cache_uncached_done,    // uncached operation done signal

    input   wire            bp_valid,               // indicating whether a branch instruction is fetched (if cache hit)

    input   wire            bp_taken,               // PHT output
    input   wire            bp_hit,                 // BTB hit
    input   wire [31:0]     bp_target,              // BTB output

    //
    output  wire            cctrl_miss,             // cache miss request to cache controller
    output  wire            cctrl_uncached,         // uncached request to cache controller

    //
    output  wire [31:0]     pc_paddr,
    output  wire [31:0]     pc_vaddr,
    output  wire [3:0]      pc_bid,
    output  wire            pc_uncached,
    output  wire            pc_valid,

    output  wire            locked                  //
);

    //
    reg         readyn_R;

    always @(posedge clk) begin

        if (~resetn) begin
            readyn_R <= 1'b0;
        end
        else begin
            readyn_R <= readyn;
        end
    end


    // Fetch target FSM registers
    (*MAX_FANOUT = 128 *)
    reg [0:0]   state_R, state_next;

    always @(posedge clk) begin

        if (~resetn) begin
            state_R <= `FETCH_QUEUE_SEQUENTIAL;
        end
        else begin
            state_R <= state_next;
        end
    end

    
    // Queue registers
    reg [3:0]   pc_bid_R          [1:0];
    reg [31:0]  pc_value_R        [1:0];
    reg         pc_valid_R        [1:0];
    reg         pc_delayslot_R    [1:0];

    reg [3:0]   pc_bid_next       [1:0];
    reg [31:0]  pc_value_next     [1:0];
    reg         pc_valid_next     [1:0];
    reg         pc_delayslot_next [1:0];

    always @(posedge clk) begin

        if (~resetn) begin

            pc_bid_R      [0] <= 'b0;
            pc_value_R    [0] <= 'b0;
            pc_valid_R    [0] <= 'b0;
            pc_delayslot_R[0] <= 'b0;

            pc_bid_R      [1] <= 'b0;
            pc_value_R    [1] <= `FETCH_STARTUP_PC;
            pc_valid_R    [1] <= 'b1;
            pc_delayslot_R[1] <= 'b0;
        end
        else begin

            pc_bid_R      [0] <= pc_bid_next      [0];
            pc_value_R    [0] <= pc_value_next    [0];
            pc_valid_R    [0] <= pc_valid_next    [0];
            pc_delayslot_R[0] <= pc_delayslot_next[0];

            pc_bid_R      [1] <= pc_bid_next      [1];
            pc_value_R    [1] <= pc_value_next    [1];
            pc_valid_R    [1] <= pc_valid_next    [1];
            pc_delayslot_R[1] <= pc_delayslot_next[1];
        end
    end

    //
    reg     fc_valid_R;

    always @(posedge clk) begin

        if (~resetn) begin
            fc_valid_R <= 1'b0;
        end
        else if (bco_valid) begin
            fc_valid_R <= 1'b0;
        end
        else begin
            fc_valid_R <= pc_valid;
        end
    end


    // Cache miss queue lock logic
    assign locked   = state_R == `FETCH_QUEUE_LOCKED;

    reg     locked_on_readyn_R;

    always @(posedge clk) begin

        if (~resetn) begin
            locked_on_readyn_R <= 1'b0;
        end
        else if (locked && (state_next == `FETCH_QUEUE_SEQUENTIAL) && readyn_R) begin   // LOCKED to unLOCKED edge
            locked_on_readyn_R <= 1'b1;
        end
        else if (~readyn_R) begin
            locked_on_readyn_R <= 1'b0;
        end
    end

    
    // Queue shift logic (Left shift eliminated)
    wire    ql_t_state_sequential;
    wire    ql_t_input_tolock;

    wire    ql_shr;     // right shifting

    assign ql_t_state_sequential = state_R == `FETCH_QUEUE_SEQUENTIAL;
    assign ql_t_input_tolock     = fc_valid_R & ~cache_hit;

    assign ql_shr =  ql_t_state_sequential & ~ql_t_input_tolock & ~readyn_R
                  & ~locked_on_readyn_R;

    //
    // *NOTICE: The 1 clk history of 'ql_shr' indicates whether the instruction was
    //          shifted out of the fetch queue.
    reg     ql_shr_R;

    always @(posedge clk) begin

        if (~resetn) begin
            ql_shr_R <= 1'b0;
        end
        else begin
            ql_shr_R <= ql_shr;
        end
    end

    
    // Write logic
    reg bco_state_refresh;

    always @(*) begin

        bco_state_refresh = 'b0;

        if (ql_shr) begin

            pc_bid_next      [0] = pc_bid_R  [1];
            pc_value_next    [0] = pc_value_R[1];
            pc_valid_next    [0] = pc_valid_R[1];
            pc_delayslot_next[0] = /*ql_shr_R &*/ bp_valid;

            pc_bid_next      [1] = ((ql_shr_R & bp_valid) | pc_delayslot_R[1]) ? (pc_bid_R[1] + 'd1) : pc_bid_R[1];
            pc_value_next    [1] = pc_value_R[1] + 4; // default next pc
            pc_valid_next    [1] = 'b1;
            pc_delayslot_next[1] = 'b0;
        end
        else begin

            pc_bid_next      [0] = pc_bid_R         [0];
            pc_value_next    [0] = pc_value_R       [0];
            pc_valid_next    [0] = pc_valid_R       [0];
            pc_delayslot_next[0] = pc_delayslot_R   [0];

            pc_bid_next      [1] = pc_bid_R         [1];
            pc_value_next    [1] = pc_value_R       [1];
            pc_valid_next    [1] = pc_valid_R       [1];
            pc_delayslot_next[1] = (ql_shr_R & bp_valid) ? 1'b1 : pc_delayslot_R[1];
        end


        // branch prediction fallback logic
        if (fc_valid_R & bp_valid & (ql_shr_R)) begin

            if (bp_taken & bp_hit) begin
                pc_value_next[1] = bp_target;
            end
        end

        // branch commit override logic
        if (bco_valid) begin

            bco_state_refresh    = 1'b1;
            pc_value_next[1]     = bco_target;
            pc_delayslot_next[1] = 1'b0;

            if (~pc_delayslot_R[0]) begin
                pc_valid_next[0] = 1'b0;
            end
        end

        // snoop override
        if (snoop_hit) begin

            pc_valid_next[0] = 'b0;

            pc_value_next[1] = snoop_addr;
            pc_valid_next[1] = 'b1;
        end
    end


    // State transition logic
    always @(*) begin

        case (state_R)

            `FETCH_QUEUE_SEQUENTIAL: begin
                
                if (fc_valid_R) begin

                    if (~cache_hit) begin  

                        // To LOCKED on cache miss
                        state_next = `FETCH_QUEUE_LOCKED;
                    end
                    else begin
                        state_next = `FETCH_QUEUE_SEQUENTIAL;
                    end
                end
                else begin
                    state_next = `FETCH_QUEUE_SEQUENTIAL;
                end
            end

            `FETCH_QUEUE_LOCKED: begin
                
                if (snoop_hit) begin

                    // Back to SEQUENTIAL fetch on ICache Snoop hit
                    state_next = `FETCH_QUEUE_SEQUENTIAL;
                end
                else if (bco_state_refresh & ~pc_delayslot_R[0]) begin 

                    // Back to SEQUENTIAL fetch immediately on branch commit WHILE not LOCKED on delay slot
                    state_next = `FETCH_QUEUE_SEQUENTIAL;
                end 
                else if (cache_refilled_hit | cache_uncached_done) begin

                    // Back to SEQUENTIAL fetch on any cache buffer hit under LOCKED
                    state_next = `FETCH_QUEUE_SEQUENTIAL;
                end
                else begin
                    state_next = `FETCH_QUEUE_LOCKED;
                end
            end

            default:
                state_next = `FETCH_QUEUE_SEQUENTIAL;
        endcase
    end


    // Cache control request logic
    reg cctrl_miss_R;
    reg cctrl_uncached_R;

    reg cctrl_miss_next;
    reg cctrl_uncached_next;

    always @(posedge clk) begin

        if (~resetn) begin

            cctrl_miss_R     <= 'b0;
            cctrl_uncached_R <= 'b0;
        end
        else begin

            cctrl_miss_R     <= cctrl_miss_next;
            cctrl_uncached_R <= cctrl_uncached_next;
        end
    end

    always @(*) begin

        cctrl_miss_next     = 'b0;
        cctrl_uncached_next = 'b0;

        case (state_R)

            `FETCH_QUEUE_SEQUENTIAL: begin

                if (fc_valid_R & ~cache_hit) begin

                    if (cache_uncached) begin
                        cctrl_uncached_next = 'b1;
                    end
                    else begin
                        cctrl_miss_next = 'b1;
                    end
                end
            end

            `FETCH_QUEUE_LOCKED: begin

                if (~bco_state_refresh | pc_delayslot_next[0]) begin

                    cctrl_miss_next     = cctrl_miss_R;
                    cctrl_uncached_next = cctrl_uncached_R;
                end
            end

            default: begin
            end
        endcase
    end


    
    
    //
    assign cctrl_miss     = cctrl_miss_R;
    assign cctrl_uncached = cctrl_uncached_R;

    // *NOTICE: The PC output is buffered by the fetch queue, 
    //          switch to history PC on LOCKED (cache miss).
    assign pc_bid       = locked || locked_on_readyn_R ?  pc_bid_R  [0]                                       :  pc_bid_R  [1];
    assign pc_valid     = locked || locked_on_readyn_R ? (pc_valid_R[0] && (pc_delayslot_R[0] | ~bco_valid))  : (pc_valid_R[1] && ~bco_valid);
    assign pc_vaddr     = locked || locked_on_readyn_R ?  pc_value_R[0]                                       :  pc_value_R[1];

    misc_vpaddr misc_vpaddr_INST (
        .vaddr  (pc_vaddr),
        
        .paddr  (pc_paddr),
        .kseg1  (pc_uncached)
    );

    //

endmodule
