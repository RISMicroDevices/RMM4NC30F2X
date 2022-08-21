`define     FETCH_STARTUP_PC                        32'h80000000

`define     FETCH_STATE_SEQUENTIAL                  1'b0
`define     FETCH_STATE_LOCKED                      1'b1


module fetch_sequence (
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
    output  wire            pc_uncached,
    output  wire            pc_valid,

    //
    output  wire [31:0]     o_pc_vaddr,
    output  wire [7:0]      o_pc_fid,
    output  wire            o_pc_valid
);

    //
    reg     readyn_R;

    always @(posedge clk) begin

        if (~resetn) begin
            readyn_R <= 1'b0;
        end
        else begin
            readyn_R <= readyn;
        end
    end

    
    //
    reg     cache_refilled_hit_R;
    reg     cache_uncached_done_R;

    always @(posedge clk) begin

        if (~resetn) begin

            cache_refilled_hit_R    <= 1'b0;
            cache_uncached_done_R   <= 1'b0;
        end
        else begin

            cache_refilled_hit_R    <= cache_refilled_hit;
            cache_uncached_done_R   <= cache_uncached_done;
        end
    end


    //
    wire    fc_valid;


    //
    reg     state_R,    state_next;
    reg     state_R1;

    wire    s_locked;
    wire    s_to_locked;
    wire    s_to_unlocked;

    wire    s_to_locked_for_readyn;

    wire    q_shr;

    assign s_locked      = state_R    == `FETCH_STATE_LOCKED;
    assign s_to_locked   = state_next == `FETCH_STATE_LOCKED;

    assign q_shr         = (~s_locked && (~s_to_locked || s_to_locked_for_readyn));

    always @(posedge clk) begin

        if (~resetn) begin

            state_R     <= `FETCH_STATE_SEQUENTIAL;
            state_R1    <= `FETCH_STATE_SEQUENTIAL;
        end
        else begin

            state_R     <= state_next;
            state_R1    <= state_R;
        end
    end


    reg     s_to_locked_for_readyn_comb;
    
    assign s_to_locked_for_readyn = s_to_locked_for_readyn_comb;

    always @(*) begin

        state_next = state_R;

        s_to_locked_for_readyn_comb = 1'b0;

        case (state_R)

            `FETCH_STATE_SEQUENTIAL:    begin

                if (fc_valid) begin
                    
                    if (~cache_hit) begin

                        // Falls into LOCKED on cache miss or uncached fetch
                        state_next = `FETCH_STATE_LOCKED;
                    end
                    else if (readyn) begin
                        
                        // Falls into LOCKED on 'readyn' asserted
                        state_next = `FETCH_STATE_LOCKED;

                        s_to_locked_for_readyn_comb = 1'b1;
                    end
                end
            end

            `FETCH_STATE_LOCKED:        begin

                if (snoop_hit) begin
                    
                    // Clear on snoop (unused currently)
                    state_next = `FETCH_STATE_SEQUENTIAL;
                end
                else if (bco_valid) begin

                    // Fall back to SEQUENTIAL immeidately on BCO
                    state_next = `FETCH_STATE_SEQUENTIAL;
                end
                else if (~readyn && (cache_refilled_hit || cache_uncached_done)) begin

                    // Back to SEQUENTIAL fetch on cache/buffer hit on LOCKED
                    // *NOTICE: On uncached fetch, if the fetch sequence is blocked by 'readyn' signal,
                    //          the uncached instruction fetch procedure would simply restart (immedately)
                    //          after the procedure accomplished, because Uncached Fetch Buffer only holds
                    //          instruction data for 1 cycle and fetch sequence wouldn't store the fetched
                    //          instruction data.
                    state_next = `FETCH_STATE_SEQUENTIAL;
                end
                else if (~readyn && cache_hit && state_R1 == `FETCH_STATE_LOCKED) begin
                    
                    // Recovery to SEQUENTIAL when LOCKED on 'readyn'
                    state_next = `FETCH_STATE_SEQUENTIAL;
                end
            end

            default:    begin
            end
        endcase
    end


    //
    reg  [31:0] pc_value_R      [1:0];
    reg         pc_valid_R      [1:0]; 

    reg  [31:0] pc_value_next   [1:0];
    reg         pc_valid_next   [1:0];

    always @(posedge clk) begin

        if (~resetn) begin

            pc_value_R[0] <= `FETCH_STARTUP_PC;
            pc_valid_R[0] <= 1'b1;

            pc_value_R[1] <=  'b0;
            pc_valid_R[1] <= 1'b0;
        end
        else begin

            pc_value_R[0] <= pc_value_next[0];
            pc_valid_R[0] <= pc_valid_next[0];

            pc_value_R[1] <= pc_value_next[1];
            pc_valid_R[1] <= pc_valid_next[1];
        end
    end

    always @(*) begin

        if (snoop_hit) begin

            pc_value_next[0] = snoop_addr;
            pc_valid_next[0] = 1'b1;

            pc_value_next[1] = pc_value_R[1];
            pc_valid_next[1] = 1'b0;
        end
        else if (bco_valid) begin

            pc_value_next[0] = bco_target;
            pc_valid_next[0] = 1'b1;

            pc_value_next[1] = pc_value_R[1];
            pc_valid_next[1] = 1'b0;
        end
        else if (q_shr) begin

            pc_value_next[0] = pc_value_R[0] + 'd4;
            pc_valid_next[0] = 1'b1;

            pc_value_next[1] = pc_value_R[0];
            pc_valid_next[1] = pc_valid_R[0];

            if (fc_valid && bp_valid && bp_hit && bp_taken) begin
                pc_value_next[0] = bp_target;
            end
        end
        else begin

            pc_value_next[0] = pc_value_R[0];
            pc_valid_next[0] = pc_valid_R[0];

            pc_value_next[1] = pc_value_R[1];
            pc_valid_next[1] = pc_valid_R[1];
        end
    end

    
    //
    reg  [7:0]  fid_R;

    always @(posedge clk) begin

        if (~resetn) begin
            fid_R <= 'b0;
        end
        else if (q_shr) begin
            fid_R <= fid_R + 'd1;
        end
    end


    //
    reg     cctrl_miss_R,       cctrl_miss_next;
    reg     cctrl_uncached_R,   cctrl_uncached_next;

    always @(posedge clk) begin

        if (~resetn) begin

            cctrl_miss_R        <= 1'b0;
            cctrl_uncached_R    <= 1'b0;
        end
        else begin
            
            cctrl_miss_R        <= cctrl_miss_next;
            cctrl_uncached_R    <= cctrl_uncached_next;
        end
    end
    
    always @(*) begin

        cctrl_miss_next     = cctrl_miss_R;
        cctrl_uncached_next = cctrl_uncached_R;

        case (state_R)

            `FETCH_STATE_SEQUENTIAL:    begin
            end

            `FETCH_STATE_LOCKED:    begin

                if (state_next == `FETCH_STATE_SEQUENTIAL) begin

                    cctrl_miss_next     = 1'b0;
                    cctrl_uncached_next = 1'b0;
                end
                else begin

                    if (cache_uncached) begin
                        cctrl_uncached_next = 1'b1;
                    end
                    else if (~cache_hit) begin

                        // *NOTICE: There is no need to trigger cache refill procedure if LOCKED
                        //          on 'readyn' signal.
                        cctrl_miss_next     = 1'b1;
                    end
                end
            end

            default:    begin
            end
        endcase
    end

    assign cctrl_miss       = cctrl_miss_R;
    assign cctrl_uncached   = cctrl_uncached_R;


    //
    assign fc_valid = pc_valid_R[1];

    //
    assign pc_vaddr = s_locked ? pc_value_R[1] : pc_value_R[0];
    assign pc_valid = s_locked ? pc_valid_R[1] : pc_valid_R[0];

    misc_vpaddr misc_vpaddr_INST (
        .vaddr  (pc_vaddr),

        .paddr  (pc_paddr),
        .kseg1  (pc_uncached)
    );

    //
    assign o_pc_valid   = pc_valid_R[1];
    assign o_pc_vaddr   = pc_value_R[1];
    assign o_pc_fid     = fid_R;

    //

    //

endmodule
