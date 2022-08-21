
module execute_mem_s2dffs (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            i_valid,
    input   wire [3:0]      i_dst_rob,
    input   wire [7:0]      i_fid,

    input   wire            i_s_byte,
    input   wire            i_s_store,
    input   wire            i_s_load,

    input   wire [31:0]     i_agu_v_addr,

    input   wire [31:0]     i_agu_p_addr,
    input   wire            i_agu_p_uncached,

    //
    output  wire            o_valid,
    output  wire [3:0]      o_dst_rob,
    output  wire [7:0]      o_fid,

    output  wire            o_s_byte,
    output  wire            o_s_store,
    output  wire            o_s_load,

    output  wire [31:0]     o_agu_v_addr,

    output  wire [31:0]     o_agu_p_addr,
    output  wire            o_agu_p_uncached
);

    //
    reg         valid_R;
    reg [3:0]   dst_rob_R;
    reg [7:0]   fid_R;

    reg         s_byte_R;
    reg         s_store_R;
    reg         s_load_R;

    reg [31:0]  agu_v_addr_R;

    reg [31:0]  agu_p_addr_R;
    reg         agu_p_uncached_R;

    always @(posedge clk) begin

        if (~resetn) begin
            valid_R <= 'b0;
        end
        else begin
            valid_R <= i_valid;
        end

        dst_rob_R           <= i_dst_rob;
        fid_R               <= i_fid;

        s_byte_R            <= i_s_byte;
        s_store_R           <= i_s_store;
        s_load_R            <= i_s_load;

        agu_v_addr_R        <= i_agu_v_addr;

        agu_p_addr_R        <= i_agu_p_addr;
        agu_p_uncached_R    <= i_agu_p_uncached;
    end

    //
    assign o_valid          = valid_R;
    assign o_dst_rob        = dst_rob_R;
    assign o_fid            = fid_R;

    assign o_s_byte         = s_byte_R;
    assign o_s_store        = s_store_R;
    assign o_s_load         = s_load_R;

    assign o_agu_v_addr     = agu_v_addr_R;

    assign o_agu_p_addr     = agu_p_addr_R;
    assign o_agu_p_uncached = agu_p_uncached_R;

    //

endmodule
