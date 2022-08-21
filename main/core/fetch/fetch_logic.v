`define     FETCH_STARTUP_PC                        32'h80000000

`define     FETCH_STATE_SEQUENTIAL                  1'b0
`define     FETCH_STATE_LOCKED                      1'b1

module fetch_logic (
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
    reg         readyn_R;
    reg         readyn_R2;

    always @(posedge clk) begin

        if (~resetn) begin

            readyn_R  <= 1'b0;
            readyn_R2 <= 1'b0;
        end
        else begin
            
            readyn_R  <= readyn;
            readyn_R2 <= readyn_R;
        end
    end


    //
    integer i;
    genvar  j;


    //
    wire        fc_valid;

    //
    wire [3:1]  bco_bid_hit;

    assign bco_bid_hit = 3'b0;

    //
    reg  [7:0]  fid_R;

    reg  [31:0] pc_value_R      [3:1];
    reg         pc_valid_R      [3:1];
    reg  [3:0]  pc_bid_R        [3:1];

    //
    reg         state_R,    state_next;

    always @(posedge clk) begin

        if (~resetn) begin
            state_R <= `FETCH_STATE_SEQUENTIAL;
        end
        else begin
            state_R <= state_next;
        end
    end

    always @(*) begin

        state_next = state_R;

        case (state_R)

            `FETCH_STATE_SEQUENTIAL:    begin

                if (fc_valid && ~cache_hit && ~readyn_R2) begin

                    if (bco_valid && ~bco_bid_hit[3]) begin
                        
                        // Fast-forward path
                        // *NOTICE: There is no need to go into LOCKED if not missing instruction
                        //          on the coupled delayslot of BCO.
                        state_next = `FETCH_STATE_SEQUENTIAL;
                    end
                    else begin

                        // Instruction cache miss / uncached instruction fetch
                        state_next = `FETCH_STATE_LOCKED;
                    end
                end
            end

            `FETCH_STATE_LOCKED:    begin

                if (snoop_hit) begin
                    
                    // CLEAN fetch queue on Snoop Filter hit
                    state_next = `FETCH_STATE_SEQUENTIAL;
                end
                else if (cache_refilled_hit || cache_uncached_done) begin

                    // Instruction fetched from memory, back to SEQUENTIAL
                    state_next = `FETCH_STATE_SEQUENTIAL;
                end
                else if (bco_valid && ~bco_bid_hit[2]) begin

                    // Fast-forward path to SEQUENTIAL on BCO
                    state_next = `FETCH_STATE_SEQUENTIAL;
                end
            end

            default:    begin
            end
        endcase
    end


    //
    wire        locked;

    wire        to_locked;
    wire        to_unlocked;

    assign locked    = state_R == `FETCH_STATE_LOCKED;

    assign to_locked   = state_R == `FETCH_STATE_SEQUENTIAL && state_next == `FETCH_STATE_LOCKED;
    assign to_unlocked = state_R == `FETCH_STATE_LOCKED     && state_next == `FETCH_STATE_SEQUENTIAL;


    //
    reg         shr_R,  shr_next;  // SHR operation history
    reg         shl_R,  shl_next;  // SHL operation history

    reg  [7:0]  fid_next;

    reg  [31:0] pc_value_next   [3:1];
    reg         pc_valid_next   [3:1];
    reg  [3:0]  pc_bid_next     [3:1];

    always @(posedge clk) begin

        if (~resetn) begin

            shr_R         <= 'b0;
            shl_R         <= 'b0;

            fid_R         <= 'b0;

            pc_value_R[2] <= `FETCH_STARTUP_PC;
            pc_valid_R[2] <= 1'b1;
            pc_bid_R  [2] <= 'b0;

            pc_valid_R[1] <= 'b0;
            pc_valid_R[3] <= 'b0;
        end
        else begin

            shr_R <= shr_next;
            shl_R <= shl_next;

            fid_R <= fid_next;

            for (i = 1; i < 4; i = i + 1) begin

                pc_value_R[i]   <= pc_value_next[i];
                pc_valid_R[i]   <= pc_valid_next[i];
                pc_bid_R  [i]   <= pc_bid_next  [i];
            end
        end
    end

    always @(*) begin

        //
        shr_next = 1'b0;
        shl_next = 1'b0;

        fid_next = fid_R;

        for (i = 1; i < 4; i = i + 1) begin

            pc_value_next[i] = pc_value_R[i];
            pc_valid_next[i] = pc_valid_R[i];
            pc_bid_next  [i] = pc_bid_R  [i];
        end

        //
        if (to_locked) begin

            // Shift back (SHL) fetch queue on transition to LOCKED
            shl_next         = 1'b1;

//          pc_value_next[3] = 'b0;
            pc_valid_next[3] = 'b0;
//          pc_bid_next  [3] = 'b0;

            pc_value_next[2] = pc_value_R[3];
            pc_valid_next[2] = pc_valid_R[3];
            pc_bid_next  [2] = pc_bid_R  [3];

            //
            pc_value_next[1] = pc_value_R[2];
            pc_valid_next[1] = pc_valid_R[2];
            pc_bid_next  [1] = pc_bid_R  [2];

            //*NOTICE: There is no need to shift PC value of PC_QUEUE[2] back to PC_QUEUE[1] actually,
            //         because value in PC_QUEUE[2] would always be generated by the PC address adder,
            //         or shifted from BCO value in PC_QUEUE[1].
            //         But, queue shifting back is still necessary to record BID increment properly.


            if (bco_valid) begin
                
                // Miss on BCO coupled delayslot
                pc_value_next[1] = bco_target;
                pc_valid_next[1] = 1'b1;
            end
        end
        else if (~readyn_R && (~locked || to_unlocked)) begin 

            // Out shifting (SHR) fetch queue
            shr_next         = 1'b1;

            fid_next         = fid_R + 'd1;

            pc_value_next[3] = pc_value_R[2];
            pc_valid_next[3] = pc_valid_R[2];
            pc_bid_next  [3] = pc_bid_R  [2];

            pc_value_next[2] = pc_value_R[2] + 'd4;
            pc_valid_next[2] = 1'b1;
            pc_bid_next  [2] = pc_bid_R[2];

//          pc_value_next[1] = 'b0;
            pc_valid_next[1] = 'b0;
//          pc_bid_next  [1] = 'b0;

            if (bp_valid && shr_R) begin 

                // Increase BID
                // *NOTICE: The BID value MUST be incremented after a delayslot, incorrect generation
                //          would destroy all the following branch-forward checkpoints.

                pc_bid_next[2] = pc_bid_R[2] + 'd1;
            end

            if (pc_valid_R[1]) begin

                // History BCO Override
                // *NOTICE: This action is usually triggered on a delayslot cache miss.

                pc_value_next[2] = pc_value_R[1];
                pc_bid_next  [2] = pc_bid_R  [1];

                pc_valid_next[1] = 1'b0;
            end
            else if ((bp_valid && shr_R) && bp_taken && bp_hit) begin

                // Branch Prediciton Override

                pc_value_next[2] = bp_target;
            end


            if (bco_valid) begin

                // *NOTICE: On fetch queue SHR, BCO coupled delayslot would no more settle in PC_QUEUE[2].
                //          In fact, this SHR is at least two SHR cycles after the branch is issued,
                //          which means that the coupled delayslot would be shifted to PC_QUEUE[3] in this
                //          SHR cycle in worst case.

                pc_value_next[2] = bco_target;

                pc_valid_next[3] = bco_bid_hit[2];
                pc_valid_next[2] = 1'b1;
                pc_valid_next[1] = 1'b0;
            end
        end
        else begin

            // PC fetch freeze circumstances

            //
            pc_valid_next[3] = 1'b0;

            // *NOTICE: On LOCKED state or 'readyn' asserted, the instruction has been shifted out
            //          (shifted to PC_QUEUE[3]) must maintain only 1 cycle of life.
            //          This also indicates that under 'readyn', the instruction that already
            //          shifted into PC_QUEUE[3] would always be accepted by later pipelines.
            //

            //
            if (bp_valid && shr_R) begin

                if (bp_taken && bp_hit) begin

                    pc_value_next[1] = bp_target;
                    pc_valid_next[1] = 1'b1;
                end
            end

            // *NOTICE: Under 'readyn', PC_QUEUE[3] would never be shifted back to PC_QUEUE[2],
            //          so an extra register is needed to record information for delayslot
            //          for generating next PC and the BID increment properly.

            
            if (bco_valid) begin

                if (bco_bid_hit[2]) begin

                    // Miss on BCO coupled delayslot
                    pc_value_next[1] = bco_target;
                    pc_valid_next[1] = 1'b1;
                end
                else begin

                    // Immediately replace the current instruction stream
                    pc_value_next[2] = bco_target;
                    pc_valid_next[2] = 1'b1;

                    pc_valid_next[1] = 1'b0;
                end
            end
        end

        //
        if (snoop_hit) begin

            pc_value_next[2] = snoop_addr;
            pc_valid_next[2] = 1'b1;
            pc_bid_next  [2] = 'b0;

            pc_valid_next[1] = 'b0;
            pc_valid_next[3] = 'b0;
        end
    end


    //
    reg         cctrl_miss_R,       cctrl_miss_next;
    reg         cctrl_uncached_R,   cctrl_uncached_next;

    always @(posedge clk) begin

        if (~resetn) begin

            cctrl_miss_R        <= 'b0;
            cctrl_uncached_R    <= 'b0;
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

                if (state_next == `FETCH_STATE_LOCKED) begin

                    if (cache_uncached) begin
                        cctrl_uncached_next = 1'b1;
                    end
                    else begin
                        cctrl_miss_next     = 1'b1;
                    end
                end
            end

            `FETCH_STATE_LOCKED:    begin

                if (state_next == `FETCH_STATE_SEQUENTIAL) begin

                    cctrl_miss_next     = 1'b0;
                    cctrl_uncached_next = 1'b0;
                end
            end

            default:    begin
            end
        endcase
    end

    assign cctrl_miss       = cctrl_miss_R;
    assign cctrl_uncached   = cctrl_uncached_R;


    //
    assign fc_valid = pc_valid_R[3];


    //
    assign pc_vaddr     = pc_value_R[2];
    assign pc_valid     = pc_valid_R[2];

    misc_vpaddr misc_vpaddr_INST (
        .vaddr  (pc_vaddr),
        
        .paddr  (pc_paddr),
        .kseg1  (/*pc_uncached*/)
    );

    assign pc_uncached = 1'b1;

    //
    assign o_pc_vaddr   = pc_value_R[3];
    assign o_pc_fid     = fid_R;
    assign o_pc_valid   = pc_valid_R[3];

    //

    //

endmodule
