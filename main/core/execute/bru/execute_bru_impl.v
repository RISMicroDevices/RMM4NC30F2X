
module execute_bru_impl (
    input   wire            clk,
    input   wire            resetn,
    
    //
    input   wire [1:0]      i_bp_pattern,
    input   wire            i_bp_taken,
    input   wire            i_bp_hit,
    input   wire [31:0]     i_bp_target,

    //
    input   wire            i_valid,

    input   wire [31:0]     i_pc,

    input   wire [31:0]     i_src0_value,
    input   wire [31:0]     i_src1_value,

    input   wire [3:0]      i_dst_rob,

    input   wire [25:0]     i_imm,

    input   wire [7:0]      i_fid,

    input   wire [6:0]      i_bru_cmd,
    input   wire [1:0]      i_bagu_cmd,

    //
    output  wire            o_valid,
    output  wire [3:0]      o_dst_rob,    
    output  wire [7:0]      o_fid,

    output  wire [31:0]     o_result,

    //
    output  wire            o_bco_valid,
    output  wire [31:0]     o_bco_pc,
    output  wire [1:0]      o_bco_oldpattern,
    output  wire            o_bco_taken,
    output  wire [31:0]     o_bco_target
);

    //
    wire [31:0] agu_target;
    wire [31:0] agu_wavefront;

    execute_bru_impl_agu execute_bru_impl_agu_INST (
        //
        .i_pc           (i_pc),
        
        .i_src0_value   (i_src0_value),
        .i_src1_value   (i_src1_value),

        .i_imm          (i_imm),

        .i_bagu_cmd     (i_bagu_cmd),

        //
        .o_target       (agu_target),
        .o_wavefront    (agu_wavefront)
    );

    //
    wire        cond_taken;

    execute_bru_impl_cond execute_bru_impl_cond_INST (
        //
        .i_src0_value   (i_src0_value),
        .i_src1_value   (i_src1_value),

        .i_bru_cmd      (i_bru_cmd),

        //
        .o_taken        (cond_taken)
    );


    //
    reg     bco_valid_comb;

    always @(*) begin

        if (cond_taken) begin

            if (i_bp_taken & i_bp_hit) begin
                bco_valid_comb = agu_target != i_bp_target;
            end
            else begin
                bco_valid_comb = 1'b1;
            end
        end
        else begin

            if (i_bp_taken & i_bp_hit) begin
                bco_valid_comb = 1'b1;
            end
            else begin
                bco_valid_comb = 1'b0;
            end
        end
    end


    //
    assign o_valid      = i_valid;
    assign o_dst_rob    = i_valid ? i_dst_rob : 'b0;
    assign o_fid        = i_valid ? i_fid     : 'b0;

    assign o_result     = i_valid ? agu_wavefront   : 'b0;

    //
    assign o_bco_pc          = i_pc;
    assign o_bco_oldpattern  = i_bp_pattern;
    assign o_bco_taken       = cond_taken;
    assign o_bco_target      = cond_taken ? agu_target : agu_wavefront;

    assign o_bco_valid       = i_valid & bco_valid_comb;

    //

endmodule
