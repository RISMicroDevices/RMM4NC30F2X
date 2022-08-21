`define     ENABLE_WRITEBACK_DFF

module decode_idffs (
    input   wire            clk,
    input   wire            resetn,

    // Snoop filter refresh
    input   wire            snoop_hit,
    
    // Branch commit override
    input   wire            bco_valid,

    //
    input   wire            i_wb_en,
    input   wire [3:0]      i_wb_dst_rob,
    input   wire [7:0]      i_wb_fid,
    input   wire [31:0]     i_wb_value,
    input   wire            i_wb_lsmiss,
    input   wire [3:0]      i_wb_cmtdelay,

    input   wire            i_wb_bco_valid,
    input   wire [1:0]      i_wb_bco_pattern,
    input   wire            i_wb_bco_taken,
    input   wire [31:0]     i_wb_bco_target,

    //
    input   wire            i_valid,
    input   wire [31:0]     i_pc,
    input   wire [7:0]      i_fid,
    input   wire [31:0]     i_data,

    input   wire [1:0]      i_bp_pattern,
    input   wire            i_bp_taken,
    input   wire            i_bp_hit,
    input   wire [31:0]     i_bp_target,

    //
    output  wire            o_wb_en,
    output  wire [3:0]      o_wb_dst_rob,
    output  wire [7:0]      o_wb_fid,
    output  wire [31:0]     o_wb_value,
    output  wire            o_wb_lsmiss,
    output  wire [3:0]      o_wb_cmtdelay,

    output  wire            o_wb_bco_valid,
    output  wire [1:0]      o_wb_bco_pattern,
    output  wire            o_wb_bco_taken,
    output  wire [31:0]     o_wb_bco_target,

    //
    output  wire            o_valid,
    output  wire [31:0]     o_pc,
    output  wire [7:0]      o_fid,
    output  wire [31:0]     o_data,

    output  wire [1:0]      o_bp_pattern,
    output  wire            o_bp_taken,
    output  wire            o_bp_hit,
    output  wire [31:0]     o_bp_target
);

    //
    reg         snoop_hit_R;

    reg         i_valid_R;
    reg  [31:0] i_pc_R;
    reg  [7:0]  i_fid_R;
    reg  [31:0] i_data_R;

    reg  [1:0]  i_bp_pattern_R;
    reg         i_bp_taken_R;
    reg         i_bp_hit_R;
    reg  [31:0] i_bp_target_R;

    always @(posedge clk) begin

        if (~resetn) begin

            snoop_hit_R    <= 'b0;

            i_valid_R      <= 'b0;
        end
        else begin

            snoop_hit_R    <= snoop_hit;

            if (snoop_hit | snoop_hit_R) begin 

                // *NOTICE: Snoop refresh of DECODE stage would hold for at least 2 cycles waiting for
                //          FETCH stage to be ready.
                i_valid_R <= 'b0;
            end
            else if (bco_valid) begin
                i_valid_R <= 'b0;
            end
            else begin
                i_valid_R <= i_valid;
            end
        end

        i_pc_R         <= i_pc;
        i_fid_R        <= i_fid;
        i_data_R       <= i_data;

        i_bp_pattern_R <= i_bp_pattern;
        i_bp_taken_R   <= i_bp_taken;
        i_bp_hit_R     <= i_bp_hit;
        i_bp_target_R  <= i_bp_target;
    end

    //
    assign o_valid      = i_valid_R;
    assign o_pc         = i_pc_R;
    assign o_fid        = i_fid_R;
    assign o_data       = i_data_R;

    assign o_bp_pattern = i_bp_pattern_R;
    assign o_bp_taken   = i_bp_taken_R;
    assign o_bp_hit     = i_bp_hit_R;
    assign o_bp_target  = i_bp_target_R;

    //
`ifdef ENABLE_WRITEBACK_DFF
    
    reg         wb_en_R;
    reg [3:0]   wb_dst_rob_R;
    reg [7:0]   wb_fid_R;
    reg [31:0]  wb_value_R;
    reg         wb_lsmiss_R;
    reg [3:0]   wb_cmtdelay_R;

    reg         wb_bco_valid_R;
    reg [1:0]   wb_bco_pattern_R;
    reg         wb_bco_taken_R;
    reg [31:0]  wb_bco_target_R;

    always @(posedge clk) begin

        if (~resetn) begin
            wb_en_R <= 1'b0;
        end
        else begin
            wb_en_R <= i_wb_en;
        end

        wb_dst_rob_R    <= i_wb_dst_rob;
        wb_fid_R        <= i_wb_fid;
        wb_value_R      <= i_wb_value;
        wb_lsmiss_R     <= i_wb_lsmiss;
        wb_cmtdelay_R   <= i_wb_cmtdelay;

        wb_bco_valid_R  <= i_wb_bco_valid;
        wb_bco_pattern_R<= i_wb_bco_pattern;
        wb_bco_taken_R  <= i_wb_bco_taken;
        wb_bco_target_R <= i_wb_bco_target;
    end

    assign o_wb_en          = wb_en_R;
    assign o_wb_dst_rob     = wb_dst_rob_R;
    assign o_wb_fid         = wb_fid_R;
    assign o_wb_value       = wb_value_R;
    assign o_wb_lsmiss      = wb_lsmiss_R;
    assign o_wb_cmtdelay    = wb_cmtdelay_R;

    assign o_wb_bco_valid   = wb_bco_valid_R;
    assign o_wb_bco_pattern = wb_bco_pattern_R;
    assign o_wb_bco_taken   = wb_bco_taken_R;
    assign o_wb_bco_target  = wb_bco_target_R;
`else

    assign o_wb_en          = i_wb_en;
    assign o_wb_dst_rob     = i_wb_dst_rob;
    assign o_wb_fid         = i_wb_fid;
    assign o_wb_value       = i_wb_value;
    assign o_wb_lsmiss      = i_wb_lsmiss;
    assign o_wb_cmtdelay    = i_wb_cmtdelay;

    assign o_wb_bco_valid   = i_wb_bco_valid;
    assign o_wb_bco_pattern = i_wb_bco_pattern;
    assign o_wb_bco_taken   = i_wb_bco_taken;
    assign o_wb_bco_target  = i_wb_bco_target;
`endif

    //

endmodule