
module execute_bru_odffs (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            i_valid,
    input   wire [3:0]      i_dst_rob,    
    input   wire [7:0]      i_fid,

    input   wire [31:0]     i_result,

    //
    input   wire            i_bco_valid,
    input   wire [31:0]     i_bco_pc,
    input   wire [1:0]      i_bco_oldpattern,
    input   wire            i_bco_taken,
    input   wire [31:0]     i_bco_target,

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
    reg         valid_R;
    reg [3:0]   dst_rob_R;
    reg [7:0]   fid_R;

    reg [31:0]  result_R;

    always @(posedge clk) begin

        if (~resetn) begin
            valid_R     <= 'b0;
        end
        else begin
            valid_R     <= i_valid;
        end

        dst_rob_R   <= i_dst_rob;
        fid_R       <= i_fid;

        result_R    <= i_result;
    end

    //
    reg         bco_valid_R;
    reg [31:0]  bco_pc_R;
    reg [1:0]   bco_oldpattern_R;
    reg         bco_taken_R;
    reg [31:0]  bco_target_R;

    always @(posedge clk) begin

        if (~resetn) begin
            bco_valid_R <= 'b0;
        end
        else begin
            bco_valid_R <= i_bco_valid;
        end

        bco_pc_R         <= i_bco_pc;
        bco_oldpattern_R <= i_bco_oldpattern;
        bco_taken_R      <= i_bco_taken;
        bco_target_R     <= i_bco_target;
    end

    //
    assign o_valid      = valid_R;
    assign o_dst_rob    = dst_rob_R;
    assign o_fid        = fid_R;

    assign o_result     = result_R;

    //
    assign o_bco_valid       = bco_valid_R;
    assign o_bco_pc          = bco_pc_R;
    assign o_bco_oldpattern  = bco_oldpattern_R;
    assign o_bco_taken       = bco_taken_R;
    assign o_bco_target      = bco_target_R;

    //

endmodule
